<#
.SYNOPSIS
Gets the current Execution Policies and Scopes.

.DESCRIPTION
Gets the current Execution Policies and Scopes.

.PARAMETER List
[switch] Returns Policies for all Scopes.

.PARAMETER Scope
[string] Retruns the Policy for a specific Scope.

.EXAMPLE
    Get-ABAClientExecutionPolicy -Scope $Scope
    Get-ABAClientExecutionPolicy -List

.NOTES
Return $ExecutionPolicy
#>
function Get-ClientExecutionPolicy {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [switch]$List
        ,
        [Parameter(Mandatory = $False)]
        [string]$Scope
    )
    try {
        if($List) {
            $ExecutionPolicy = Get-ExecutionPolicy -List
        } 
        if($Scope) {
            $ExecutionPolicy = Get-ExecutionPolicy -Scope $Scope
        }
    } catch {
        Write-Warning -Message ("Error Getting Execution Policy. `r`n" + $global:Error[0].Exception.Message) -ErrorAction Stop
    }
    Return $ExecutionPolicy
}