echo Uninstalling application...
msiexec /x {23170F69-40C1-2702-2409-000001000000} /q
echo Uninstallation finished with %ERRORLEVEL%

Exit /B %ERRORLEVEL%