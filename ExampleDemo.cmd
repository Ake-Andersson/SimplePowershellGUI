powershell.exe -ExecutionPolicy Bypass "%~dp0StartGUIAsUser.ps1" ^
-Title 'Restart Required' ^
-Text 'An application requiring a system reboot is about to be installed. `n`nTo proceed with the installation, please save any open work and press Install, or the system will automatically continue in 60 minutes. `n`nTo postpone installation, press Postpone.' ^
-Button1Text 'Install' ^
-Button1ExitCode 0 ^
-Button2Enabled ^
-Button2Text 'Postpone' ^
-Button2ExitCode 1622 ^
-CountdownEnabled ^
-CountdownTime 3600 