### AuthenticationType Enum
### Defines authentication methods for Microsoft Graph API

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2023-10-01


enum AuthenticationType {
	Interactive = 0      ### Interactive browser-based authentication
	Certificate = 1      ### Certificate-based authentication (app-only)
	ClientSecret = 2     ### Client secret authentication (app-only)
	ManagedIdentity = 3  ### Azure Managed Identity authentication
	DeviceCode = 4       ### Device code flow for headless scenarios
}
