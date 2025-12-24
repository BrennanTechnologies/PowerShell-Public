<#
.SYNOPSIS
Add job to the DevOpsJob table in the DevOps database.

.DESCRIPTION
Add job to the DevOpsJob table in the DevOps database.

.PARAMETER Site
vCenter Site. (i.e. NY, TX, SF, L1, L2)

.PARAMETER ClientCode
3 character Client Code (i.e ABA, CTX, TST)

.PARAMETER ServerType
Server Type (FS, DC, CTX)

.PARAMETER JobStatus
JobStatus (i.e. Started, Running, Complete)

.EXAMPLE
    ### Add DevOps Job in SQL
    ###-----------------------------------------
    $DevOpsJobParams = @{
        Site       = $Site
        ClientCode = $ClientCode
        ServerType = $ServerType
        JobStatus  = "New Job"
    }
    $JobID = Add-DevOpsJob.SQL @DevOpsJobParams

.NOTES
Returns the JobID from SQL.

#>

function Add-DevOpsJob.SQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Site
        ,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientCode
        ,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerType
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
        $Database       = "DevOps"
        $Table          = "DevOpsJobs"
        $Site           = $Site
        $ClientCode     = $ClientCode
        $ServerType     = $ServerType
        $JobName        = Split-Path $MyInvocation.PSCommandPath -Leaf
        $JobParameters = "Site=$Site, ClientCode=$ClientCode, ServerType=$ServerType"

        ### Build SQL Query
        ###--------------------------
        $InsertQuery = [string]" 
        INSERT INTO [dbo].[$Table]
            (
                [JobName],
                [JobParameters],
                [JobStatus]
            ) 
            OUTPUT Inserted.JobID
            VALUES 
            (
                '$JobName',
                '$JobParameters',
                '$JobStatus'
            )"

        ### Exececute SQL Command
        ###--------------------------
        try {
            $JobID = Invoke-SQLCmd -ServerInstance $DatabaseInstance -Database $Database -query $InsertQuery
            $JobID = $JobID.Item(0)
            if($DeveloperMode){
                Write-Host "JobID:" $JobID -ForegroundColor DarkCyan
            }
            Return $JobID
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