function Update-ServerRecord.SQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [int]$ServerID
        ,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$ConfigParams
    )

    ###--------------------------------
    ### Write Server Params to SQL
    ###--------------------------------
    Begin {
        Write-Log -LogString "Start : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray
    }
    Process {
        ### Database Variables
        ###--------------------------
        $Database = "VMDeploy"
        $Table    = "Servers"

        ### Build SQL Query
        ###--------------------------
        $UpdateQuery = "
            UPDATE [dbo].[$Table] 
                SET
                " 
        foreach($Param in $ConfigParams.GetEnumerator()){
            $string += ("[" + $Param.Name + "] = '" + $Param.Value + "',")
        }
        $UpdateQuery += $string.Substring(0, ($string.length-1))
        $UpdateQuery += "
            WHERE ServerID ='$ServerID' 
        "
        if($DeveloperMode) {
            Write-Host "Updating Server Params in SQL:" -ForegroundColor Cyan
            $Params = @()
            foreach($Param in $ConfigParams.GetEnumerator())
            {
                $Object = [PSCustomObject]@{
                    $Param.Name = $Param.Value
                }
                Write-Host "dbo.ServerParam : " ($Param.Name + " : " + $Param.Value ) -ForegroundColor DarkCyan
            }
            $Params += $Object
        }

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

