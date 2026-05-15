<#
.SYNOPSIS
Return all Code Signing Certs on the LocalMachine.

.DESCRIPTION
Return all Code Signing Certs on the LocalMachine.

.PARAMETER DnsName
DNS Name of thee Computer

.PARAMETER CertStoreLocations
Location of the Cert Store.

.EXAMPLE
Get-ABACodeSigningCerts -DnsName $DnsName -CertStoreLocation $CertStoreLocation

.NOTES
Returns an array of all Code Signing Certs
#>
function Get-ABACodeSigningCerts {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        [string]$DnsName = $env:COMPUTERNAME
        ,
        [Parameter(Mandatory = $False)]
        [array]$CertStoreLocations = @('cert:\LocalMachine\','cert:\CurrentUser\')
    )
    $CodeSigningCerts  =@()
    foreach($CertStoreLocation in $CertStoreLocations){
        try {
            $CodeSigningCerts += @( ((Get-ChildItem $CertStoreLocation -codesigning -Recurse) | Where {$_.Subject -match "CN=Brennan Group LLC"} | Select-Object -Property *) )
        } catch {
            Write-Warning -Message ("Error Locating Codesigning Certs on this machine. `r`n" + $global:Error[0].Exception.Message) -ErrorAction Stop
        }
    }
    if( $CodeSigningCerts.Count -eq 0 ) {
        Write-Host "No Brennan Code Signing Certs where found on this computer."
    }
    else {
        Write-Host "CodeSigning Certs: " $CodeSigningCerts
    }
    Return $CodeSigningCerts
}

