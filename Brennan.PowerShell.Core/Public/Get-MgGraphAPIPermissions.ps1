function Get-MgGraphAPIPermissions {
	<#
	.SYNOPSIS
	    Retrieve API permissions for a Microsoft Graph service principal.

	.DESCRIPTION
	    Connects to Microsoft Graph and retrieves both application permissions (app roles)
	    and delegated permissions (OAuth2 grants) for the authenticated service principal.
	    Displays detailed information including permission scopes, resources, and descriptions.
	    Supports multiple output formats for different use cases (console display, object manipulation, summary view).

	.PARAMETER AppId
	    The Application (Client) ID to query.
	    If not specified, uses the currently connected app from Get-MgContext.
	    Format: GUID (e.g., "7f5ffe8f-b0b2-4c1a-8cfc-430124f125dd")

	.PARAMETER OutputFormat
	    The output format for results. Valid values:
	    - Console: Formatted display with Write-Log (default)
	    - Object: Returns PSCustomObject with full permission details
	    - Summary: Returns PSCustomObject with permission counts only
	    Default: Console

	.INPUTS
	    None. This function does not accept pipeline input.

	.OUTPUTS
	    System.Management.Automation.PSCustomObject (when OutputFormat is Object or Summary)
	    Properties include:
	    - AppName: Service principal display name
	    - AppId: Application (client) ID
	    - ObjectId: Service principal object ID
	    - TenantId: Azure AD tenant ID
	    - ApplicationPermissions: Array of app role assignments
	    - DelegatedPermissions: Array of OAuth2 permission grants
	    - ApplicationPermissionCount: Count of app permissions
	    - DelegatedPermissionCount: Count of delegated permissions
	    - TotalPermissions: Total permission count

	    None (when OutputFormat is Console) - outputs to console via Write-Log

	.EXAMPLE
	    Get-MgGraphAPIPermissions
	    Retrieves permissions for the currently connected app and displays to console.

	.EXAMPLE
	    Get-MgGraphAPIPermissions -OutputFormat Object
	    Returns permissions as PowerShell objects for further processing.

	.EXAMPLE
	    $permissions = Get-MgGraphAPIPermissions -AppId "7f5ffe8f-b0b2-4c1a-8cfc-430124f125dd" -OutputFormat Object
	    Retrieves permissions for a specific application as an object.

	.EXAMPLE
	    Get-MgGraphAPIPermissions -OutputFormat Summary | Format-List
	    Displays permission summary with counts only.

	.EXAMPLE
	    $perms = Get-MgGraphAPIPermissions -OutputFormat Object
	    $perms.ApplicationPermissions | Where-Object {$_.Permission -like "*Write*"}
	    Retrieves permissions and filters for write permissions.

	.NOTES
	    Author: Chris Brennan, chris@brennantechnologies.com
	    Company: Brennan Technologies, LLC
	    Date: December 14, 2025
	    Version: 1.0

	    Requirements:
	    - PowerShell 5.1 or higher
	    - Must be connected to Microsoft Graph (use Connect-MgGraphAPI first)
	    - Requires permissions to read service principals and permission grants
	    - Recommended permissions: Directory.Read.All or Application.Read.All

	    Compatibility:
	    - Compliant w/ PowerShell 5.1+ and PowerShell Core to support automation for Azure Functions and Azure RunBooks, etc.

	    Permission Types:
	    - Application Permissions (App Roles): Used for app-only access
	    - Delegated Permissions (OAuth2 Grants): Used for user-delegated access
	#>

	[CmdletBinding()]
	[OutputType([PSCustomObject])]
	param(
		[Parameter(Mandatory = $false)]
		[string]$AppId,

		[Parameter(Mandatory = $false)]
		[ValidateSet('Console', 'Object', 'Summary')]
		[string]$OutputFormat = 'Console'
	)

	### Verify connection to Microsoft Graph
	$context = Get-MgContext
	if (-not $context) {
		throw "Not connected to Microsoft Graph. Please run Connect-MgGraphAPI first."
	}

	### Use current app if not specified
	if (-not $AppId) {
		$AppId = $context.ClientId
		Write-Verbose "Using currently connected app: $AppId"
	}

	try {
		### Get the service principal for the app
		Write-Verbose "Looking up service principal for AppId: $AppId"
		$uri = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '$AppId'"
		$spResponse = Invoke-MgGraphRequest -Method GET -Uri $uri

		if (-not $spResponse.value -or $spResponse.value.Count -eq 0) {
			throw "Service principal not found for AppId: $AppId"
		}

		$servicePrincipal = $spResponse.value[0]
		$spId = $servicePrincipal.id

		Write-Verbose "Service Principal: $($servicePrincipal.displayName) (ObjectId: $spId)"

		### Get App Role Assignments (Application permissions)
		Write-Verbose "Retrieving application permissions..."
		$appRolesUri = "https://graph.microsoft.com/v1.0/servicePrincipals/$spId/appRoleAssignments"
		$appRolesResponse = Invoke-MgGraphRequest -Method GET -Uri $appRolesUri

		$applicationPermissions = @()
		if ($appRolesResponse.value -and $appRolesResponse.value.Count -gt 0) {
			foreach ($assignment in $appRolesResponse.value) {
				### Get the resource service principal to lookup the role name
				$resourceSpUri = "https://graph.microsoft.com/v1.0/servicePrincipals/$($assignment.resourceId)"
				$resourceSp = Invoke-MgGraphRequest -Method GET -Uri $resourceSpUri

				### Find the matching app role
				$appRole = $resourceSp.appRoles | Where-Object { $_.id -eq $assignment.appRoleId }

				$applicationPermissions += [PSCustomObject]@{
					Permission  = $appRole.value
					Resource    = $resourceSp.displayName
					Description = $appRole.description
					Type        = 'Application'
				}
			}
		}

		### Get OAuth2 Permission Grants (Delegated permissions)
		Write-Verbose "Retrieving delegated permissions..."
		$oauth2Uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$spId/oauth2PermissionGrants"
		$oauth2Response = Invoke-MgGraphRequest -Method GET -Uri $oauth2Uri

		$delegatedPermissions = @()
		if ($oauth2Response.value -and $oauth2Response.value.Count -gt 0) {
			foreach ($grant in $oauth2Response.value) {
				### Get the resource service principal
				$resourceSpUri = "https://graph.microsoft.com/v1.0/servicePrincipals/$($grant.resourceId)"
				$resourceSp = Invoke-MgGraphRequest -Method GET -Uri $resourceSpUri

				$scopes = $grant.scope -split ' ' | Where-Object { $_ }

				foreach ($scope in $scopes) {
					### Find the matching OAuth2 permission
					$permission = $resourceSp.oauth2PermissionScopes | Where-Object { $_.value -eq $scope }

					$delegatedPermissions += [PSCustomObject]@{
						Permission  = $scope
						Resource    = $resourceSp.displayName
						Description = if ($permission.adminConsentDescription) { $permission.adminConsentDescription } elseif ($permission.userConsentDescription) { $permission.userConsentDescription } else { 'N/A' }
						ConsentType = $grant.consentType
						Type        = 'Delegated'
					}
				}
			}
		}

		### Build result object
		$result = [PSCustomObject]@{
			AppName                    = $servicePrincipal.displayName
			AppId                      = $AppId
			ObjectId                   = $spId
			TenantId                   = $context.TenantId
			ApplicationPermissions     = $applicationPermissions
			DelegatedPermissions       = $delegatedPermissions
			ApplicationPermissionCount = $applicationPermissions.Count
			DelegatedPermissionCount   = $delegatedPermissions.Count
			TotalPermissions           = $applicationPermissions.Count + $delegatedPermissions.Count
		}

		### Output based on format
		switch ($OutputFormat) {
			'Object' {
				return $result
			}
			'Summary' {
				return [PSCustomObject]@{
					AppName                    = $result.AppName
					AppId                      = $result.AppId
					TenantId                   = $result.TenantId
					ApplicationPermissionCount = $result.ApplicationPermissionCount
					DelegatedPermissionCount   = $result.DelegatedPermissionCount
					TotalPermissions           = $result.TotalPermissions
				}
			}
			'Console' {
				### Display formatted output
				Write-Log "Service Principal: $($result.AppName)" -Level Success
				Write-Log "Object ID: $($result.ObjectId)" -Level SubItem

				### Application Permissions
				Write-Log "Application Permissions (App Roles)" -Level Header
				if ($result.ApplicationPermissions.Count -gt 0) {
					foreach ($perm in $result.ApplicationPermissions) {
						Write-Log "• $($perm.Permission)" -Level SubItem
						Write-Host "    Resource: $($perm.Resource)" -ForegroundColor Gray
						Write-Host "    Description: $($perm.Description)" -ForegroundColor Gray
					}
				}
				else {
					Write-Log "No application permissions assigned" -Level SubItem
				}

				### Delegated Permissions
				Write-Log "Delegated Permissions (OAuth2 Grants)" -Level Header
				if ($result.DelegatedPermissions.Count -gt 0) {
					$groupedByResource = $result.DelegatedPermissions | Group-Object -Property Resource
					foreach ($group in $groupedByResource) {
						Write-Log "Resource: $($group.Name)" -Level SubItem
						Write-Host "  Consent Type: $($group.Group[0].ConsentType)" -ForegroundColor Gray
						Write-Host "  Scopes:" -ForegroundColor Gray
						foreach ($perm in $group.Group) {
							Write-Host "    • $($perm.Permission)" -ForegroundColor Cyan
							Write-Host "      $($perm.Description)" -ForegroundColor Gray
						}
						Write-Host ""
					}
				}
				else {
					Write-Log "No delegated permissions assigned" -Level SubItem
				}

				### Summary
				Write-Log "Summary" -Level Header
				Write-Host "App Name: $($result.AppName)" -ForegroundColor White
				Write-Host "App ID: $($result.AppId)" -ForegroundColor White
				Write-Host "Tenant ID: $($result.TenantId)" -ForegroundColor White
				Write-Host "Application Permissions: $($result.ApplicationPermissionCount)" -ForegroundColor White
				Write-Host "Delegated Permissions: $($result.DelegatedPermissionCount)" -ForegroundColor White
			}
		}
	}
	catch {
		Write-Log "Error retrieving permissions: $($_.Exception.Message)" -Level Error

		if ($_.ErrorDetails.Message) {
			$errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
			if ($errorDetail.error) {
				Write-Log "Error Code: $($errorDetail.error.code)" -Level Error
				Write-Log "Error Message: $($errorDetail.error.message)" -Level Error
			}
		}

		throw
	}
}
