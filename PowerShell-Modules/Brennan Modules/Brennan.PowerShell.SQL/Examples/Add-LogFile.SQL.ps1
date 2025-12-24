    <#
    LogPath             : C:\PSlogs\Brennan-vmdeploy\Brennan-vmDeploy.log
    ScriptName          : Brennan-vmDeploy
    AttachToExistingLog : FALSE
    AuditLog            : True
    AuditLogPath        : \\service02.corp\DFS\SHARES\PSAuditLogs\Brennan-vmdeploy\Brennan-vmDeploy.log
    VerbosePreference   : SilentlyContinue
    DebugPreference     : SilentlyContinue
    UniqueLogID         : 96f12233c105cec94df9daf73af9e3eb054e0c2b

 $LogString = "[$Date] [$($this.ScriptName)] [$LogLevel] [$env:USERDOMAIN\$env:USERNAME] [$env:COMPUTERNAME] - $LogMessage"
 LogDate
 ScriptName
 LogLevel
 UserName
 ComputerName
 UniqueLogID
 LogMessage

 $LogString | Out-File -Append -LiteralPath $This.LogPath -Encoding utf8

#>


function Add-LogFile.SQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$LogPath,
        [Parameter(Mandatory = $False)]
        [switch]$Quite
    )
    Begin {
        Write-Log -LogString "Start : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray
    }

    Process {

        ### Database Variables
        ###-----------------------------------------
        $Database = "DevOpsLogs"
        $Table    = "VMDeployLogs"

        Write-Host "dbo.Database   : " $Database  -ForegroundColor DarkCyan
        Write-Host "dbo.Table      : " $Table     -ForegroundColor DarkCyan

        ### Write Logs to SQL
        ###-----------------------------------------
        if($audit){
            $LogPath = $audit_logpath
        }
        else {
            $LogPath = $log_logpath
        }

        $LogData = Get-Content -Path $LogPath

        foreach($Row in $LogData) {
            $LogColumns   = $Row.Split(" ")
            $LogDate      = $LogColumns[0]
            $ScriptName   = $LogColumns[1]
            $LogLevel     = $LogColumns[2]
            $UserName     = $LogColumns[3]
            $ComputerName = $LogColumns[4]
            $UniqueLogID  = $LogColumns[5]
            $LogMessage   = $Row.Split("]")[-1]

            if($Quite -ne $true) {
                Write-Host "LogDate      : " $LogDate      -ForegroundColor Cyan
                Write-Host "ScriptName   : " $ScriptName   -ForegroundColor Cyan
                Write-Host "LogLevel     : " $LogLevel     -ForegroundColor Cyan
                Write-Host "UserName     : " $UserName     -ForegroundColor Cyan
                Write-Host "ComputerName : " $ComputerName -ForegroundColor Cyan
                Write-Host "UniqueLogID  : " $UniqueLogID  -ForegroundColor Cyan
                Write-Host "LogMessage   : " $LogMessage   -ForegroundColor Cyan
            }

        ### Build SQL Query
        ###-----------------------------------------
        $InsertQuery = [string]"
        INSERT INTO [dbo].[$Table]
            (
                LogDate,
                ScriptName,
                LogLevel,
                UserName,
                ComputerName,
                UniqueLogID,
                LogMessage
            )
            VALUES
            (
                '$LogDate',
                '$ScriptName',
                '$LogLevel',
                '$UserName',
                '$ComputerName',
                '$UniqueLogID',
                '$LogMessage'
            )"

            ### Exececute SQL Command
            ###--------------------------
            try {
                Invoke-SQLcmd -ServerInstance $DatabaseInstance -Database $Database -query $InsertQuery
            }
            catch {
                $ErrMsg = "ERROR: " + $((Get-PSCallStack)[0].Command) + "`n`r" + $global:Error[0].Exception.Message
                Write-Log -LogString $ErrMsg -LogLevel Warning -LogObject $VMDeployLogObject
            }
        }
    }
    End {
        if($DeveloperMode){Write-Log -LogString "End   : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray}
    }
}
