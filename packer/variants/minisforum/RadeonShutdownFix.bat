@echo off
setlocal enabledelayedexpansion

set LOGFILE=C:\Scripts\disable.log
echo [%date% %time%] Starting disable script >> %LOGFILE%

echo Disabling Display devices...
for /f "tokens=*" %%a in ('pnputil /enum-devices /class Display ^| findstr /c:"Instance ID"') do (
    set "id=%%a"
    set "id=!id:Instance ID: =!"
    set "id=!id: =!"
    if not "!id!"=="" (
        pnputil /disable-device "!id!" >nul 2>&1
        if errorlevel 0 (
            echo [%date% %time%] Disabled: !id! >> %LOGFILE%
        ) else (
            echo [%date% %time%] Failed to disable: !id! (errorlevel: %errorlevel%) >> %LOGFILE%
        )
    )
)

echo Disabling MEDIA devices...
for /f "tokens=*" %%a in ('pnputil /enum-devices /class MEDIA ^| findstr /c:"Instance ID"') do (
    set "id=%%a"
    set "id=!id:Instance ID: =!"
    set "id=!id: =!"
    if not "!id!"=="" (
        pnputil /disable-device "!id!" >nul 2>&1
        if errorlevel 0 (
            echo [%date% %time%] Disabled: !id! >> %LOGFILE%
        ) else (
            echo [%date% %time%] Failed to disable: !id! (errorlevel: %errorlevel%) >> %LOGFILE%
        )
    )
)

echo Disabling Bluetooth devices...
for /f "tokens=*" %%a in ('pnputil /enum-devices /class Bluetooth ^| findstr /c:"Instance ID"') do (
    set "id=%%a"
    set "id=!id:Instance ID: =!"
    set "id=!id: =!"
    if not "!id!"=="" (
        pnputil /disable-device "!id!" >nul 2>&1
        if errorlevel 0 (
            echo [%date% %time%] Disabled: !id! >> %LOGFILE%
        ) else (
            echo [%date% %time%] Failed to disable: !id! (errorlevel: %errorlevel%) >> %LOGFILE%
        )
    )
)

echo [%date% %time%] Disable script complete >> %LOGFILE%
endlocal
