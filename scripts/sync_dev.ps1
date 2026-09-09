<# Synchronize the current checkout to existing development runtimes. No downloads or Git pulls. #>
[CmdletBinding()]
param(
    [string]$ServerDirectory,
    [string]$ClientDirectory = (Join-Path $env:APPDATA 'ModrinthApp\profiles\Blood on the Clocktower'),
    [switch]$CheckOnly
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not $ServerDirectory) { $ServerDirectory = Join-Path $repo 'server' }
$targets = @([IO.Path]::GetFullPath($ServerDirectory), [IO.Path]::GetFullPath($ClientDirectory))
$checkedPaths = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

function Get-SafePath([string]$Root, [string]$Relative) {
    $path = [IO.Path]::GetFullPath((Join-Path $Root $Relative))
    if (-not $path.StartsWith($Root.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escapes target: $Relative"
    }
    for ($parent = $path; $parent; $parent = Split-Path -Parent $parent) {
        if ($checkedPaths.Contains($parent)) { break }
        if ((Test-Path -LiteralPath $parent) -and
            ((Get-Item -LiteralPath $parent -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "Refusing linked deployment path: $parent"
        }
        $null = $checkedPaths.Add($parent)
    }
    return $path
}

function Get-RunningGames {
    # Never print command lines: client launch arguments contain access tokens.
    Get-CimInstance Win32_Process -Filter "Name = 'java.exe' OR Name = 'javaw.exe'" | Where-Object {
        -not $_.CommandLine -or $_.CommandLine -match 'fabric-server-launch|KnotServer|net.minecraft.server' -or
        $_.CommandLine.IndexOf($targets[1], [StringComparison]::OrdinalIgnoreCase) -ge 0
    } | Select-Object -ExpandProperty ProcessId
}

if ($targets[0] -eq $targets[1]) { throw 'Server and client must be different directories.' }
foreach ($target in $targets) {
    if ($target -eq $repo -or -not (Test-Path -LiteralPath (Join-Path $target 'mods'))) {
        throw "Expected an existing installed runtime: $target"
    }
}
$paths = @(& git -c core.quotepath=false -C $repo diff --name-only fc5d8ee -- config resources scripts/loaded_script.json)
if ($LASTEXITCODE) { throw 'Cannot read checkout changes.' }
$paths += @(& git -c core.quotepath=false -C $repo ls-files --others --exclude-standard -- config resources scripts/loaded_script.json)
if ($LASTEXITCODE) { throw 'Cannot read new checkout files.' }
$paths = @($paths | Sort-Object -Unique)
foreach ($relative in $paths) {
    foreach ($target in $targets) { $null = Get-SafePath $target $relative }
}
if ($CheckOnly) {
    Write-Host "Validated $($paths.Count) checkout paths for both runtimes. No files changed."
    Write-Host "Server: $($targets[0])"
    Write-Host "Client: $($targets[1])"
    exit 0
}

Write-Host 'Close Minecraft and type stop in the server console. Waiting for normal shutdown...'
while (@(Get-RunningGames).Count) { Start-Sleep -Seconds 2 }
Write-Host 'Building the shared mod...'
& (Join-Path $PSScriptRoot 'build_display_names.ps1') -FancyMenuJar (Join-Path $targets[0] 'mods\fancymenu_fabric_3.9.10_MC_1.21.11.jar')

$backup = Join-Path $repo ('.dev-sync-backups\' + [DateTime]::Now.ToString('yyyyMMdd-HHmmss-fff'))
$stage = Join-Path $backup 'staged'
New-Item -ItemType Directory -Path $stage -Force | Out-Null
$sources = @{}
foreach ($relative in $paths) {
    $source = Get-SafePath $repo $relative
    if (Test-Path -LiteralPath $source -PathType Leaf) {
        $copy = Get-SafePath $stage $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $copy) | Out-Null
        Copy-Item -LiteralPath $source -Destination $copy
        $sources[$relative] = $copy
    } else { $sources[$relative] = $null }
}
$mod = 'mods/botc-display-names-1.0.0.jar'
$sources[$mod] = Join-Path $stage 'botc-display-names-1.0.0.jar'
Copy-Item -LiteralPath (Join-Path $repo "extensions/display-names/build/libs/botc-display-names-1.0.0.jar") -Destination $sources[$mod]
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = 'resources/datapack/required/ct.zip'
$sources[$archive] = Join-Path $stage 'ct.zip'
[IO.Compression.ZipFile]::CreateFromDirectory((Join-Path $repo 'resources/datapack/required/ct'), $sources[$archive])
$resourceZip = Join-Path $stage 'BotC-resources-1.6.0.zip'
[IO.Compression.ZipFile]::CreateFromDirectory((Join-Path $repo 'resources/resourcepack/required/Blood on the Clocktower'), $resourceZip)

# Back up every changed file on BOTH targets before replacing any runtime file.
$changes = @()
for ($i = 0; $i -lt $targets.Count; $i++) {
    $files = $sources.Clone()
    if ($i -eq 0) { $files['client/BotC-resources-1.6.0.zip'] = $resourceZip }
    foreach ($relative in $files.Keys) {
        $destination = Get-SafePath $targets[$i] $relative
        $exists = Test-Path -LiteralPath $destination -PathType Leaf
        $source = $files[$relative]
        if (-not $source -and -not $exists) { continue }
        if ($source -and $exists -and (Get-FileHash -LiteralPath $source).Hash -eq (Get-FileHash -LiteralPath $destination).Hash) { continue }
        $saved = Get-SafePath $backup "$i/$relative"
        if ($exists) {
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $saved) | Out-Null
            Copy-Item -LiteralPath $destination -Destination $saved
        }
        $changes += [pscustomobject]@{ Destination = $destination; Source = $source; Backup = $saved; Existed = $exists }
    }
}
$changes | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $backup 'manifest.json') -Encoding UTF8
if (@(Get-RunningGames).Count) { throw 'A runtime started during preparation. Close it and rerun.' }
$applied = @()
try {
    foreach ($change in $changes) {
        $applied += $change
        if ($change.Source) {
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $change.Destination) | Out-Null
            Copy-Item -LiteralPath $change.Source -Destination $change.Destination -Force
            if ((Get-FileHash -LiteralPath $change.Source).Hash -ne (Get-FileHash -LiteralPath $change.Destination).Hash) {
                throw "Verification failed: $($change.Destination)"
            }
        } else { Remove-Item -LiteralPath $change.Destination }
    }
} catch {
    foreach ($change in $applied) {
        if ($change.Existed) { Copy-Item -LiteralPath $change.Backup -Destination $change.Destination -Force }
        elseif (Test-Path -LiteralPath $change.Destination) { Remove-Item -LiteralPath $change.Destination }
    }
    throw
}
Write-Host "Done: $($changes.Count) files synchronized and verified. You can restart the server and client."
Write-Host "Backup: $backup"
