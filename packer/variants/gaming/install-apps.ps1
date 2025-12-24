# Install applications via winget

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\install-apps.log" -Append

Write-Host "Installing applications via winget..."
winget install --silent --accept-source-agreements --accept-package-agreements `
    Microsoft.DotNet.DesktopRuntime.8 `
    Proton.ProtonVPN `
    Proton.ProtonPass `
    Hawaii_Beach.TinyNvidiaUpdateChecker `
    Valve.Steam `
    Discord.Discord `
    Mozilla.Firefox `
    EpicGames.EpicGamesLauncher

Write-Host "Applications installed"

Stop-Transcript
