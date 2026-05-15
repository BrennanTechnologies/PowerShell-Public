<#
.SYNOPSIS
    Test script for Brennan.PowerShell.Core module

.DESCRIPTION
    Imports the Brennan.PowerShell.Core module, connects to Microsoft Graph using certificate authentication,
    and retrieves API permissions using Get-MgGraphAPIPermissions.

.PARAMETER LogMode
    Logging mode for Write-Log function. Valid values: Continuous, Daily, Session. Default: Daily

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    None. Displays connection status and permissions to console, writes to log files.

.EXAMPLE
    .\Test-GraphConnection.ps1
    Connects to Graph and retrieves permissions with daily logging.

.EXAMPLE
    .\Test-GraphConnection.ps1 -LogMode Continuous
    Uses continuous logging mode (single log file).

.NOTES
    Author: Chris Brennan, chris@brennantechnologies.com
    Company: Brennan Technologies, LLC
    Date: December 14, 2025
    Version: 1.0

    Requirements:
    - PowerShell 5.1 or higher
    - settings.json file with app registration details
    - Certificate installed in CurrentUser\My store
    - Microsoft.Graph.Authentication module

    Compatibility:
    - Compliant w/ PowerShell 5.1+ and PowerShell Core to support automation for Azure Functions and Azure RunBooks, etc.
#>[CmdletBinding()]
param(
	[Parameter(Mandatory = $false)]
	[ValidateSet('Continuous', 'Daily', 'Session')]
	[string]$LogMode = 'Daily'
)

### Set script-level LogMode to override Write-Log default
$script:LogMode = $LogMode

### Get module path
$ModulePath = Join-Path -Path $PSScriptRoot -ChildPath "Brennan.PowerShell.Core.psd1"

### Import module
Write-Host "Importing Brennan.PowerShell.Core module..." -ForegroundColor Cyan
try {
	Import-Module $ModulePath -Force -ErrorAction Stop
	Write-Host "✓ Module imported successfully" -ForegroundColor Green
}
catch {
	Write-Host "✗ Failed to import module: $($_.Exception.Message)" -ForegroundColor Red
	exit 1
}

### Connect to Microsoft Graph
Write-Log "Connecting to Microsoft Graph..." -Level Info
try {
	$context = Connect-MgGraphAPI -Verbose

	if (-not $context) {
		throw "Connection failed - no context returned"
	}
}
catch {
	Write-Log "Failed to connect: $($_.Exception.Message)" -Level Error
	exit 1
}

### Get API permissions using the new function
Write-Log "Retrieving API permissions..." -Level Info
try {
	Get-MgGraphAPIPermissions -OutputFormat Console
}
catch {
	Write-Log "Failed to retrieve permissions: $($_.Exception.Message)" -Level Error
	exit 1
}

Write-Log "Script completed successfully" -Level Success
