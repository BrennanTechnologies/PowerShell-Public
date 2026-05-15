function Get-VMTags.SQL {
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
        ### Get Server Build Specs
        ###-----------------------------------------

        ### Database Variables
        ###-----------------------------------------
        $Database   = "VMDeploy"
        $Table      = "VMTags"
        $BuildID = $BuildID

        ### Build SQL Query
        ###-----------------------------------------
        $SelectQuery = " SELECT * FROM [dbo].[$Table] WHERE BuildID = '$BuildID' "
        
        ### Exececute SQL Command
        ###-----------------------------------------
        try {
            $VMTags = Invoke-SQLcmd -ServerInstance $DatabaseInstance -Database $Database -Query $SelectQuery
        }
        catch {
            $ErrMsg = "ERROR: " + $((Get-PSCallStack)[0].Command) + "`n`r" + $global:Error[0].Exception.Message
            Write-Log -LogString $ErrMsg -LogLevel Warning -LogObject $VMDeployLogObject
        }
        if($DeveloperMode) {
            Write-Host "VMTags.BuildID        : " $VMTags.BuildID        -ForegroundColor DarkCyan
            Write-Host "VMTags.TagName        : " $VMTags.TagName        -ForegroundColor DarkCyan
            Write-Host "VMTags.TagCategory    : " $VMTags.TagCategory    -ForegroundColor DarkCyan
            Write-Host "VMTags.TagDescription : " $VMTags.TagDescription -ForegroundColor DarkCyan
        }
        Return $VMTags
    }
    End {
        if($DeveloperMode){Write-Log -LogString "End   : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray}
    }
}
