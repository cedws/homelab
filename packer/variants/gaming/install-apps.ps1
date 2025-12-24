# Install applications via winget

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\install-apps.log" -Append

Write-Host "Installing applications via winget..."

# Install each package individually with --source winget to avoid msstore SSL errors
$packages = @(
    "Microsoft.DotNet.DesktopRuntime.8",
    "Proton.ProtonVPN",
    "Proton.ProtonPass",
    "Hawaii_Beach.TinyNvidiaUpdateChecker",
    "Valve.Steam",
    "Discord.Discord",
    "Mozilla.Firefox",
    "EpicGames.EpicGamesLauncher"
)

foreach ($package in $packages) {
    Write-Host "Installing $package..."
    winget install --id $package --source winget --silent --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to install $package (exit code: $LASTEXITCODE)"
    }
}

Write-Host "Applications installed"

Stop-Transcript
