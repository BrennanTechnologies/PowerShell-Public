function Test-CertificateValidity {
	<#
	.SYNOPSIS
	    Internal helper function to validate certificate existence and properties.

	.DESCRIPTION
	    Checks if a certificate exists in the specified certificate store and validates its properties
	    including private key availability, expiration status, and days until expiry.
	    This is a private module function used internally by public functions like Connect-MgGraphAPI.

	.PARAMETER Thumbprint
	    The certificate thumbprint to validate. Required.
	    Format: 40-character hexadecimal string (e.g., "9055CBB6C4F436B8B7D9066537BC70380FD85554")

	.PARAMETER StorePath
	    The certificate store path to search.
	    Default: Cert:\CurrentUser\My
	    Other common paths: Cert:\LocalMachine\My, Cert:\CurrentUser\Root

	.INPUTS
	    None. This function does not accept pipeline input.

	.OUTPUTS
	    System.Management.Automation.PSCustomObject
	    Properties:
	    - IsValid: Boolean indicating if certificate is valid for use
	    - Certificate: X509Certificate2 object or $null
	    - HasPrivateKey: Boolean indicating if private key is available
	    - IsExpired: Boolean indicating if certificate is expired
	    - DaysUntilExpiry: Integer days until expiration (null if expired or not found)
	    - ErrorMessage: String error message if validation fails

	.EXAMPLE
	    $result = Test-CertificateValidity -Thumbprint "9055CBB6C4F436B8B7D9066537BC70380FD85554"
	    if ($result.IsValid) { Write-Host "Certificate is valid" }

	.EXAMPLE
	    Test-CertificateValidity -Thumbprint "ABC123..." -StorePath "Cert:\LocalMachine\My"
	    Validates certificate in the local machine store.

	.NOTES
	    Author: Chris Brennan, chris@brennantechnologies.com
	    Company: Brennan Technologies, LLC
	    Date: December 14, 2025
	    Version: 1.0

	    This is a private module function - not exported to users.
	    Used internally for certificate validation before Graph API connections.

	    Compatibility:
	    - Compliant w/ PowerShell 5.1+ and PowerShell Core to support automation for Azure Functions and Azure RunBooks, etc.

	    Validation Checks:
	    - Certificate exists in specified store
	    - Certificate has private key accessible
	    - Certificate is not expired
	    - Warns if certificate expires within 30 days
	#>

	[CmdletBinding()]
	[OutputType([PSCustomObject])]
	param(
		[Parameter(Mandatory = $true)]
		[string]$Thumbprint,

		[Parameter(Mandatory = $false)]
		[string]$StorePath = "Cert:\CurrentUser\My"
	)

	$result = [PSCustomObject]@{
		IsValid         = $false
		Certificate     = $null
		HasPrivateKey   = $false
		IsExpired       = $false
		DaysUntilExpiry = $null
		ErrorMessage    = $null
	}

	try {
		### Attempt to retrieve certificate
		$cert = Get-ChildItem -Path "$StorePath\$Thumbprint" -ErrorAction Stop

		if (-not $cert) {
			$result.ErrorMessage = "Certificate not found in store: $StorePath"
			return $result
		}

		$result.Certificate = $cert

		### Check for private key
		if ($cert.HasPrivateKey) {
			$result.HasPrivateKey = $true
		}
		else {
			$result.ErrorMessage = "Certificate exists but has no private key"
			return $result
		}

		### Check expiration
		$now = Get-Date
		if ($cert.NotAfter -lt $now) {
			$result.IsExpired = $true
			$result.ErrorMessage = "Certificate expired on $($cert.NotAfter)"
			return $result
		}

		### Calculate days until expiry
		$daysUntilExpiry = ($cert.NotAfter - $now).Days
		$result.DaysUntilExpiry = $daysUntilExpiry

		### Warn if expiring soon (within 30 days)
		if ($daysUntilExpiry -le 30) {
			Write-Warning "Certificate expires in $daysUntilExpiry days on $($cert.NotAfter)"
		}

		### All checks passed
		$result.IsValid = $true
		Write-Verbose "Certificate validation successful: $($cert.Subject)"
	}
	catch {
		$result.ErrorMessage = "Certificate validation failed: $($_.Exception.Message)"
		Write-Verbose $result.ErrorMessage
	}

	return $result
}
