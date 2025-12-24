### GraphAPIConnection Class
### Manages Microsoft Graph API connection state and context

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

class GraphAPIConnection {
	[string]$TenantId
	[string]$ClientId
	[AuthenticationType]$AuthType
	[ConnectionStatus]$Status
	[datetime]$ConnectedAt
	[datetime]$ExpiresAt
	[string[]]$Scopes

	### Constructor with required parameters
	GraphAPIConnection([string]$tenantId, [string]$clientId, [AuthenticationType]$authType) {
		$this.TenantId = $tenantId
		$this.ClientId = $clientId
		$this.AuthType = $authType
		$this.Status = [ConnectionStatus]::Disconnected
		$this.Scopes = @()
	}

	### Check if connection is still valid
	[bool]IsValid() {
		if ($this.Status -ne [ConnectionStatus]::Connected) {
			return $false
		}
		if ($this.ExpiresAt -lt (Get-Date)) {
			$this.Status = [ConnectionStatus]::Expired
			return $false
		}
		return $true
	}

	### Update connection status
	[void]UpdateStatus([ConnectionStatus]$newStatus) {
		$this.Status = $newStatus
		if ($newStatus -eq [ConnectionStatus]::Connected) {
			$this.ConnectedAt = Get-Date
		}
	}

	### Add scopes to connection
	[void]AddScopes([string[]]$scopes) {
		foreach ($scope in $scopes) {
			if ($this.Scopes -notcontains $scope) {
				$this.Scopes += $scope
			}
		}
	}
}
