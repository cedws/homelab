# Install and configure NextDNS

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\install-nextdns.log" -Append

Write-Host "Installing NextDNS..."

Invoke-WebRequest -Uri "https://nextdns.io/download/windows/stable.msi" -OutFile "$env:TEMP\NextDNSSetup.msi"
msiexec /qn /i "$env:TEMP\NextDNSSetup.msi" PROFILE=aa4f2a UI=0
Remove-Item "$env:TEMP\NextDNSSetup.msi" -Force -ErrorAction SilentlyContinue

Write-Host "NextDNS installed and configured"

Stop-Transcript
