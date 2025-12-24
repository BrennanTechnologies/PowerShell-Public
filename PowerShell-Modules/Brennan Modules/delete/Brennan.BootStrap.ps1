### Brennan.BootStrap.ps1 from Brennan 11-21-21 6:41pm

<#
    Description:
    ------------
    Brennan Boot Strap - "Login Script"

    Version:
    --------
    11.21.21
    7:07pm


    Required Modules:
    -----------------
    $requiredModules = @("Brennan")

    NOTES:
    ------

#>

function Set-ModulePath {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $ModulePaths = @(
            "C:\WindowsPowerShell\Modules"
        )
        ,
        [Parameter()]
        [string]
        $LogLevel = "DeveloperMode"
    )
    begin {
        Write-Host "Function: " $((Get-PSCallStack)[0].Command) -ForegroundColor DarkGray
        if($logLevel -eq "DeveloperMode"){
            foreach($ModulePath in $ModulePaths){
                Write-Host "Adding Module Path: " $ModulePath -ForegroundColor DarkGray
            }
        }
    }
    process {
        foreach($ModulePath in $ModulePaths){
            if((Test-Path $ModulePath)){
                if($env:PSModulePath.Split(";").Contains($ModulePath) -eq $false){                                        ### If the path is not already in the PSModulePath, add it.
                    Write-Host "Adding New ModulePath"  $ModulePath -ForegroundColor Green
                    $env:PSModulePath = "$($env:PSModulePath -split ';' -notmatch "\\\\" -join ";");$ModulePath"          ### Remove any UNC paths & Add my Paths.
                } else {
                    Write-Host "Skipping: Module Path already in PSModulePath" -ForegroundColor Cyan
                }
            } else {
                Write-Host "Module Path does not exist" -ForegroundColor Red
            }
        }
    }
    end {
        if($logLevel -eq "DeveloperMode") {
            foreach($path in $env:PSModulePath.Split(';')){
                Write-Host "Current ModulePath`t $path" -ForegroundColor DarkGray
            }

        }
    }
}
function Import-RequiredModules {
    <#
    .SYNOPSIS
    #

    .DESCRIPTION
    Long description

    .PARAMETER RequiredModules
    Parameter description

    .PARAMETER DebugMode
    Parameter description

    .EXAMPLE
    An example

    .NOTES
        ### Get Commands
        ### Get-Command -Module Brennan.VCE
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $requiredModules = @(
            "All"
            ,
            "Brennan.VCE"
            #,
            #"VMWare.Vim*"
            #,
            #"Brennan.Core"
            #,
            #"Brennan.CodeSigning"
        )
        ,
        [Parameter()]
        [switch]
        $DebugMode
        ,
        [Parameter()]
        [switch]
        $Prompt
    )
    begin {
        Write-Host "Function: " $((Get-PSCallStack)[0].Command) -ForegroundColor DarkGray
    }
    process {
        ### Import Required Modules.
        ###------------------------------------------------
        if($Prompt.IsPresent){
            [string]$loadModules = Read-Host -Prompt "Load Required Modules? (Y/N)"                             ### Prompt user to load modules
            if($loadModules.ToUpper() -eq "Y") {
                foreach($module in $requiredModules){
                    try {
                        if( [bool](Get-Module -Name $module -ListAvailable) -eq $true ){                        ### Test module exists
                            Write-Host "Importing Module: " $module -ForegroundColor Magenta
                            if($DebugMode){
                                Get-Module -Name $module -ListAvailable | Import-Module -Force #-Verbose            ### Force & Verbose
                                Get-Module -Name $module                                                        ### Display the Module
                            } else {
                                Get-Module -Name $module -ListAvailable | Import-Module -Force                  ### Force Only
                            }
                        }
                        else {
                            Write-Error -Message "Required Module $RequiredModule isnt available."              ### Module doesnt exist
                        }
                    }
                    catch {
                        Write-Warning -Message ("ERROR Importing required module: $RequiredModule" + $global:Error[0].Exception.Message) -ErrorAction Stop ### Error Imporing module
                    }
                }
            }
         } else {
            foreach($module in $requiredModules){
                try {
                    if( [bool](Get-Module -Name $module -ListAvailable) -eq $true ){                        ### Test module exists
                        Write-Host "Importing Module: " $module -ForegroundColor Magenta
                        if($DebugMode){
                            Get-Module -Name $module -ListAvailable | Import-Module -Force #-Verbose            ### Force & Verbose
                            Get-Module -Name $module                                                        ### Display the Module
                        } else {
                            Get-Module -Name $module -ListAvailable | Import-Module -Force                  ### Force Only
                        }
                    }
                    else {
                        Write-Error -Message "Required Module $RequiredModule isnt available."              ### Module doesnt exist
                    }
                }
                catch {
                    Write-Warning -Message ("ERROR Importing required module: $RequiredModule" + $global:Error[0].Exception.Message) -ErrorAction Stop ### Error Imporing module
                }
            }
        } ### Exit without loading MRequired odules
    }
    end {}
}

### Run the script
&{
    begin {
        Write-Host "Begin BootStrap: " -ForegroundColor DarkMagenta

        ### Set-ModulePath
        ###------------------------------------------------
        Set-ModulePath                                                          ### Modify $PSModulepath:   Adds Custom $PSModulepath, removes UNC paths

        ### Import-RequiredModules                                              ### Imports an array of Custom modules
        ###------------------------------------------------
        [string[]]$requiredModules = @(
            #"Brennan.VCE.All"
            #,
            #"Brennan.VCE"
            #,
            "Brennan"
            #,
            #"VMware.VimAutomation.Core"
        )
        ### Import-RequiredModules                                              ### Manually import VMWare modules as needed
        #[string]$loadModules = Read-Host -Prompt "Load Required Modules? (Y/N)"
        #if($loadModules.ToUpper() -eq "Y") {
            #Import-RequiredModules -RequiredModules $RequiredModules -DebugMode #-Prompt -Verbose
        #}

        ### Import VMWare Modules                                               ### Skip  if already loaded

         ### FIXED THIS BEFORE!!!!
        function Import-VMWareModules {
            if(-not $(Get-Module vmware.vim*)){
                Get-Module vmware.vim Import-VMWareModules* -ListAvailable | Import-Module
            }
        } Import-VMWareModules

    }
    process {
        Write-Host "Process BootStrap: " -ForegroundColor DarkMagenta

        Write-Log -Category Info -Message "This is a test" -Color Green
        Write-Log -Category WARN -Message "This is a test" -Color Red
        Exit

        ### Connect vCenter
        ### ----------- --------------
        $vCenter = "svs0604pdv.us.global.Brennan.com"
        $vCenter = Connect-VCE.vCenter -vCenter $vCenter -Credential $credential

        ###-----------------------------------------------------------------------------------------------------
        ### Get-VCE.ClusterHA
        ###-----------------------------------------------------------------------------------------------------
        $vmhostCluster = "PDC1-C-LAB-HCI-TEST"
        $checkHA = Get-VCE.ClusterHA -ClusterName $vmhostCluster
        #Write-Host "HA:"
        #$checkHA
        $checkDRS = Get-VCE.ClusterDRS -ClusterName $vmhostCluster
        #Write-Host "DRS:"
        #$checkDRS
        $checkEVC = Get-VCE.ClusterEVC -ClusterName $vmhostCluster
        #Write-Host "EVC:"
        #$checkEVC
        #exit

        ###-----------------------------------------------------------------------------------------------------
        ###  HA: Set-VCE.ClusterHA: Retry Loop
        ###-----------------------------------------------------------------------------------------------------
        $clusterName = "PDC1-C-LAB-HCI-TEST"

        ### Istantiate the Check Variable
        $setHA = ""
        do {
            if ($setHA[2] -eq $false) {                                                             ### IF HA Return value is false
                Write-ScreenAndLog "INFO" "Retry Setting HA on cluster $clusterName?`r`n"           ### Options Prompt
                Write-ScreenAndLog "INFO" "1)    Yes"
                Write-ScreenAndLog "INFO" "2)    No (ends the script)"
                $user_input = InputAndCheck -numOptions 2                                           ### Get user input

                if ($user_input -eq 2) {                                                            ### User input is EXIT
                    Write-ScreenAndLog "INFO" "User ended the script early."
                    exit
                }
            }
            ### Set HA on the Cluster
            ### ---------------------------
            $setHA =  Set-VCE.ClusterHA -ClusterName $clusterName                                 ### Set-VCE.ClusterHA -ClusterName $clusterName
            Write-ScreenAndLog $setHA[0] $setHA[1]
            ### ---------------------------

        } until ($setHA[2] -eq $true -or $skip -eq $true) #                                       ### Loop until the return value is true or the user ends the script
        ###-----------------------------------------------------------------------------------------------------

        #exit # at HA

        ###-----------------------------------------------------------------------------------------------------
        ###  DRS: Set-VCE.ClusterDRS Retry Loop
        ###-----------------------------------------------------------------------------------------------------
        $clusterName = "PDC1-C-LAB-HCI-TEST"

        ## Disable
        #Set-Cluster $ClusterName -HAEnabled:$false
        #Set-Cluster $ClusterName -DrsEnabled:$false

        ### Istantiate the Check Variable
        $setDRS = ""
        do {
            if ($setDRS[2] -eq $false) {                                                            ### IF DRS Return value is false
                Write-ScreenAndLog "INFO" "Retry Setting HA on cluster $clusterName?`r`n"           ### Options Prompt
                Write-ScreenAndLog "INFO" "1)    Yes"
                Write-ScreenAndLog "INFO" "2)    No (ends the script)"
                $user_input = InputAndCheck -numOptions 2                                           ### Get user input

                if ($user_input -eq 2) {                                                            ### User input is EXIT
                    Write-ScreenAndLog "INFO" "User ended the script early."
                    exit
                }
            }
            ### Set DRS on the Cluster
            ### ---------------------------
            $setDRS =  Set-VCE.ClusterDRS -ClusterName $clusterName                                ### Set-VCE.ClusterDRS -ClusterName $clusterName
            Write-ScreenAndLog $setDRS[0] $setDRS[1]
            ### ---------------------------

        } until ($setDRS[2] -eq $true -or $skip -eq $true) #                                       ### Loop until the return value is true or the user ends the script
        ###-----------------------------------------------------------------------------------------------------

        exit # at Drs

        ###-----------------------------------------------------------------------------------------------------
        ###  EVC: Set-VCE.ClusterEVC Retry Loop
        ###-----------------------------------------------------------------------------------------------------
        $clusterName = "PDC1-C-LAB-HCI-TEST"
        Get-Cluster -Name $clusterName

        ### Istantiate the Check Variable
        $setEVC = ""
        do {
            if ($setEVC[2] -eq $false) {                                                            ### IF EVC Return value is false
                Write-ScreenAndLog "INFO" "Retry Setting HA on cluster $clusterName?`r`n"           ### Options Prompt
                Write-ScreenAndLog "INFO" "1)    Yes"
                Write-ScreenAndLog "INFO" "2)    No (ends the script)"
                $user_input = InputAndCheck -numOptions 2                                           ### Get user input

                if ($user_input -eq 2) {                                                            ### User input is EXIT
                    Write-ScreenAndLog "INFO" "User ended the script early."
                    exit
                }
            }
            ### Set EVC on the Cluster
            ### ---------------------------
            $setEVC =  Set-VCE.ClusterDRS -ClusterName $clusterName                                ### Set-VCE.ClusterEVC -ClusterName $clusterName
            Write-ScreenAndLog $setEVC[0] $setEVC[1]
            ### ---------------------------

        } until ($setEVC[2] -eq $true -or $skip -eq $true) #                                       ### Loop until the return value is true or the user ends the script
        ###-----------------------------------------------------------------------------------------------------

        #$clusterHAConfig = Get-Cluster $ClusterName | Select-Object -Property HAEnabled

        ### Get Licensing Totals
        ### ----------- --------------
        #Get-LicesnseTotals

        ############################
        ### Testing:
        ############################

        ### Info
        #Write-Log -Msg “This is a Test” -Cat “Info” -Color “White” -WriteToFile $true -WriteToConsole $true -LogFilePath “$PSScriptRoot\logs\” -LogFileName “$LogFilePath\log.txt” -debugMode $true

        ### Warning
        #Write-Log -Msg “This is a Warning" -Cat "Warning" -Color “White” -WriteToFile $true -WriteToConsole $true -LogFilePath “$PSScriptRoot\logs\” -LogFileName “$LogFilePath\log.txt”
    }
    end {
        Write-Host "End BootStrap: " -ForegroundColor DarkMagenta
    }
}


