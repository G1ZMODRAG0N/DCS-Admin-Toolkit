$mainGUIselectSSH.Add_Click({
    $sshForm.ShowDialog() | Out-Null
    Start-Process cmd.exe -Wait -Argument "/c ssh 10.120.99.10 -l netadmin"
    }
)

$mainGUIselectpwdgen.Add_Click({
    $pwdgenForm.ShowDialog() | Out-Null
}
)
$mainGUIselectpwd_ISE.Add_Click({
    Start-Process powershell_ISE.exe
}
)
$mainGUIselectAD.Add_Click({
    Start-Process dsa.msc
}
)
$pwdgenToggle.Add_Click({
    Write-Host $pwdgenToggle.BackColor
    if ($pwdgenToggle.BackColor -match 'White') {
        $pwdgenToggle.BackColor = 'Blue'
    }
    else {
        $pwdgenToggle.BackColor = 'White'
    }

})
$mainGUIselectBulkUpload.Add_Click({

    #clear previous field
    $uploadField.Text = ""
    #$pwdstatusLabel.Text = ""

    #show pwd status dialog GUI
    $uploadForm.ShowDialog() | Out-Null
}
)
$uploadCancelButton.Add_Click({
    Write-Host "words"
    $file = Import-CSV -Path $uploadOpenDialog.FileName | ConvertFrom-Csv
    Write-Output $file[0]
    #$uploadForm.Hide()
})
$uploadButton.Add_Click({

    $uploadCSV = ""

    $uploadOpenDialog.ShowDialog() | Out-Null

    if ($uploadCSV -ne "" -and $uploadCSV.FileName.EndsWith('.csv')) {
        Write-Host $uploadCSV + "NOT NULL"
        $uploadCSV = Import-Csv $uploadOpenDialog.FileName | Format-Table
        $uploadField.Text = $uploadOpenDialog.FileName
        else {
            Write-Host "THIS THANG IS NULL"
        }
    }
})
$mainGUIADsyncbutton.Add_Click({ 
    &.\scripts\run_ad_sync.ps1
    return
})
$mainGUIbattdiagbutton.Add_Click({
    &.\scripts\batt_diag.ps1
})
$cancelPWDButton.Add_Click({
    $msolPWDForm.Hide() 
})
$mainGUIpwdStatbutton.Add_Click({
    if (-not (msolConnected)) {
        try { 
            Connect-MsolService -ErrorAction Stop
        }
        catch {
            Disconnect-msolservice
        }
    }
    if (-not (msolConnected)) { return }

    #clear previous field
    $pwduserField.Text = ""
    $pwdstatusLabel.Text = ""

    #show pwd status dialog GUI
    $msolPWDForm.ShowDialog() | Out-Null
})
$checkPWDbutton.Add_Click({ &.\scripts\check_pwd.ps1 })
$UPNchangebutton.Add_Click({
    &.\scripts\change_upn.ps1
    $changeUPN
})
$checkPWDbutton.Add_Click({ &.\scripts\check_pwd.ps1 })
$UPNchangebutton.Add_Click({
    &.\scripts\change_upn.ps1
    $changeUPN
})
$UPNcancelbutton.Add_Click({$msolUPNForm.Hide()})
$mainGUIupnUpdate.Add_Click({
    #if not connected to MSOL service connect to it
    if (-not (msolConnected)) {
        try { 
            Connect-MsolService -ErrorAction Stop
        }
        catch {
            Disconnect-msolservice
        }
    }
    #if still not connect end
    if (-not (msolConnected)) { return }

    #clear previous fields
    $oldUPNfield.Text = ""
    $newUPNfield.Text = ""
    $upnValidation.Text = ""

    #show UPN dialog GUI
    $msolUPNForm.ShowDialog() | Out-Null
})
$mainGUIselectDCES.Add_Click({ addCopier "\\dces-ps01\AnyCopier" "\\10.129.100.14\AnyCopier" $barLabel })


$mainGUIselectFS.Add_Click({})

$mainGUIchangeUserbutton.Add_Click({
    if (azureadConnected) {
        #[System.Windows.Forms.MessageBox]::Show('Connected to AzureAD')
    }
    else {
        try { Connect-AzureAD } catch { return } 
    }
    #show UPN dialog GUI
    $changeUserForm.ShowDialog() | Out-Null
}
)