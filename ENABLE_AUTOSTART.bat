@echo off
REM Quick one-click autostart installer

echo Installing Claude Scheduler to start with Windows...

REM Get the startup folder path
set "startupFolder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

REM Create shortcut using PowerShell
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%startupFolder%\Claude Scheduler.lnk'); $Shortcut.TargetPath = '%~dp0CommandPromptQueue.ahk'; $Shortcut.WorkingDirectory = '%~dp0'; $Shortcut.IconLocation = 'shell32.dll,167'; $Shortcut.Description = 'Claude Message Scheduler - Autostart'; $Shortcut.Save()"

if exist "%startupFolder%\Claude Scheduler.lnk" (
    cls
    echo ============================================
    echo          AUTOSTART ENABLED!
    echo ============================================
    echo.
    echo ✓ Claude Scheduler will now start automatically
    echo   every time Windows starts.
    echo.
    echo Starting the scheduler now...
    start "" "%~dp0CommandPromptQueue.ahk"
    echo.
    echo To disable autostart, run REMOVE_AUTOSTART.bat
    echo.
    timeout /t 5
) else (
    echo ERROR: Could not enable autostart.
    echo Try running INSTALL_AUTOSTART.bat instead.
    pause
)