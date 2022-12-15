# SimplePowershellGUI
A simple customizable powershell GUI, designed for use with Configuration Manager deployments in order to notify users of required deployments and allow them some control.

For example, you create a package in SCCM / MECM containing the script file and Icon.png file. Then you can call this script file from a Task Sequence with the parameters specified.

You may also replace Icon.png for 25x25 .png file to display a different logo (for example your organisations logo)

If paramaters are not supplied, default values will be used. You should always provide a title and body text.

<br>
<br>

<b>Parameters:</b>

[string] Title: Sets the form title, as well as a title text in the form.
[string] Text: Sets a body text of the form.
    
[string] Button1Text: Sets a text on Button 1. Default value is "OK".
[int] Button1ExitCode: Sets which exit code should be used when user presses the button. Default value is 0.
    
[bool] Button2Enabled: Decides if Button 2 should be visible and enabled. Default value is $true.
[string] Button2Text: Sets a text on Button 2. Default value is "Cancel".
[int] Button2ExitCode: Sets which exit code should be used when user presses the button. Default value is 1622.

[bool] CountdownEnabled: Decides if a countdown timer should be included. Default value is $false.
[int] CountdownTime: Sets the amount of time in seconds the timer will count down. Default value is 3600.

<br>
<br>

<b>Usage examples:</b>

From Powershell:

.\SimplePowershellGUI.ps1 -Title "Restart Required" -Text "An operating system upgrade is in progress. In order to continue, a restart is required.\`n`nPlease save any open work and press 'Restart' to continue." -Button1Text "Restart" -Button2Text "Postpone" -CountdownEnabled $true -CountdownTime 3600

![bild](https://user-images.githubusercontent.com/91835664/207888586-d920f376-9a1e-4929-9fdf-2eda77fbfcd7.png)
