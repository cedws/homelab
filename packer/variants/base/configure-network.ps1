# Configure network settings

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\configure-network.log" -Append

Write-Host "Configuring network..."

# Enable ping (ICMP)
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow

# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -ErrorAction SilentlyContinue
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue

Write-Host "Network configured"

Stop-Transcript
