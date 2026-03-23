@echo off
setlocal

set "BASE_DIR=%USERPROFILE%\Projekte"

call :pullRepo "%BASE_DIR%\TDLINK"
call :pullRepo "%BASE_DIR%\TDNOLDS"
call :pullRepo "%BASE_DIR%\TDAudioSwitch"

echo.
echo Fertig.
pause
exit /b 0

:pullRepo
set "REPO=%~1"
echo.
echo ================================
echo Pull fuer %REPO%
echo ================================

if not exist "%REPO%\.git" (
    echo Uebersprungen: kein Git-Repository gefunden.
    exit /b 0
)

pushd "%REPO%"
git fetch --all
if errorlevel 1 (
    echo Fetch fehlgeschlagen in %REPO%.
    popd
    exit /b 0
)

git pull
if errorlevel 1 (
    echo Pull fehlgeschlagen in %REPO%.
) else (
    echo Pull abgeschlossen fuer %REPO%.
)
popd
exit /b 0
