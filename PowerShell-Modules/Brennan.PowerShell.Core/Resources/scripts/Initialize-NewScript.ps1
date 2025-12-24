<#
.SYNOPSIS
    Initialize a new PowerShell script from the Brennan.PowerShell.Core template

.DESCRIPTION
    Creates a new PowerShell script based on the Script Template.ps1, customized with
    the specified script name and optional parameters. The new script will be configured
    to use the Brennan.PowerShell.Core module with all best practices included.

.PARAMETER ScriptName
    Name of the new script (without .ps1 extension)

.PARAMETER OutputPath
    Directory where the new script will be created
    Default: Current directory

.PARAMETER IncludeGraphAPI
    Include Microsoft Graph API connection functions and required modules

.PARAMETER LogMode
    Default logging mode for the new script
    Valid values: Continuous, Daily, Session
    Default: Daily

.EXAMPLE
    .\Initialize-NewScript.ps1 -ScriptName "Get-UserReport"
    Creates Get-UserReport.ps1 in the current directory

.EXAMPLE
    .\Initialize-NewScript.ps1 -ScriptName "Sync-Data" -OutputPath "C:\Scripts" -IncludeGraphAPI
    Creates Sync-Data.ps1 with Graph API functions in C:\Scripts

.NOTES
    Author  : Chris Brennan
    Email   : chris@brennantechnologies.com
    Company : Brennan Technologies, LLC
    Version : 1.0
    Date    : 2025-12-14
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[string]$ScriptName,

	[Parameter(Mandatory = $false)]
	[string]$OutputPath = ".",

	[Parameter(Mandatory = $false)]
	[switch]$IncludeGraphAPI,

	[Parameter(Mandatory = $false)]
	[ValidateSet('Continuous', 'Daily', 'Session')]
	[string]$LogMode = 'Daily'
)

### Set error action preference
$ErrorActionPreference = 'Stop'

### Prompt for script name if not provided
if (-not $ScriptName) {
	$ScriptName = Read-Host "Enter the name for your new script (without .ps1 extension)"
	if ([string]::IsNullOrWhiteSpace($ScriptName)) {
		Write-Host "Script name is required. Operation cancelled." -ForegroundColor Red
		exit 1
	}
}

### Prompt for output path if not provided
if ($OutputPath -eq ".") {
	$outputPathInput = Read-Host "Enter output directory (press Enter for current directory '.')"
	if (-not [string]::IsNullOrWhiteSpace($outputPathInput)) {
		$OutputPath = $outputPathInput
	}
}

try {
	### Ensure script name doesn't have .ps1 extension
	$ScriptName = $ScriptName -replace '\.ps1$', ''

	### Get template path
	$templatePath = Join-Path $PSScriptRoot "Script Template.ps1"

	if (-not (Test-Path $templatePath)) {
		throw "Template file not found: $templatePath"
	}

	### Resolve output path
	$outputDir = Resolve-Path $OutputPath -ErrorAction Stop
	$newScriptPath = Join-Path $outputDir "$ScriptName.ps1"

	if (Test-Path $newScriptPath) {
		$response = Read-Host "Script '$newScriptPath' already exists. Overwrite? (Y/N)"
		if ($response -ne 'Y') {
			Write-Host "Operation cancelled." -ForegroundColor Yellow
			exit 0
		}
	}

	### Read template content
	Write-Host "Reading template from: $templatePath" -ForegroundColor Cyan
	$templateContent = Get-Content -Path $templatePath -Raw

	### Replace placeholders
	Write-Host "Customizing template for: $ScriptName" -ForegroundColor Cyan

	### Replace script name
	$newContent = $templateContent -replace 'YourScriptName', $ScriptName

	### Replace default log mode
	$newContent = $newContent -replace "LogMode = 'Daily'", "LogMode = '$LogMode'"

	### Update synopsis and description
	$newContent = $newContent -replace 'Brief description of what this script does', "Description for $ScriptName"
	$newContent = $newContent -replace "Detailed description of the script's functionality, including:", "Detailed description for ${ScriptName}:"

	### Update example script name in help
	$newContent = $newContent -replace '\\YourScript\.ps1', "\$ScriptName.ps1"

	### Remove Graph API functions if not needed
	if (-not $IncludeGraphAPI) {
		Write-Host "Removing Graph API functions (use -IncludeGraphAPI to include them)" -ForegroundColor Yellow

		### Remove Connect-GraphAPI function
		$newContent = $newContent -replace '(?s)function Connect-GraphAPI \{.*?\n\}', ''

		### Remove Graph API modules import section
		$newContent = $newContent -replace '(?s)### Import additional required modules.*?#endregion Module Import', '#endregion Module Import'

		### Remove Connect region in main execution
		$newContent = $newContent -replace '(?s)#region Connect.*?#endregion Connect\s*', ''
	}

	### Write new script
	Write-Host "Creating new script: $newScriptPath" -ForegroundColor Green
	Set-Content -Path $newScriptPath -Value $newContent -Encoding UTF8

	### Create Logs folder in same directory
	$logsFolder = Join-Path $outputDir "Logs"
	if (-not (Test-Path $logsFolder)) {
		Write-Host "Creating Logs folder: $logsFolder" -ForegroundColor Cyan
		New-Item -Path $logsFolder -ItemType Directory -Force | Out-Null
	}

	### Summary
	Write-Host "`nScript created successfully!" -ForegroundColor Green
	Write-Host "  Location: $newScriptPath" -ForegroundColor White
	Write-Host "  Log Mode: $LogMode" -ForegroundColor White
	Write-Host "  Graph API: $(if ($IncludeGraphAPI) { 'Included' } else { 'Not Included' })" -ForegroundColor White
	Write-Host "`nNext steps:" -ForegroundColor Yellow
	Write-Host "  1. Edit the script to customize functionality" -ForegroundColor White
	Write-Host "  2. Update the help documentation (synopsis, description, examples)" -ForegroundColor White
	Write-Host "  3. Implement your business logic in the function definitions" -ForegroundColor White
	Write-Host "  4. Test with -WhatIf parameter" -ForegroundColor White

	### Offer to open in editor
	$response = Read-Host "`nOpen script in VS Code? (Y/N)"
	if ($response -eq 'Y') {
		code $newScriptPath
	}
}
catch {
	Write-Host "Error creating script: $($_.Exception.Message)" -ForegroundColor Red
	exit 1
}
