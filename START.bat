@echo off
cls
echo ============================================
echo     CLAUDE MESSAGE SCHEDULER - READY!
echo ============================================
echo.
echo QUICK START:
echo   F9        = Schedule a message
echo   Shift+F9  = View/Copy/Cancel messages
echo.
echo Starting scheduler...
taskkill /F /IM AutoHotkey64.exe >nul 2>&1
taskkill /F /IM AutoHotkey32.exe >nul 2>&1
taskkill /F /IM AutoHotkey.exe >nul 2>&1
timeout /t 1 >nul
start "" "CommandPromptQueue.ahk"
echo.
echo Ready! The scheduler is now running.
echo You can close this window.
echo.
timeout /t 5