@echo off
setlocal

call :pushRepo "C:\Users\tobias.lange\Projekte\TDLINK"
call :pushRepo "C:\Users\tobias.lange\Projekte\TDNOLDS"
call :pushRepo "C:\Users\tobias.lange\Projekte\TDAudioSwitch"

echo.
echo Fertig.
pause
exit /b 0

:pushRepo
set "REPO=%~1"
echo.
echo ================================
echo Push fuer %REPO%
echo ================================

if not exist "%REPO%\.git" (
    echo Uebersprungen: kein Git-Repository gefunden.
    exit /b 0
)

pushd "%REPO%"
git add .
git status --short
git push
if errorlevel 1 (
    echo Push fehlgeschlagen in %REPO%.
) else (
    echo Push abgeschlossen fuer %REPO%.
)
popd
exit /b 0
