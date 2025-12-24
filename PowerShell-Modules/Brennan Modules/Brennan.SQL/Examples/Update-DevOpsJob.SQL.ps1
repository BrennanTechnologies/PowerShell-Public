<#
.SYNOPSIS
Update the DevOpsJob table in the DevOps database.

.DESCRIPTION
Update the DevOpsJob table in the DevOps database.

.PARAMETER JobID
Pimary key JobID

.PARAMETER JobStatus
Status of the Job (i.e "Job Started", "Job Completed")

.EXAMPLE
    ### Update DevOpsJob/ServerRequest in SQL
    ###-----------------------------------------
    $Status = "Job Started"
    Update-DevOpsJob.SQL -JobID $JobID -Status $Status
    
#>
function Update-DevOpsJob.SQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [int]$JobID
        ,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$JobStatus
    )

    ###--------------------------------
    ### Write Server Request to SQL
    ###--------------------------------
    Begin {
        Write-Log -LogString "Start : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray
    }
    Process {
        ### Database Variables
        ###--------------------------
        $Database  = "DevOps"
        $Table     = "DevOpsJobs"
        $JobID     = $JobID
        $JobStatus = $JobStatus

        if($DeveloperMode) {
            Write-Host "dbo.Database   : " $Database  -ForegroundColor DarkCyan
            Write-Host "dbo.Table      : " $Table     -ForegroundColor DarkCyan
            Write-Host "dbo.JobID      : " $JobID     -ForegroundColor DarkCyan
            Write-Host "dbo.JobStatus  : " $JobStatus -ForegroundColor DarkCyan
        }

        ### Build SQL Query
        ###--------------------------
        $UpdateQuery = [string]" UPDATE [dbo].[$Table] SET [JobStatus] = '$JobStatus' WHERE JobID ='$JobID' "
        
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