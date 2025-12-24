function Get-OSCustomizationSpec.SQL {
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
        $Table      = "OSCustomizationSpec"
        $BuildID    = $BuildID

        ### Build SQL Query
        ###-----------------------------------------
        $SelectQuery = " SELECT * FROM [dbo].[$Table] WHERE BuildID = '$BuildID' "
        
        ### Exececute SQL Command
        ###-----------------------------------------
        try {
            [PSCustomObject]$OSCustomizationSpec = Invoke-SQLcmd -ServerInstance $DatabaseInstance -Database $Database -Query $SelectQuery
        }
        catch {
            $ErrMsg = "ERROR: " + $((Get-PSCallStack)[0].Command) + "`n`r" + $global:Error[0].Exception.Message
            Write-Log -LogString $ErrMsg -LogLevel Warning -LogObject $VMDeployLogObject
        }
        if($DeveloperMode) {
            foreach($Spec in $OSCustomizationSpec) {
                Write-Host "OSCustomizationSpec.OSCustomizationSpecID : " $Spec.OSCustomizationSpecID  -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.BuildID               : " $Spec.BuildID                -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.Name                  : " $Spec.Name                   -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.Description           : " $Spec.Description            -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.FullName              : " $Spec.FullName               -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.OrgName               : " $Spec.OrgName                -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.Domain                : " $Spec.Domain                 -ForegroundColor DarkGray
                Write-Host "OSCustomizationSpec.OSType                : " $Spec.OSType                 -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.ChangeSid             : " $Spec.ChangeSid              -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.Type                  : " $Spec.Type                   -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.AutoLogonCount        : " $Spec.AutoLogonCount         -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.LicenseMode           : " $Spec.LicenseMode            -ForegroundColor DarkCyan
                Write-Host "OSCustomizationSpec.LicenseMaxConnections : " $Spec.LicenseMaxConnections  -ForegroundColor DarkCyan
            }
        }
        Return $OSCustomizationSpec
    }
    End {
        if($DeveloperMode){Write-Log -LogString "End   : $((Get-PSCallStack)[0].Command)" -LogLevel Output -LogObject $VMDeployLogObject -ForegroundColor DarkGray}
    }
}
