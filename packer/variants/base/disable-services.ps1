# Disable unnecessary services for minimal installation

# Create log directory and start transcript
if (-not (Test-Path "C:\packer")) {
    New-Item -ItemType Directory -Path "C:\packer" -Force | Out-Null
}
Start-Transcript -Path "C:\packer\disable-services.log" -Append

Write-Host "Disabling unnecessary services..."

$services = @(
    "DiagTrack",                    # Connected User Experiences and Telemetry
    "dmwappushservice",             # WAP Push Message Routing Service
    "HomeGroupListener",            # HomeGroup Listener
    "HomeGroupProvider",            # HomeGroup Provider
    "lfsvc",                        # Geolocation Service
    "MapsBroker",                   # Downloaded Maps Manager
    "NetTcpPortSharing",            # Net.Tcp Port Sharing Service
    "RemoteAccess",                 # Routing and Remote Access
    "RemoteRegistry",               # Remote Registry
    "SharedAccess",                 # Internet Connection Sharing (ICS)
    "TrkWks",                       # Distributed Link Tracking Client
    "WbioSrvc",                     # Windows Biometric Service
    "WMPNetworkSvc",                # Windows Media Player Network Sharing Service
    "XblAuthManager",               # Xbox Live Auth Manager
    "XblGameSave",                  # Xbox Live Game Save
    "XboxNetApiSvc"                 # Xbox Live Networking Service
)

foreach ($service in $services) {
    try {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "Disabled: $service"
    }
    catch {
        Write-Host "Could not disable: $service (may not exist)"
    }
}

Write-Host "Service configuration complete."

Stop-Transcript
