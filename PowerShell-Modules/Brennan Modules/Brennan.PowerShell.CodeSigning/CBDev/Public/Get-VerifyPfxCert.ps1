    <#
    ### Verify Cert
    ###---------------------------------------
    $ABAPfxCert = (Get-ChildItem $CertStoreLocation -codesigning | Select-Object -Property * | Where-Object {$_.Thumbprint -eq $CertThumbprint})

    if($null -ne $ABAPfxCert) {
        Write-Host "The Brennan Code Signing Cert is present on this computer." -ForegroundColor Green
        Return 0
    } else {
        #Write-Warning -Message ("Error Finding Brennan CodeSigning Cert on this computer. `r`n" + $global:Error[0].Exception.Message) -ErrorAction Stop
        Write-Warning -Message "Error Finding Brennan CodeSigning Cert on this computer. `r`n" -ErrorAction Stop
        Return 1
    }
#>