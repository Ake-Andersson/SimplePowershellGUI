# SimplePowershellGUI
A simple customizable powershell GUI, designed for use with Configuration Manager or Intune deployments in order to notify users of required deployments and allow them some control.

Since the script GUI itself needs to be an .exe for the purposes of being displayed to the user, I've also provided the .ps1 source in case you would rather compile it into an .exe yourself.

The idea behind this solution being that you're able to deploy this GUI with deployments that might require downtime for the user, in order to warn them as well as possibly give them the option to postpone. By setting a non-zero exit code, we can fail the deployment and as such make it retry at a later time.

Note that if you're running script/application control such as Applocker, you might need to create a rule to allow the script and/or exe to run.

Feel free to use/copy/edit/take inspiration from this solution in any way you'd like.

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

From Command-Line:
powershell.exe -ExecutionPolicy Bypass "%~dp0StartGUIAsUser.ps1" -Title 'Restart Required' -Text 'An application requiring a system reboot is about to be installed. `n`nTo proceed with the installation, please save any open work and press Install, or the system will automatically continue in 60 minutes. `n`nTo postpone installation, press Postpone.' -Button1Text 'Install' -Button1ExitCode 0 -Button2Enabled -Button2Text 'Postpone' -Button2ExitCode 1622 -CountdownEnabled -CountdownTime 3600

ExampleDemo.cmd:
My preferred method is to call the script from a batch/cmd script file with parameters split into new lines. See "ExampleDemo.cmd" as an example of this.

```
You may also replace Icon.png with any 25x25 png image, such as an image representing your organization.

![bild](https://github.com/Ake-Andersson/SimplePowershellGUI/assets/91835664/f25572f4-f13e-4c95-ae82-96783940b050)


