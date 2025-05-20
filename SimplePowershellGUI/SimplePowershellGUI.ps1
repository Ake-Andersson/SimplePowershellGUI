#===============================================================================================
#This script is a GUI, meant to be called from the StartGUI.ps1 script
#
#Modify the below parameters to suit your needs. You can use `n for linebreaks in the body text.
#
#Visit the github for more information:
#https://github.com/Ake-Andersson/SimplePowershellGUI
#===============================================================================================

param (
    #===============================Parameters and default values===============================

    #The title of the window and the body text it should display
    [string]$Title = "SimplePowershellGUI", 
    [string]$Text = "This is a default body text.`n`nWith some more text on a new line.", 
    
    #The text on the first button and what exit code it should return
    [string]$Button1Text = "OK", 
    [int]$Button1ExitCode = 0,
    
    #If the 2nd button should be enabled, and if so what it should say and what exit code it should return
    [switch]$Button2Enabled = $false, 
    [string]$Button2Text = "Cancel",
    [int]$Button2ExitCode = 1602,

    #If the countdown should enabled, and how long in seconds it should be
    [switch]$CountdownEnabled = $true,
    [int]$CountdownTime = 3600,

    #The exit code returned if the user closes the dialog (with the X-button or through task manager or similar)
    [int]$DefaultExitCode = 1602,

    #If the dialog should always be on top and if the close (corner X-button) and minimize should be enabled
    [switch]$AlwaysOnTop = $true,
    [switch]$ShowMinimizeAndClose = $false
    
    #==============================Modify according to your needs===============================
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()


$Global:Result = $DefaultExitCode

$Form                         = New-Object system.Windows.Forms.Form
$Form.ClientSize              = '500,250'
$Form.FormBorderStyle         = 'FixedDialog'
$Form.text                    = $Title
$Form.MaximizeBox             = $False
$Form.ControlBox              = $ShowMinimizeAndClose

$Button1                      = New-Object system.Windows.Forms.Button
$Button1.text                 = $Button1Text
$Button1.width                = 100
$Button1.height               = 25
$Button1.location             = New-Object System.Drawing.Point(145,215)
$Button1.Font                 = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Regular)
$Button1.BackColor            = 'White'

#Center button1 if button2 is disabled
if(!$Button2Enabled){
    $Button1.location = New-Object System.Drawing.Point(200,215)
}

$Button2                      = New-Object system.Windows.Forms.Button
$Button2.text                 = $Button2Text
$Button2.width                = 100
$Button2.height               = 25
$Button2.location             = New-Object System.Drawing.Point(255,215)
$Button2.Font                 = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Regular)
$Button2.Enabled              = $Button2Enabled
$Button2.Visible              = $Button2Enabled
$Button2.BackColor            = 'White'

$TextLabel                    = New-Object system.Windows.Forms.Label
$TextLabel.width              = 480
$TextLabel.height             = 140
$TextLabel.location           = New-Object System.Drawing.Point(10,55)
$TextLabel.Font               = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Regular)
$Text = $Text.Replace('`n', "`n") #This is for some reason necessary to parse newlines from CMD
$TextLabel.Text               = $Text

<#
$NonInteractive = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonI*' }
if ([Environment]::UserInteractive -and -not $NonInteractive) {
    #Session is interactive
    Write-Host "SimplePowershellGUI.ps1 is running in interactive shell"
    $TextLabel.Text = "Running in interactive shell"
}else{
Write-Host "SimplePowershellGUI.ps1 is running in non-interactive shell"
    $TextLabel.Text = "Running in non-interactive shell"
}
#>

$TitleLabel                   = New-Object system.Windows.Forms.Label
$TitleLabel.width             = 400
$TitleLabel.height            = 25
$TitleLabel.location          = New-Object System.Drawing.Point(50,10)
$TitleLabel.Font              = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::Bold)
$TitleLabel.Text              = $Title

$IconBox                      = New-Object Windows.Forms.PictureBox
$IconBox.width                = 25
$IconBox.height               = 25
$IconBox.location             = New-Object System.Drawing.Point(20,10)
$Icon                         = [system.drawing.image]::FromFile("$($PSScriptRoot)\Icon.png")
$IconBox.Image                = $Icon

$CountdownLabel               = New-Object system.Windows.Forms.Label
$CountdownLabel.width         = 70
$CountdownLabel.height        = 25
$CountdownLabel.location      = New-Object System.Drawing.Point(350,15)
$CountdownLabel.Font          = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Regular)
$CountdownLabel.Text          = "Countdown:"
$CountdownLabel.Enabled       = $CountdownEnabled
$CountdownLabel.Visible       = $CountdownEnabled

$CountLabel                   = New-Object system.Windows.Forms.Label
$CountLabel.width             = 70
$CountLabel.height            = 25
$CountLabel.location          = New-Object System.Drawing.Point(420,15)
$CountLabel.Font              = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Regular)
$CountLabel.Enabled           = $CountdownEnabled
$CountLabel.Visible           = $CountdownEnabled
$DueTime                      = (Get-Date).AddSeconds($CountdownTime)
$CountLabel.Text              = $CountLabel.Text = "{0:hh}:{0:mm}:{0:ss}" -f ($DueTime - (Get-Date))


$Button1.Add_Click({
    $Global:Result = $Button1ExitCode
    $Form.Close()
})

$Button2.Add_Click({
    $Global:Result = $Button2ExitCode
    $Form.Close()
})


if($CountdownEnabled){
    $Timer = New-Object System.Windows.Forms.Timer
    $Timer.Interval = 1000 
    $Timer.add_Tick({
        $CountLabel.Text = "{0:hh}:{0:mm}:{0:ss}" -f ($DueTime - (Get-Date))
        
        if((Get-Date) -ge $DueTime){ #exit if timer has expired
            $Global:Result = $Button1ExitCode
            $Form.Close()
        }
    })

    $Timer.Start()
}

$Form.controls.AddRange(@($Button1, $Button2, $TextLabel, $CountdownLabel, $CountLabel, $TitleLabel, $IconBox))
$Form.TopMost = $AlwaysOnTop
$Form.ShowDialog() | Out-Null

if($CountdownEnabled){
    $Timer.Stop()
    $Timer.Dispose()

}


Exit $Global:Result
