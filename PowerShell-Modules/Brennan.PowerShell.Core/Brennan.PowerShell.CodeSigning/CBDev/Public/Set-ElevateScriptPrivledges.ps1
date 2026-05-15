<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>
function Set-ElevateScriptPrivledges {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [scriptBlock]$ScriptBlock
    )
    
    ### Elevate the Script to Admin Level Privlidges to Import the Cert to "Trusted Publishers"
    ### ---------------------------------------------
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
    {
        Start-Process -FilePath C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -Verb Runas -ArgumentList "-noexit", "-noprofile", "-command &{$ScriptBlock}"
        Start-Sleep -Seconds 30
        Exit
    }
}