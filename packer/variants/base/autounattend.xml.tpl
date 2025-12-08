<?xml version="1.0" encoding="utf-8" ?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <!-- Windows PE Pass - Disk Configuration and TPM Bypass -->
    <settings pass="windowsPE">
        <component
            name="Microsoft-Windows-International-Core-WinPE"
            processorArchitecture="amd64"
            publicKeyToken="31bf3856ad364e35"
            language="neutral"
            versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        >
            <SetupUILanguage>
                <UILanguage>${ui_language}</UILanguage>
            </SetupUILanguage>
            <InputLocale>${keyboard_layout}</InputLocale>
            <SystemLocale>${ui_language}</SystemLocale>
            <UILanguage>${ui_language}</UILanguage>
            <UserLocale>${ui_language}</UserLocale>
        </component>

        <component
            name="Microsoft-Windows-Setup"
            processorArchitecture="amd64"
            publicKeyToken="31bf3856ad364e35"
            language="neutral"
            versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        >

            <!-- TPM, Secure Boot, RAM, CPU and Storage Bypass -->
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Path
                    >reg add HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <Path
                    >reg add HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>3</Order>
                    <Path
                    >reg add HKLM\SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>4</Order>
                    <Path
                    >reg add HKLM\SYSTEM\Setup\LabConfig /v BypassCPUCheck /t REG_DWORD /d 1 /f</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>5</Order>
                    <Path
                    >reg add HKLM\SYSTEM\Setup\LabConfig /v BypassStorageCheck /t REG_DWORD /d 1 /f</Path>
                </RunSynchronousCommand>
            </RunSynchronous>

            <DiskConfiguration>
                <Disk wcm:action="add">
                    <DiskID>0</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                    <CreatePartitions>
                        <!-- EFI System Partition -->
                        <CreatePartition wcm:action="add">
                            <Order>1</Order>
                            <Size>100</Size>
                            <Type>EFI</Type>
                        </CreatePartition>
                        <!-- Microsoft Reserved Partition -->
                        <CreatePartition wcm:action="add">
                            <Order>2</Order>
                            <Size>128</Size>
                            <Type>MSR</Type>
                        </CreatePartition>
                        <!-- Windows Partition -->
                        <CreatePartition wcm:action="add">
                            <Order>3</Order>
                            <Extend>true</Extend>
                            <Type>Primary</Type>
                        </CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <ModifyPartition wcm:action="add">
                            <Order>1</Order>
                            <PartitionID>1</PartitionID>
                            <Format>FAT32</Format>
                            <Label>System</Label>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Order>2</Order>
                            <PartitionID>2</PartitionID>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Order>3</Order>
                            <PartitionID>3</PartitionID>
                            <Format>NTFS</Format>
                            <Label>Windows</Label>
                            <Letter>C</Letter>
                        </ModifyPartition>
                    </ModifyPartitions>
                </Disk>
            </DiskConfiguration>

            <ImageInstall>
                <OSImage>
                    <InstallFrom>
                        <MetaData wcm:action="add">
                            <Key>/IMAGE/INDEX</Key>
                            <Value>${image_index}</Value>
                        </MetaData>
                    </InstallFrom>
                    <InstallTo>
                        <DiskID>0</DiskID>
                        <PartitionID>3</PartitionID>
                    </InstallTo>
                </OSImage>
            </ImageInstall>

            <UserData>
                <ProductKey>
                    <Key />
                    <WillShowUI>Never</WillShowUI>
                </ProductKey>
                <AcceptEula>true</AcceptEula>
                <FullName>${username}</FullName>
                <Organization />
            </UserData>
        </component>

        <!-- Load VirtIO Drivers during Windows PE -->
        <component
            name="Microsoft-Windows-PnpCustomizationsWinPE"
            processorArchitecture="amd64"
            publicKeyToken="31bf3856ad364e35"
            language="neutral"
            versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        >
            <!--
                This makes the VirtIO drivers available to Windows during installation.
                VirtIO ISO is mounted as E: drive.
                Based on https://fedorapeople.org/groups/virt/virtio-win/
            -->
            <DriverPaths>
                <!-- Storage drivers (critical for installation) -->
                <PathAndCredentials wcm:action="add" wcm:keyValue="1">
                    <Path>E:\viostor\${virtio_win_version}\amd64</Path>
                </PathAndCredentials>

                <!-- SCSI storage driver -->
                <PathAndCredentials wcm:action="add" wcm:keyValue="2">
                    <Path>E:\vioscsi\${virtio_win_version}\amd64</Path>
                </PathAndCredentials>

                <!-- Network driver -->
                <PathAndCredentials wcm:action="add" wcm:keyValue="3">
                    <Path>E:\NetKVM\${virtio_win_version}\amd64</Path>
                </PathAndCredentials>

                <!-- Balloon driver (memory management) -->
                <PathAndCredentials wcm:action="add" wcm:keyValue="4">
                    <Path>E:\Balloon\${virtio_win_version}\amd64</Path>
                </PathAndCredentials>

                <!-- pvpanic (guest panic notification) -->
                <PathAndCredentials wcm:action="add" wcm:keyValue="5">
                    <Path>E:\pvpanic\${virtio_win_version}\amd64</Path>
                </PathAndCredentials>

                <!-- qemupciserial (serial port) -->
                <PathAndCredentials wcm:action="add" wcm:keyValue="6">
                    <Path>E:\qemupciserial\${virtio_win_version}\amd64</Path>
                </PathAndCredentials>

                <!-- qxldod (display driver) -->
                <PathAndCredentials wcm:action="add" wcm:keyValue="7">
                    <Path>E:\qxldod\${virtio_win_version}\amd64</Path>
                </PathAndCredentials>

                <!-- vioinput (input devices) -->
                <PathAndCredentials wcm:action="add" wcm:keyValue="8">
                    <Path>E:\vioinput\${virtio_win_version}\amd64</Path>
                </PathAndCredentials>

                <!-- viorng (random number generator) -->
                <PathAndCredentials wcm:action="add" wcm:keyValue="9">
                    <Path>E:\viorng\${virtio_win_version}\amd64</Path>
                </PathAndCredentials>

                <!-- vioserial (serial port) -->
                <PathAndCredentials wcm:action="add" wcm:keyValue="10">
                    <Path>E:\vioserial\${virtio_win_version}\amd64</Path>
                </PathAndCredentials>
            </DriverPaths>
        </component>
    </settings>

    <!-- Offline Servicing Pass - Disable UAC -->
    <settings pass="offlineServicing">
        <component
            name="Microsoft-Windows-LUA-Settings"
            processorArchitecture="amd64"
            publicKeyToken="31bf3856ad364e35"
            language="neutral"
            versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        >
            <EnableLUA>false</EnableLUA>
        </component>
    </settings>

    <!-- Specialize Pass - Computer Name and Regional Settings -->
    <settings pass="specialize">
        <component
            name="Microsoft-Windows-Deployment"
            processorArchitecture="amd64"
            publicKeyToken="31bf3856ad364e35"
            language="neutral"
            versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        >
            <RunSynchronous>
                <!-- Additional TPM bypass in specialize pass for safety -->
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Path
                    >reg add HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <Path
                    >reg add HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>

        <component
            name="Microsoft-Windows-Shell-Setup"
            processorArchitecture="amd64"
            publicKeyToken="31bf3856ad364e35"
            language="neutral"
            versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        >
            <ComputerName>${computer_name}</ComputerName>
            <TimeZone>${time_zone}</TimeZone>
        </component>

        <component
            name="Microsoft-Windows-International-Core"
            processorArchitecture="amd64"
            publicKeyToken="31bf3856ad364e35"
            language="neutral"
            versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        >
            <InputLocale>${keyboard_layout}</InputLocale>
            <SystemLocale>${ui_language}</SystemLocale>
            <UILanguage>${ui_language}</UILanguage>
            <UserLocale>${ui_language}</UserLocale>
        </component>
    </settings>

    <!-- OOBE Pass - User Account and SSH Setup -->
    <settings pass="oobeSystem">
        <component
            name="Microsoft-Windows-Shell-Setup"
            processorArchitecture="amd64"
            publicKeyToken="31bf3856ad364e35"
            language="neutral"
            versionScope="nonSxS"
            xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        >

            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Work</NetworkLocation>
                <ProtectYourPC>3</ProtectYourPC>
                <SkipMachineOOBE>true</SkipMachineOOBE>
                <SkipUserOOBE>true</SkipUserOOBE>
            </OOBE>

            <UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Name>${username}</Name>
                        <DisplayName>${username}</DisplayName>
                        <Group>Administrators</Group>
                        <Password>
                            <Value>${password}</Value>
                            <PlainText>true</PlainText>
                        </Password>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>

            <AutoLogon>
                <Enabled>true</Enabled>
                <Username>${username}</Username>
                <Password>
                    <Value>${password}</Value>
                    <PlainText>true</PlainText>
                </Password>
                <LogonCount>10</LogonCount>
            </AutoLogon>

            <FirstLogonCommands>
                <!-- Install QEMU Guest Agent FIRST so Proxmox can report IP -->
                <SynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <CommandLine
                    >cmd /c start /wait msiexec /i E:\guest-agent\qemu-ga-x86_64.msi /qn /norestart /l*v C:\qemu-ga-install.log</CommandLine>
                    <Description
                    >Install QEMU Guest Agent from VirtIO ISO</Description>
                </SynchronousCommand>
                <!-- Start the agent service -->
                <SynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <CommandLine
                    >cmd /c sc config qemu-ga start= auto</CommandLine>
                    <Description
                    >Set QEMU Guest Agent to auto-start</Description>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Order>3</Order>
                    <CommandLine>cmd /c net start qemu-ga</CommandLine>
                    <Description>Start QEMU Guest Agent</Description>
                </SynchronousCommand>
                <!-- Install OpenSSH Server -->
                <SynchronousCommand wcm:action="add">
                    <Order>4</Order>
                    <CommandLine
                    >powershell -ExecutionPolicy Bypass -Command "Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0"</CommandLine>
                    <Description>Install OpenSSH Server</Description>
                </SynchronousCommand>
                <!-- Start OpenSSH Server -->
                <SynchronousCommand wcm:action="add">
                    <Order>5</Order>
                    <CommandLine
                    >powershell -ExecutionPolicy Bypass -Command "Start-Service sshd"</CommandLine>
                    <Description>Start OpenSSH Server</Description>
                </SynchronousCommand>
                <!-- Set OpenSSH Server to Automatic -->
                <SynchronousCommand wcm:action="add">
                    <Order>6</Order>
                    <CommandLine
                    >powershell -ExecutionPolicy Bypass -Command "Set-Service -Name sshd -StartupType 'Automatic'"</CommandLine>
                    <Description>Set OpenSSH Server to Automatic</Description>
                </SynchronousCommand>
                <!-- Configure Firewall for OpenSSH -->
                <SynchronousCommand wcm:action="add">
                    <Order>7</Order>
                    <CommandLine
                    >powershell -ExecutionPolicy Bypass -Command "New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22"</CommandLine>
                    <Description>Configure Firewall for OpenSSH</Description>
                </SynchronousCommand>
                <!-- Set network profile to Private -->
                <SynchronousCommand wcm:action="add">
                    <Order>8</Order>
                    <CommandLine
                    >cmd /c powershell -ExecutionPolicy Bypass -Command "Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private"</CommandLine>
                    <Description>Set Network to Private</Description>
                </SynchronousCommand>
            </FirstLogonCommands>
        </component>
    </settings>
</unattend>
