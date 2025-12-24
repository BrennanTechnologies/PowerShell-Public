<#
.SYNOPSIS
Gets the Server Current Configuration from SQL.

.DESCRIPTION
Gets the Server Current Configuration from SQL.

.PARAMETER ServerID
Primary key of Server record.

.EXAMPLE
    ### Get Server Current Configuration from SQL
    ###-----------------------------------------
    $ServerConfig = Get-ServerConfig.SQL -ServerID $ServerID

.NOTES
The data returned is used for email report.

#>
function Get-ServerConfig.SQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [int]$ServerID
    )
    Begin {
        Write-Log -LogString "Start : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray
    }
    Process {
        ###-----------------------------------------
        ### Get Server Build Specs from SQL
        ###-----------------------------------------

        ### Database Variables
        ###-----------------------------------------
        $Database = "VMDeploy"
        $Table    = "Servers"
        $ServerID = $ServerID

        ### Build SQL Query
        ###-----------------------------------------
        $SelectQuery = " SELECT * FROM [dbo].[$Table] WHERE ServerID = '$ServerID' "
        
        ### Exececute SQL Command
        ###-----------------------------------------
        try {
            $ServerConfig = Invoke-SQLcmd -ServerInstance $DatabaseInstance -Database $Database -Query $SelectQuery
        }
        catch {
            $ErrMsg = "ERROR: " + $((Get-PSCallStack)[0].Command) + "`n`r" + $global:Error[0].Exception.Message
            Write-Log -LogString $ErrMsg -LogLevel Warning -LogObject $VMDeployLogObject
        }
        if($DeveloperMode) {
            Write-Host "dbo.Server Configuration Parameters : "                                   -ForegroundColor Cyan
            Write-Host "dbo.ServerConfig.ServerID           : " $ServerConfig.ServerID            -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.BuildID            : " $ServerConfig.BuildID             -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.ServerType         : " $ServerConfig.ServerType          -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.Description        : " $ServerConfig.Description         -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.OSType             : " $ServerConfig.OSType              -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.VMTemplate         : " $ServerConfig.VMTemplate          -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.OSCustomizationSpec: " $ServerConfig.OSCustomizationSpec -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.NumCPU             : " $ServerConfig.NumCPU              -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.MemoryGB           : " $ServerConfig.MemoryGB            -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.Disk0Label         : " $ServerConfig.Disk0Label          -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.Disk0SizeGB        : " $ServerConfig.Disk0SizeGB         -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.Disk1Label         : " $ServerConfig.Disk1Label          -ForegroundColor DarkCyan
            Write-Host "dbo.ServerConfig.Disk1SizeGB        : " $ServerConfig.Disk1SizeGB         -ForegroundColor DarkCyan
            #Write-Host "dbo.ServerConfig.Disk2Label         : " $ServerConfig.Disk2Label          -ForegroundColor DarkGray
            #Write-Host "dbo.ServerConfig.Disk2SizeGB        : " $ServerConfig.Disk2SizeGB         -ForegroundColor DarkGray
            #Write-Host "dbo.ServerConfig.Disk3Label         : " $ServerConfig.Disk3Label          -ForegroundColor DarkGray
            #Write-Host "dbo.ServerConfig.Disk3SizeGB        : " $ServerConfig.Disk3SizeGB         -ForegroundColor DarkGray
            #Write-Host "dbo.ServerConfig.Disk4Label         : " $ServerConfig.Disk4Label          -ForegroundColor DarkGray
            #Write-Host "dbo.ServerConfig.Disk4SizeGB        : " $ServerConfig.Disk4SizeGB         -ForegroundColor DarkGray
        }
        Return $ServerConfig
    }
    End {
        if($DeveloperMode){Write-Log -LogString "End   : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray}
    }
}
