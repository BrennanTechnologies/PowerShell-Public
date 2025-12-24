<#
.SYNOPSIS
Update ServerRequest table in the VMDeploy database.

.DESCRIPTION
Update ServerRequest table in the VMDeploy database.

.PARAMETER RequestID
Primary key of ServerRequest.

.PARAMETER Status
Job Status

.EXAMPLE
    ### Update ServerRequest in SQL
    ###-----------------------------------------
    $Status = "Job Started"
    Update-ServerRequest.SQL -RequestID $RequestID -Status $Status

#>
function Update-ServerRequest.SQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [int]$RequestID
        ,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Status
    )

    ###--------------------------------
    ### Update Server Request to SQL
    ###--------------------------------
    Begin {
        Write-Log -LogString "Start : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray
    }
    Process {
        ### Database Variables
        ###--------------------------
        $Database  = "VMDeploy"
        $Table     = "ServerRequest"
        $RequestID = $RequestID
        $Status    = $Status
        
        if($DeveloperMode) {
            Write-Host "dbo.Database  : " $Database   -ForegroundColor DarkCyan
            Write-Host "dbo.Table     : " $Table      -ForegroundColor DarkCyan
            Write-Host "dbo.RequestID : " $RequestID  -ForegroundColor DarkCyan
            Write-Host "dbo.Status    : " $Status     -ForegroundColor DarkCyan
        }
        ### Build SQL Query
        ###--------------------------
        $UpdateQuery = [string]" UPDATE [dbo].[$Table] SET [Status] = '$Status' WHERE RequestID ='$RequestID' "
        
        ### Exececute SQL Command
        ###--------------------------
        try {
            Invoke-SQLCmd -ServerInstance $DatabaseInstance -Database $Database -query $UpdateQuery
        }
        catch {
            $ErrMsg = "ERROR: " + $((Get-PSCallStack)[0].Command) + "`n`r" + $global:Error[0].Exception.Message
            Write-Log -LogString $ErrMsg -LogLevel Warning -LogObject $VMDeployLogObject
        }
    }
    End {
        if($DeveloperMode){Write-Log -LogString "End   : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray}  
    }
}