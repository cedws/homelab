# Configure Group Policy Startup and Shutdown Scripts
# Simple GPO configuration using cmd.exe /c to call batch files

Write-Host "Configuring Group Policy startup and shutdown scripts..."

# Create the Scripts directory for logs
$scriptsDir = "C:\Scripts"
if (!(Test-Path $scriptsDir)) {
    New-Item -Path $scriptsDir -ItemType Directory -Force | Out-Null
    Write-Host "Created directory: $scriptsDir"
}

# Create Group Policy script directories
$startupDir = "C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup"
$shutdownDir = "C:\Windows\System32\GroupPolicy\Machine\Scripts\Shutdown"

if (!(Test-Path $startupDir)) {
    New-Item -Path $startupDir -ItemType Directory -Force | Out-Null
    Write-Host "Created directory: $startupDir"
}

if (!(Test-Path $shutdownDir)) {
    New-Item -Path $shutdownDir -ItemType Directory -Force | Out-Null
    Write-Host "Created directory: $shutdownDir"
}

# Find the batch scripts on CD-ROM drives
Write-Host "Searching for batch scripts on CD-ROM drives..."
$cdDrives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 5 } | Select-Object -ExpandProperty DeviceID

$startupScript = $null
$shutdownScript = $null

foreach ($drive in $cdDrives) {
    $testStartup = Join-Path $drive "RadeonStartupFix.bat"
    $testShutdown = Join-Path $drive "RadeonShutdownFix.bat"

    if ((Test-Path $testStartup) -and (Test-Path $testShutdown)) {
        $startupScript = $testStartup
        $shutdownScript = $testShutdown
        Write-Host "Found scripts on drive: $drive"
        break
    }
}

# Fallback to temp location
if (-not $startupScript) {
    Write-Host "Scripts not found on CD-ROM, checking C:\Windows\Temp..."
    $tempStartup = "C:\Windows\Temp\RadeonStartupFix.bat"
    $tempShutdown = "C:\Windows\Temp\RadeonShutdownFix.bat"

    if ((Test-Path $tempStartup) -and (Test-Path $tempShutdown)) {
        $startupScript = $tempStartup
        $shutdownScript = $tempShutdown
        Write-Host "Found scripts in C:\Windows\Temp"
    }
}

# Copy scripts to GPO directories
if ($startupScript -and (Test-Path $startupScript)) {
    Copy-Item -Path $startupScript -Destination $startupDir -Force
    Write-Host "Copied RadeonStartupFix.bat to $startupDir"
} else {
    Write-Host "ERROR: RadeonStartupFix.bat not found!"
    exit 1
}

if ($shutdownScript -and (Test-Path $shutdownScript)) {
    Copy-Item -Path $shutdownScript -Destination $shutdownDir -Force
    Write-Host "Copied RadeonShutdownFix.bat to $shutdownDir"
} else {
    Write-Host "ERROR: RadeonShutdownFix.bat not found!"
    exit 1
}

# Configure scripts.ini for GPO
$scriptsIniPath = "C:\Windows\System32\GroupPolicy\Machine\Scripts\scripts.ini"
$scriptsIniContent = @"
[Startup]
0CmdLine=cmd.exe
0Parameters=/c RadeonStartupFix.bat

[Shutdown]
0CmdLine=cmd.exe
0Parameters=/c RadeonShutdownFix.bat
"@

Set-Content -Path $scriptsIniPath -Value $scriptsIniContent -Force
Write-Host "Created scripts.ini with startup and shutdown scripts"

# Update Group Policy registry to enable the scripts
# CRITICAL: Need to create both registry paths for scripts to work on fresh install
# Path 1: State\Machine\Scripts (used during script execution)
$gpoStateRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts"

# Startup registry (State path) - Parent key with GPO metadata
$startupStateParentPath = "$gpoStateRegPath\Startup\0"
if (!(Test-Path $startupStateParentPath)) {
    New-Item -Path $startupStateParentPath -Force | Out-Null
}
Set-ItemProperty -Path $startupStateParentPath -Name "GPO-ID" -Value "LocalGPO" -Force
Set-ItemProperty -Path $startupStateParentPath -Name "SOM-ID" -Value "Local" -Force
Set-ItemProperty -Path $startupStateParentPath -Name "FileSysPath" -Value "C:\WINDOWS\System32\GroupPolicy\Machine" -Force
Set-ItemProperty -Path $startupStateParentPath -Name "DisplayName" -Value "Local Group Policy" -Force
Set-ItemProperty -Path $startupStateParentPath -Name "GPOName" -Value "Local Group Policy" -Force
Set-ItemProperty -Path $startupStateParentPath -Name "PSScriptOrder" -Value 1 -Type DWord -Force

# Startup registry (State path) - Child key with script details
$startupStateRegPath = "$gpoStateRegPath\Startup\0\0"
if (!(Test-Path $startupStateRegPath)) {
    New-Item -Path $startupStateRegPath -Force | Out-Null
}
Set-ItemProperty -Path $startupStateRegPath -Name "Script" -Value "cmd.exe" -Force
Set-ItemProperty -Path $startupStateRegPath -Name "Parameters" -Value "/c RadeonStartupFix.bat" -Force
Set-ItemProperty -Path $startupStateRegPath -Name "ExecTime" -Value ([long]0) -Type QWord -Force

# Shutdown registry (State path) - Parent key with GPO metadata
$shutdownStateParentPath = "$gpoStateRegPath\Shutdown\0"
if (!(Test-Path $shutdownStateParentPath)) {
    New-Item -Path $shutdownStateParentPath -Force | Out-Null
}
Set-ItemProperty -Path $shutdownStateParentPath -Name "GPO-ID" -Value "LocalGPO" -Force
Set-ItemProperty -Path $shutdownStateParentPath -Name "SOM-ID" -Value "Local" -Force
Set-ItemProperty -Path $shutdownStateParentPath -Name "FileSysPath" -Value "C:\WINDOWS\System32\GroupPolicy\Machine" -Force
Set-ItemProperty -Path $shutdownStateParentPath -Name "DisplayName" -Value "Local Group Policy" -Force
Set-ItemProperty -Path $shutdownStateParentPath -Name "GPOName" -Value "Local Group Policy" -Force
Set-ItemProperty -Path $shutdownStateParentPath -Name "PSScriptOrder" -Value 1 -Type DWord -Force

# Shutdown registry (State path) - Child key with script details
$shutdownStateRegPath = "$gpoStateRegPath\Shutdown\0\0"
if (!(Test-Path $shutdownStateRegPath)) {
    New-Item -Path $shutdownStateRegPath -Force | Out-Null
}
Set-ItemProperty -Path $shutdownStateRegPath -Name "Script" -Value "cmd.exe" -Force
Set-ItemProperty -Path $shutdownStateRegPath -Name "Parameters" -Value "/c RadeonShutdownFix.bat" -Force
Set-ItemProperty -Path $shutdownStateRegPath -Name "ExecTime" -Value ([long]0) -Type QWord -Force

# Path 2: Scripts (required for scripts to be recognized - missing on fresh installs!)
# This is what gpedit.msc creates when you first configure scripts
# The structure is Scripts\Startup\0\0 and Scripts\Shutdown\0\0 (nested)
$gpoScriptsRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts"

# Create the base Scripts path if it doesn't exist
if (!(Test-Path $gpoScriptsRegPath)) {
    New-Item -Path $gpoScriptsRegPath -Force | Out-Null
    Write-Host "Created missing Group Policy\Scripts registry path"
}

# Startup registry (Scripts path) - Parent key with GPO metadata
$startupScriptsParentPath = "$gpoScriptsRegPath\Startup\0"
if (!(Test-Path $startupScriptsParentPath)) {
    New-Item -Path $startupScriptsParentPath -Force | Out-Null
}
Set-ItemProperty -Path $startupScriptsParentPath -Name "GPO-ID" -Value "LocalGPO" -Force
Set-ItemProperty -Path $startupScriptsParentPath -Name "SOM-ID" -Value "Local" -Force
Set-ItemProperty -Path $startupScriptsParentPath -Name "FileSysPath" -Value "C:\WINDOWS\System32\GroupPolicy\Machine" -Force
Set-ItemProperty -Path $startupScriptsParentPath -Name "DisplayName" -Value "Local Group Policy" -Force
Set-ItemProperty -Path $startupScriptsParentPath -Name "GPOName" -Value "Local Group Policy" -Force
Set-ItemProperty -Path $startupScriptsParentPath -Name "PSScriptOrder" -Value 1 -Type DWord -Force

# Startup registry (Scripts path) - Child key with script details
$startupScriptsRegPath = "$gpoScriptsRegPath\Startup\0\0"
if (!(Test-Path $startupScriptsRegPath)) {
    New-Item -Path $startupScriptsRegPath -Force | Out-Null
}
Set-ItemProperty -Path $startupScriptsRegPath -Name "Script" -Value "cmd.exe" -Force
Set-ItemProperty -Path $startupScriptsRegPath -Name "Parameters" -Value "/c RadeonStartupFix.bat" -Force
Set-ItemProperty -Path $startupScriptsRegPath -Name "IsPowershell" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $startupScriptsRegPath -Name "ExecTime" -Value ([long]0) -Type QWord -Force

# Shutdown registry (Scripts path) - Parent key with GPO metadata
$shutdownScriptsParentPath = "$gpoScriptsRegPath\Shutdown\0"
if (!(Test-Path $shutdownScriptsParentPath)) {
    New-Item -Path $shutdownScriptsParentPath -Force | Out-Null
}
Set-ItemProperty -Path $shutdownScriptsParentPath -Name "GPO-ID" -Value "LocalGPO" -Force
Set-ItemProperty -Path $shutdownScriptsParentPath -Name "SOM-ID" -Value "Local" -Force
Set-ItemProperty -Path $shutdownScriptsParentPath -Name "FileSysPath" -Value "C:\WINDOWS\System32\GroupPolicy\Machine" -Force
Set-ItemProperty -Path $shutdownScriptsParentPath -Name "DisplayName" -Value "Local Group Policy" -Force
Set-ItemProperty -Path $shutdownScriptsParentPath -Name "GPOName" -Value "Local Group Policy" -Force
Set-ItemProperty -Path $shutdownScriptsParentPath -Name "PSScriptOrder" -Value 1 -Type DWord -Force

# Shutdown registry (Scripts path) - Child key with script details
$shutdownScriptsRegPath = "$gpoScriptsRegPath\Shutdown\0\0"
if (!(Test-Path $shutdownScriptsRegPath)) {
    New-Item -Path $shutdownScriptsRegPath -Force | Out-Null
}
Set-ItemProperty -Path $shutdownScriptsRegPath -Name "Script" -Value "cmd.exe" -Force
Set-ItemProperty -Path $shutdownScriptsRegPath -Name "Parameters" -Value "/c RadeonShutdownFix.bat" -Force
Set-ItemProperty -Path $shutdownScriptsRegPath -Name "IsPowershell" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $shutdownScriptsRegPath -Name "ExecTime" -Value ([long]0) -Type QWord -Force

Write-Host "Group Policy scripts configured successfully!"
Write-Host "Startup: cmd.exe /c RadeonStartupFix.bat"
Write-Host "Shutdown: cmd.exe /c RadeonShutdownFix.bat"

# Create/update GPT.INI with proper version and extension GUIDs
# This is critical - without this, Windows doesn't recognize the scripts!
Write-Host "Creating GPT.INI with proper configuration..."

$gptIniPath = "C:\Windows\System32\GroupPolicy\GPT.INI"
$version = 65537  # Version 1 for both computer (65536) and user (1) policies

# Extension GUIDs required for script processing:
# {42B5FAAE-6536-11D2-AE5A-0000F87571E3} = Scripts (Startup/Shutdown) Client Side Extension
# {40B6664F-4972-11D1-A7CA-0000F87571E3} = Registry Client Side Extension
$extensionNames = "[{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B6664F-4972-11D1-A7CA-0000F87571E3}]"

$gptIniContent = @"
[General]
Version=$version
gPCMachineExtensionNames=$extensionNames
"@

Set-Content -Path $gptIniPath -Value $gptIniContent -Encoding UTF8 -Force
Write-Host "Created GPT.INI with version $version and script extension GUIDs"

# Refresh Group Policy to apply changes
Write-Host "Refreshing Group Policy..."
gpupdate /force

Write-Host "Configuration complete!"
Write-Host "GPO scripts should be active on next reboot."
