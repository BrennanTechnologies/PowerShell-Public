<#
.SYNOPSIS
    Demonstration script for Brennan.PowerShell.Core module

.DESCRIPTION
    Imports the Brennan.PowerShell.Core module and demonstrates all exported functions:
    - Connect-MgGraphAPI: Connects to Microsoft Graph using certificate authentication
    - Write-Log: Logs messages with various severity levels
    - Get-MgGraphAPIPermissions: Retrieves and displays API permissions

.PARAMETER SkipConnection
    Switch to skip the Microsoft Graph connection demonstration.

.PARAMETER PermissionsOutputFormat
    Format for permissions output. Valid values: Console, Object, Summary. Default: Console

.PARAMETER LogMode
    Logging mode for Write-Log function. Valid values: Continuous, Daily, Session. Default: Daily

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    None. Displays formatted output to console and writes to log files.

.EXAMPLE
    .\Brennan.PowerShell.Core.ps1
    Runs full demonstration with default settings.

.EXAMPLE
    .\Brennan.PowerShell.Core.ps1 -SkipConnection
    Demonstrates logging without connecting to Microsoft Graph.

.EXAMPLE
    .\Brennan.PowerShell.Core.ps1 -PermissionsOutputFormat Object -LogMode Session
    Runs with object output format and session-based logging.

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
	[Parameter(Mandatory = $false)]
	[ValidateSet('Console', 'Object', 'Summary')]
	[string]$PermissionsOutputFormat = 'Console',

	[Parameter(Mandatory = $false)]
	[ValidateSet('Continuous', 'Daily', 'Session')]
	[string]$LogMode = 'Continuous'
)

### Set script-level LogMode to override Write-Log default
$script:LogMode = $LogMode


### Get module path
$ModulePath = Join-Path -Path $PSScriptRoot -ChildPath "Brennan.PowerShell.Core.psd1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Brennan.PowerShell.Core Module" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

#region Module Import
Write-Host "Importing Modules..." -ForegroundColor Yellow
try {
	Import-Module $ModulePath -Force -ErrorAction Stop
	Write-Host "✓ Module imported successfully" -ForegroundColor Green

	### List exported functions
	$exportedFunctions = (Get-Module Brennan.PowerShell.Core).ExportedFunctions.Keys
	Write-Host "  Exported Functions: $($exportedFunctions -join ', ')" -ForegroundColor Gray
}
catch {
	Write-Host "✗ Failed to import module: $($_.Exception.Message)" -ForegroundColor Red
	exit 1
}
#endregion

#region Write-Log Demonstration
Write-Host "`nDemonstrating Write-Log Function..." -ForegroundColor Yellow
Write-Host "Testing different log levels:" -ForegroundColor Gray

Write-Log "This is an informational message" -Level Info
Write-Log "This is a success message" -Level Success
Write-Log "This is a warning message" -Level Warning
Write-Log "This is an error message (non-terminating)" -Level Error
Write-Log "This is a verbose message" -Level Verbose
Write-Log "Section Header" -Level Header
Write-Log "Sub-item entry" -Level SubItem

Write-Host "✓ Write-Log demonstration complete" -ForegroundColor Green
#endregion

#region Connect-MgGraphAPI
$existingContext = Get-MgContext

if (-NOT $existingContext) {
	Write-Log "Already connected to Microsoft Graph" -Level Info
	Write-Log "Tenant: $($existingContext.TenantId)" -Level SubItem
	Write-Log "App: $($existingContext.ClientId)" -Level SubItem
}
else {
	Write-Log "Connecting to Microsoft Graph..." -Level Info
	$context = Connect-MgGraphAPI -Verbose
}


#region Get-MgGraphAPIPermissions Demonstration
Write-Host "`nDemonstrating Get-MgGraphAPIPermissions Function..." -ForegroundColor Yellow

### ***Verify connection before attempting to get permissions
$context = Get-MgContext

if (-not $context) {
	Write-Log "Not connected to Microsoft Graph - skipping permissions retrieval" -Level Warning
	Write-Host "  Run without -SkipConnection to see full demo" -ForegroundColor Gray
}
else {
	try {
		Write-Log "Retrieving API permissions..." -Level Info

		switch ($PermissionsOutputFormat) {
			'Console' {
				Write-Host "`nPermissions Report (Console Format):" -ForegroundColor Cyan
				Get-MgGraphAPIPermissions -OutputFormat Console
			}
			'Object' {
				Write-Host "`nPermissions Report (Object Format):" -ForegroundColor Cyan
				$permissions = Get-MgGraphAPIPermissions -OutputFormat Object

				Write-Host "`nApplication Permissions:" -ForegroundColor Yellow
				$permissions.ApplicationPermissions | Format-Table Permission, Resource, Description -AutoSize

				Write-Host "`nDelegated Permissions:" -ForegroundColor Yellow
				$permissions.DelegatedPermissions | Format-Table Permission, Resource, ConsentType -AutoSize

				Write-Host "`nSummary:" -ForegroundColor Yellow
				Write-Host "  Total Application Permissions: $($permissions.ApplicationPermissionCount)" -ForegroundColor Gray
				Write-Host "  Total Delegated Permissions: $($permissions.DelegatedPermissionCount)" -ForegroundColor Gray
				Write-Host "  Grand Total: $($permissions.TotalPermissions)" -ForegroundColor Gray
			}
			'Summary' {
				Write-Host "`nPermissions Report (Summary Format):" -ForegroundColor Cyan
				$summary = Get-MgGraphAPIPermissions -OutputFormat Summary
				$summary | Format-List
			}
		}

		Write-Log "Permissions retrieval complete" -Level Success
	}
	catch {
		Write-Log "Failed to retrieve permissions: $($_.Exception.Message)" -Level Error

		if ($_.ErrorDetails.Message) {
			$errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
			if ($errorDetail.error) {
				Write-Log "Error Code: $($errorDetail.error.code)" -Level Error
			}
		}
	}
}
#endregion

#region Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Module Demonstration Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nAvailable Functions:" -ForegroundColor Yellow
Write-Host "  • Connect-MgGraphAPI       - Connect to Microsoft Graph with certificate auth" -ForegroundColor Gray
Write-Host "  • Write-Log                - Write formatted log messages" -ForegroundColor Gray
Write-Host "  • Get-MgGraphAPIPermissions - Retrieve API permissions for service principal" -ForegroundColor Gray

Write-Host "`nExample Usage:" -ForegroundColor Yellow
Write-Host "  Import-Module '$ModulePath'" -ForegroundColor Gray
Write-Host "  Connect-MgGraphAPI" -ForegroundColor Gray
Write-Host "  Get-MgGraphAPIPermissions -OutputFormat Summary" -ForegroundColor Gray
Write-Host "  Write-Log 'Operation complete' -Level Success" -ForegroundColor Gray

Write-Log "`nAll demonstrations completed successfully!" -Level Success
#endregion
