<#
.SYNOPSIS
Creates a New Self-Signed Cert.

.DESCRIPTION
Creates a New Self-Signed Cert.

.PARAMETER DnsName
DNS Name of the Compuer

.PARAMETER FriendlyName
Friendly Name for the Cert.

.PARAMETER CertStoreLocation
Cert Store Location.

.EXAMPLE
New-ABASelfSignedCertificate -DnsName $DnsName -FriendlyName $FriendlyName -CertStoreLocation $CertStoreLocation

.NOTES
Returns 0 (success) or 1 (error)
#>
function New-ABASelfSignedCertificate {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        [string]$DnsName = $env:COMPUTERNAME
        ,
        [Parameter(Mandatory = $False)]
        [string]$FriendlyName = "PowerShellScriptSelfSigning"
        ,
        [Parameter(Mandatory = $False)]
        [string]$CertStoreLocation = 'cert:\LocalMachine\My'
    )
    try {
        New-SelfSignedCertificate -DnsName $DnsName -CertStoreLocation $CertStoreLocation -FriendlyName $FriendlyName -KeyFriendlyName $FriendlyName -Type CodeSigningCert
        if (((Get-ChildItem $CertStoreLocation -codesigning | Where-Object {$_.Subject -eq "CN=$DnsName"}).Subject).Split("=")[1] -eq $DnsName ) {
            Write-Host "The Self-Signed Cert was created." -ForegroundColor Green
            Return 0
        } 
        else {
            Write-Warning -Message ("Error Finding New Self Signed Cert. `r`n" + $global:Error[0].Exception.Message) -ErrorAction Continue
            Return 1
        }
    } catch {
        Write-Warning -Message ("Error Creating New Self Signed Cert. `r`n" + $global:Error[0].Exception.Message) -ErrorAction Stop
    }
}