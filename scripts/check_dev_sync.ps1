# Run with powershell -NoProfile -File scripts/check_dev_sync.ps1.
# Exercise deployment in temporary directories without Java or live runtimes.
$ErrorActionPreference = 'Stop'
$pack = Join-Path $PSScriptRoot '../resources/datapack/required/ct'
$hooks = @{
    'cmd/nom/long_arm' = 'nomination_started'
    'loop/vote/start_vote' = 'vote_started'
    'loop/vote/end_voting' = 'vote_finished'
    'kill/execute/execute' = 'execution'
}
foreach ($entry in $hooks.GetEnumerator()) {
    $body = Get-Content -Raw -LiteralPath "$pack/data/ct/function/$($entry.Key).mcfunction"
    if (-not $body.Contains("function #ct:broadcast/$($entry.Value)")) {
        throw "Missing source broadcast hook: $($entry.Key)"
    }
    $tag = Get-Content -Raw -LiteralPath "$pack/data/ct/tags/function/broadcast/$($entry.Value).json" | ConvertFrom-Json
    if ($tag.replace -or $tag.values.Count) { throw 'Fallback tags must be empty and additive.' }
}
$voteEnd = Get-Content -Raw -LiteralPath "$pack/data/ct/function/loop/vote/end_voting.mcfunction"
if ($voteEnd.IndexOf('function #ct:broadcast/vote_finished') -gt $voteEnd.IndexOf('scoreboard players set total vote 0')) {
    throw 'Broadcast must capture the vote before its score is reset.'
}
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('botc-sync-check-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path "$testRoot/scripts" -Force | Out-Null
Copy-Item -LiteralPath "$PSScriptRoot/sync_dev.ps1" -Destination "$testRoot/scripts/sync_dev.ps1"
function git {
    $global:LASTEXITCODE = 0
    if ($args -contains 'diff') { 'config/menu.txt'; 'config/deleted.txt' }
    else { 'config/new.txt' }
}
function Get-CimInstance { @() }
function Assert([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}
try {
    foreach ($directory in @('config', 'resources/datapack/required/ct',
        'resources/resourcepack/required/Blood on the Clocktower',
        'extensions/display-names/build/libs', 'broadcast/build/libs', 'server/mods', 'client/mods',
        'server/config', 'client/config')) {
        New-Item -ItemType Directory -Path "$testRoot/$directory" -Force | Out-Null
    }
    Set-Content "$testRoot/scripts/build_display_names.ps1" 'param($FancyMenuJar)'
    Set-Content "$testRoot/broadcast/gradlew.bat" '@exit /b 0'
    Set-Content "$testRoot/broadcast/build/libs/botc-broadcast-1.0.0.jar" 'broadcast'
    Set-Content "$testRoot/extensions/display-names/build/libs/botc-display-names-1.0.0.jar" 'mod'
    Set-Content "$testRoot/resources/datapack/required/ct/pack.mcmeta" 'datapack'
    New-Item -ItemType Directory -Path "$testRoot/resources/datapack/required/ct/data/ct/function" -Force | Out-Null
    Set-Content "$testRoot/resources/datapack/required/ct/data/ct/function/check.mcfunction" 'say test'
    Set-Content "$testRoot/resources/resourcepack/required/Blood on the Clocktower/pack.mcmeta" 'resources'
    Set-Content "$testRoot/config/menu.txt" 'current'
    Set-Content "$testRoot/config/new.txt" 'new'
    foreach ($target in @('server', 'client')) {
        Set-Content "$testRoot/$target/config/menu.txt" 'previous'
        Set-Content "$testRoot/$target/config/deleted.txt" 'removed upstream'
        Set-Content "$testRoot/$target/config/personal.txt" 'keep'
    }
    & "$testRoot/scripts/sync_dev.ps1" -ServerDirectory "$testRoot/server" -ClientDirectory "$testRoot/client" -BroadcastDirectory "$testRoot/broadcast"
    foreach ($target in @('server', 'client')) {
        Assert ((Get-Content "$testRoot/$target/config/menu.txt") -eq 'current') 'Changed file was not copied'
        Assert ((Get-Content "$testRoot/$target/config/new.txt") -eq 'new') 'New file was not copied'
        Assert (-not (Test-Path "$testRoot/$target/config/deleted.txt")) 'Deleted file survived'
        Assert ((Get-Content "$testRoot/$target/config/personal.txt") -eq 'keep') 'Personal file changed'
        Assert (Test-Path "$testRoot/$target/resources/datapack/required/ct.zip") 'Datapack archive missing'
        $zip = [IO.Compression.ZipFile]::OpenRead("$testRoot/$target/resources/datapack/required/ct.zip")
        try {
            Assert ($null -ne $zip.GetEntry('data/ct/function/check.mcfunction')) 'ZIP paths must use forward slashes'
        } finally { $zip.Dispose() }
        Assert (Test-Path "$testRoot/$target/mods/botc-display-names-1.0.0.jar") 'Shared mod missing'
    }
    Assert (Test-Path "$testRoot/server/mods/botc-broadcast-1.0.0.jar") 'Server broadcast mod missing'
    Assert (Test-Path "$testRoot/client/mods/botc-broadcast-1.0.0.jar") 'Client broadcast helper missing'
    $backups = @(Get-ChildItem "$testRoot/.dev-sync-backups" -Recurse -Filter menu.txt |
        Where-Object { (Get-Content -LiteralPath $_.FullName) -eq 'previous' })
    Assert ($backups.Count -eq 2) 'Both previous versions must be backed up'
    Write-Host 'Development synchronization check: PASS'
} finally {
    $resolved = [IO.Path]::GetFullPath($testRoot)
    if ($resolved.StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path -Leaf $resolved) -like 'botc-sync-check-*') {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
