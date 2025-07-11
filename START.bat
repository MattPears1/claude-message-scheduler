@echo off
cls

REM Check if already running
tasklist /FI "IMAGENAME eq AutoHotkey64.exe" 2>NUL | find /I /N "AutoHotkey64.exe">NUL
if "%ERRORLEVEL%"=="0" goto :already_running

tasklist /FI "IMAGENAME eq AutoHotkey32.exe" 2>NUL | find /I /N "AutoHotkey32.exe">NUL
if "%ERRORLEVEL%"=="0" goto :already_running

:start_fresh
echo ============================================
echo     CLAUDE MESSAGE SCHEDULER - STARTING
echo ============================================
echo.
echo QUICK START:
echo   F9        = Schedule a message
echo   Shift+F9  = View/Copy/Cancel messages
echo.
echo Starting scheduler...
start "" "CommandPromptQueue.ahk"
echo.
echo Ready! The scheduler is now running.
echo You can close this window.
echo.
timeout /t 3
exit

:already_running
echo ============================================
echo     CLAUDE MESSAGE SCHEDULER
echo ============================================
echo.
echo The scheduler is ALREADY RUNNING!
echo.
echo To restart it:
echo   1. Close this window
echo   2. Press Ctrl+Shift+Esc (Task Manager)
echo   3. End AutoHotkey process
echo   4. Run START.bat again
echo.
echo Or just use it now:
echo   F9        = Schedule a message
echo   Shift+F9  = View/Copy/Cancel messages
echo.
pause
exit