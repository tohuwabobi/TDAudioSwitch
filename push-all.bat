@echo off
setlocal

where git >nul 2>nul
if errorlevel 1 (
    echo Git wurde nicht gefunden.
    pause
    exit /b 1
)

set "BASE_DIR=%USERPROFILE%\Projekte"

set /p COMMIT_MESSAGE=Commit-Message eingeben ^(leer = Auto^) : 
if not defined COMMIT_MESSAGE (
    set "COMMIT_MESSAGE=Auto commit %date% %time%"
)

call :pushRepo "%BASE_DIR%\TDLINK"
call :pushRepo "%BASE_DIR%\TDNOLDS"
call :pushRepo "%BASE_DIR%\TDAudioSwitch"

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
git add -A
if errorlevel 1 (
    echo Hinzufuegen fehlgeschlagen in %REPO%.
    popd
    exit /b 0
)

git diff --cached --quiet
if errorlevel 1 (
    git commit -m "%COMMIT_MESSAGE%"
    if errorlevel 1 (
        echo Commit fehlgeschlagen in %REPO%.
        popd
        exit /b 0
    )
) else (
    echo Keine neuen Aenderungen zum Committen in %REPO%.
)

git status --short
git push
if errorlevel 1 (
    echo Push fehlgeschlagen in %REPO%.
) else (
    echo Push abgeschlossen fuer %REPO%.
)
popd
exit /b 0
