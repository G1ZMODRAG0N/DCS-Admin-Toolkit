#-----------------------------------------------------------------------

#DREW TECHNOLOGY ADMINISTRATIVE TOOL
#Description: Tool to allow Drew technology specilists to have access to Powershell commands through a friendly interface
#Author: Elliot Hinton
#Company: Charles Drew Charter Schools
#Notes: Application generated as exe through PS2EXE module. Version information can be found on config.json.

#-----------------------------------------------------------------------
#LOAD SYSTEM FORM AND PREREQ
Add-Type -AssemblyName System.Windows.Forms

#define main gui form sizes
$formSize = '380, 500'
$buttonSizeM = '150, 40'
$buttonSizeS = '100, 30'

#Enable win10 style
[System.Windows.Forms.Application]::EnableVisualStyles()

#define path
$path = (Get-Location).Path

#load configuration file
$config = Get-Content ($path + '\config.json') | Out-String | ConvertFrom-Json

#set icon file path
$icon = ($path + "\Drew_Assist_Icon.ico")

#$versionArray = $config.version.Split(".")

#-----------------------------------------------------------------------
#FUNCTIONS

function setupEXE() {
    $path = (Get-Location).Path
    $config = Get-Content ($path + '\config.json') | Out-String | ConvertFrom-Json
    Invoke-ps2exe .\DrewTechnologyTool.ps1 .\DCSAdminTOOLKIT.exe -noconsole -version $config.version -requireAdmin -iconFile .\Drew_Assist_Icon.ico -Title "DCS Admin Toolkit" -company "Charles Drew Charter Schools" -verbose
}

#progressbar
function progressBar_1($step, $time, $x, $y, $form) {
    $progressBar_1 = New-Object System.Windows.Forms.ProgressBar -Property @{
        Location = New-Object System.Drawing.Size ($x, $y)
        Size     = '330, 15'
        Name     = 'progressBar1'
        Value    = 1
        Style    = "Blocks"
        Maximum  = 100
        Minimum  = 1
        Step     = $step
    }
    $form.Controls.Add($progressBar_1)
    $form.Controls.SetChildIndex($progressBar_1, 1)

    #loop for normal progress bar
    for ($i = 0; $i -le 100; $i++) {
        $progressBar_1.PerformStep()
        Start-Sleep -Milliseconds $time
    }
    $form.Controls.Remove($progressBar_1)
}

#progressBar_2
function progressBarModules($step, $time, $x, $y, $form, $minimum, $maximum) {
    $progressBar_2 = New-Object System.Windows.Forms.ProgressBar -Property @{
        Location = New-Object System.Drawing.Size ($x, $y)
        Size     = '330, 15'
        Name     = 'progressBar_2'
        Value    = 1
        Style    = "Blocks"
        Maximum  = $maximum
        Minimum  = $minimum
        Step     = $step
    }
    $form.Controls.Add($progressBar_2)
    $form.Controls.SetChildIndex($progressBar_2, 1)
    
    #loop for normal progress bar
    for ($i = $progressBar_2.Minimum; $i -le $progressBar_2.Maximum; $i++) {
        $progressBar_2.PerformStep()
        if ($i -lt $progressBar_2.Maximum - 30) {
            Start-Sleep -Milliseconds $time
        }
    }
    $form.Controls.Remove($progressBar_2)
}


#check if copiers are installed on client
function checkInstalledCopiers($copierhostname, $copieripadd) {
    #get instance of all currently installed copiers
    $currentCopiers = Get-CIMInstance win32_printer | Select-Object -Property Name
    #return if ip or host name are found
    return $currentCopiers.Name -contains $copierhostname -or $currentCopiers.Name -contains $copieripadd
}


#add copier to client
function addCopier($copierHost, $copierIP, $label) {

    #if host is not found end and return
    if ((checkInstalledCopiers $copierHost $copierIP) -eq $true) {
        [System.Windows.Forms.MessageBox]::Show($copierHost + ' has already been installed on this device')
        return
    }
    #host not found, add copier by host name
    add-printer -AsJob -connectionname $copierHost
    $label.Text = "Installing " + $copierHost + "..."
    progressBar_1 2 20 20 422 $guiForm
    #sleep timers are to give time for installation
    Start-Sleep -s 2

    #if host installation failed attempt install by ip address
    if ((checkInstalledCopiers $copierHost $copierIP) -eq $false) {
        $label.Text = "Unable to locate copier by hostname. Trying IP..."
        progressBar_1 2 10 20 422 $guiForm
        Start-Sleep -s 1
        add-printer -AsJob -connectionname $copierIP
        $label.Text = "Installing " + $copierIP + "..."
        progressBar_1 2 20 20 422 $guiForm
        Start-Sleep -s 3
    }

    #last check for copier installation
    if ((checkInstalledCopiers $copierHost $copierIP) -eq $false) {
        [System.Windows.Forms.MessageBox]::Show('Installation FAILED. Please ensure that the IP/HOSTNAME is reachable from this device.')
        $label.Text = ""
        return
    }
    [System.Windows.Forms.MessageBox]::Show($copierHost + ' added!')
    $label.Text = ""
}


#check if conencted to msol service
function msolConnected {
    #if able to see domain return result as success or error
    Get-msolDomain -ErrorAction SilentlyContinue | out-null
    $result = $?
    return $result
}

#check if conencted to azuread service
function azureadConnected {
    #if able to see domain return result as success or error
    try { Get-azureADDomain -ErrorAction SilentlyContinue | out-null }catch {}
    $result = $?
    return $result
}

function Disconnect-msolservice {
    [Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()
}

function loadingPeriods($label, $prefix, $count) {
    $label.Text = "."
    $periods = @()
    $period = "."
    for ($i = 0; $i -lt $count; $i++) {
        $periods += $period
        $label.Text = $periods
        Start-Sleep -Milliseconds 400
    }
}

function buttonTemplate($Location,$Text) {
    $buttonTemplate = @{
    FlatStyle = "Flat"
    Size      = $buttonSizeM
    BackColor = [System.Drawing.Color]::FromName("White")
    Location = $Location
    Text = $Text
}
return New-Object System.Windows.Forms.Button -Property $buttonTemplate
}

#-----------------------------------------------------------------------
#FORMS

#Startup module installation form
$startupForm = New-Object System.Windows.Forms.Form -Property @{
    Cursor          = [System.Windows.Forms.Cursor]::Wait
    Text            = "DCS Admin Toolkit"
    Size            = '400, 100'
    StartPosition   = "CenterScreen"
    FormBorderStyle = "1"
    MaximizeBox     = $false
    Icon            = $icon
}

#Main GUI form
$guiForm = New-Object System.Windows.Forms.Form -Property @{
    Text            = "DCS Admin Toolkit"
    Cursor          = [System.Windows.Forms.Cursor]::Arrow
    Size            = $formSize
    StartPosition   = "CenterScreen"
    FormBorderStyle = "1"
    MaximizeBox     = $false
    BackColor       = [System.Drawing.Color]::FromName("seagreen")
    Icon            = $icon
}

#UserPrincipalName change form
$msolUPNForm = New-Object System.Windows.Forms.Form -Property @{
    Text          = "Change UserPrincipalName"
    Size          = '400, 250'
    StartPosition = "CenterScreen"
    MaximizeBox   = $false
    Icon          = $icon
}

#Password generator form
$pwdgenForm = New-Object System.Windows.Forms.Form -Property @{
    Text            = "Password Generator - PwPosh"
    Size            = '400, 550'
    StartPosition   = "CenterScreen"
    FormBorderStyle = "1"
    MaximizeBox     = $false
    Icon            = $icon
}

#Check password status form
$msolPWDForm = New-Object System.Windows.Forms.Form -Property @{
    Text            = "User Password Status"
    Size            = '400, 250'
    StartPosition   = "CenterScreen"
    FormBorderStyle = "1"
    MaximizeBox     = $false
    Icon            = $icon
}

#Change primary device user form
$changeUserForm = New-Object System.Windows.Forms.Form -Property @{
    Text            = "Change Primary User"
    Size            = '400, 250'
    StartPosition   = "CenterScreen"
    FormBorderStyle = "1"
    MaximizeBox     = $false
    Icon            = $icon
}

#Bulk upload users to AD via csv form
$uploadForm = New-Object System.Windows.Forms.Form -Property @{
    Text            = "Bulk Upload Users"
    Size            = '400, 250'
    StartPosition   = "CenterScreen"
    FormBorderStyle = "1"
    MaximizeBox     = $false
    Icon            = $icon
}

#
#SSH Form
$sshForm = New-Object System.Windows.Forms.Form -Property @{
    Text            = "SSH into Appliance"
    Size            = '400, 250'
    StartPosition   = "CenterScreen"
    FormBorderStyle = "1"
    MaximizeBox     = $false
    Icon            = $icon
}

#-----------------------------------------------------------------------
#LABELS

#Module install form Label
$mainGUIloadingLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '-10, 0'
    Size      = '400, 30'
    TextAlign = "MiddleCenter"
}

#Main GUI Title Label
$mainGUItitleLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '-8, -40'
    Size      = '390, 100'
    Text      = "DCS Admin Toolkit"
    TextAlign = "BottomCenter"
    BackColor = [System.Drawing.Color]::FromName("darkseagreen")
    ForeColor = "white"
    Font      = [System.Drawing.Font]::new("Calibri", 32, [System.Drawing.FontStyle]::Bold)
}

#Main GUI Footer Label
$mainGUIfooterLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '0, 390'
    Size      = '380, 90'
    Text      = ""
    BackColor = [System.Drawing.Color]::FromName("darkseagreen")
}

#Main GUI version Label
$mainGUIversionLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '260, 445'
    Size      = '130, 20'
    Text      = "v" + $config.version + " by " + $config.author
    TextAlign = "TopLeft"
    BackColor = [System.Drawing.Color]::FromName("darkseagreen")
    ForeColor = "White"
}

#Main GUI progress bar feedback label
$mainGUIbarLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '20, 400'
    Size      = '380, 16'
    Text      = ""
    TextAlign = "TopLeft"
    BackColor = [System.Drawing.Color]::FromName("darkseagreen")
    ForeColor = "White"
}

#Main GUI progress bar outline label
$mainGUIbaroutlineLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '17, 420'
    Size      = '337, 20'
    Text      = ""
    BackColor = [System.Drawing.Color]::FromName("Mediumdarkgoldenrod")
}

#UPN change form Label old upn
$oldUPNLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '10, 20'
    Size      = '130, 20'
    Text      = "Old UserPrincipalName:"
    TextAlign = "TopLeft"
}

#UPN change form Label new upn
$newUPNLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '10, 80'
    Size      = '150, 20'
    Text      = "New UserPrincipalName:"
    TextAlign = "TopLeft"
}

#UPN change form Label validation of old upn
$upnValidation = New-Object System.Windows.Forms.Label -Property @{
    Location  = '80, 43'
    Size      = '120, 30'
    TextAlign = "TopLeft"
    Text      = ""
    ForeColor = [System.Drawing.Color]::FromName("Green")
}

#pwd status form Label
$pwdformLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '10, 10'
    Size      = '400, 20'
    Text      = "Input user UPN to check current password status."
    TextAlign = "TopLeft"
}

#pwd status form Label 2
$pwdstatusLabel = New-Object System.Windows.Forms.Label -Property @{
    Location    = '10, 60'
    Size        = '360, 70'
    Text        = ""
    BorderStyle = "Fixed3D"
    TextAlign   = "TopLeft"
    Font        = [System.Drawing.Font]::new("Ariel", 8, [System.Drawing.FontStyle]::Italic)
    ForeColor   = [System.Drawing.Color]::FromArgb(255, 255, 255)
    BackColor   = [System.Drawing.Color]::FromArgb(20, 20, 20)
}

#Change primary user form Label
$deviceIDLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '10, 20'
    Size      = '130, 20'
    Text      = "Device Object ID:"
    TextAlign = "TopLeft"
}

#Change primary user form Label
$primaryUserLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '10, 80'
    Size      = '50, 20'
    Text      = "New primary user(uPN):"
    TextAlign = "TopLeft"
}

#pwdgenLabel
$pwdgenLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '20, 20'
    Size      = '360, 20'
    Text      = "Enter the password to be generated"
    TextAlign = "TopLeft"
}

#pwdgenLabel txt count
$pwdgentxtLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = '260, 155'
    Size      = '150, 20'
    Text      = "0/22 characters"
    ForeColor = 'Red'
    TextAlign = "TopLeft"
}

#-----------------------------------------------------------------------
#FIELDS

#old UPN field
$oldUPNfield = New-Object System.Windows.Forms.TextBox -Property @{
    Location = New-Object System.Drawing.Point(10, 40)
    Size     = New-Object System.Drawing.Size(260, 20)
}

#old UPN field check; on key press check if input matches domain
$oldUPNfield.Add_KeyDown({
        if ($oldUPNfield.Text.Trim() -match "^[a-z]*\.[a-z]*\@DREWCHARTERSCHOOL.onmicrosoft.co$") {
            $upnValidation.Text = "VALID"
            $upnValidation.ForeColor = [System.Drawing.Color]::FromName("Green")
            return
        }
        #check UPN by domain regex
        if ($oldUPNfield.Text.Trim() -notmatch "^[a-z]*\.[a-z]*\@drewcharterschoo(l|ls)\.or$") {
            $upnValidation.Text = "INVALID"
            $upnValidation.ForeColor = [System.Drawing.Color]::FromName("Red")
        }
        elseif ((Get-MSOLUser -UserPrincipalName ($oldUPNfield.Text.Trim() + "g")) -ne $null) {
            $upnValidation.Text = "VALID"
            $upnValidation.ForeColor = [System.Drawing.Color]::FromName("Green")
        }
        else {
            $upnValidation.Text = ""
            $upnValidation.ForeColor = [System.Drawing.Color]::FromName("Red")
        }

    })

#new UPN field
$newUPNfield = New-Object System.Windows.Forms.TextBox -Property @{
    Location = '10, 100'
    Size     = '260, 20'
}

#pwd status user field
$pwduserField = New-Object System.Windows.Forms.TextBox -Property @{
    Location = '10, 30'
    Size     = '260, 20'
}
$pwduserField.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { &.\scripts\check_pwd.ps1 } })

#bulk upload file path field
$uploadField = New-Object System.Windows.Forms.TextBox -Property @{
    Location = '30, 35'
    Size     = '220, 20'
}

#deviceID field
$deviceIDField = New-Object System.Windows.Forms.TextBox -Property @{
    Location = '10, 40'
    Size     = '60, 20'
}

#primaryUser field
$primaryUserField = New-Object System.Windows.Forms.TextBox -Property @{
    Location = '10, 100'
    Size     = '260, 20'
}

#pwdgen field
$pwdgenField = New-Object System.Windows.Forms.TextBox -Property @{
    Location  = '40, 100'
    Size      = '300, 50'
    Text      = "Manually enter a password to be published and shared..."
    Multiline = $true
    MaxLength = 22
    ForeColor = [System.Drawing.Color]::FromName("Gray")
    TextAlign = "Center"
}
$pwdgenField.Add_Click( {
        if ($pwdgenField.Text -match "Manually") {
            $this.Text = ""
            $this.TextAlign = "Left"
            $this.ForeColor = [System.Drawing.Color]::FromName("Black")
            $this.Focus() 
        }
    })
$pwdgenField.Add_Keypress({
        $pwdgentxtLabel.Text = $this.Text.Length.ToString() + "/" + $this.MaxLength.ToString() + " characters"
        if ($this.Text.Length -ge 8) { 
            $pwdgentxtLabel.ForeColor = 'Green' 
        }
        else {
            $pwdgentxtLabel.ForeColor = 'Red'  
        }
    })

#$pwdgenField.Add_LostFocus({
#if($this.Text.Length -eq 0){
#$this.Text = "Manually enter a password to be published and shared..."
#$this.ForeColor = [System.Drawing.Color]::FromName("Gray")
#$this.TextAlign = "Center"
#$this.ResetCursor()
#}
#})
#-----------------------------------------------------------------------
#OPEN FILE DIALOGS

#upload open path dialog
$uploadOpenDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
    Filter           = 'CSV File (*.csv)|*.csv|All files (*.*)|*.*'
}

#-----------------------------------------------------------------------
#STARTUP : LOAD MODULES
$modules = Get-ChildItem -Path .\modules\ -Director
$startupForm.Controls.Add($mainGUIloadingLabel)
$startupForm.Show() | Out-Null

foreach ($module in $modules) {
    $mainGUIloadingLabel.Text = "Importing powershell module...\" + $module.Name + "..."
    progressBarModules 10 1 30 40 $startupForm 1 70
    $modulePath = $module.FullName
    Import-Module -Name $modulePath -Force
}
$mainGUIloadingLabel.Text = "Loading interfaces...."
progressBarModules 4 1 30 40 $startupForm 1 70
$startupForm.Hide()

#-----------------------------------------------------------------------
#BUTTONS : MAIN GUI (general buttons)
#-----------------------------------------------------------------------
#SSH button
$mainGUIselectSSH = (buttonTemplate "10,80" "SSH to Appliance")
#PWD GEN
$mainGUIselectpwdgen = (buttonTemplate  "10,130" "Password Generator WIP")
#PWRSHELL
$mainGUIselectpwd_ISE = (buttonTemplate "10,180" "PowerShell ISE")
#AD button
$mainGUIselectAD = (buttonTemplate "10,230" "Active Directory")
#Bulk upload users button
$mainGUIselectBulkUpload = (buttonTemplate "200,180" "Bulk Upload to AD WIP")
#DCES AnyCopier button
$mainGUIselectDCES = (buttonTemplate "200,80" "Install DCES-PS01/AnyCopier")
#Add FS01 AnyCopier button
$mainGUIselectFS =(buttonTemplate "200,130" "-")
#Change primary user on device button
$mainGUIchangeUserbutton =  (buttonTemplate "10,280" "Change Primary User WIP")

#-----------------------------------------------------------------------



#PWD TOGGLE BUTTON
$pwdgenToggle = New-Object System.Windows.Forms.Button -Property @{
    Location  = '50,30'
    Size      = '20,20'
    BackColor = 'White'
}


#-----------------------------------------------------------------------
#Bulk Upload Button





#Cancel bulk upload button
$uploadCancelButton = New-Object System.Windows.Forms.Button -Property @{
    FlatStyle = "Flat"
    Size      = $buttonSizeM
    Text      = 'Cancel'
    Location  = '215,150'
    BackColor = [System.Drawing.Color]::FromName("White")
}


#open file bulk upload button
$uploadButton = New-Object System.Windows.Forms.Button -Property @{
    FlatStyle = "Flat"
    Size      = $buttonSizeS
    Text      = 'Open'
    Location  = '260,30'
}


#-----------------------------------------------------------------------



#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
#Change Primary User button


#-----------------------------------------------------------------------
#AD SYNC button
$mainGUIADsyncbutton = New-Object System.Windows.Forms.Button -Property @{
    FlatStyle = "Flat"
    Size      = $buttonSizeM
    Text      = 'Sync AD Connector'
    Location  = '200,230'
    BackColor = [System.Drawing.Color]::FromName("White")
}

#-----------------------------------------------------------------------
#BATT DIAG button

$mainGUIbattdiagbutton = New-Object System.Windows.Forms.Button -Property @{
    FlatStyle = "Flat"
    Size      = $buttonSizeM
    Text      = 'Battery Diagnostics'
    Location  = '10,330'
    BackColor = [System.Drawing.Color]::FromName("White")
}



#-----------------------------------------------------------------------
#CHECK PWD button

#Check user pwd status button
$mainGUIpwdStatbutton = New-Object System.Windows.Forms.Button -Property @{
    FlatStyle = "Flat"
    Size      = $buttonSizeM
    Text      = 'Check user password status'
    Location  = '200,330'
    BackColor = [System.Drawing.Color]::FromName("White")
}


#Cancelpwd status button
$cancelPWDButton = New-Object System.Windows.Forms.Button -Property @{
    FlatStyle = "Flat"
    Size      = $buttonSizeM
    Text      = 'Close'
    Location  = '215,150'
    BackColor = [System.Drawing.Color]::FromName("White")
}


#Check button
$checkPWDbutton = New-Object System.Windows.Forms.Button -Property @{
    FlatStyle = "Flat"
    Size      = $buttonSizeM
    Text      = 'Check password status'
    Location  = '30,150'
}




#?????????????????


#Change UPN button
$UPNchangebutton = New-Object System.Windows.Forms.Button -Property @{
    FlatStyle = "Flat"
    Size      = $buttonSizeM
    Text      = 'Change'
    Location  = '30,150'
}



$changeUPN = {}

#CancelUPN button
$UPNcancelbutton = New-Object System.Windows.Forms.Button -Property @{
    FlatStyle = "Flat"
    Size      = $buttonSizeM
    Text      = 'Cancel'
    Location  = '215,150'
}



#-----------------------------------------------------------------------
#UPN button main GUI
$mainGUIupnUpdate = New-Object System.Windows.Forms.Button -Property @{
    FlatStyle = "Flat"
    Size      = $buttonSizeM
    Text      = 'Update User UPN'
    Location  = '200,280'
    BackColor = [System.Drawing.Color]::FromName("White")
}

&.\scripts\add_clicks.ps1
#-----------------------------------------------------------------------
#FORM CONTROL ADDS
#identify form objects
$mainGUIControls = Get-Variable | Where-Object { ($_.Value -match "System.Windows.Forms.Button") -or ($_.Value -match "System.Windows.Forms.Label") -or ($_.Value -match "System.Windows.Forms.Label")}
#$formNames = $mainGUIControls.Name

$mainGUIControls.Name | ForEach-Object {
    if ($_ -match "mainGUI") {
        $guiForm.Controls.Add((Get-Variable $_).Value)
        Write-Host "Loading..."(Get-Variable $_).Value
    }
}

<#
#all main gui form elements through a loop
for ($i = 0; $i -lt $formNames.Length; $i++) {
    $formToAdd = Get-Variable $formNames[$i]
    try { $guiForm.Controls.Add($formToAdd.value) }catch { "err" }
    #Write-Host "Loading..."$guiForm "-"$formNames[$i]
}
#>

$guiForm.Controls.SetChildIndex($mainGUIbaroutlineLabel, 1)
$guiForm.Controls.SetChildIndex($mainGUIfooterLabel, -1)
$guiForm.Controls.SetChildIndex($mainGUItitleLabel, 1)

<#
$msolUPNForm.Controls.Add($UPNchangebutton)
$msolUPNForm.Controls.Add($UPNcancelbutton)
$msolUPNForm.Controls.Add($oldUPNfield)
$msolUPNForm.Controls.Add($newUPNfield)
$msolUPNForm.Controls.Add($oldUPNLabel)
$msolUPNForm.Controls.Add($newUPNLabel)
$msolUPNForm.Controls.Add($upnValidation)

$msolPWDForm.Controls.Add($pwduserField)
$msolPWDForm.Controls.Add($pwdformLabel)

$msolPWDForm.Controls.Add($checkPWDbutton)
$msolPWDForm.Controls.Add($cancelPWDButton)
$msolPWDForm.Controls.Add($pwdstatusLabel)

$changeUserForm.Controls.Add($deviceIDLabel)
$changeUserForm.Controls.Add($primaryUserLabel)
$changeUserForm.Controls.Add($deviceIDField)
$changeUserForm.Controls.Add($primaryUserField)

$uploadForm.Controls.Add($uploadField)
##$uploadForm.Controls.Add($uploadOpenDialog)
$uploadForm.Controls.Add($uploadCancelButton)
$uploadForm.Controls.Add($uploadButton)

$pwdgenForm.Controls.Add($pwdgenLabel)
$pwdgenForm.Controls.Add($pwdgenToggle)
$pwdgenForm.Controls.Add($pwdgenToggle)
$pwdgenForm.Controls.Add($pwdgenField)
$pwdgenForm.Controls.Add($pwdgentxtLabel)
#>
#-----------------------------------------------------------------------

#GUI START
$guiForm.ShowDialog() | Out-Null