# Install Scoop package manager

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\install-scoop.log" -Append

Write-Host "Installing Scoop..."

$env:SCOOP = 'C:\Users\Anon\scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')

irm get.scoop.sh -outfile "$env:TEMP\scoop-installer.ps1"
& "$env:TEMP\scoop-installer.ps1" -RunAsAdmin -ScoopDir 'C:\Users\Anon\scoop'
Remove-Item "$env:TEMP\scoop-installer.ps1" -Force -ErrorAction SilentlyContinue

# Refresh environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Start-Sleep -Seconds 5

# Install git and add buckets
& scoop install git
& scoop bucket add extras
& scoop bucket add games

Write-Host "Scoop installed"

Stop-Transcript
