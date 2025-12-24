### Brennan.BootStrap.ps1

<#
	Description:
    ------------------------------------------------------------
	Boot Strap - "Login Script"

    Version:
    ------------------------------------------------------------
	11.22.21
	5:55PM

	Author      = 'Chris Brennan'
	CompanyName = 'Brennan Technologies'
	Copyright   = '(c) 2021 Brennan Technologies, LLC "All rights reserved, for Use with Permission Only"'


    NOTES:
    ------------------------------------------------------------
	Required Modules:
	$RequiredModules = @(
							"Brennan"
							,
							"Brennan.Core"
						)

#>

###===========================================================
### 		Set Global Variables & Constants
###===========================================================
	### Global & Script Level Variables
	###-----------------
	$global:debugMode				= $true
	$global:debugMsgPrefix			= "DEBUG: "
	$global:InformationPreference	= $InformationPreference
	$script:ScriptPath				= $PSScriptRoot

	### Other Environment Variables
	###-----------------
	$ProgressPreference				= $ProgressPreference
	$ErrorActionPreference			= $ErrorActionPreference

	### CONSTANTS
	###-----------------
	$CONT_LOGLEVEL					= "INFO"
	$CONT_LOGLEVEL_DEBUG			= "DEBUG"
	$CONT_LOGLEVEL_ERROR			= "ERROR"
	$CONT_LOGLEVEL_WARNING			= "WARNING"
	$CONT_LOGLEVEL_VERBOSE			= "VERBOSE"
	$CONT_LOGLEVEL_NONE				= "NONE"

###===========================================================

<#
#Requires -Module 1
#Requires -Module 2
#Requires -Module RequiredModule1
#Requires -Module @{ModuleName = 'RequiredModule2'; ModuleVersion = '1.0'}
#Requires -Module @{ModuleName = 'RequiredModule3'; RequiredVersion = '2.0'}
#Requires -Module ExternalModule1

#>
function Set-PSModulePath {
	<#
	.SYNOPSIS
	Adds custom paths to the $PSModulePath variable.

	.DESCRIPTION
	Adds custom paths to the $PSModulePath variable. This is useful for adding custom modules to the path.

	- Adds custom paths to the $PSModulePath variable.
	- Removes UNC Paths
	- Test-Path exists on the path
	- Removes duplicate paths

	.PARAMETER ModulePaths
	[string[]]
	Array of paths to add to the $PSModulePath variable.

	.PARAMETER debugMode
	[bool]
	If true, will print debug messages.

	.EXAMPLE
    $modulePath = "C:\Users\brenn\OneDrive\___CB Docs\_Repo\PowerShell\WindowsPowerShell"
    $env:PSModulePath = "$($env:PSModulePath -split ';' -notmatch "\\\\" -join ";");$modulePath"
    $env:PSModulePath -split ';'

	.NOTES
	General notes
	#>

	[CmdletBinding()]
	param (
		[Parameter()]
		[string[]]
		$ModulePaths = @()
		,
		[Parameter()]
		[bool]
		$debugMode = $true
	)
	begin {
		Write-Host "Function: " $((Get-PSCallStack)[0].Command) -ForegroundColor DarkGray
		if($debugMode){
			foreach($modulePath in $modulePaths){
				Write-Host "Adding Module Path: " $modulePath -ForegroundColor DarkGray
			}
		}
	}
	process {
		foreach($modulePath in $modulePaths){
			if((Test-Path $ModulePath)){
				if($env:PSModulePath.Split(";").Contains($modulePath) -eq $false){                                        ### If the path is not already in the PSModulePath, add it.
					Write-Host "Adding New ModulePath"  $modulePath -ForegroundColor Green
					$env:PSModulePath = "$($env:PSModulePath -split ';' -notmatch "\\\\" -join ";");$modulePath"          ### Remove any UNC paths & Add my Paths.
				} else {
					Write-Host "Skipping: Module Path already in PSModulePath: $modulePath" -ForegroundColor Cyan
				}
			} else {
				Write-Host "Module Path does not exist" -ForegroundColor Red
			}
		}
	}
	end {
		if($debugMode) {
			foreach($path in $env:PSModulePath.Split(';')){
				Write-Host "Current ModulePath`t $path" -ForegroundColor DarkGray
			}

		}
	}
}
function Import-RequiredModules {
	<#
	.SYNOPSIS
	Imports all a list of custom modunes.

	.DESCRIPTION
		- Force Imports all a list of custom modunes.
		- Prompt User to Reloadc
		- Display the modules when loaded.

	.PARAMETER RequiredModules
	[string[]]
	Array of required modules to import.

	.PARAMETER DebugMode
	[bool]
	If true, will print debug messages.

	.EXAMPLE
	Import-Module "Brennan -Force"

	.NOTES
		### Get Commands
		### Get-Command -Module Brennan.VCE
	#>
	[CmdletBinding()]
	param (
		[Parameter()]
		[string[]]
		$RequiredModules = @(
			"Brennan"
			#,
			#"Brennan"
			#,
			#"Brennan.VCE"
			#,
			#"VMWare.Vim*"
			#,
			#"Brennan.Core"
			#,
			#"Brennan.CodeSigning"
		)
		,
		[Parameter()]
		[bool]
		$DebugMode # = $true
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
							if($debugMode){
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
					if( [bool](Get-Module -Name $module -ListAvailable) -eq $true ){                        ### Check if module exists
						Write-Host "Importing Module: " $module -ForegroundColor Magenta
						if($DebugMode){
							Get-Module -Name $module -ListAvailable | Import-Module -Force #-Verbose        ### Force & Verbose
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

		### Set-ModulePath 																								### Modify $PSModulepath:   Adds Custom $PSModulepath, removes UNC paths
		###------------------------------------------------
		Set-PSModulePath -ModulePaths @(
										#"C:\WindowsPowerShell\Modules"													### Brennan Lab
										#,
										#"C:\Users\brenn\OneDrive\___CB Docs\_Repo\Clients\Brennan"						### CB Lab
										#,
										"C:\Users\brenn\OneDrive\___CB Docs\_Repo\PowerShell\WindowsPowerShell"			### CB Lab
                                        ,
                                        "C:\Users\brenn\OneDrive\___CB Docs\_Repo\Clients\Brennan"
									)

		### Import-RequiredModules                                              ### Imports an array of Custom modules
		###------------------------------------------------
		[string[]]$RequiredModules = @(
			"Brennan"
			#,
			#"Brennan.VCE.All"
			#,
			#"Brennan.VCE"
		)
		Import-RequiredModules -RequiredModules $RequiredModules


		### Import VMWare Modules                                               ### Skip  if already loaded
		###------------------------------------------------
		function Import-VMWareModules {
			[CmdletBinding()]
			param ([Parameter()][string]$Load)
			if( ($Load.ToUpper() -eq "Y") -and (-not $(Get-Module vmware.vim*) )){
				Write-Host "Importing VMWare Modules" -ForegroundColor Magenta
				Get-Module vmware.vim* -ListAvailable | Import-Module
			}
		} Import-VMWareModules -Load "N"   ### Y=Load, N=Skip


		###################################################
		### Brennan Testing
		###################################################

        #Get-AppxPackage -name “Microsoft.Office.Desktop”
        Get-AppxPackage -name “Microsoft.Off*” | Remove-AppxPackage

        <##>
		Write-Log -Category Info -Message "This is a INFO"
		Write-Log -Category Info -Message "This is a INFO2" -Color Cyan

		Write-Log -Category WARN -Message "This is a WARN"
		Write-Log -Category WARN -Message "This is a WARN2" -Color Red

		#Write-Log -Category ERROR -Message "This is a ERROR purposly sent by CB."

		Write-Log -Category Info -Message "This is a test" -Color Green

		Exit
		#>

		###################################################
		### Brennan Testing
		###################################################
		<#
		###################################################
		### Brennan Testing
		###################################################

		### RACKADD
		$buildType = "RACKADD1"
		if ($buildType -eq "RACKADD") {
			$clusterName = "PDC1-C-LAB-HCI-TEST"
			$clusterHA = Get-VCE.ClusterHA -ClusterName $clusterName
			$clusterHA
		}

		### NEWBUILD
		if ($buildType -eq "NEWBUILD1") {
			$clusterName = "PDC1-C-LAB-HCI-TEST"
			$clusterHA = Set-VCE.ClusterHA -ClusterName $clusterName
			$clusterHA
		}
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
		#>

	}
	end {
		Write-Host "End BootStrap: " -ForegroundColor DarkMagenta
	}
}


