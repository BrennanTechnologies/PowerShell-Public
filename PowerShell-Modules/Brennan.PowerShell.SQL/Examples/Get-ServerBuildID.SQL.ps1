<#
.SYNOPSIS
Get the BuildID from the ServerBuildSpecs tbale based on Server Type.  

.DESCRIPTION
Get the BuildID from the ServerBuildSpecs tbale based on Server Type.

.PARAMETER ServerType
Server Type (FS, DC, CTX)

.EXAMPLE
$BuildID = Get-ServerBuildID.SQL -ServerType $ServerType

.NOTES
Returns the Server Build Specifications.

    ### Server Build Specifications
    ###---------------------------------------
    ServerType          = $BuildSpecs.ServerType
    Description         = $BuildSpecs.Description
    OSType              = $BuildSpecs.OSType
    NumCPU              = $BuildSpecs.NumCPU
    MemoryGB            = $BuildSpecs.MemoryGB
    Disk0Label          = $BuildSpecs.Disk0Label
    Disk0SizeGB         = $BuildSpecs.Disk0SizeGB
    Disk1Label          = $BuildSpecs.Disk1Label
    Disk1SizeGB         = $BuildSpecs.Disk1SizeGB
#>
function Get-ServerBuildID.SQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerType
    )

    Begin {
        Write-Log -LogString "Start : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray
    }
    Process {
        ###-----------------------------------------
        ### Get Server Build Spec ID from SQL
        ###-----------------------------------------

        ### Database Variables
        ###-----------------------------------------
        $Database   = "VMDeploy"
        $Table      = "ServerBuildSpecs"
        $ServerType = $ServerType

        ### Build SQL Query
        ###-----------------------------------------
        $SelectQuery = " SELECT BuildID FROM [dbo].[$Table] WHERE ServerType = '$ServerType' "
        
        ### Exececute SQL Command
        ###-----------------------------------------
        try {
            $BuildID = Invoke-SQLcmd -ServerInstance $DatabaseInstance -Database $Database -Query $SelectQuery
            [int]$BuildID =  $BuildID.Item(0)
            if($DeveloperMode){
                Write-Host "BuildID:" $BuildID -ForegroundColor Cyan
            }
        }
        catch {
            $ErrMsg = "ERROR: " + $((Get-PSCallStack)[0].Command) + "`n`r" + $global:Error[0].Exception.Message
            Write-Log -LogString $ErrMsg -LogLevel Warning -LogObject $VMDeployLogObject
        }
        Return $BuildID
    }
    End {
        if($DeveloperMode){Write-Log -LogString "End   : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray}
    }
}
