<#
.SYNOPSIS
Check if the script is signed.

.DESCRIPTION
Long description

.PARAMETER ScriptFileName
Check if the script is signed.

.EXAMPLE
Get-ABAScriptSignature -ScriptFilePath $ScriptFilePath

.NOTES
Returns True or False
#>
function Get-ABAScriptSignature {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [string]$ScriptFilePath
    )
    try {
        if((Get-AuthenticodeSignature -FilePath $ScriptFilePath).Status -eq 'Valid') {
            Write-Host "The script was succesfully signed." -ForegroundColor Green
            Return $true
        } 
        else {
            Write-Warning -Message ("Error Getting Authenticode Signature. `r`n" + $global:Error[0].Exception.Message) -ErrorAction Continue
            Return $false
        }
    } catch {
        Write-Warning -Message ("Error Getting Authenticode Signature. `r`n" + $global:Error[0].Exception.Message) -ErrorAction Stop
    }
}