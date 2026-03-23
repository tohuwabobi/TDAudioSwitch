@echo off
setlocal
title TDAudioSwitch Toggle

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_PATH=%SCRIPT_DIR%main.ps1"

set "A_OUTPUT=Lautsprecher (Jabra Link 380)"
set "A_MICROPHONE=Mikrofon (Jabra Link 380)"
set "B_OUTPUT=LG ULTRAWIDE (NVIDIA High Definition Audio)"
set "B_MICROPHONE=Mikrofon (4- Insta360 Link 2)"

for /f "usebackq tokens=1,* delims==" %%A in (`powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" -GetCurrentDefaults`) do (
    if /i "%%A"=="OUTPUT" set "CURRENT_OUTPUT=%%B"
    if /i "%%A"=="MICROPHONE" set "CURRENT_MICROPHONE=%%B"
)

if /i "%CURRENT_OUTPUT%"=="%A_OUTPUT%" if /i "%CURRENT_MICROPHONE%"=="%A_MICROPHONE%" (
    call "%~dp0TDAudioSwitch.bat" -OutputName "%B_OUTPUT%" -MicrophoneName "%B_MICROPHONE%"
    exit /b %ERRORLEVEL%
)

call "%~dp0TDAudioSwitch.bat" -OutputName "%A_OUTPUT%" -MicrophoneName "%A_MICROPHONE%"
exit /b %ERRORLEVEL%
