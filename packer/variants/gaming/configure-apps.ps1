# Configure installed applications

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\configure-apps.log" -Append

Write-Host "Configuring applications..."

# Configure TinyNvidiaUpdateChecker
$tnucConfigDir = "$env:LOCALAPPDATA\Hawaii_Beach\TinyNvidiaUpdateChecker"
if (-not (Test-Path $tnucConfigDir)) {
    New-Item -Path $tnucConfigDir -ItemType Directory -Force | Out-Null
}

$configContent = @'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <appSettings>
        <add key="Check for Updates" value="false" />
        <add key="Minimal install" value="true" />
        <add key="Download location" value="uk" />
        <add key="Driver type" value="grd" />
        <add key="Minimal install components" value="Display.Driver" />
    </appSettings>
</configuration>
'@

Set-Content -Path "$tnucConfigDir\app.config" -Value $configContent -Force
Write-Host "TinyNvidiaUpdateChecker configured"

# Configure Steam to run on startup
$steamPath = "${env:ProgramFiles(x86)}\Steam\steam.exe"
if (Test-Path $steamPath) {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Steam" -Value "`"$steamPath`" -silent" -Type String -Force
    Write-Host "Steam configured to run on startup"
}

Write-Host "Applications configured"

Stop-Transcript
