        #attempt to ping sync server
        $barLabel.Text = "Attempting to reach server..."
        progressBar_1 1 2 20 422 $guiForm
        if ((Test-Connection 10.120.98.24 -Count 1) -eq $null) {
            $barLabel.Text = ""
            return
        }
    

        #Input admin Credential
        $credentials = Get-Credential -Message "Administrative credential required to connect to remote server \\dchs-adsync." -UserName dchs\$env:UserName
        if ($credentials -eq $null) {
            $barLabel.Text = ""
            return
        }

        #Test if WIRM is installed
        if ((Test-WSMan -ComputerName localhost) -eq $null) {
            Enable-PSRemoting -SkipNetworkProfileCheck -Force
        }
        #Add WIRM trusted host
        if ((Get-Item WSMan:\localhost\Client\TrustedHosts | Where-Object -Property Value -match 10.120.98.24) -eq $null) {
            Set-Item WSMan:localhost\client\trustedhosts -value 10.120.98.24 -Force
        }
        #Restore listener configuration
        #winrm invoke Restore winrm/Config
        #winrm quickconfig

        try {
            #invoke psremote command to adsync server
            $startSync = (Invoke-Command -ComputerName 10.120.98.24 -Credential $credentials -ScriptBlock { Start-ADSyncSyncCycle -PolicyType delta })
            $barLabel.Text = "Invoking remote command to dchs-adsync..."
            progressBar_1 1 2 20 422 $guiForm
            $barLabel.Text = "Sending ADSyncCycle command..."
            progressBar_1 1 2 20 422 $guiForm
            $barLabel.Text = ""
            #return if sync fails
            if ($startSync -eq $null) {
                [System.Windows.Forms.MessageBox]::Show('AD Connect Synchronization failed.')
                $barLabel.Text = ""
                return
            }
            else {
                [System.Windows.Forms.MessageBox]::Show('AD Sync successful! Please allow up to 2 minutes for the sync to propagate.')
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show('Connecting to remote server 10.120.98.24 failed.')
            $barLabel.Text = ""
            return
        }
        $barLabel.Text = ""