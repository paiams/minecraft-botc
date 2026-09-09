<# Build the shared client/server display-name mod. Does not install runtime files. #>
[CmdletBinding()]
param(
    [string]$FancyMenuJar = (Join-Path $PSScriptRoot '..\server\mods\fancymenu_fabric_3.9.10_MC_1.21.11.jar')
)
$ErrorActionPreference = 'Stop'
$extensionRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\extensions\display-names'))
$fancyPath = [IO.Path]::GetFullPath($FancyMenuJar)
if (-not (Test-Path -LiteralPath $fancyPath)) {
    throw "Missing pinned FancyMenu compile dependency: $fancyPath. Prepare the upstream mods first or pass -FancyMenuJar."
}
# MSIX-hosted Windows shells can redirect the default Unix-domain socket directory.
# Use an ordinary short path for this build only; restore the caller's environment.
$previousJavaOptions = $env:JAVA_TOOL_OPTIONS
try {
    $socketDirectory = Join-Path $env:USERPROFILE '.cache\botc-java-sockets'
    New-Item -ItemType Directory -Force -Path $socketDirectory | Out-Null
    $env:JAVA_TOOL_OPTIONS = "$previousJavaOptions `"-Djdk.net.unixdomain.tmpdir=$socketDirectory`"".Trim()
    & (Join-Path $extensionRoot 'gradlew.bat') -p $extensionRoot "-PfancyMenuJar=$fancyPath" build --console=plain
    if ($LASTEXITCODE -ne 0) { throw "Display-name build failed with exit code $LASTEXITCODE" }
}
finally { $env:JAVA_TOOL_OPTIONS = $previousJavaOptions }
Write-Host "Built: $(Join-Path $extensionRoot 'build\libs\botc-display-names-1.0.0.jar')"
