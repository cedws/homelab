# Template cleanup

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\cleanup.log" -Append

Write-Host "Cleaning up..."

# Clear Windows Update cache
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clear user temp files only
Remove-Item -Path "C:\Users\*\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clear Windows logs
Get-EventLog -LogName * | ForEach-Object { Clear-EventLog $_.Log -ErrorAction SilentlyContinue }

# Clear Recycle Bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Optimize disk
Optimize-Volume -DriveLetter C -Defrag -ErrorAction SilentlyContinue

Write-Host "Cleanup complete"

Stop-Transcript
