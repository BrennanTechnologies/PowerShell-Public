function Get-PfxCertificate{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        [string]$CertFilePath = "\\management.corp\shares\Kits\Certificates\CodeSigning\CodeSigningCert.pfx"
        ,
        [Parameter(Mandatory = $False)]
        [string]$CertStoreLocation = "Cert:\localmachine\TrustedPublisher\"
        ,
        [Parameter(Mandatory = $False)]
        [string]$CertThumbprint = "852909CCF83A2037BB1ED408B175529AE1E2662D"
        ,
        [Parameter(Mandatory = $True)]
        [System.Security.SecureString]
        $Password
    )
    ### Verify Brennan Self Signing Cert
    ###---------------------------------------
    $ABAPfxCert = (Get-ChildItem $CertStoreLocation -codesigning | Select-Object -Property * | Where-Object {$_.Thumbprint -eq $CertThumbprint})

    if($null -ne $ABAPfxCert) {
        Write-Host "The Brennan Code Signing Cert was imported." -ForegroundColor Green
        Return 0
    }
    else {
        Write-Warning -Message ("Error Finding Brennan CodeSigning Cert on this computer. `r`n" + $global:Error[0].Exception.Message) -ErrorAction Stop
        Return 1
    }
}