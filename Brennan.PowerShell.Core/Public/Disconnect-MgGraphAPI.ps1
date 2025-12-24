function Disconnect-MgGraphAPI {
	<#
	.SYNOPSIS
	    Disconnect from Microsoft Graph API

	.DESCRIPTION
	    Safely disconnects the current Microsoft Graph API session and clears authentication context.
	    This function is a wrapper around Disconnect-MgGraph with additional logging and error handling.

	.INPUTS
	    None. This function does not accept pipeline input.

	.OUTPUTS
	    None. This function does not return output.

	.EXAMPLE
	    Disconnect-MgGraphAPI
	    Disconnects from the current Graph API session

	.EXAMPLE
	    Disconnect-MgGraphAPI -Verbose
	    Disconnects with verbose output

	.NOTES
	    Author: Chris Brennan, chris@brennantechnologies.com
	    Company: Brennan Technologies, LLC
	    Version: 1.0
	    Date: December 14, 2025

	    Requirements:
	    - Microsoft.Graph.Authentication module v2.0.0 or higher
	    - Active Microsoft Graph session

	    Compatibility:
	    - Compliant w/ PowerShell 5.1+ and PowerShell Core to support automation for Azure Functions and Azure RunBooks, etc.
	#>

	[CmdletBinding()]
	param()

	try {
		Write-Verbose "Disconnecting from Microsoft Graph..."

		### Check if there's an active session
		$context = Get-MgContext -ErrorAction SilentlyContinue

		if ($context) {
			Write-Verbose "Active session found - TenantId: $($context.TenantId), ClientId: $($context.ClientId)"

			Disconnect-MgGraph -ErrorAction Stop

			Write-Verbose "Successfully disconnected from Microsoft Graph"

			### Log if Write-Log is available
			if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
				Write-Log "Disconnected from Microsoft Graph" -Level Success
			}
		}
		else {
			Write-Verbose "No active Microsoft Graph session found"

			### Log if Write-Log is available
			if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
				Write-Log "No active Microsoft Graph session to disconnect" -Level Warning
			}
		}
	}
	catch {
		$errorMessage = "Failed to disconnect from Microsoft Graph: $($_.Exception.Message)"
		Write-Error $errorMessage

		### Log if Write-Log is available
		if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
			Write-Log $errorMessage -Level Error
		}

		throw
	}
}