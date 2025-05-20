powershell.exe -ExecutionPolicy Bypass -File "%~dp0StartGUI.ps1"

IF %ERRORLEVEL% == 1602 (
echo User Postponed Installation..
GOTO END
)

echo Installing application...
msiexec /i "7z2409-x64.msi" /q
echo Installation finished with %ERRORLEVEL%

:END
Exit /B %ERRORLEVEL%