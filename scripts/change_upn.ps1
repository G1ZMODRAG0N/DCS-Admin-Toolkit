$oldUPN = $oldUPNfield.Text.Trim()
        $newUPN = $newUPNfield.Text.Trim()
        $regex = "(^[a-z]*\.[a-z]*\@drewcharterschoo(l|ls)\.org$|^[a-z]*\.[a-z]*\@DREWCHARTERSCHOOL.onmicrosoft.com$)"
        if (($oldUPN -notmatch $regex) -or ($newUPN -notmatch $regex)) {
            [System.Windows.Forms.MessageBox]::Show('Please complete both fields to change UPN.')
            return
        }
        elseif ((Get-MSOLUser -UserPrincipalName $oldUPN) -eq $null) {
            [System.Windows.Forms.MessageBox]::Show('UserPrincipalName change FAILED. Unable to locate user "' + $oldUPN + '"')
            return
        }
        else {
            Set-msolUserPrincipalName -UserPrincipalName $oldUPN -NewUserPrincipalName $newUPN
            Start-Sleep -Milliseconds 100
            [System.Windows.Forms.MessageBox]::Show('UserPrincipalName "' + $oldUPN + '" was succesfully changed to "' + $newUPN + '" Please allow up to 5 minutes for the change to be reflected.')
            $msolUPNForm.Hide() 
        }