![Brennan Technologies Logo](../Resources/images/BrennanLogo_BizCard_White.png)

# Brennan.PowerShell.Core - Function Reference

Complete documentation for all public functions in the Brennan.PowerShell.Core module.

---

## Table of Contents

1. [Overview](#overview)
2. [Microsoft Graph Functions](#microsoft-graph-functions)
   - [Connect-MgGraphAPI](#connect-mggraphapi)
   - [Disconnect-MgGraphAPI](#disconnect-mggraphapi)
   - [Get-MgGraphAPIPermissions](#get-mggraphapipermissions)
3. [Module Management](#module-management)
   - [Import-RequiredModules](#import-requiredmodules)
4. [Logging Functions](#logging-functions)
   - [Write-Log](#write-log)
5. [Common Parameters](#common-parameters)
6. [Related Documentation](#related-documentation)

---

## Overview

The Brennan.PowerShell.Core module provides essential PowerShell functions for Microsoft Graph API integration, module management, and robust logging capabilities. All functions are designed to work seamlessly with PowerShell 5.1+ and PowerShell Core, making them suitable for both interactive use and automation scenarios including Azure Functions and Azure Runbooks.

**Key Features:**
- Certificate-based Microsoft Graph authentication
- Automated module installation and management
- Comprehensive logging with multiple modes and severity levels
- Full compatibility with Windows PowerShell and PowerShell Core
- Extensive error handling and troubleshooting guidance

---

## Microsoft Graph Functions

### Connect-MgGraphAPI

Establishes a connection to Microsoft Graph API using certificate-based authentication with app registration credentials.

#### Synopsis
Connect to Microsoft Graph API using app registration credentials from settings.json

#### Description
Reads app registration details (TenantId, ClientId, CertificateThumbprint) from settings.json and establishes a connection to Microsoft Graph using certificate-based authentication. Automatically installs Microsoft.Graph.Authentication module if not present. Validates certificate existence and connectivity before returning.

#### Parameters

| Parameter        | Type     | Mandatory | Default           | Description                                                                                                                                                                                         |
| ---------------- | -------- | --------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **SettingsPath** | String   | No        | `.\settings.json` | Path to the settings.json file containing app registration details. Required JSON structure: TenantId, ClientId, CertificateThumbprint                                                              |
| **Scopes**       | String[] | No        | `$null`           | Optional array of Graph API permission scopes to request. When using certificate authentication, scopes are pre-configured in the app registration. Example: `@("User.Read.All", "Group.Read.All")` |

#### Inputs
**None.** This function does not accept pipeline input.

#### Outputs
**Microsoft.Graph.PowerShell.Authentication.Models.GraphContext** - Returns the Microsoft Graph context object with connection details including TenantId, ClientId, AuthType, and Scopes.

#### Examples

**Example 1: Connect using default settings file**
```powershell
Connect-MgGraphAPI
```
Connects to Microsoft Graph using settings from `.\settings.json` in the current directory.

**Example 2: Connect using custom settings path**
```powershell
Connect-MgGraphAPI -SettingsPath "C:\Config\settings.json"
```
Connects using app registration settings from a specific configuration file path.

**Example 3: Connect with verbose output and capture context**
```powershell
$context = Connect-MgGraphAPI -Verbose
Write-Host "Connected to tenant: $($context.TenantId)"
```
Connects with detailed verbose output and stores the Graph context object for later reference.

**Example 4: Connect with specific scopes (delegated auth scenarios)**
```powershell
Connect-MgGraphAPI -Scopes @("Directory.Read.All", "User.Read.All")
```
Connects with specific permission scopes. Note: With certificate auth, scopes are typically pre-configured in Azure AD.

**Example 5: Connect and verify permissions**
```powershell
$ctx = Connect-MgGraphAPI
if ($ctx.AuthType -eq "AppOnly") {
    Write-Host "Successfully connected with app-only authentication"
    Get-MgGraphAPIPermissions
}
```
Connects to Graph, validates the authentication type, and retrieves assigned permissions.

#### Notes

**Author:** Chris Brennan, chris@brennantechnologies.com
**Company:** Brennan Technologies, LLC
**Version:** 1.0
**Date:** December 14, 2025

**Requirements:**
- PowerShell 5.1 or higher
- Microsoft.Graph.Authentication module (auto-installed if missing)
- Certificate with private key installed in CurrentUser\My store
- App registration in Azure AD with required Graph API permissions
- settings.json file with valid TenantId, ClientId, and CertificateThumbprint

**Compatibility:**
- Compliant with PowerShell 5.1+ and PowerShell Core
- Supports automation for Azure Functions and Azure Runbooks

**Troubleshooting:**
1. Verify certificate exists: `Get-ChildItem Cert:\CurrentUser\My`
2. Check certificate has private key
3. Verify app registration permissions in Azure portal
4. Ensure certificate is associated with app registration
5. Confirm admin consent is granted for app permissions

**Settings File Format (settings.json):**
```json
{
    "TenantId": "your-tenant-id-guid",
    "ClientId": "your-client-id-guid",
    "CertificateThumbprint": "certificate-thumbprint-hex-string"
}
```

#### Related Functions
- [Disconnect-MgGraphAPI](#disconnect-mggraphapi) - Disconnect from Graph API
- [Get-MgGraphAPIPermissions](#get-mggraphapipermissions) - View assigned permissions

---

### Disconnect-MgGraphAPI

Safely disconnects the current Microsoft Graph API session and clears authentication context.

#### Synopsis
Disconnect from Microsoft Graph API

#### Description
Safely disconnects the current Microsoft Graph API session and clears authentication context. This function is a wrapper around Disconnect-MgGraph with additional logging and error handling. Automatically detects if a session is active before attempting disconnection.

#### Parameters

**This function takes no parameters.**

#### Inputs
**None.** This function does not accept pipeline input.

#### Outputs
**None.** This function does not return output but writes status messages to console and log.

#### Examples

**Example 1: Simple disconnect**
```powershell
Disconnect-MgGraphAPI
```
Disconnects from the current Microsoft Graph API session if one is active.

**Example 2: Disconnect with verbose output**
```powershell
Disconnect-MgGraphAPI -Verbose
```
Disconnects with detailed verbose logging showing session details before disconnection.

**Example 3: Disconnect in a script with error handling**
```powershell
try {
    ### Perform Graph operations
    $users = Get-MgUser -Top 10
}
finally {
    Disconnect-MgGraphAPI
}
```
Ensures Graph session is disconnected even if errors occur during operations.

**Example 4: Check session before disconnect**
```powershell
if (Get-MgContext) {
    Write-Host "Active session found. Disconnecting..."
    Disconnect-MgGraphAPI
} else {
    Write-Host "No active session to disconnect."
}
```
Manually checks for active session before disconnecting (note: the function does this automatically).

**Example 5: Disconnect and verify**
```powershell
Disconnect-MgGraphAPI
$context = Get-MgContext
if (-not $context) {
    Write-Host "Successfully disconnected - no active session"
}
```
Disconnects and verifies that no Graph context remains active.

#### Notes

**Author:** Chris Brennan, chris@brennantechnologies.com
**Company:** Brennan Technologies, LLC
**Version:** 1.0
**Date:** December 14, 2025

**Requirements:**
- Microsoft.Graph.Authentication module v2.0.0 or higher
- Active Microsoft Graph session (function handles gracefully if no session exists)

**Compatibility:**
- Compliant with PowerShell 5.1+ and PowerShell Core
- Supports automation for Azure Functions and Azure Runbooks

**Behavior:**
- Automatically detects if a session is active before attempting disconnection
- Logs disconnection status using Write-Log if available
- Provides graceful handling when no active session exists
- Includes comprehensive error handling with detailed error messages

#### Related Functions
- [Connect-MgGraphAPI](#connect-mggraphapi) - Connect to Graph API

---

### Get-MgGraphAPIPermissions

Retrieves and displays API permissions for a Microsoft Graph service principal, including both application permissions (app roles) and delegated permissions (OAuth2 grants).

#### Synopsis
Retrieve API permissions for a Microsoft Graph service principal.

#### Description
Connects to Microsoft Graph and retrieves both application permissions (app roles) and delegated permissions (OAuth2 grants) for the authenticated service principal. Displays detailed information including permission scopes, resources, and descriptions. Supports multiple output formats for different use cases (console display, object manipulation, summary view).

#### Parameters

| Parameter        | Type   | Mandatory | Default         | Description                                                                                                                                                                                                                                                              |
| ---------------- | ------ | --------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **AppId**        | String | No        | Current Context | The Application (Client) ID to query. If not specified, uses the currently connected app from Get-MgContext. Format: GUID (e.g., "7f5ffe8f-b0b2-4c1a-8cfc-430124f125dd")                                                                                                 |
| **OutputFormat** | String | No        | `Console`       | The output format for results. Valid values: `Console`, `Object`, `Summary`<br>• **Console**: Formatted display with Write-Log<br>• **Object**: Returns PSCustomObject with full permission details<br>• **Summary**: Returns PSCustomObject with permission counts only |

#### Inputs
**None.** This function does not accept pipeline input.

#### Outputs
**System.Management.Automation.PSCustomObject** (when OutputFormat is `Object` or `Summary`)

**Object Format Properties:**
- **AppName** (String) - Service principal display name
- **AppId** (String) - Application (client) ID
- **ObjectId** (String) - Service principal object ID
- **TenantId** (String) - Azure AD tenant ID
- **ApplicationPermissions** (Array) - Array of app role assignments
- **DelegatedPermissions** (Array) - Array of OAuth2 permission grants
- **ApplicationPermissionCount** (Int) - Count of app permissions
- **DelegatedPermissionCount** (Int) - Count of delegated permissions
- **TotalPermissions** (Int) - Total permission count

**None** (when OutputFormat is `Console`) - outputs formatted text to console via Write-Log

#### Examples

**Example 1: View permissions for current app**
```powershell
Connect-MgGraphAPI
Get-MgGraphAPIPermissions
```
Retrieves and displays permissions for the currently connected app in formatted console output.

**Example 2: Get permissions as objects for processing**
```powershell
$permissions = Get-MgGraphAPIPermissions -OutputFormat Object
$writePerms = $permissions.ApplicationPermissions | Where-Object {$_.Permission -like "*Write*"}
Write-Host "Found $($writePerms.Count) write permissions"
```
Retrieves permissions as PowerShell objects and filters for write permissions.

**Example 3: Query specific application by AppId**
```powershell
$perms = Get-MgGraphAPIPermissions -AppId "7f5ffe8f-b0b2-4c1a-8cfc-430124f125dd" -OutputFormat Object
foreach ($perm in $perms.ApplicationPermissions) {
    Write-Host "$($perm.Permission) - $($perm.Description)"
}
```
Retrieves permissions for a specific application and displays permission details.

**Example 4: Display permission summary only**
```powershell
Get-MgGraphAPIPermissions -OutputFormat Summary | Format-List
```
Shows a summary with permission counts without listing individual permissions.

**Example 5: Export permissions to JSON**
```powershell
$permissions = Get-MgGraphAPIPermissions -OutputFormat Object
$permissions | ConvertTo-Json -Depth 10 | Out-File "permissions.json"
```
Exports complete permission details to a JSON file for documentation or auditing.

**Example 6: Compare permissions across environments**
```powershell
### Production
Connect-MgGraphAPI -SettingsPath ".\prod-settings.json"
$prodPerms = Get-MgGraphAPIPermissions -OutputFormat Object

### Development
Connect-MgGraphAPI -SettingsPath ".\dev-settings.json"
$devPerms = Get-MgGraphAPIPermissions -OutputFormat Object

### Compare
$prodOnly = $prodPerms.ApplicationPermissions.Permission | Where-Object {$_ -notin $devPerms.ApplicationPermissions.Permission}
Write-Host "Permissions in Production but not Development: $($prodOnly -join ', ')"
```
Compares permissions between different environments to identify discrepancies.

#### Notes

**Author:** Chris Brennan, chris@brennantechnologies.com
**Company:** Brennan Technologies, LLC
**Version:** 1.0
**Date:** December 14, 2025

**Requirements:**
- PowerShell 5.1 or higher
- Must be connected to Microsoft Graph (use Connect-MgGraphAPI first)
- Requires permissions to read service principals and permission grants
- Recommended permissions: Directory.Read.All or Application.Read.All

**Compatibility:**
- Compliant with PowerShell 5.1+ and PowerShell Core
- Supports automation for Azure Functions and Azure Runbooks

**Permission Types:**
- **Application Permissions (App Roles)**: Used for app-only access, no user context required
- **Delegated Permissions (OAuth2 Grants)**: Used for user-delegated access, requires user sign-in

**Understanding Output:**
- Application permissions appear as app role assignments
- Delegated permissions are grouped by resource
- Consent type indicates admin vs. user consent
- Each permission includes description and resource information

#### Related Functions
- [Connect-MgGraphAPI](#connect-mggraphapi) - Connect to Graph API before using this function

---

## Module Management

### Import-RequiredModules

Imports and installs required PowerShell modules automatically, ensuring all dependencies are available before script execution.

#### Synopsis
Import and install required PowerShell modules

#### Description
Imports an array of PowerShell modules, automatically installing any that are missing from the specified scope. Supports both module names from PowerShell Gallery and file paths to local module files. Provides detailed logging of import status including success, warnings, and errors. Designed for use in scripts that have module dependencies.

#### Parameters

| Parameter   | Type     | Mandatory | Default       | Pipeline      | Description                                                                                                                                                                                 |
| ----------- | -------- | --------- | ------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Modules** | String[] | Yes       | N/A           | Yes (ByValue) | Array of module names or file paths to import. File paths should be absolute paths to .psd1 or .psm1 files. Module names should be standard PowerShell module names available in PSGallery. |
| **Scope**   | String   | No        | `CurrentUser` | No            | Installation scope for missing modules. Valid values: `CurrentUser`, `AllUsers`. CurrentUser does not require elevation.                                                                    |
| **Force**   | Switch   | No        | `$true`       | No            | Force reimport of modules even if already loaded. This ensures the latest version is loaded.                                                                                                |

#### Inputs
**System.String[]** - Accepts array of module names or file paths via pipeline.

#### Outputs
**None.** Writes status messages to console and logs via Write-Log.

#### Examples

**Example 1: Import Microsoft Graph modules**
```powershell
Import-RequiredModules -Modules @("Microsoft.Graph.Users", "Microsoft.Graph.Reports")
```
Imports Microsoft Graph modules, automatically installing them from PSGallery if not already present.

**Example 2: Import local and gallery modules**
```powershell
Import-RequiredModules -Modules @("C:\Modules\MyCustomModule.psd1", "Az.Accounts")
```
Imports a local module by file path and Az.Accounts from PowerShell Gallery.

**Example 3: Import with AllUsers scope (requires elevation)**
```powershell
Import-RequiredModules -Modules @("Microsoft.Graph.Authentication") -Scope AllUsers
```
Installs module for all users on the system. Requires running PowerShell as Administrator.

**Example 4: Import via pipeline**
```powershell
"Microsoft.Graph.Users", "Az.Accounts", "ImportExcel" | Import-RequiredModules
```
Passes module names through the pipeline for import.

**Example 5: Import modules in a script with error handling**
```powershell
$requiredModules = @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Users",
    "Microsoft.Graph.Groups"
)

try {
    Import-RequiredModules -Modules $requiredModules -Verbose
    Write-Host "All dependencies loaded successfully"
}
catch {
    Write-Error "Failed to load required modules: $_"
    exit 1
}
```
Robust module loading at the beginning of a script with comprehensive error handling.

**Example 6: Import modules without forcing reload**
```powershell
Import-RequiredModules -Modules @("Az.Accounts") -Force:$false
```
Imports modules but does not force reload if already loaded in the session.

#### Notes

**Author:** Chris Brennan, chris@brennantechnologies.com
**Company:** Brennan Technologies, LLC
**Version:** 1.0
**Date:** December 14, 2025

**Compatibility:**
- Compliant with PowerShell 5.1+ and PowerShell Core
- Supports automation for Azure Functions and Azure Runbooks

**Behavior:**
- Automatically detects whether input is a file path or module name
- Installs missing modules from PowerShell Gallery automatically
- Uses AllowClobber to prevent conflicts during installation
- Forces module reload by default to ensure latest version
- Provides detailed logging through Write-Log function
- Throws terminating error if module import fails

**Best Practices:**
- Define required modules at the beginning of scripts
- Use CurrentUser scope when possible to avoid elevation requirements
- Consider using -Force:$false in production to improve performance if modules rarely change
- Wrap in try/catch for graceful script termination on dependency failure

**Troubleshooting:**
- Ensure PSGallery is registered: `Get-PSRepository`
- Check network connectivity to PowerShell Gallery
- For local modules, verify file paths are absolute and files exist
- Use -Verbose for detailed import information

#### Related Functions
- [Connect-MgGraphAPI](#connect-mggraphapi) - Automatically installs Graph modules
- [Write-Log](#write-log) - Used for status logging

---

## Logging Functions

### Write-Log

Writes formatted log messages to console and/or log file with timestamps, severity levels, and color-coded output.

#### Synopsis
Write formatted log messages to console and log file with timestamp and severity levels.

#### Description
Outputs log messages with consistent formatting including timestamp and color-coded severity levels. Supports multiple message types including info, success, warning, error, headers, and sub-items. Automatically creates a Logs folder in the module root and writes to timestamped log files. Log file paths are cached per session to ensure consistent file naming. Supports three logging modes: Continuous (single file), Daily (one per day), and Session (one per script execution).

#### Parameters

| Parameter     | Type   | Mandatory | Default        | Description                                                                                                                                                                                                                                                                                                                                                                               |
| ------------- | ------ | --------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Message**   | String | Yes       | N/A            | The message text to log. Position 0 parameter.                                                                                                                                                                                                                                                                                                                                            |
| **Level**     | String | No        | `Info`         | The severity/formatting level. Valid values:<br>• **Info**: Standard informational message<br>• **Success**: Success message with green checkmark<br>• **Warning**: Warning message with warning symbol<br>• **Error**: Error message with error symbol<br>• **Verbose**: Verbose detail message<br>• **Header**: Section header with separator lines<br>• **SubItem**: Indented sub-item |
| **LogPath**   | String | No        | Auto-generated | Custom path to the log file. If not specified, automatically generates path based on calling script name:<br>`$ModuleRoot\Logs\{ScriptName}[_timestamp]_Log.log`                                                                                                                                                                                                                          |
| **LogMode**   | String | No        | `Continuous`   | Determines log file naming strategy. Can be overridden by `$script:LogMode` variable in calling script.<br>• **Continuous**: Single log file (ScriptName_Log.log)<br>• **Daily**: New log file per day (ScriptName_yyyyMMdd_Log.log)<br>• **Session**: New log file per session (ScriptName_yyyyMMdd_HHmmss_Log.log)                                                                      |
| **NoConsole** | Switch | No        | `$false`       | If specified, only writes to log file and skips console output.                                                                                                                                                                                                                                                                                                                           |
| **NoLog**     | Switch | No        | `$false`       | If specified, only writes to console and skips file logging.                                                                                                                                                                                                                                                                                                                              |

#### Inputs
**None.** This function does not accept pipeline input.

#### Outputs
**None.** Writes to console (via Write-Host/Write-Verbose) and/or log file based on parameters.

#### Examples

**Example 1: Basic informational logging**
```powershell
Write-Log "Processing started" -Level Info
```
Writes a standard informational message to both console and log file with timestamp.

**Example 2: Success message**
```powershell
Write-Log "User created successfully" -Level Success
```
Writes a success message with green checkmark (✓) to console.

**Example 3: Section headers**
```powershell
Write-Log "Data Processing" -Level Header
Write-Log "Processing file 1 of 10" -Level SubItem
Write-Log "Processing file 2 of 10" -Level SubItem
```
Creates formatted section headers with indented sub-items for organized log output.

**Example 4: Error logging**
```powershell
try {
    Get-MgUser -UserId "nonexistent@domain.com"
}
catch {
    Write-Log "Failed to retrieve user: $($_.Exception.Message)" -Level Error
}
```
Logs error messages with red error symbol (✗) and detailed error information.

**Example 5: Custom log file location**
```powershell
Write-Log "Application started" -LogPath "C:\CustomLogs\MyApp.log"
```
Writes log messages to a custom log file location instead of default.

**Example 6: Console-only output (no file logging)**
```powershell
Write-Log "Temporary debug message" -Level Verbose -NoLog
```
Writes verbose message to console only without persisting to log file.

**Example 7: File-only logging (silent operation)**
```powershell
Write-Log "Background task completed" -NoConsole
```
Writes to log file only without displaying on console (useful for silent scripts).

**Example 8: Session-based logging**
```powershell
$script:LogMode = 'Session'
Write-Log "Script execution started"
Write-Log "Processing data..."
Write-Log "Script execution completed"
```
Creates a new log file for each script execution with timestamp in filename.

**Example 9: Daily logging mode**
```powershell
### In script initialization
$script:LogMode = 'Daily'

### All subsequent Write-Log calls use daily mode
Write-Log "Daily report generated" -Level Success
```
Uses daily log files - creates new file each day (e.g., ScriptName_20251214_Log.log).

**Example 10: Comprehensive logging example**
```powershell
### Configure session logging
$script:LogMode = 'Session'

Write-Log "Microsoft Graph Operations" -Level Header

Write-Log "Connecting to Microsoft Graph..." -Level Info
Connect-MgGraphAPI
Write-Log "Connected successfully" -Level Success

Write-Log "User Operations" -Level Header
try {
    $users = Get-MgUser -Top 10
    Write-Log "Retrieved $($users.Count) users" -Level SubItem

    foreach ($user in $users) {
        Write-Log "Processing: $($user.DisplayName)" -Level SubItem
    }
    Write-Log "User processing complete" -Level Success
}
catch {
    Write-Log "Error processing users: $($_.Exception.Message)" -Level Error
}
finally {
    Write-Log "Disconnecting from Graph..." -Level Info
    Disconnect-MgGraphAPI
    Write-Log "Operations complete" -Level Success
}
```
Complete example showing structured logging throughout a script with headers, sub-items, and error handling.

#### Notes

**Author:** Chris Brennan, chris@brennantechnologies.com
**Company:** Brennan Technologies, LLC
**Version:** 1.0
**Date:** December 14, 2025

**Compatibility:**
- Compliant with PowerShell 5.1+ and PowerShell Core
- Supports automation for Azure Functions and Azure Runbooks

**Log File Naming Formats:**
- **Continuous**: `ScriptName_Log.log` - Single continuous log file
- **Daily**: `ScriptName_yyyyMMdd_Log.log` (e.g., `Brennan.PowerShell.Core_20251214_Log.log`)
- **Session**: `ScriptName_yyyyMMdd_HHmmss_Log.log` (e.g., `Brennan.PowerShell.Core_20251214_143530_Log.log`)

**Log File Content Format:**
Each log entry includes:
- Timestamp (yyyy-MM-dd HH:mm:ss)
- Call stack information
- Severity level
- Message text

Example log entry:
```
2025-12-14 14:35:30    [callStack: MyScript.ps1]    [INFO]    Processing started
```

**Console Output Symbols:**
- Info: No symbol (plain text)
- Success: ✓ (green checkmark)
- Warning: ⚠ (yellow warning symbol)
- Error: ✗ (red error symbol)
- Verbose: Standard verbose output
- Header: Section separator with === markers
- SubItem: Indented text (cyan)

**Setting LogMode:**
LogMode can be set three ways (in order of precedence):
1. Explicitly via `-LogMode` parameter
2. Via `$script:LogMode` variable in calling script
3. Default to 'Continuous' if not specified

**Best Practices:**
- Set `$script:LogMode` at the beginning of scripts for consistent logging
- Use Session mode for troubleshooting individual runs
- Use Daily mode for scheduled tasks and long-running services
- Use Continuous mode for development and testing
- Use Headers to organize log output into logical sections
- Use SubItems for detailed operation logging under headers
- Consider -NoConsole for scheduled tasks to reduce console output
- Use -NoLog for temporary debugging that shouldn't be persisted

**Advanced Usage - Custom Caller Detection:**
The function automatically detects the calling script name from the call stack. When called from the console or script blocks, it uses "Console" or "Unknown" as the script name. This ensures log files are always properly named.

#### Related Functions
- All functions in this module use Write-Log for status output
- [Import-RequiredModules](#import-requiredmodules) - Uses Write-Log extensively
- [Connect-MgGraphAPI](#connect-mggraphapi) - Uses Write-Host but compatible with Write-Log patterns

---

## Common Parameters

All functions in this module support the common PowerShell parameters:

- **-Verbose**: Provides detailed operation information
- **-Debug**: Enables debug output
- **-ErrorAction**: Controls error handling behavior
- **-WarningAction**: Controls warning message behavior
- **-InformationAction**: Controls information message behavior
- **-ErrorVariable**: Captures errors to a variable
- **-WarningVariable**: Captures warnings to a variable
- **-InformationVariable**: Captures information messages to a variable
- **-OutVariable**: Captures output to a variable
- **-OutBuffer**: Sets the output buffer size

### Examples Using Common Parameters

```powershell
### Verbose output for troubleshooting
Connect-MgGraphAPI -Verbose

### Suppress errors (not recommended for Graph functions)
Import-RequiredModules -Modules @("NonExistentModule") -ErrorAction SilentlyContinue

### Capture warnings
Get-MgGraphAPIPermissions -WarningVariable warnings
if ($warnings) {
    Write-Host "Warnings encountered: $($warnings.Count)"
}
```

---

## Related Documentation

### Module Documentation
- **[README.md](../README.md)** - Module overview, installation, and quick start
- **[CHANGELOG.md](./CHANGELOG.md)** - Version history and release notes
- **[CONTRIBUTING.md](../CONTRIBUTING.md)** - Contribution guidelines for developers

### Microsoft Graph Resources
- [Microsoft Graph API Documentation](https://learn.microsoft.com/en-us/graph/)
- [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/)
- [App-only Authentication](https://learn.microsoft.com/en-us/graph/auth-v2-service)
- [Graph API Permissions Reference](https://learn.microsoft.com/en-us/graph/permissions-reference)

### PowerShell Resources
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
- [PowerShell Gallery](https://www.powershellgallery.com/)
- [About Comment-Based Help](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help)

### Azure Resources
- [Azure AD App Registrations](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
- [Certificate-Based Authentication](https://learn.microsoft.com/en-us/azure/active-directory/develop/active-directory-certificate-credentials)
- [Azure Functions PowerShell Guide](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-powershell)
- [Azure Automation Runbooks](https://learn.microsoft.com/en-us/azure/automation/automation-runbook-types)

---

## Getting Help

### In-Module Help
All functions include comprehensive comment-based help. Access detailed help using:

```powershell
### View full help
Get-Help Connect-MgGraphAPI -Full

### View examples only
Get-Help Write-Log -Examples

### View online help (if available)
Get-Help Get-MgGraphAPIPermissions -Online

### View parameter details
Get-Help Import-RequiredModules -Parameter Modules
```

### Support
For issues, questions, or feature requests:

**Email:** chris@brennantechnologies.com
**Company:** Brennan Technologies, LLC

---

## Author

**Chris Brennan**
Brennan Technologies, LLC
chris@brennantechnologies.com

---

*Last Updated: December 14, 2025*
*Module Version: 1.0*
*Documentation Version: 1.0*
