# SimplePowershellGUI

![bild](https://github.com/Ake-Andersson/SimplePowershellGUI/assets/91835664/f25572f4-f13e-4c95-ae82-96783940b050)

This project aims to be a simple customizable powershell GUI, to be able to inform and offer users the ability to postpone or cancel required deployments.

Intended for use with Configuration Manager or Intune applications/packages/task sequences/scripts, in cases where other solution such as PSADT or ServiceUI.exe feel more cumbersome or does not work.

The idea behind this solution being that you're able to deploy this GUI with deployments that might require downtime for the user, in order to warn them as well as possibly give them the option to postpone. By setting a non-zero exit code, we can fail the deployment and as such make it retry at a later time.

Feel free to use/copy/edit/take inspiration from this solution in any way you'd like.

In order to use, simply modify the parameters in SimplePowershellGUI.ps1 to reflect what you want to display to the user:

```Text
[-Title "<Title>"] - The title text of the GUI
[-Text "<Body text>"] - The body text of the GUI
[-Button1Text "<Button text>"] - The text of the first button
[-Button1ExitCode <INT>] - The exit code used when the user presses the first button
[-Button2Enabled <Boolean>] - If the second button should be enabled
[-Button2Text "<Button text>"] - The text on the second button
[-Button2ExitCode <INT>] - The exit code used when the user presses the second button
[-CountdownEnabled <Boolean>] - If the countdown should be enabled
[-CountdownTime <INT>] - How much time (in seconds) the countdown is
[-DefaultExitCode <INT>] - The default exit code, used if the user manages to close the dialog without pressing a button
[-AlwaysOnTop <Boolean>] - If the dialog window should always be on top of the desktop apps
[-ShowMinimizeAndClose <Boolean>] - If the dialog window should show the minimize and close (X-button)
```
Then call StartGUI.ps1 to open the GUI for the user.

If the GUI is not able to run as a user (if no user is logged on), the script will exit with Exit Code: 1621. If needed, this can be modified by changing the $GUIExitCode at the top of StartGUI.ps1.


```Text
Usage Tips

From Command-Line:
powershell.exe -ExecutionPolicy Bypass "StartGUI.ps1"

Or from .bat or .cmd file:
powershell.exe -ExecutionPolicy Bypass "%~dp0StartGUI.ps1"

Example Demo Package - 7-Zip 2409:
This is an example of a packaged application (7-Zip 2409) I've included simply for demonstration purposes

If you need the application to succeed if no user is logged on:
Either add the exit code 1621 as a success exit code on your applications OR modify $GUIExitCode at the start of StartGUI.ps1 to 0

To change the icon displayed next to the title text:
Simply replace Icon.png with any 25x25 .png image, such as an image representing your organization

```

So far tested and verified working with:

Configuration Manager: Applications, Packages, Task Sequence (in FullOS)

Intune: -


```Text
How it works:

StartGUI.ps1 checks if it is running as the SYSTEM or user account.

If it is running as the SYSTEM account, C# code to start a process is loaded and used to start SimplePowershellGUI.ps1 as the logged in user.

If no logged in user is found, the exit code 1621 will be returned. Otherwise, it waits for the exit code from SimplePowershellGUI.ps1.

If the StartGUI.ps1 is already running as a user account, it simply starts the GUI for that same user and awaits the exit code from the GUI.

In addition, StartGUI.ps1 contains a check to use the virtual SysNative-folder if it is running in 32-bit.
```

