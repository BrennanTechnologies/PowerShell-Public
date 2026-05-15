function Import-RequiredModules {
	<#
	.SYNOPSIS
	    Import and install required PowerShell modules

	.DESCRIPTION
	    Imports an array of PowerShell modules, automatically installing any that are missing.
	    Supports both module names and file paths. Provides detailed logging of import status.

	.PARAMETER Modules
	    Array of module names or file paths to import.
	    File paths should be absolute paths to .psd1 or .psm1 files.
	    Module names should be standard PowerShell module names available in PSGallery.
	    Accepts pipeline input.

	.PARAMETER Scope
	    Installation scope for missing modules. Valid values: CurrentUser, AllUsers.
	    Default: CurrentUser

	.PARAMETER Force
	    Force reimport of modules even if already loaded.
	    Default: $true

	.INPUTS
	    System.String[]
	    Accepts array of module names or file paths via pipeline.

	.OUTPUTS
	    None. Writes status to console and logs via Write-Log.

	.EXAMPLE
	    Import-RequiredModules -Modules @("Microsoft.Graph.Users", "Microsoft.Graph.Reports")
	    Imports Microsoft Graph modules, installing if needed.

	.EXAMPLE
	    Import-RequiredModules -Modules @("C:\Modules\MyModule.psd1", "Az.Accounts")
	    Imports a local module by path and Az.Accounts from gallery.

	.EXAMPLE
	    $modules = @("Microsoft.Graph.Users", "Microsoft.Graph.Authentication")
	    Import-RequiredModules -Modules $modules -Scope AllUsers
	    Imports modules with AllUsers scope for installations.

	.EXAMPLE
	    "Microsoft.Graph.Users", "Az.Accounts" | Import-RequiredModules
	    Imports modules via pipeline input.

	.NOTES
	    Author: Chris Brennan, chris@brennantechnologies.com
	    Company: Brennan Technologies, LLC
	    Date: December 14, 2025
	    Version: 1.0

	    Compatibility:
	    - Compliant w/ PowerShell 5.1+ and PowerShell Core to support automation for Azure Functions and Azure RunBooks, etc.
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string[]]$Modules,

		[Parameter(Mandatory = $false)]
		[ValidateSet('CurrentUser', 'AllUsers')]
		[string]$Scope = 'CurrentUser',

		[Parameter(Mandatory = $false)]
		[switch]$Force = $true
	)

	Begin {
		Write-Log "Importing required modules..." -Level Header
	}

	Process {
		foreach ($module in $Modules) {
			try {
				### Check if it's a path or module name
				if (Test-Path $module -ErrorAction SilentlyContinue) {
					### It's a file path
					$moduleName = Split-Path -Path $module -Leaf
					Write-Log "Importing module from path: $moduleName" -Level Info
					Import-Module $module -Force:$Force -ErrorAction Stop
					Write-Log "Module imported: $moduleName" -Level Success
				}
				else {
					### It's a module name - check if available
					Write-Log "Checking for module: $module" -Level Info

					if (-not (Get-Module -ListAvailable -Name $module)) {
						Write-Log "Module not found - installing $module from PSGallery..." -Level Warning
						Install-Module -Name $module -Scope $Scope -Force -AllowClobber -ErrorAction Stop
						Write-Log "Module installed: $module" -Level Success
					}

					Import-Module $module -Force:$Force -ErrorAction Stop
					Write-Log "Module imported: $module" -Level Success
				}
			}
			catch {
				Write-Log "Failed to import module: $module" -Level Error
				Write-Log "Error: $($_.Exception.Message)" -Level Error
				throw "Module import failed: $module"
			}
		}
	}

	End {
		Write-Log "All required modules loaded successfully" -Level Success
	}
}
