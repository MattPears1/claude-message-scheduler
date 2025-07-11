@echo off
echo CLEAN QUEUE SCHEDULER
echo ====================
echo.
echo Simple workflow:
echo   1. Press F9 - Opens dialog box
echo   2. Type your message
echo   3. Enter delay (30s, 5m, 1h)
echo   4. Click Submit
echo.
echo   Press Shift+F9 to view all scheduled messages
echo.
echo Starting scheduler...
taskkill /F /IM AutoHotkey64.exe >nul 2>&1
taskkill /F /IM AutoHotkey32.exe >nul 2>&1
timeout /t 1 >nul
start "" "MultiMessageQueue.ahk"
echo.
echo Ready! Press F9 to schedule a message.
pause