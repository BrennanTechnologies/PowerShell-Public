function Connect-MgGraphAPI {
	<#
	.SYNOPSIS
	    Connect to Microsoft Graph API using app registration credentials from settings.json

	.DESCRIPTION
	    Reads app registration details (TenantId, ClientId, CertificateThumbprint) from settings.json
	    and establishes a connection to Microsoft Graph using certificate-based authentication.

	.PARAMETER SettingsPath
	    Path to the settings.json file. Default: .\settings.json

	.PARAMETER Scopes
	    Optional array of Graph API permission scopes to request.
	    When using certificate authentication, scopes are pre-configured in the app registration.

	.EXAMPLE
	    Connect-MgGraphAPI
	    Connects to Graph using settings from .\settings.json

	.EXAMPLE
	    Connect-MgGraphAPI -SettingsPath "C:\Config\settings.json"
	    Connects using settings from a specific path

	.NOTES
	    Author: Brennan Technologies
	    Version: 1.0
	    Date: December 14, 2025

	    Requirements:
	    - Microsoft.Graph.Authentication module
	    - Certificate with private key installed in CurrentUser\My store
	    - App registration with required Graph API permissions
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false)]
		[string]$SettingsPath = "C:\Users\brenn\OneDrive\Documents\__Repo\PowerShell\Work\KE\settings.json",

		[Parameter(Mandatory = $false)]
		[string[]]$Scopes
	)

	### Ensure Microsoft.Graph.Authentication module is available
	if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
		Write-Host "Installing Microsoft.Graph.Authentication module..." -ForegroundColor Yellow
		Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser -Force -AllowClobber
	}

	Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

	### Read settings file
	if (-not (Test-Path $SettingsPath)) {
		throw "Settings file not found: $SettingsPath"
	}

	Write-Verbose "Reading settings from: $SettingsPath"
	try {
		$settings = Get-Content -Path $SettingsPath -Raw | ConvertFrom-Json
	}
	catch {
		throw "Failed to parse settings.json: $($_.Exception.Message)"
	}

	### Validate required settings
	$requiredSettings = @('TenantId', 'ClientId', 'CertificateThumbprint')
	foreach ($setting in $requiredSettings) {
		if (-not $settings.$setting) {
			throw "Missing required setting: $setting"
		}
	}

	Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
	Write-Verbose "  Tenant ID: $($settings.TenantId)"
	Write-Verbose "  Client ID: $($settings.ClientId)"
	Write-Verbose "  Certificate Thumbprint: $($settings.CertificateThumbprint)"

	try {
		### Verify certificate exists
		$cert = Get-ChildItem -Path Cert:\CurrentUser\My\$($settings.CertificateThumbprint) -ErrorAction SilentlyContinue
		if (-not $cert) {
			throw "Certificate not found in CurrentUser\My store: $($settings.CertificateThumbprint)"
		}

		Write-Verbose "Certificate found: $($cert.Subject)"

		### Build connection parameters
		$connectParams = @{
			TenantId              = $settings.TenantId
			ClientId              = $settings.ClientId
			CertificateThumbprint = $settings.CertificateThumbprint
			NoWelcome             = $true
			ErrorAction           = 'Stop'
		}

		### Add scopes if provided (note: with certificate auth, scopes are typically pre-configured)
		if ($Scopes) {
			$connectParams.Scopes = $Scopes
		}

		### Connect to Microsoft Graph
		Connect-MgGraph @connectParams

		### Verify connection
		$context = Get-MgContext
		if ($context) {
			Write-Host "✓ Successfully connected to Microsoft Graph" -ForegroundColor Green
			Write-Host "  Tenant: $($context.TenantId)" -ForegroundColor Gray
			Write-Host "  App ID: $($context.ClientId)" -ForegroundColor Gray
			Write-Host "  Auth Type: $($context.AuthType)" -ForegroundColor Gray

			if ($context.Scopes) {
				Write-Host "  Scopes: $($context.Scopes -join ', ')" -ForegroundColor Gray
			}

			return $context
		}
		else {
			throw "Connection established but context is null"
		}
	}
	catch {
		Write-Host "✗ Failed to connect to Microsoft Graph" -ForegroundColor Red
		Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red

		Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
		Write-Host "  1. Verify certificate is installed: Get-ChildItem Cert:\CurrentUser\My\$($settings.CertificateThumbprint)" -ForegroundColor Yellow
		Write-Host "  2. Verify app registration has required API permissions" -ForegroundColor Yellow
		Write-Host "  3. Verify admin consent is granted for app permissions" -ForegroundColor Yellow
		Write-Host "  4. Check certificate has private key and is not expired" -ForegroundColor Yellow

		throw
	}
}

### If script is run directly (not dot-sourced), execute the function
if ($MyInvocation.InvocationName -ne '.') {
	Connect-MgGraphAPI
}

Connect-MgGraphAPI
