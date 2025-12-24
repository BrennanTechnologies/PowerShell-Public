<#
.SYNOPSIS
Add Server Record to Server table in the VMDeploy Database

.DESCRIPTION
Add Server Record to Server table in the VMDeploy Database

.PARAMETER Site
vCenter Site. (i.e. NY, TX, SF, L1, L2)

.PARAMETER ClientCode
3 character Client Code (i.e ABA, CTX, TST)

.PARAMETER ServerType
Server Type (FS, DC, CTX)

.PARAMETER FourthOctet
Fourth Octect of the IP Address (i.e. 222)

.PARAMETER VMTemplate
Optional: VMTemplate Name (if specified)

.PARAMETER JobID
JobID primary key from the DevOpsJob table.

.PARAMETER RequestID
ReuestID primary key from the ServerRequest table.

.PARAMETER BuildID
BuildID primary key from the ServerBuildSpecs table.

.EXAMPLE
    ### Add New Server Record to SQL
    ###-----------------------------------------
    $NewServerParams = @{
        Site        = $Site
        ClientCode  = $ClientCode
        ServerType  = $ServerType
        FourthOctet = $FourthOctet
        VMTemplate  = $VMTemplate
        JobID       = $JobID
        RequestID   = $RequestID
        BuildID     = $BuildID
    }
    $ServerID = Add-Server.SQL @NewServerParams

.NOTES
Returns the ServerID from SQL

#>
function Add-Server.SQL {
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
        [int]$FourthOctet
        ,
        [Parameter(Mandatory = $False)]
        [string]$VMTemplate
        ,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [int]$JobID
        ,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [int]$RequestID
        ,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [int]$BuildID
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
        $Database       = "VMDeploy"
        $Table          = "Servers"
        $Site           = $Site
        $ClientCode     = $ClientCode
        $ServerType     = $ServerType
        $FourthOctet    = $FourthOctet
        $VMTemplate     = $VMTemplate
        $UserName       = $env:USERNAME
        $ComputerName   = $env:COMPUTERNAME
        $JobID          = $JobID
        $RequestID      = $RequestID
        $BuildID        = $BuildID

        if($DeveloperMode) {
            Write-Host "Database     : " $Database     -ForegroundColor DarkCyan
            Write-Host "Table        : " $Table        -ForegroundColor DarkCyan
            Write-Host "Site         : " $Site         -ForegroundColor DarkCyan
            Write-Host "ClientCode   : " $ClientCode   -ForegroundColor DarkCyan
            Write-Host "ServerType   : " $ServerType   -ForegroundColor DarkCyan
            Write-Host "FourthOctet  : " $FourthOctet  -ForegroundColor DarkCyan
            Write-Host "VMTemplate   : " $VMTemplate   -ForegroundColor DarkCyan
            Write-Host "UserName     : " $UserName     -ForegroundColor DarkCyan
            Write-Host "ComputerName : " $ComputerName -ForegroundColor DarkCyan
            Write-Host "JobID        : " $JobID        -ForegroundColor DarkCyan
            Write-Host "RequestID    : " $RequestID    -ForegroundColor DarkCyan
            Write-Host "BuildID      : " $BuildID      -ForegroundColor DarkCyan
        }

        ### Build SQL Query
        ###--------------------------
        $InsertQuery = [string]" 
        INSERT INTO [dbo].[$Table]
            (
                Site,
                ClientCode,
                ServerType,
                FourthOctet,
                VMTemplate,
                UserName,
                ComputerName,
                JobID,
                RequestID,
                BuildID
            ) 
            OUTPUT Inserted.ServerID
            VALUES 
            (
                '$Site',
                '$ClientCode',
                '$ServerType',
                '$FourthOctet',
                '$VMTemplate',
                '$UserName',
                '$ComputerName',
                '$JobID',
                '$RequestID',
                '$BuildID'
            )"

        ### Exececute SQL Command
        ###--------------------------
        try {
            $ServerID =  Invoke-SQLcmd -ServerInstance $DatabaseInstance -Database $Database -query $InsertQuery
            $ServerID =  $ServerID.Item(0)
            if($DeveloperMode){
                Write-Host "ServerID:" $ServerID -ForegroundColor DarkCyan
            }
        }
        catch {
            $ErrMsg = "ERROR: " + $((Get-PSCallStack)[0].Command) + "`n`r" + $global:Error[0].Exception.Message
            Write-Log -LogString $ErrMsg -LogLevel Warning -LogObject $VMDeployLogObject
        }
        Return $ServerID
    }
    End {
        if($DeveloperMode){Write-Log -LogString "End   : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray}
    }
}