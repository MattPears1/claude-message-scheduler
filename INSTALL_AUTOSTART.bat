@echo off
cls
echo ============================================
echo     AUTOSTART SETUP FOR CLAUDE SCHEDULER
echo ============================================
echo.
echo This will make the scheduler start automatically
echo when Windows starts.
echo.
echo Choose installation method:
echo.
echo [1] Install to Startup Folder (Recommended)
echo [2] Install to Registry (Advanced)
echo [3] Cancel
echo.
choice /C 123 /N /M "Select option (1-3): "

if errorlevel 3 goto :cancel
if errorlevel 2 goto :registry
if errorlevel 1 goto :startup

:startup
echo.
echo Installing to Startup folder...

REM Get the startup folder path
set "startupFolder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

REM Create a shortcut in the startup folder
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%startupFolder%\Claude Scheduler.lnk'); $Shortcut.TargetPath = '%~dp0CommandPromptQueue.ahk'; $Shortcut.WorkingDirectory = '%~dp0'; $Shortcut.IconLocation = 'shell32.dll,167'; $Shortcut.Description = 'Claude Message Scheduler - Autostart'; $Shortcut.Save()"

if exist "%startupFolder%\Claude Scheduler.lnk" (
    echo.
    echo ✓ SUCCESS! Claude Scheduler will now start automatically.
    echo.
    echo Location: %startupFolder%
    echo.
    echo To remove autostart:
    echo   1. Press Win+R
    echo   2. Type: shell:startup
    echo   3. Delete "Claude Scheduler.lnk"
    echo.
    echo Starting the scheduler now...
    start "" "%~dp0CommandPromptQueue.ahk"
) else (
    echo.
    echo ✗ ERROR: Could not create startup shortcut.
    echo Please try the registry method instead.
)
goto :end

:registry
echo.
echo Installing to Registry...
echo.
echo This requires administrator privileges.
echo Please run this file as Administrator.
echo.

REM Add to registry
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ClaudeScheduler" /t REG_SZ /d "\"%~dp0CommandPromptQueue.ahk\"" /f

if %errorlevel% == 0 (
    echo.
    echo ✓ SUCCESS! Claude Scheduler added to registry.
    echo.
    echo To remove autostart:
    echo   1. Press Win+R
    echo   2. Type: regedit
    echo   3. Navigate to: HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
    echo   4. Delete "ClaudeScheduler"
    echo.
    echo Starting the scheduler now...
    start "" "%~dp0CommandPromptQueue.ahk"
) else (
    echo.
    echo ✗ ERROR: Could not add to registry.
    echo Try running as Administrator.
)
goto :end

:cancel
echo.
echo Installation cancelled.
goto :end

:end
echo.
pause