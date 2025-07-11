@echo off
echo ==========================================
echo    SMART MESSAGE SCHEDULER - IMPROVED
echo ==========================================
echo.
echo NEW SMART FEATURES:
echo   - Verifies messages are actually sent
echo   - Retries up to 3 times if sending fails
echo   - Can wait until you're inactive
echo   - Better window activation
echo   - Clipboard verification
echo.
echo PERFECT FOR:
echo   - Overnight sessions (won't interrupt)
echo   - Working while scheduling
echo   - Ensuring messages send reliably
echo.
echo Starting Smart Scheduler...
taskkill /F /IM AutoHotkey64.exe >nul 2>&1
taskkill /F /IM AutoHotkey32.exe >nul 2>&1
timeout /t 1 >nul
start "" "SmartCommandPromptQueue.ahk"
echo.
echo Ready! Press F9 to use smart scheduling.
pause