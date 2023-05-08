#progress text output function
if(($pwduserField.Text.Trim() -eq "") -or ($pwduserField.Text.Trim().contains("Please enter a correct username."))){
    [System.Windows.Forms.MessageBox]::Show("Please enter a correct username.")
    return
}
if(!$pwduserField.Text.Trim().EndsWith("@drewcharterschool.org") -and ($pwduserField.Text -notcontains "microsoft")){
    $pwduserField.Text = $pwduserField.Text.Trim()+"@drewcharterschool.org"
}
    loadingPeriods $pwdstatusLabel "Checking" 7
    #get lastpwset for user in field
    $expirey = Get-MSOLUser -UserPrincipalName $pwduserField.Text.Trim() | Select-Object LastPasswordChangeTimeStamp -ErrorAction Ignore

    if(!($expirey)){
        $pwdstatusLabel.Text = 'Status lookup FAILED. Unable to find user.'
        return
    }
    #compare pwdlastset plus 90 days to current date
    $pwExpired = ($expirey.LastPasswordChangeTimestamp.AddDays(90) -lt (Get-Date))
    #determine password expiration by adding 90 days to pwdlastset
    $expiresOn = $expirey.LastPasswordChangeTimestamp.AddDays(90)
    #determine days remaining by calculating the time span between pwdlastset and expiration
    $daysRemaining = (New-TimeSpan -Start (Get-Date) -End ($expirey.LastPasswordChangeTimestamp.AddDays(90))).Days

    #if already expired return 0 for days remaining
    if ($daysRemaining -le 0) {
        $daysRemaining = 0
    }
    #fail if unable to pull pwdlastset
    $pwdstatusLabel.Text = "Password last changed: " + $expirey.LastPasswordChangeTimestamp + "`r`nPassword expired: " + $pwExpired + "`r`nWill expire: " + $expiresOn + "`r`nDays remaining: " + $daysRemaining