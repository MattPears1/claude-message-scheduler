@echo off
echo Restarting Message Queue Scheduler...
taskkill /F /IM AutoHotkey64.exe >nul 2>&1
taskkill /F /IM AutoHotkey32.exe >nul 2>&1
taskkill /F /IM AutoHotkey.exe >nul 2>&1
timeout /t 1 >nul
start "" "MultiMessageQueue.ahk"
echo.
echo Scheduler restarted!
echo.
echo Press F9 to add messages
echo Press Shift+F9 to view queue
echo.
pause