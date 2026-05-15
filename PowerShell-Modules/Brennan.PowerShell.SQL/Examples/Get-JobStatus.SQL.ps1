function Get-JobStatus.SQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [int]$JobID
    )

    Begin {
        Write-Log -LogString "Start : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray
    }
    Process {
        ###-----------------------------------------
        ### Get Job Status
        ###-----------------------------------------

        ### Database Variables
        ###-----------------------------------------
        $Database   = "DevOps"
        $Table      = "DevOpsJobs"

        Get-Process -ComputerName "Scoot"

        Write-Host 
        ### Build SQL Query
        ###-----------------------------------------
        $SelectQuery = " SELECT JobStatus FROM [dbo].[$Table] WHERE JobID = '$JobID' "
        
        ### Exececute SQL Command
        ###-----------------------------------------
        try {
            $JobStatus = Invoke-SQLcmd -ServerInstance $DatabaseInstance -Database $Database -Query $SelectQuery
            if($DeveloperMode){
                Write-Host "JobStatus:" $JobStatus.JobStatus -ForegroundColor Cyan
            }
        }
        catch {
            $ErrMsg = "ERROR: " + $((Get-PSCallStack)[0].Command) + "`n`r" + $global:Error[0].Exception.Message
            Write-Log -LogString $ErrMsg -LogLevel Warning -LogObject $VMDeployLogObject
        }
        Return $JobStatus.JobStatus
    }
    End {
        if($DeveloperMode){Write-Log -LogString "End   : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray}
    }
}
