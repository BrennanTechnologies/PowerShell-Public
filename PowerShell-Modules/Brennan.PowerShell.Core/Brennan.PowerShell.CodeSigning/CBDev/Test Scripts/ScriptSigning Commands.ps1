Get-Module Brennan-ScriptSigning -ListAvailable | Import-Module -Force


    ### Create New Signed Cert
    ###----------------------------
    $DnsName = $env:COMPUTERNAME
    $FriendlyName = "PowerShellScriptSigning"
    $CertStoreLocation = 'cert:\LocalMachine\My'
    New-ABASelfSignedCertificate -DnsName $DnsName -FriendlyName $FriendlyName -CertStoreLocation $CertStoreLocation


    ### Get DigiCert Cert
    ###----------------------------


    ### Import PFX Certificate
    ###----------------------------
    $FilePath = "C:\Users\adm-cbrennan\Documents\WindowsPowerShell\Modules\Brennan-ScriptSigning\Certs\SelfSigned.pfx"
    Import-PfxCertificate -FilePath $FilePath

    ### Get Code Signing Certs
    ###----------------------------
    $DnsName = $env:COMPUTERNAME
    $CertStoreLocation = "cert:\LocalMachine\My"
    Get-ABACodeSigningCerts -DnsName $DnsName -CertStoreLocation $CertStoreLocation

    ### Set Client Execution Policy
    ###----------------------------
    $Scope = "Process"
    $ExecutionPolicy = "AllSigned"
    Set-ClientExecutionPolicy -Scope $Scope -ExecutionPolicy $ExecutionPolicy

    ### Get Client Execution Policy
    ###----------------------------
    $Scope = "Process"
    Get-ClientExecutionPolicy -Scope $Scope
    Get-ClientExecutionPolicy -List

    ### Sign the Script
    ###----------------------------
    $ScriptFilePath = "C:\Users\adm-cbrennan\Documents\WindowsPowerShell\Modules\Brennan-ScriptSigning\Scripts\NewSignedScript.ps1"
    #C:\Users\adm-cbrennan\Documents\WindowsPowerShell\Modules\Brennan-scriptsigning\Brennan-ScriptSigning\Scripts\Chocolatey\Install-BrennanChocolateyAndPackages.ps1
    Set-ABAScriptSignature -ScriptFilePath $ScriptFilePath

    ### Get Signed Script Signature
    ###----------------------------
    Get-ABAScriptSignature -ScriptFilePath $ScriptFilePath


    ### Create a Encrypted Password File
    ###----------------------------

    ### Create a 256-bit AES Encrypted Password File
    ###----------------------------