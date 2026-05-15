<#
.SYNOPSIS
Sets the Execution Policy and Scope on the Local Client Machine.

.DESCRIPTION
Sets the Execution Policy and Scope on the Local Client Machine.

.PARAMETER Scope
Scope of the Execution Policy.

.PARAMETER ExecutionPolicy
One of the Execution Policies.

.EXAMPLE
Set-ABAClientExecutionPolicy -Scope $Scope -ExecutionPolicy $ExecutionPolicy

.NOTES
Returns 0 (success) or 1 (error)

    NOTE:
        - By default the Windows 10 client ExecutionPolicy is set to "Restricted".
        - By default Windowes Server ExecutionPolicy is set to "RemoteSigtned".

    Example:
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy AllSigned
        - This command will set the ExecutionPolicy to "AllSigned" ONLY for the scope "Process" (which is the current PowerShell session or script).

    EXECUTION POLICY:
    ================
    Level of Restriction  ExecutionPolicy  Notes
    --------------------  ---------------  ------
    Highest  |            Restricted       <-- Doesn't load configuration files or run scripts. *** The default execution policy Windows client computers. ***
             |            AllSigned        <-- Requires that all scripts and configuration files are signed by a trusted publisher, including scripts written on the local computer.
             |            RemoteSigned     <-- Requires that all scripts and configuration files downloaded from the Internet are signed by a trusted publisher. *** The default execution policy for Windows server computers. ***
             |            Unrestricted     <-- Loads all configuration files and runs all scripts. If you run an unsigned script that was downloaded from the internet, you're prompted for permission before it runs.
    Lowest   v            ByPass           <-- Nothing is blocked and there are no warnings or prompts.
            ---
                          Undefined        <-- Removes an assigned execution policy from a scope that is not set by a Group Policy
                          Default          <-- Sets the default execution policy. Restricted for Windows clients or RemoteSigned for Windows servers.

    EXECUTION POLICY SCOPE:
    ======================
    Order of Precedence   Scope           ExecutionPolicy   Notes
    -------------------   -----           ---------------   -----
    Highest  |            MachinePolicy   Undefined         <-- Set in GPO. Set by a Group Policy for all users of the computer.
             |            UserPolicy      Undefined         <-- Set in GPO. Set by a Group Policy for the current user of the computer.
             |            Process         AllSigned         <-- Current Session. Affects only the current PowerShell session.
             |            CurrentUser     AllSigned         <-- Affects only the current user.
    Lowest   v            LocalMachine    AllSigned         <-- Default scope that affects all users of the computer.
            ---


    Unblock-File
    ============
    - Unblock a script to run it without changing the execution policy.
    - The Unblock-File cmdlet unblocks scripts so they can run, but doesn't change the execution policy.
    
    Example:
    Unblock-File -Path .\Start-ActivityTracker.ps1

#>
function Set-ClientExecutionPolicy {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        [string]$Scope = "Process"
        ,
        [Parameter(Mandatory = $False)]
        [string]$ExecutionPolicy = "AllSigned"
    )
    try {
        Set-ExecutionPolicy -Scope $Scope -ExecutionPolicy $ExecutionPolicy -Force
        if( (Get-ExecutionPolicy -Scope $Scope) -eq $ExecutionPolicy  ) {
            Write-Host "The ExecutionPolicy was Set to $ExecutionPolicy for scope $Scope." -ForegroundColor Green
            Return 0
        } 
        else {
            Write-Warning -Message ("Error Getting ExecutionPolicy $ExecutionPolicy for scope $Scope. `r`n" + $global:Error[0].Exception.Message) -ErrorAction Stop
            Return 1
        }
    } catch {
        Write-Warning -Message ("Error Setting Execution Policy. `r`n" + $global:Error[0].Exception.Message) -ErrorAction Stop
    }
}