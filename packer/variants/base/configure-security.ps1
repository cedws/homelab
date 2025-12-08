# Configure security settings

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\configure-security.log" -Append

Write-Host "Configuring security settings..."

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

# Disable Windows Update
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Set-Service -Name wuauserv -StartupType Disabled -ErrorAction SilentlyContinue

# Disable telemetry
$telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (!(Test-Path $telemetryPath)) {
    New-Item -Path $telemetryPath -Force | Out-Null
}
Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

Write-Host "Security settings configured"

Stop-Transcript
