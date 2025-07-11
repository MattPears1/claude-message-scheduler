@echo off
echo COMMAND PROMPT MESSAGE QUEUE
echo ===========================
echo.
echo This version is designed specifically for command prompts!
echo.
echo HOW IT WORKS:
echo 1. Type your message in the command prompt
echo 2. Press F9 (DON'T press Enter!)
echo 3. Enter delay (30s, 5m, 1h)
echo 4. The message sends automatically
echo.
echo IMPORTANT: Each message you type and schedule with F9
echo will send independently at its scheduled time.
echo.
echo Press Shift+F9 to see all scheduled messages
echo.
echo Restarting AutoHotkey...
taskkill /F /IM AutoHotkey64.exe >nul 2>&1
taskkill /F /IM AutoHotkey32.exe >nul 2>&1
timeout /t 1 >nul
start "" "CommandPromptQueue.ahk"
echo.
echo Ready! Type a message and press F9.
pause