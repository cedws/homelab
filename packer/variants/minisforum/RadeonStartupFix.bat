@echo off
setlocal enabledelayedexpansion

set LOGFILE=C:\Scripts\enable.log
echo [%date% %time%] Starting enable script >> %LOGFILE%

echo Enabling Display devices...
for /f "tokens=*" %%a in ('pnputil /enum-devices /class Display ^| findstr /c:"Instance ID"') do (
    set "id=%%a"
    set "id=!id:Instance ID: =!"
    set "id=!id: =!"
    if not "!id!"=="" (
        pnputil /enable-device "!id!" >nul 2>&1
        if errorlevel 0 (
            echo [%date% %time%] Enabled: !id! >> %LOGFILE%
        ) else (
            echo [%date% %time%] Failed to enable: !id! (errorlevel: %errorlevel%) >> %LOGFILE%
        )
    )
)

echo Enabling MEDIA devices...
for /f "tokens=*" %%a in ('pnputil /enum-devices /class MEDIA ^| findstr /c:"Instance ID"') do (
    set "id=%%a"
    set "id=!id:Instance ID: =!"
    set "id=!id: =!"
    if not "!id!"=="" (
        pnputil /enable-device "!id!" >nul 2>&1
        if errorlevel 0 (
            echo [%date% %time%] Enabled: !id! >> %LOGFILE%
        ) else (
            echo [%date% %time%] Failed to enable: !id! (errorlevel: %errorlevel%) >> %LOGFILE%
        )
    )
)

echo Enabling Bluetooth devices...
for /f "tokens=*" %%a in ('pnputil /enum-devices /class Bluetooth ^| findstr /c:"Instance ID"') do (
    set "id=%%a"
    set "id=!id:Instance ID: =!"
    set "id=!id: =!"
    if not "!id!"=="" (
        pnputil /enable-device "!id!" >nul 2>&1
        if errorlevel 0 (
            echo [%date% %time%] Enabled: !id! >> %LOGFILE%
        ) else (
            echo [%date% %time%] Failed to enable: !id! (errorlevel: %errorlevel%) >> %LOGFILE%
        )
    )
)

echo [%date% %time%] Enable script complete >> %LOGFILE%
endlocal
