Start-Process "powercfg.exe" -WindowStyle Hidden -ArgumentList "/batteryreport /output C:\batteryreport.html" -Verb runAs
        $barLabel.Text = "Loading powercfg /batteryreport..."
        progressBar_1 1 1 20 422 $guiForm
        $barLabel.Text = "Exporting HTML to C:\..."
        progressBar_1 1 1 20 422 $guiForm
        $barLabel.Text = "Opening batteryreport.html..."
        progressBar_1 1 1 20 422 $guiForm
        $barLabel.Text = ""
        if ((Test-Path "C:\batteryreport.html") -eq $false) {
            [System.Windows.Forms.MessageBox]::Show('Battery diagnostic FAILED. The device must have a battery to run this report.')
            return
        }
        Start-Process "explorer.exe" -ArgumentList "C:\batteryreport.html"