
@echo off
setlocal
title TDAudioSwitch

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_PATH=%SCRIPT_DIR%main.ps1"
cd /d "%SCRIPT_DIR%"

if not exist "%SCRIPT_PATH%" (
    echo Fehler: "%SCRIPT_PATH%" wurde nicht gefunden.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
    echo.
    echo TDAudioSwitch wurde mit Fehlercode %EXIT_CODE% beendet.
)

echo.
pause
exit /b %EXIT_CODE%
