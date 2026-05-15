###################################
### VM Provioning Script
### ECI.EMI.Automation.VM.Prod.ps1
###################################
Param(
        [Parameter(Mandatory = $True)][int]$ServerID,
        [Parameter(Mandatory = $True)][int]$RequestID,
        [Parameter(Mandatory = $True)][string]$Environment,
        [Parameter(Mandatory = $True)][string]$ConfigurationMode
     )

    switch ($Env)
    {
        "Dev"          { $global:Environment = "Development" }
        "Stage"        { $global:Environment = "Staging"     }
        "Prod"         { $global:Environment = "Production"  }
        "Development"  { $global:Environment = "Development" }
        "Staging"      { $global:Environment = "Staging"     }
        "Production"   { $global:Environment = "Production"  }
    }


### ==================================================
### Invoke ECI.EMI.VM.vCenterResouces
### ==================================================
function Invoke-ECI.EMI.VM.Resources
{
    Param(
        [Parameter(Mandatory = $True)][string]$RequestID,
        [Parameter(Mandatory = $True)][string]$InstanceLocation,
        [Parameter(Mandatory = $True)][string]$serverRole,
        [Parameter(Mandatory = $True)][string]$GPID,
        [Parameter(Mandatory = $True)][string]$VMName
        #[Parameter(Mandatory = $True)][string]$Environment
    )

    $FunctionName = $((Get-PSCallStack)[0].Command);Write-Host `r`n('=' * 100)`r`n "EXECUTING FUNCTION: " $FunctionName `r`n('=' * 100) -ForegroundColor Cyan
    
    #####################
    ### Get vCenter Resources
    #####################
    
    $vCenterResources = @{
            RequestID        = $RequestID
            InstanceLocation = $InstanceLocation
            ServerRole       = $ServerRole
            GPID             = $GPID
            VMName           = $VMName
    }
    

    ### ECI.ConfigServer.Invoke-ConfigureRoles.ps1
    ###------------------------------------------------
    $File = "ECI.EMI.Automation.VM.Resources"
    $FilePath =  "\\eciscripts.file.core.windows.net\clientimplementation\" + $Environement + "\ECI.Modules." + $Env + "\" + $File + "." + $Env + "\" + $File  + "." + $Env + ".ps1"
    . ($FilePath) @vCenterResources

}


&{
    BEGIN
    {
        ### Write Header Information
        ###---------------------------------
        Write-Host `r`n`r`n('*' * 100)`r`n (' ' * 20)" --------- STARTING VM PROVISIONING --------- " `r`n('*' * 100)  -ForegroundColor Cyan
        Write-Host ('-' * 50)`r`n                                                                                      -ForegroundColor DarkCyan
        Write-Host "Env         : " $Env                                                                               -ForegroundColor DarkCyan
        Write-Host "Environment : " $Environment                                                                       -ForegroundColor DarkCyan
        Write-Host "Script      : " (Split-Path (Get-PSCallStack)[0].ScriptName -Leaf)                                 -ForegroundColor DarkCyan
        Write-Host `r`n('-' * 50)`r`n                                                                                  -ForegroundColor DarkCyan
        
        ### Script Setup
        ###---------------------------------
        $script:VMStartTime = Get-Date
        $global:VerifyErrorCount = 0 ### Reset Verify Error Counter
        Get-ECI.EMI.Automation.vCenter -InstanceLocation $InstanceLocation
        Connect-ECI.EMI.Automation.VIServer -InstanceLocation $InstanceLocation -User $vCenter_Account -Password $vCenter_Password
    }

    PROCESS 
    {
        ###---------------------------------
        ### Get vCenter Resources
        ###---------------------------------
        $vCenterResources = @{
            RequestID        = $RequestID
            InstanceLocation = $InstanceLocation
            serverRole       = $serverRole
            GPID             = $GPID
            VMName           = $VMName
            #Environment      = $Environment
        }

        Invoke-ECI.EMI.VM.Resources @vCenterResources
       
        Get-ECI.EMI.AutoMation.VM.VMTemplate

        ###======================================================
        ### Create New VM
        ###======================================================
        Write-Host "NEW VM PARAMETERS:" 
        Write-Host "-------------------------------------------------------------"
        Write-Host "ConfigurationMode          : " $ConfigurationMode
        Write-Host "VMName                     : " $VMName
        Write-Host "ECIVMTemplate              : " $ECIVMTemplate
        Write-Host "OSCustomizationSpecName    : " $OSCustomizationSpecName
        Write-Host "ResourcePool               : " $ResourcePool
        Write-Host "OSDataStore                : " $OSDataStore
        Write-Host "SwapDataStore              : " $SwapDataStore
        Write-Host "PortGroup                  : " $PortGroup
        Write-Host "IPv4Address                : " $IPv4Address
        Write-Host "SubnetMask                 : " $SubnetMask
        Write-Host "DefaultGateway             : " $DefaultGateway
        Write-Host "PrimaryDNS                 : " $PrimaryDNS
        Write-Host "SecondaryDNS               : " $SecondaryDNS
        Write-Host "-------------------------------------------------------------"

        ###------------------------
        ### Configuration Mode
        ###------------------------
        Write-Host "Current Configuration Mode : " $ConfigurationMode -ForegroundColor Magenta
        if($ConfigurationMode -eq "Report")
        {
            ###------------------------
            ### Report Mode
            ###------------------------
            $ReadOnlyVMReport = @{

                InstanceLocation         = $VCenter
                GPID                     = $GPID
                VMName                   = $VMName
                ConfigurationMode        = $ConfigurationMode
                ECIVMTemplate            = $ECIVMTemplate
                OSCustomizationSpecName  = $OSCustomizationSpecName
                ResourcePool             = $ResourcePool
                PortGroup                = $PortGroup
                OSDataStore              = $OSDataStore
                SwapDataStore            = $SwapDataStore
                vCPU                     = $vCPUCount
                vMemory                  = $vMemoryGB
                IPv4Address              = $IPv4Address
                SubnetMask               = $SubnetMask
                DefaultGateway           = $DefaultGateway
                PrimaryDNS               = $PrimaryDNS
                SecondaryDNS             = $SecondaryDNS

            }
            
            Write-Host "REPORT MODE: New VM Parameters:" -ForegroundColor Cyan
            #$NewVMParameters | FT

            Report-ECI.EMI.ReadOnlyVMReport @ReadOnlyVMReport

        }
        elseif($ConfigurationMode -eq "Configure")
        {
            ###------------------------
            ### Configure Mode
            ###------------------------

            $NewVMParameters = @{
                ConfigurationMode        = $ConfigurationMode
                VMName                   = $VMName
                ECIVMTemplate            = $ECIVMTemplate
                OSCustomizationSpecName  = $OSCustomizationSpecName
                ResourcePool             = $ResourcePool
                OSDataStore              = $OSDataStore
                PortGroup                = $PortGroup
                IPv4Address              = $IPv4Address
                SubnetMask               = $SubnetMask
                DefaultGateway           = $DefaultGateway
                PrimaryDNS               = $PrimaryDNS
                SecondaryDNS             = $SecondaryDNS
            }

            Write-Host "CONFIGURE MODE: New VM Parameters:" -ForegroundColor Cyan
            $NewVMParameters | FT

            ### Create New VM (ECI Cmdlet))
            ###------------------------
            New-ECI.EMI.Automation.VM @NewVMParameters
        }
        


        ### Set UUID + MoRef
        ###------------------------
        Set-ECI.EMI.Automation.VM.ServerUUID

        ### Configure Hard Disks
        ###-----------------------
        Configure-ECI.EMI.Automation.VM.HardDisks
        New-ECI.EMI.Automation.VM.HardDisk.PageFile -VMName $VMName

        ### Configure CPU & Memoery
        ###-----------------------
        Set-ECI.EMI.Automation.VM.VMCPU
        Set-ECI.EMI.Automation.VM.VMMemory

        ### Start VM
        ###-----------------------
        Start-ECI.EMI.Automation.VM


        ### Write Logs to SQL
        ###------------------------
        Write-ECI.EMI.Automation.VMLogstoSQL
    }

    END
    {
        $VMStopTime = Get-Date
        $global:VMElapsedTime = ($VMStopTime-$VMStartTime)
        Write-Host `r`n`r`n('=' * 75)`r`n "VM Configuration: Total Execution Time:`t" $VMElapsedTime `r`n`r`n('=' * 75)`r`n -ForegroundColor Gray
        Write-Host "END VM CONFIGURATION SCRIPTS" -ForegroundColor Gray
        ### END VM PROVISIONING SCRIPT
    }
}