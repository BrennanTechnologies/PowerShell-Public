function Get-ServerBuildSpecs.SQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [int]$BuildID
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
        $Database   = "VMDeploy"
        $Table      = "ServerBuildSpecs"
        $BuildID = $BuildID

        ### Build SQL Query
        ###-----------------------------------------
        $SelectQuery = " SELECT * FROM [dbo].[$Table] WHERE BuildID = '$BuildID' "
        
        ### Exececute SQL Command
        ###-----------------------------------------
        try {
            $BuildSpecs = Invoke-SQLcmd -ServerInstance $DatabaseInstance -Database $Database -Query $SelectQuery
        }
        catch {
            $ErrMsg = "ERROR: " + $((Get-PSCallStack)[0].Command) + "`n`r" + $global:Error[0].Exception.Message
            Write-Log -LogString $ErrMsg -LogLevel Warning -LogObject $VMDeployLogObject
        }
        
        if($DeveloperMode) {
            Write-Host "BuildSpecs.BuildID            : " $BuildSpecs.BuildID               -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.ServerType         : " $BuildSpecs.ServerType            -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.Description        : " $BuildSpecs.Description           -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.OSType             : " $BuildSpecs.OSType                -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.VMTemplate         : " $BuildSpecs.VMTemplate            -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.OSCustomizationSpec: " $BuildSpecs.OSCustomizationSpec   -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.NumCPU             : " $BuildSpecs.NumCPU                -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.MemoryGB           : " $BuildSpecs.MemoryGB              -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.Disk0Label         : " $BuildSpecs.Disk0Label            -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.Disk0SizeGB        : " $BuildSpecs.Disk0SizeGB           -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.Disk1Label         : " $BuildSpecs.Disk1Label            -ForegroundColor DarkCyan
            Write-Host "BuildSpecs.Disk1SizeGB        : " $BuildSpecs.Disk1SizeGB           -ForegroundColor DarkCyan
            #Write-Host "BuildSpecs.Disk2Label         : " $BuildSpecs.Disk2Label            -ForegroundColor DarkGray
            #Write-Host "BuildSpecs.Disk2SizeGB        : " $BuildSpecs.Disk2SizeGB           -ForegroundColor DarkGray
            #Write-Host "BuildSpecs.Disk3Label         : " $BuildSpecs.Disk3Label            -ForegroundColor DarkGray
            #Write-Host "BuildSpecs.Disk3SizeGB        : " $BuildSpecs.Disk3SizeGB           -ForegroundColor DarkGray
            #Write-Host "BuildSpecs.Disk4Label         : " $BuildSpecs.Disk4Label            -ForegroundColor DarkGray
            #Write-Host "BuildSpecs.Disk4SizeGB        : " $BuildSpecs.Disk4SizeGB           -ForegroundColor DarkGray
        }
        Return $BuildSpecs
    }
    End {
        if($DeveloperMode){Write-Log -LogString "End   : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray}
    }
}
