# Remove Windows bloatware

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\remove-bloatware.log" -Append

Write-Host "Removing bloatware..."

# Appx packages to remove (both installed and provisioned)
$appxBloatware = @(
    "Clipchamp.Clipchamp",
    "Microsoft.BingNews",
    "Microsoft.BingSearch",
    "Microsoft.BingWeather",
    "Microsoft.Edge.GameAssist",
    "Microsoft.GetHelp",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.OutlookForWindows",
    "Microsoft.Paint",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Todos",
    "Microsoft.Windows.Photos",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.YourPhone",
    "Microsoft.WidgetsPlatformRuntime",
    "MicrosoftCorporationII.QuickAssist",
    "MicrosoftWindows.Client.WebExperience",
    "MicrosoftWindows.CrossDevice",
    "MSTeams"
)

# Remove installed packages
foreach ($app in $appxBloatware) {
    Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}

# Remove provisioned packages
foreach ($app in $appxBloatware) {
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# Winget uninstalls for non-appx packages
winget uninstall --id Microsoft.OneDrive --silent --accept-source-agreements 2>$null
winget uninstall --id Microsoft.Edge --exact --silent --accept-source-agreements 2>$null

Write-Host "Bloatware removed"

Stop-Transcript
exit 0
