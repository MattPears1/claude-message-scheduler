@echo off
cls
echo ============================================
echo   REMOVE AUTOSTART FOR CLAUDE SCHEDULER
echo ============================================
echo.
echo This will stop the scheduler from starting
echo automatically with Windows.
echo.
echo Checking for installations...
echo.

set "removed=0"

REM Check startup folder
set "startupFolder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
if exist "%startupFolder%\Claude Scheduler.lnk" (
    echo Found: Startup folder installation
    del "%startupFolder%\Claude Scheduler.lnk"
    echo ✓ Removed from Startup folder
    set "removed=1"
    echo.
)

REM Check registry
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ClaudeScheduler" >nul 2>&1
if %errorlevel% == 0 (
    echo Found: Registry installation
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ClaudeScheduler" /f >nul 2>&1
    echo ✓ Removed from Registry
    set "removed=1"
    echo.
)

if "%removed%"=="0" (
    echo.
    echo No autostart installations found.
    echo The scheduler was not set to start automatically.
) else (
    echo.
    echo ✓ SUCCESS! Autostart has been disabled.
    echo.
    echo The scheduler will no longer start with Windows.
    echo You can still run it manually with START.bat
)

echo.
pause