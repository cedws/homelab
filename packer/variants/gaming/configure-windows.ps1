# Configure Windows settings

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\configure-windows.log" -Append

Write-Host "Configuring Windows..."

# Disable OneDrive
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -Force -ErrorAction SilentlyContinue

$oneDrivePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
if (-not (Test-Path $oneDrivePolicyPath)) {
    New-Item -Path $oneDrivePolicyPath -Force | Out-Null
}
Set-ItemProperty -Path $oneDrivePolicyPath -Name "DisableFileSyncNGSC" -Value 1 -Type DWord -Force

$oneDriveSetupPath = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (Test-Path $oneDriveSetupPath) {
    Start-Process -FilePath $oneDriveSetupPath -ArgumentList "/uninstall" -NoNewWindow -Wait -ErrorAction SilentlyContinue
}
Write-Host "OneDrive disabled"

# Set taskbar alignment to left
$taskbarRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $taskbarRegPath -Name "TaskbarAl" -Value 0 -Type DWord -Force
Write-Host "Taskbar set to left alignment"

# Set Firefox as default browser
$firefoxPath = "${env:ProgramFiles}\Mozilla Firefox\firefox.exe"
if (Test-Path $firefoxPath) {
    $assocPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations"

    foreach ($protocol in @("http", "https")) {
        if (-not (Test-Path "$assocPath\$protocol\UserChoice")) {
            New-Item -Path "$assocPath\$protocol\UserChoice" -Force | Out-Null
        }
        Set-ItemProperty -Path "$assocPath\$protocol\UserChoice" -Name "ProgId" -Value "FirefoxURL-308046B0AF4A39CB" -Force -ErrorAction SilentlyContinue
    }

    $fileAssocPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts"
    foreach ($ext in @(".htm", ".html")) {
        if (-not (Test-Path "$fileAssocPath\$ext\UserChoice")) {
            New-Item -Path "$fileAssocPath\$ext\UserChoice" -Force | Out-Null
        }
        Set-ItemProperty -Path "$fileAssocPath\$ext\UserChoice" -Name "ProgId" -Value "FirefoxHTML-308046B0AF4A39CB" -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Firefox set as default browser"
}

Write-Host "Windows configured"

Stop-Transcript
