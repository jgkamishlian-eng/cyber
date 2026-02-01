param(
    [Parameter(Mandatory = $true)]
    [string]$Destination
)

$destinationRoot = $Destination
if (-not $destinationRoot.EndsWith("\\")) {
    $destinationRoot = "$destinationRoot\\"
}

$targetDir = Join-Path $destinationRoot "cyber-gui"

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

$sourceDir = Resolve-Path -Path "."

$robocopyArgs = @(
    $sourceDir,
    $targetDir,
    "/E",
    "/XD",
    ".git"
)

$robocopyResult = Start-Process -FilePath "robocopy" -ArgumentList $robocopyArgs -NoNewWindow -Wait -PassThru
if ($robocopyResult.ExitCode -ge 8) {
    throw "Robocopy failed with exit code $($robocopyResult.ExitCode)."
}

$shortcutPath = Join-Path $destinationRoot "Cyber GUI.lnk"
$launcherPath = Join-Path $targetDir "launch-gui.bat"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $launcherPath
$shortcut.WorkingDirectory = $targetDir
$shortcut.IconLocation = $launcherPath
$shortcut.Save()

Write-Host "USB setup complete. Shortcut created at $shortcutPath"
