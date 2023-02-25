# SimplePowershellGUI
A simple customizable powershell GUI, designed for use with Configuration Manager or Intune deployments in order to notify users of required deployments and allow them some control.

- **v1**: Contains only the GUI script and will work fine if your deployment is in the user context.  
- **v2**: Contains the GUI script and an additional script for starting the GUI in the users context in order for it to display for a user if the deployment is using for example the system account.  
- **v3**: Same as v2, but instead of the GUI being a powershell script it has been compiled into an .exe using ps2exe. This is useful if your client is running a restricted powershell executionpolicy, since the users context will not be allowed to run a script in that case. (The GUI script is also provided, if you'd prefer to compile it yourself)

Note that if you're running script/application control such as Applocker, you might need to create a rule to allow the script and/or exe to run.

```PowerShell
[-Title "<Title>"] [-Text "<Body text>"]
[-Button1Text "<Button text>"] [-Button1ExitCode <INT>] 
[-Button2Enabled] [-Button2Text "<Button text>"] [-Button2ExitCode <INT>]
[-CountdownEnabled] [-CountdownTime <INT>]
```

```Text
-Title: Changes the windows title [Default: SimplePowershellGUI]
-Text: Changes the body text [Default: This is a default body text.]
-Button1Text: Changes the text on the first button [Default: OK]
-Button1ExitCode: The exit code the program will use when user presses the button [Default: 0]
-Button2Enabled: Switch that enables the second button [Default: not enabled]
-Button2Text: Changes the text on the second button [Default: Cancel]
-Button2ExitCode: The exit code the program will use when the user presses the button. (The idea is to fail the deployment so it will autoretry if the user wants to postpone, for example) [Default: 1622]
-CountdownEnabled: Switch that enabled the countdown timer [Default: not enabled]
-CountdownTime: Time in seconds that the countdown will start at [Default: 3600]
```

```Text
Usage Examples

v1 From Powershell:
.\SimplePowershellGUI -Title "Restart Required" -Text "An operating system upgrade is in progress. A system restart will be required during the upgrade process.`n`nPlease save any open work and press Restart to continue, or the system will automatically restart in 2 hours." -Button1Text "Restart" -Button2Enabled -Button2Text "Postpone" -CountdownEnabled -CountdownTime 7200

v1 From Command Line:
Powershell.exe -File .\SimplePowershellGUI.ps1 -Title "Restart Required" -Text "An operating system upgrade is in progress. A system restart will be required during the upgrade process.`n`nPlease save any open work and press Restart to continue, or the system will automatically restart in 2 hours." -Button1Text "Restart" -Button2Enabled -Button2Text "Postpone" -CountdownEnabled -CountdownTime 7200

v2 and v3 from Powershell:
.\StartGUIAsUser.ps1 -Title "Restart Required" -Text "An operating system upgrade is in progress. A system restart will be required during the upgrade process.`n`nPlease save any open work and press Restart to continue, or the system will automatically restart in 2 hours." -Button1Text "Restart" -Button2Enabled -Button2Text "Postpone" -CountdownEnabled -CountdownTime 7200

v2 and v3 from Command Line:
Powershell.exe -File .\StartGUIAsUser.ps1 -Title "Restart Required" -Text "An operating system upgrade is in progress. A system restart will be required during the upgrade process.`n`nPlease save any open work and press Restart to continue, or the system will automatically restart in 2 hours." -Button1Text "Restart" -Button2Enabled -Button2Text "Postpone" -CountdownEnabled -CountdownTime 7200
```

![bild](https://user-images.githubusercontent.com/91835664/221362675-75a2d6f8-15cf-4d33-b7fd-9116c650cd98.png)

