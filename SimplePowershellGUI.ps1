param (
    #Parameters and default values
    [string]$Title = "SimpleGUI", 
    [string]$Text = "This is a default body text.", 
    
    [string]$Button1Text = "OK", 
    [int]$Button1ExitCode = 0,
    
    [bool]$Button2Enabled = $true, 
    [string]$Button2Text = "Cancel",
    [int]$Button2ExitCode = 1622,

    [bool]$CountdownEnabled = $false,
    [int]$CountdownTime = 3600
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Global:Result = 0

$Form                         = New-Object system.Windows.Forms.Form
$Form.ClientSize              = '400,200'
$Form.FormBorderStyle         = 'FixedDialog'
$Form.text                    = $Title

$Button1                      = New-Object system.Windows.Forms.Button
$Button1.text                 = $Button1Text
$Button1.width                = 100
$Button1.height               = 25
$Button1.location             = New-Object System.Drawing.Point(95,165)
$Button1.Font                 = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Regular)
$Button1.BackColor            = 'White'

$Button2                      = New-Object system.Windows.Forms.Button
$Button2.text                 = $Button2Text
$Button2.width                = 100
$Button2.height               = 25
$Button2.location             = New-Object System.Drawing.Point(205,165)
$Button2.Font                 = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Regular)
$Button2.Enabled              = $Button2Enabled
$Button2.Visible              = $Button2Enabled
$Button2.BackColor            = 'White'

$TextLabel                    = New-Object system.Windows.Forms.Label
$TextLabel.width              = 380
$TextLabel.height             = 100
$TextLabel.location           = New-Object System.Drawing.Point(10,55)
$TextLabel.Font               = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Regular)
$TextLabel.Text               = $Text

$TitleLabel                   = New-Object system.Windows.Forms.Label
$TitleLabel.width             = 200
$TitleLabel.height            = 25
$TitleLabel.location          = New-Object System.Drawing.Point(50,10)
$TitleLabel.Font              = New-Object System.Drawing.Font("Arial",14,[System.Drawing.FontStyle]::Bold)
$TitleLabel.Text              = $Title

$IconBox                      = New-Object Windows.Forms.PictureBox
$IconBox.width                = 25
$IconBox.height               = 25
$IconBox.location             = New-Object System.Drawing.Point(20,10)
$Icon                         = [system.drawing.image]::FromFile("$PSScriptRoot\Icon.png")
$IconBox.Image                = $Icon

$CountdownLabel               = New-Object system.Windows.Forms.Label
$CountdownLabel.width         = 70
$CountdownLabel.height        = 25
$CountdownLabel.location      = New-Object System.Drawing.Point(250,15)
$CountdownLabel.Font          = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Regular)
$CountdownLabel.Text          = "Countdown:"
$CountdownLabel.Enabled       = $CountdownEnabled
$CountdownLabel.Visible       = $CountdownEnabled

$CountLabel                   = New-Object system.Windows.Forms.Label
$CountLabel.width             = 70
$CountLabel.height            = 25
$CountLabel.location          = New-Object System.Drawing.Point(320,15)
$CountLabel.Font              = New-Object System.Drawing.Font("Arial",9,[System.Drawing.FontStyle]::Regular)
$CountLabel.Enabled           = $CountdownEnabled
$CountLabel.Visible           = $CountdownEnabled
$CountLabel.Text              = "00:00:00"


$Button1.Add_Click({
    $Global:Result = $Button1ExitCode
    $Form.Close()
})

$Button2.Add_Click({
    $Global:Result = $Button2ExitCode
    $Form.Close()
})


if($CountdownEnabled){
    $DueTime = (Get-Date).AddSeconds($CountdownTime)
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

$Form.controls.AddRange(@($Button1, $Button2, $TextLabel, $TitleLabel, $IconBox, $CountdownLabel, $CountLabel))
$Form.ShowDialog()
$Timer.Stop()
$Timer.Dispose()

Exit $Global:Result
