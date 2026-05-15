### ConnectionStatus Enum
### Defines states for Microsoft Graph API connections

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

enum ConnectionStatus {
	Disconnected = 0  ### No active connection
	Connecting = 1    ### Connection attempt in progress
	Connected = 2     ### Successfully connected and authenticated
	Failed = 3        ### Connection attempt failed
	Expired = 4       ### Connection token expired, re-authentication required
}
