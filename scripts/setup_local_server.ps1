[CmdletBinding()]
param(
    [string]$ServerDirectory = (Join-Path $PSScriptRoot '..\server'),
    [switch]$VerifyOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$packVersion = '1.6.0'
$minecraftVersion = '1.21.11'
$fabricLoaderVersion = '0.19.4'
$fabricInstallerVersion = '1.1.2'
$localizationBaseCommit = 'fc5d8ee'
$packUrl = 'https://cdn.modrinth.com/data/nihni4Eg/versions/FrfRxPe6/Blood%20on%20the%20Clocktower%201.6.0.mrpack'
$packSha512 = 'd245fc95f02829263fcf5f4f2f437d9bb13123fbaf1016781e54be3f18c94d77aba6e5e3c066ac7b067ffdeb0f26f4e86dffda776522ed121544f047a9d110dd'
$fabricServerUrl = "https://meta.fabricmc.net/v2/versions/loader/$minecraftVersion/$fabricLoaderVersion/$fabricInstallerVersion/server/jar"
$fabricServerSha512 = 'd27b348a0b60e4694aabfd97e7cf192ef537f3f94f5fa378edfa53ebbdff797e9d9f0f6c62199bcb5a931c3b28cb33facd2a114da11d7a6f55c34e84f3af1ae2'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$serverRoot = [System.IO.Path]::GetFullPath($ServerDirectory)
$serverPrefix = $serverRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
$packPath = Join-Path $serverRoot ".cache\Blood on the Clocktower $packVersion.mrpack"
$markerPath = Join-Path $serverRoot '.botc-pack-version'
$fabricServerPath = Join-Path $serverRoot 'fabric-server-launch.jar'
$clientPackPath = Join-Path $serverRoot "client\BotC-ko-KR-$packVersion.zip"
$resourcePackSource = Join-Path $repoRoot 'resources\resourcepack\required\Blood on the Clocktower'
$datapackSource = Join-Path $repoRoot 'resources\datapack\required\ct'
$datapackArchivePath = Join-Path $serverRoot 'resources\datapack\required\ct.zip'

function Get-SafeServerPath {
    param([Parameter(Mandatory)][string]$RelativePath)

    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "Pack contains an absolute path: $RelativePath"
    }

    $normalized = $RelativePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $serverRoot $normalized))
    if (-not $fullPath.StartsWith($serverPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Pack path escapes the server directory: $RelativePath"
    }
    return $fullPath
}

function Get-Sha512 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA512).Hash.ToLowerInvariant()
}

function Get-VerifiedDownload {
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$Destination,
        [string]$Sha512
    )

    if (Test-Path -LiteralPath $Destination) {
        if (-not $Sha512 -or (Get-Sha512 $Destination) -eq $Sha512) {
            return
        }
    }

    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    $partial = "$Destination.download"
    Invoke-WebRequest -Uri $Url -OutFile $partial
    if ($Sha512 -and (Get-Sha512 $partial) -ne $Sha512) {
        throw "Downloaded file failed SHA-512 verification: $Url"
    }
    Move-Item -LiteralPath $partial -Destination $Destination -Force
}

function Read-PackIndex {
    param([Parameter(Mandatory)][string]$Path)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try {
        $entry = $archive.GetEntry('modrinth.index.json')
        if (-not $entry) {
            throw 'The Modrinth pack has no modrinth.index.json.'
        }
        $reader = [System.IO.StreamReader]::new($entry.Open())
        try {
            return ($reader.ReadToEnd() | ConvertFrom-Json)
        }
        finally {
            $reader.Dispose()
        }
    }
    finally {
        $archive.Dispose()
    }
}

function Expand-PackOverrides {
    param([Parameter(Mandatory)][string]$Path)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try {
        foreach ($entry in $archive.Entries) {
            $prefix = @('overrides/', 'server-overrides/') | Where-Object { $entry.FullName.StartsWith($_) } | Select-Object -First 1
            if (-not $prefix) {
                continue
            }

            $relative = $entry.FullName.Substring($prefix.Length)
            if (-not $relative) {
                continue
            }

            $destination = Get-SafeServerPath $relative
            if (-not $entry.Name) {
                New-Item -ItemType Directory -Force -Path $destination | Out-Null
                continue
            }

            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destination, $true)
        }
    }
    finally {
        $archive.Dispose()
    }
}

function Get-OverlayFiles {
    $files = @(& git -c core.quotepath=false -C $repoRoot diff --name-only $localizationBaseCommit -- config resources scripts/loaded_script.json)
    if ($LASTEXITCODE -ne 0 -or -not $files) {
        throw 'Could not list localization changes from the pinned 1.6.0 commit with Git.'
    }
    return $files
}

function Copy-LocalizationOverlay {
    foreach ($relative in Get-OverlayFiles) {
        $source = Join-Path $repoRoot $relative
        $destination = Get-SafeServerPath $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }
}

function New-ClientResourcePack {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $clientPackPath) | Out-Null
    if (Test-Path -LiteralPath $clientPackPath) {
        [System.IO.File]::Delete($clientPackPath)
    }
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
        $resourcePackSource,
        $clientPackPath,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $false
    )
}

function New-ServerDatapackArchive {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if (-not (Test-Path -LiteralPath $datapackSource)) {
        throw "Missing localized datapack source: $datapackSource"
    }

    $parent = Split-Path -Parent $datapackArchivePath
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    $partial = "$datapackArchivePath.tmp"
    if (Test-Path -LiteralPath $partial) {
        [System.IO.File]::Delete($partial)
    }

    try {
        [System.IO.Compression.ZipFile]::CreateFromDirectory(
            $datapackSource,
            $partial,
            [System.IO.Compression.CompressionLevel]::Optimal,
            $false
        )
        Move-Item -LiteralPath $partial -Destination $datapackArchivePath -Force
    }
    catch {
        if (Test-Path -LiteralPath $partial) {
            [System.IO.File]::Delete($partial)
        }
        throw
    }
}

function Get-StreamSha512 {
    param([Parameter(Mandatory)][System.IO.Stream]$Stream)

    $sha512 = [System.Security.Cryptography.SHA512]::Create()
    try {
        return ([BitConverter]::ToString($sha512.ComputeHash($Stream))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha512.Dispose()
    }
}

function Assert-ServerDatapackArchive {
    if (-not (Test-Path -LiteralPath $datapackArchivePath)) {
        throw "Missing server datapack archive: $datapackArchivePath"
    }
    if (-not (Test-Path -LiteralPath $datapackSource)) {
        throw "Missing localized datapack source: $datapackSource"
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($datapackArchivePath)
    try {
        $sourceFiles = @(Get-ChildItem -LiteralPath $datapackSource -Recurse -File)
        if (-not $sourceFiles) {
            throw "Localized datapack source is empty: $datapackSource"
        }

        foreach ($sourceFile in $sourceFiles) {
            $relative = $sourceFile.FullName.Substring($datapackSource.Length + 1).Replace('\', '/')
            $entry = $archive.GetEntry($relative)
            if (-not $entry) {
                throw "Server datapack archive is missing $relative"
            }

            $stream = $entry.Open()
            try {
                $packedHash = Get-StreamSha512 $stream
            }
            finally {
                $stream.Dispose()
            }
            if ($packedHash -ne (Get-Sha512 $sourceFile.FullName)) {
                throw "Server datapack archive is stale: $relative"
            }
        }
    }
    finally {
        $archive.Dispose()
    }
}

function Assert-ClientResourcePack {
    if (-not (Test-Path -LiteralPath $clientPackPath)) {
        throw "Missing client resource pack: $clientPackPath"
    }

    $archive = [System.IO.Compression.ZipFile]::OpenRead($clientPackPath)
    try {
        foreach ($relative in @('pack.mcmeta', 'assets/minecraft/lang/en_us.json', 'assets/minecraft/lang/ko_kr.json')) {
            $entry = $archive.GetEntry($relative)
            if (-not $entry) {
                throw "Client resource pack is missing $relative."
            }
            $reader = [System.IO.StreamReader]::new($entry.Open())
            try {
                $packed = $reader.ReadToEnd()
            }
            finally {
                $reader.Dispose()
            }
            $source = Get-Content -LiteralPath (Join-Path $resourcePackSource $relative) -Raw
            if ($packed -ne $source) {
                throw "Client resource pack is stale: $relative"
            }
        }
    }
    finally {
        $archive.Dispose()
    }
}

function Assert-ServerInstallation {
    param([Parameter(Mandatory)]$Index)

    foreach ($file in $Index.files | Where-Object { $_.env.server -ne 'unsupported' }) {
        $destination = Get-SafeServerPath $file.path
        if (-not (Test-Path -LiteralPath $destination)) {
            throw "Missing server file: $($file.path)"
        }
        if ((Get-Sha512 $destination) -ne $file.hashes.sha512) {
            throw "Server file failed SHA-512 verification: $($file.path)"
        }
    }

    foreach ($relative in Get-OverlayFiles) {
        $source = Join-Path $repoRoot $relative
        $destination = Get-SafeServerPath $relative
        if (-not (Test-Path -LiteralPath $destination) -or (Get-Sha512 $source) -ne (Get-Sha512 $destination)) {
            throw "Localization overlay is stale or missing: $relative"
        }
    }

    Assert-ServerDatapackArchive

    foreach ($required in @('fabric-server-launch.jar', 'server.properties', 'eula.txt', 'world\level.dat')) {
        if (-not (Test-Path -LiteralPath (Join-Path $serverRoot $required))) {
            throw "Missing server runtime file: $required"
        }
    }

    if ((Get-Sha512 $fabricServerPath) -ne $fabricServerSha512) {
        throw 'Fabric server launcher failed SHA-512 verification.'
    }

    Assert-ClientResourcePack

    $properties = Get-Content -LiteralPath (Join-Path $serverRoot 'server.properties') -Raw
    if ($properties -notmatch '(?m)^enable-command-block=true\r?$' -or $properties -notmatch '(?m)^server-ip=127\.0\.0\.1\r?$') {
        throw 'server.properties is not configured for local BotC testing.'
    }
}

New-Item -ItemType Directory -Force -Path $serverRoot | Out-Null

if (-not $VerifyOnly) {
    $javaVersion = (& java -version 2>&1 | Out-String)
    if ($LASTEXITCODE -ne 0 -or $javaVersion -notmatch 'version "21(?:\.|\")') {
        throw 'Java 21 is required to run this Minecraft server.'
    }

    Write-Host "Downloading and verifying Blood on the Clocktower $packVersion..."
    Get-VerifiedDownload $packUrl $packPath $packSha512
}
elseif (-not (Test-Path -LiteralPath $packPath) -or (Get-Sha512 $packPath) -ne $packSha512) {
    throw "Missing or invalid cached Modrinth pack: $packPath"
}

$index = Read-PackIndex $packPath
if ($index.versionId -ne $packVersion -or $index.dependencies.minecraft -ne $minecraftVersion -or $index.dependencies.'fabric-loader' -ne $fabricLoaderVersion) {
    throw 'The Modrinth pack metadata does not match the pinned 1.6.0 server versions.'
}

if (-not $VerifyOnly) {
    if (Test-Path -LiteralPath $markerPath) {
        $installedVersion = (Get-Content -LiteralPath $markerPath -Raw).Trim()
        if ($installedVersion -ne $packVersion) {
            throw "Server directory contains pack $installedVersion; use a different directory for $packVersion."
        }
    }
    else {
        if (Test-Path -LiteralPath (Join-Path $serverRoot 'world\level.dat')) {
            throw 'Refusing to overwrite an existing unmarked server world.'
        }
        Write-Host 'Extracting the official pack and world...'
        Expand-PackOverrides $packPath
        [System.IO.File]::WriteAllText($markerPath, "$packVersion`n", [System.Text.UTF8Encoding]::new($false))
    }

    $serverFiles = @($index.files | Where-Object { $_.env.server -ne 'unsupported' })
    for ($i = 0; $i -lt $serverFiles.Count; $i++) {
        $file = $serverFiles[$i]
        Write-Host ("[{0}/{1}] {2}" -f ($i + 1), $serverFiles.Count, $file.path)
        Get-VerifiedDownload $file.downloads[0] (Get-SafeServerPath $file.path) $file.hashes.sha512
    }

    Write-Host 'Installing the Fabric server launcher...'
    Get-VerifiedDownload $fabricServerUrl $fabricServerPath $fabricServerSha512

    Write-Host 'Applying the current localization branch...'
    Copy-LocalizationOverlay

    Write-Host 'Building the server datapack archive...'
    New-ServerDatapackArchive

    Write-Host 'Building the client resource pack...'
    New-ClientResourcePack

    $serverPropertiesPath = Join-Path $serverRoot 'server.properties'
    if (-not (Test-Path -LiteralPath $serverPropertiesPath)) {
        $properties = @'
enable-command-block=true
level-name=world
max-players=16
motd=BotC 1.6.0 Korean test server
online-mode=true
server-ip=127.0.0.1
server-port=25565
'@
        [System.IO.File]::WriteAllText($serverPropertiesPath, $properties.TrimStart() + "`n", [System.Text.UTF8Encoding]::new($false))
    }

    $eulaPath = Join-Path $serverRoot 'eula.txt'
    if (-not (Test-Path -LiteralPath $eulaPath)) {
        [System.IO.File]::WriteAllText($eulaPath, "eula=false`n", [System.Text.UTF8Encoding]::new($false))
    }

    New-Item -ItemType Directory -Force -Path (Join-Path $serverRoot '.tmp') | Out-Null
}

Write-Host 'Verifying server files and localization overlay...'
Assert-ServerInstallation $index
Write-Host "Local server ready: $serverRoot"
if ((Get-Content -LiteralPath (Join-Path $serverRoot 'eula.txt') -Raw) -notmatch '(?m)^eula=true$') {
    Write-Host 'Before first start, review the Minecraft EULA and change server\eula.txt to eula=true.'
}
