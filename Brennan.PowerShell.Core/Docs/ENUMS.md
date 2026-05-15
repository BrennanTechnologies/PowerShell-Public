
![Brennan Technologies Logo](../Resources/images/BrennanLogo_BizCard_White.png)

# Enumerations Reference

## Table of Contents

- [Overview](#overview)
- [LogLevel Enum](#loglevel-enum)
- [LogMode Enum](#logmode-enum)
- [ConnectionStatus Enum](#connectionstatus-enum)
- [AuthenticationType Enum](#authenticationtype-enum)
- [ModuleImportBehavior Enum](#moduleimportbehavior-enum)
- [CertificateValidationLevel Enum](#certificatevalidationlevel-enum)
- [ErrorHandlingStrategy Enum](#errorhandlingstrategy-enum)
- [Best Practices](#best-practices)
- [About](#about)

---

## Overview

The Brennan.PowerShell.Core module uses strongly-typed enumerations to provide type safety, IntelliSense support, and consistent behavior across all functions. All enums are defined in the `Enums/` directory and are automatically loaded when the module is imported.

**Benefits of Using Enums:**
- **Type Safety**: Prevents invalid values at runtime
- **IntelliSense**: Auto-completion in VS Code and PowerShell ISE
- **Self-Documenting**: Clear, descriptive value names
- **Maintainability**: Centralized definition of valid values
- **Performance**: Faster comparisons than string matching

---

## LogLevel Enum

**File:** `Enums/LogLevel.ps1`

### Description

Defines severity levels for logging operations. Used by the `Write-Log` function to categorize log messages and control output formatting.

### Definition

```powershell
enum LogLevel {
    Verbose = 0    ### Detailed diagnostic information
    Info = 1       ### General informational messages
    Warning = 2    ### Warning messages for potential issues
    Error = 3      ### Error messages for failures
    Success = 4    ### Success confirmation messages
    Header = 5     ### Section headers for log organization
    SubItem = 6    ### Sub-items under headers
    Debug = 7      ### Debug-level diagnostic information
}
```

### Values

| Value     | Numeric Code | Description                           | When to Use                                                       |
| --------- | ------------ | ------------------------------------- | ----------------------------------------------------------------- |
| `Verbose` | 0            | Detailed diagnostic information       | Trace execution flow, parameter values, intermediate calculations |
| `Info`    | 1            | General informational messages        | Normal operations, status updates, progress indicators            |
| `Warning` | 2            | Warning messages for potential issues | Non-critical issues, deprecated features, resource constraints    |
| `Error`   | 3            | Error messages for failures           | Operation failures, exceptions, critical errors                   |
| `Success` | 4            | Success confirmation messages         | Successful completions, confirmations, achievements               |
| `Header`  | 5            | Section headers for log organization  | Start of major operations, section dividers                       |
| `SubItem` | 6            | Sub-items under headers               | List items, nested operations, grouped output                     |
| `Debug`   | 7            | Debug-level diagnostic information    | Developer debugging, troubleshooting, detailed state              |

### Console Output Colors

| Level   | Color    | Symbol |
| ------- | -------- | ------ |
| Verbose | Gray     | -      |
| Info    | White    | ℹ      |
| Warning | Yellow   | ⚠      |
| Error   | Red      | ✗      |
| Success | Green    | ✓      |
| Header  | Cyan     | -      |
| SubItem | DarkGray | -      |
| Debug   | Magenta  | 🔍      |

### Usage Examples

#### Example 1: Basic Logging

```powershell
### Import the enum
using module Brennan.PowerShell.Core

### Use in Write-Log function
Write-Log -Message "Starting script execution" -Level Info
Write-Log -Message "User input validated successfully" -Level Success
Write-Log -Message "API rate limit approaching" -Level Warning
Write-Log -Message "Failed to connect to database" -Level Error
```

#### Example 2: Conditional Logging Based on Level

```powershell
function Process-Data {
    param(
        [LogLevel]$MinimumLevel = [LogLevel]::Info
    )

    $currentLevel = [LogLevel]::Verbose

    if ($currentLevel -ge $MinimumLevel) {
        Write-Log -Message "Processing item 1 of 100" -Level Verbose
    }
}

### Only logs if MinimumLevel is Verbose or lower
Process-Data -MinimumLevel Verbose
```

#### Example 3: Structured Logging with Headers and SubItems

```powershell
Write-Log -Message "User Import Process" -Level Header
Write-Log -Message "Loading users from CSV" -Level SubItem
Write-Log -Message "Validating user data" -Level SubItem
Write-Log -Message "Creating user accounts" -Level SubItem
Write-Log -Message "Import completed: 150 users processed" -Level Success
```

#### Example 4: Type-Safe Function Parameters

```powershell
function Export-Report {
    param(
        [Parameter(Mandatory)]
        [string]$ReportName,

        [LogLevel]$LoggingLevel = [LogLevel]::Info
    )

    ### Function automatically validates LogLevel parameter
    Write-Log -Message "Generating report: $ReportName" -Level $LoggingLevel
}

### Valid - uses enum value
Export-Report -ReportName "Sales" -LoggingLevel Warning

### Invalid - PowerShell will show error with valid options
Export-Report -ReportName "Sales" -LoggingLevel "InvalidLevel"
```

#### Example 5: Numeric Comparison for Log Filtering

```powershell
function Write-FilteredLog {
    param(
        [string]$Message,
        [LogLevel]$Level,
        [LogLevel]$MinLevel = [LogLevel]::Info
    )

    ### Only write if message level is >= minimum level
    if ($Level -ge $MinLevel) {
        Write-Log -Message $Message -Level $Level
    }
}

### This will log (Warning >= Info)
Write-FilteredLog -Message "Disk space low" -Level Warning -MinLevel Info

### This won't log (Verbose < Info)
Write-FilteredLog -Message "Loop iteration 1" -Level Verbose -MinLevel Info
```

### Best Practices

1. **Use Info for default operations** - Most standard messages should be Info level
2. **Reserve Verbose for detailed tracing** - Only enable in troubleshooting scenarios
3. **Use Warning for recoverable issues** - Issues that don't stop execution but need attention
4. **Use Error only for failures** - Critical issues that prevent operation completion
5. **Use Success for confirmations** - Explicitly confirm successful completions
6. **Use Header/SubItem for structure** - Organize complex output into readable sections

---

## LogMode Enum

**File:** `Enums/LogMode.ps1`

### Description

Defines logging behavior and file management strategies. Controls how log files are created, named, and rotated.

### Definition

```powershell
enum LogMode {
    Continuous = 0  ### Single log file, appends indefinitely
    Daily = 1       ### New log file created each day (YYYYMMDD format)
    Session = 2     ### New log file per PowerShell session
}
```

### Values

| Value        | Numeric Code | Description                           | File Naming Pattern                  |
| ------------ | ------------ | ------------------------------------- | ------------------------------------ |
| `Continuous` | 0            | Single log file, appends indefinitely | `ScriptName_Log.log`                 |
| `Daily`      | 1            | New log file created each day         | `ScriptName_20251214_Log.log`        |
| `Session`    | 2            | New log file per PowerShell session   | `ScriptName_20251214_143022_Log.log` |

### Usage Examples

#### Example 1: Continuous Logging (Single File)

```powershell
### Set at script level
$script:LogMode = [LogMode]::Continuous

Write-Log "Application started"
### Creates: MyScript_Log.log

Write-Log "User logged in"
### Appends to: MyScript_Log.log

### Same file is used across all sessions
### Good for: Long-running services, single-purpose scripts
```

#### Example 2: Daily Logging (Date-Based Files)

```powershell
### Set at script level
$script:LogMode = [LogMode]::Daily

Write-Log "Daily report starting"
### Creates: MyScript_20251214_Log.log

### Next day...
Write-Log "Daily report starting"
### Creates: MyScript_20251215_Log.log

### Good for: Scheduled tasks, daily operations, reporting scripts
```

#### Example 3: Session Logging (Timestamp-Based Files)

```powershell
### Set at script level
$script:LogMode = [LogMode]::Session

Write-Log "Session started"
### Creates: MyScript_20251214_143022_Log.log

### New PowerShell session
Write-Log "Session started"
### Creates: MyScript_20251214_150315_Log.log

### Good for: Interactive scripts, testing, debugging
```

#### Example 4: Dynamic Mode Selection

```powershell
function Initialize-Logging {
    param(
        [LogMode]$Mode,
        [string]$Environment = "Production"
    )

    ### Use different modes per environment
    $script:LogMode = switch ($Environment) {
        "Development" { [LogMode]::Session }
        "Test"        { [LogMode]::Daily }
        "Production"  { [LogMode]::Daily }
        default       { $Mode }
    }

    Write-Log "Logging initialized: Mode=$($script:LogMode), Env=$Environment"
}

Initialize-Logging -Environment "Production"
```

#### Example 5: Override at Function Level

```powershell
### Script default
$script:LogMode = [LogMode]::Continuous

### Override for specific log entry
Write-Log -Message "Special audit entry" -LogMode Daily

### Back to continuous for next entry
Write-Log -Message "Normal operation"
```

### Log File Examples

**Continuous Mode:**
```
C:\Logs\
  ├── BackupScript_Log.log        (all logs in one file)
```

**Daily Mode:**
```
C:\Logs\
  ├── BackupScript_20251210_Log.log
  ├── BackupScript_20251211_Log.log
  ├── BackupScript_20251212_Log.log
  ├── BackupScript_20251213_Log.log
  └── BackupScript_20251214_Log.log
```

**Session Mode:**
```
C:\Logs\
  ├── BackupScript_20251214_080015_Log.log
  ├── BackupScript_20251214_120530_Log.log
  ├── BackupScript_20251214_143022_Log.log
  └── BackupScript_20251214_180445_Log.log
```

### Best Practices

1. **Use Daily for production** - Easier log management and rotation
2. **Use Session for development** - Isolate test runs and debugging sessions
3. **Use Continuous for services** - Long-running processes with managed log rotation
4. **Consider disk space** - Daily/Session modes create more files over time
5. **Implement log cleanup** - Use scheduled tasks to archive/delete old logs

---

## ConnectionStatus Enum

**File:** `Enums/ConnectionStatus.ps1`

### Description

Defines states for Microsoft Graph API connections. Tracks the lifecycle of Graph API authentication and connection status.

### Definition

```powershell
enum ConnectionStatus {
    Disconnected = 0  ### No active connection
    Connecting = 1    ### Connection attempt in progress
    Connected = 2     ### Successfully connected and authenticated
    Failed = 3        ### Connection attempt failed
    Expired = 4       ### Connection token expired, re-authentication required
}
```

### Values

| Value          | Numeric Code | Description                              | Next Valid States        |
| -------------- | ------------ | ---------------------------------------- | ------------------------ |
| `Disconnected` | 0            | No active connection                     | Connecting               |
| `Connecting`   | 1            | Connection attempt in progress           | Connected, Failed        |
| `Connected`    | 2            | Successfully connected and authenticated | Disconnected, Expired    |
| `Failed`       | 3            | Connection attempt failed                | Connecting, Disconnected |
| `Expired`      | 4            | Connection token expired                 | Connecting, Disconnected |

### Usage Examples

#### Example 1: Track Connection State

```powershell
$connection = [GraphAPIConnection]::new(
    "tenant-id",
    "client-id",
    [AuthenticationType]::Certificate
)

### Initial state
$connection.Status = [ConnectionStatus]::Disconnected

### Start connection attempt
$connection.Status = [ConnectionStatus]::Connecting
Write-Log "Attempting to connect to Microsoft Graph..."

try {
    Connect-MgGraph -TenantId $connection.TenantId -ClientId $connection.ClientId
    $connection.Status = [ConnectionStatus]::Connected
    Write-Log "Successfully connected" -Level Success
}
catch {
    $connection.Status = [ConnectionStatus]::Failed
    Write-Log "Connection failed: $($_.Exception.Message)" -Level Error
}
```

#### Example 2: Validate Connection Before Operations

```powershell
function Get-GraphUsers {
    param([GraphAPIConnection]$Connection)

    if ($Connection.Status -ne [ConnectionStatus]::Connected) {
        throw "Not connected to Microsoft Graph. Current status: $($Connection.Status)"
    }

    if ($Connection.Status -eq [ConnectionStatus]::Expired) {
        Write-Log "Token expired, reconnecting..." -Level Warning
        Reconnect-Graph -Connection $Connection
    }

    ### Proceed with operation
    Get-MgUser -All
}
```

#### Example 3: Connection State Machine

```powershell
function Update-ConnectionStatus {
    param(
        [GraphAPIConnection]$Connection,
        [ConnectionStatus]$NewStatus
    )

    $validTransitions = @{
        [ConnectionStatus]::Disconnected = @([ConnectionStatus]::Connecting)
        [ConnectionStatus]::Connecting   = @([ConnectionStatus]::Connected, [ConnectionStatus]::Failed)
        [ConnectionStatus]::Connected    = @([ConnectionStatus]::Disconnected, [ConnectionStatus]::Expired)
        [ConnectionStatus]::Failed       = @([ConnectionStatus]::Connecting, [ConnectionStatus]::Disconnected)
        [ConnectionStatus]::Expired      = @([ConnectionStatus]::Connecting, [ConnectionStatus]::Disconnected)
    }

    $currentStatus = $Connection.Status
    if ($NewStatus -in $validTransitions[$currentStatus]) {
        $Connection.Status = $NewStatus
        Write-Log "Connection status: $currentStatus -> $NewStatus"
    }
    else {
        Write-Log "Invalid state transition: $currentStatus -> $NewStatus" -Level Warning
    }
}
```

#### Example 4: Auto-Reconnect on Expiration

```powershell
function Invoke-GraphOperation {
    param(
        [GraphAPIConnection]$Connection,
        [scriptblock]$Operation
    )

    ### Check status before operation
    switch ($Connection.Status) {
        ([ConnectionStatus]::Disconnected) {
            throw "No connection established"
        }
        ([ConnectionStatus]::Expired) {
            Write-Log "Token expired, reconnecting..." -Level Warning
            Connect-ToGraph -Connection $Connection
        }
        ([ConnectionStatus]::Failed) {
            throw "Previous connection attempt failed"
        }
        ([ConnectionStatus]::Connecting) {
            throw "Connection in progress"
        }
        ([ConnectionStatus]::Connected) {
            ### Execute operation
            & $Operation
        }
    }
}
```

#### Example 5: Connection Health Monitoring

```powershell
function Test-GraphConnection {
    param([GraphAPIConnection]$Connection)

    $health = [PSCustomObject]@{
        Status = $Connection.Status
        IsHealthy = $false
        Message = ""
    }

    switch ($Connection.Status) {
        ([ConnectionStatus]::Connected) {
            ### Test actual connectivity
            try {
                Get-MgContext -ErrorAction Stop | Out-Null
                $health.IsHealthy = $true
                $health.Message = "Connected and operational"
            }
            catch {
                $Connection.Status = [ConnectionStatus]::Expired
                $health.Message = "Token expired"
            }
        }
        ([ConnectionStatus]::Disconnected) {
            $health.Message = "Not connected"
        }
        ([ConnectionStatus]::Connecting) {
            $health.Message = "Connection in progress"
        }
        ([ConnectionStatus]::Failed) {
            $health.Message = "Connection failed"
        }
        ([ConnectionStatus]::Expired) {
            $health.Message = "Token expired - reconnection required"
        }
    }

    return $health
}
```

### Best Practices

1. **Always validate status before operations** - Check connection state before Graph API calls
2. **Handle Expired status gracefully** - Implement automatic reconnection
3. **Log state transitions** - Track connection lifecycle for troubleshooting
4. **Use state machine pattern** - Enforce valid status transitions
5. **Monitor connection health** - Periodically verify connection validity

---

## AuthenticationType Enum

**File:** `Enums/AuthenticationType.ps1`

### Description

Defines authentication methods for Microsoft Graph API. Supports multiple authentication scenarios for different deployment contexts.

### Definition

```powershell
enum AuthenticationType {
    Interactive = 0      ### Interactive browser-based authentication
    Certificate = 1      ### Certificate-based authentication (app-only)
    ClientSecret = 2     ### Client secret authentication (app-only)
    ManagedIdentity = 3  ### Azure Managed Identity authentication
    DeviceCode = 4       ### Device code flow for headless scenarios
}
```

### Values

| Value             | Numeric Code | Description                                 | Use Case                                             |
| ----------------- | ------------ | ------------------------------------------- | ---------------------------------------------------- |
| `Interactive`     | 0            | Interactive browser-based authentication    | User delegation, development, testing                |
| `Certificate`     | 1            | Certificate-based authentication (app-only) | **Recommended for production**, automation, services |
| `ClientSecret`    | 2            | Client secret authentication (app-only)     | Simple automation (less secure than certificate)     |
| `ManagedIdentity` | 3            | Azure Managed Identity authentication       | Azure VMs, Azure Functions, Azure Automation         |
| `DeviceCode`      | 4            | Device code flow for headless scenarios     | Servers without browser, remote sessions             |

### Security Comparison

| Type            | Security Level | Secret Storage          | Rotation  | Best For            |
| --------------- | -------------- | ----------------------- | --------- | ------------------- |
| Interactive     | Medium         | None (user credentials) | N/A       | Development         |
| Certificate     | **High**       | Certificate store       | Annual    | **Production**      |
| ClientSecret    | Low            | Configuration/Key Vault | 90 days   | Simple scripts      |
| ManagedIdentity | **High**       | Azure-managed           | Automatic | **Azure resources** |
| DeviceCode      | Medium         | None (user credentials) | N/A       | Headless servers    |

### Usage Examples

#### Example 1: Certificate-Based Authentication (Production)

```powershell
### Most secure for production
$connection = [GraphAPIConnection]::new(
    "12345678-1234-1234-1234-123456789abc",
    "abcdef12-abcd-abcd-abcd-abcdef123456",
    [AuthenticationType]::Certificate
)

### Connect using certificate
Connect-MgGraph -TenantId $connection.TenantId `
                -ClientId $connection.ClientId `
                -CertificateThumbprint "1234567890ABCDEF1234567890ABCDEF12345678"

$connection.Status = [ConnectionStatus]::Connected
```

#### Example 2: Interactive Authentication (Development)

```powershell
### Good for development and testing
$connection = [GraphAPIConnection]::new(
    "tenant-id",
    "client-id",
    [AuthenticationType]::Interactive
)

### Opens browser for sign-in
Connect-MgGraph -TenantId $connection.TenantId `
                -ClientId $connection.ClientId `
                -Scopes "User.Read.All", "Group.Read.All"
```

#### Example 3: Managed Identity (Azure Resources)

```powershell
### For Azure VMs, Functions, Automation Accounts
$connection = [GraphAPIConnection]::new(
    "tenant-id",
    "client-id",
    [AuthenticationType]::ManagedIdentity
)

### No credentials needed - Azure handles authentication
Connect-MgGraph -Identity
```

#### Example 4: Device Code Flow (Headless Servers)

```powershell
### For servers without browser access
$connection = [GraphAPIConnection]::new(
    "tenant-id",
    "client-id",
    [AuthenticationType]::DeviceCode
)

### Displays code to enter at microsoft.com/devicelogin
Connect-MgGraph -TenantId $connection.TenantId `
                -ClientId $connection.ClientId `
                -DeviceCode
```

#### Example 5: Dynamic Authentication Selection

```powershell
function Connect-ToGraph {
    param(
        [AuthenticationType]$AuthType,
        [hashtable]$Credentials
    )

    switch ($AuthType) {
        ([AuthenticationType]::Interactive) {
            Connect-MgGraph -Scopes $Credentials.Scopes
        }
        ([AuthenticationType]::Certificate) {
            Connect-MgGraph -TenantId $Credentials.TenantId `
                           -ClientId $Credentials.ClientId `
                           -CertificateThumbprint $Credentials.Thumbprint
        }
        ([AuthenticationType]::ClientSecret) {
            $secureSecret = ConvertTo-SecureString $Credentials.Secret -AsPlainText -Force
            $clientCreds = New-Object PSCredential($Credentials.ClientId, $secureSecret)
            Connect-MgGraph -TenantId $Credentials.TenantId -ClientSecretCredential $clientCreds
        }
        ([AuthenticationType]::ManagedIdentity) {
            Connect-MgGraph -Identity
        }
        ([AuthenticationType]::DeviceCode) {
            Connect-MgGraph -TenantId $Credentials.TenantId -DeviceCode
        }
    }
}
```

### Best Practices

1. **Use Certificate for production** - Most secure for automated scripts
2. **Never hardcode ClientSecret** - Store in Azure Key Vault or secure credential manager
3. **Use ManagedIdentity in Azure** - No credential management required
4. **Interactive for development only** - Not suitable for automation
5. **DeviceCode as fallback** - When browser-based auth isn't possible
6. **Implement certificate rotation** - Plan for certificate expiration
7. **Audit authentication usage** - Track which auth methods are used where

---

## ModuleImportBehavior Enum

**File:** `Enums/ModuleImportBehavior.ps1`

### Description

Defines behavior for module import operations. Controls how PowerShell modules are loaded and managed.

### Definition

```powershell
enum ModuleImportBehavior {
    SkipIfPresent = 0  ### Don't import if module is already loaded
    ForceReload = 1    ### Always reload module, removing existing version first
    AutoInstall = 2    ### Automatically install from PSGallery if missing, then import
}
```

### Values

| Value           | Numeric Code | Description                                     | Performance | Use Case                          |
| --------------- | ------------ | ----------------------------------------------- | ----------- | --------------------------------- |
| `SkipIfPresent` | 0            | Don't import if module is already loaded        | Fast        | **Production** - fastest          |
| `ForceReload`   | 1            | Always reload module, removing existing version | Slow        | **Development** - testing changes |
| `AutoInstall`   | 2            | Auto-install from PSGallery if missing          | Variable    | **First run** - automatic setup   |

### Usage Examples

#### Example 1: Production - Skip If Present

```powershell
function Import-RequiredModules {
    param(
        [ModuleImportBehavior]$Behavior = [ModuleImportBehavior]::SkipIfPresent
    )

    $modules = @("Microsoft.Graph.Users", "Microsoft.Graph.Groups")

    foreach ($module in $modules) {
        if ($Behavior -eq [ModuleImportBehavior]::SkipIfPresent) {
            if (Get-Module -Name $module) {
                Write-Log "Module $module already loaded, skipping" -Level Verbose
                continue
            }
        }

        Import-Module -Name $module
        Write-Log "Imported module: $module"
    }
}

### Fast, minimal overhead
Import-RequiredModules -Behavior SkipIfPresent
```

#### Example 2: Development - Force Reload

```powershell
### Testing module changes during development
function Reset-Modules {
    param([string[]]$ModuleNames)

    foreach ($module in $ModuleNames) {
        ### Remove if loaded
        if (Get-Module -Name $module) {
            Remove-Module -Name $module -Force
            Write-Log "Removed module: $module" -Level Debug
        }

        ### Reload fresh
        Import-Module -Name $module -Force
        Write-Log "Reloaded module: $module" -Level Debug
    }
}

### Use during development
Reset-Modules -ModuleNames "Brennan.PowerShell.Core"
```

#### Example 3: Auto-Install for First Run

```powershell
function Initialize-ModuleDependencies {
    param(
        [string[]]$RequiredModules,
        [ModuleImportBehavior]$Behavior = [ModuleImportBehavior]::AutoInstall
    )

    foreach ($module in $RequiredModules) {
        ### Check if module exists
        if (-not (Get-Module -Name $module -ListAvailable)) {
            if ($Behavior -eq [ModuleImportBehavior]::AutoInstall) {
                Write-Log "Installing module: $module" -Level Info
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
            }
            else {
                throw "Required module not found: $module"
            }
        }

        ### Import the module
        Import-Module -Name $module
    }
}

### First-time setup
Initialize-ModuleDependencies -RequiredModules @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Users"
) -Behavior AutoInstall
```

#### Example 4: Environment-Specific Behavior

```powershell
function Get-ImportBehavior {
    param([string]$Environment)

    switch ($Environment) {
        "Development" { [ModuleImportBehavior]::ForceReload }
        "Test"        { [ModuleImportBehavior]::SkipIfPresent }
        "Production"  { [ModuleImportBehavior]::SkipIfPresent }
        default       { [ModuleImportBehavior]::AutoInstall }
    }
}

### Dynamic behavior based on environment
$behavior = Get-ImportBehavior -Environment $env:ENVIRONMENT
Import-RequiredModules -Behavior $behavior
```

#### Example 5: Comprehensive Module Management

```powershell
function Import-ModuleWithBehavior {
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,

        [ModuleImportBehavior]$Behavior = [ModuleImportBehavior]::SkipIfPresent,

        [version]$MinimumVersion
    )

    $isLoaded = Get-Module -Name $ModuleName
    $isAvailable = Get-Module -Name $ModuleName -ListAvailable

    switch ($Behavior) {
        ([ModuleImportBehavior]::SkipIfPresent) {
            if ($isLoaded) {
                Write-Log "Module $ModuleName already loaded" -Level Verbose
                return
            }
        }
        ([ModuleImportBehavior]::ForceReload) {
            if ($isLoaded) {
                Remove-Module -Name $ModuleName -Force
                Write-Log "Removed existing module: $ModuleName" -Level Debug
            }
        }
        ([ModuleImportBehavior]::AutoInstall) {
            if (-not $isAvailable) {
                Write-Log "Installing module: $ModuleName" -Level Info
                $params = @{
                    Name = $ModuleName
                    Force = $true
                    AllowClobber = $true
                    Scope = "CurrentUser"
                }
                if ($MinimumVersion) {
                    $params.MinimumVersion = $MinimumVersion
                }
                Install-Module @params
            }
        }
    }

    ### Import the module
    $params = @{ Name = $ModuleName }
    if ($MinimumVersion) { $params.MinimumVersion = $MinimumVersion }

    Import-Module @params
    Write-Log "Imported module: $ModuleName" -Level Success
}
```

### Best Practices

1. **Use SkipIfPresent for production** - Fastest performance, no unnecessary reloads
2. **Use ForceReload for development** - Ensure latest code changes are loaded
3. **Use AutoInstall for deployment** - Simplify first-time setup
4. **Check module versions** - Verify minimum required versions
5. **Handle import errors** - Wrap in try/catch for graceful failure
6. **Log import actions** - Track module loading for troubleshooting

---

## CertificateValidationLevel Enum

**File:** `Enums/CertificateValidationLevel.ps1`

### Description

Defines validation levels for certificate checks. Controls the thoroughness of certificate validation.

### Definition

```powershell
enum CertificateValidationLevel {
    None = 0      ### No validation performed
    Basic = 1     ### Check expiration date only
    Standard = 2  ### Check expiration date and key usage purposes
    Strict = 3    ### Full validation including certificate chain and revocation
}
```

### Values

| Value      | Numeric Code | Checks Performed        | Performance | Use Case                             |
| ---------- | ------------ | ----------------------- | ----------- | ------------------------------------ |
| `None`     | 0            | No validation           | Fastest     | **Testing only** - NOT recommended   |
| `Basic`    | 1            | Expiration date         | Fast        | Development, quick checks            |
| `Standard` | 2            | Expiration + key usage  | Moderate    | **Production** - recommended default |
| `Strict`   | 3            | Full chain + revocation | Slow        | High-security environments           |

### Validation Checks by Level

| Check              | None | Basic | Standard | Strict |
| ------------------ | ---- | ----- | -------- | ------ |
| Certificate exists | ❌    | ✅     | ✅        | ✅      |
| Not expired        | ❌    | ✅     | ✅        | ✅      |
| Key usage valid    | ❌    | ❌     | ✅        | ✅      |
| Enhanced key usage | ❌    | ❌     | ✅        | ✅      |
| Certificate chain  | ❌    | ❌     | ❌        | ✅      |
| Revocation status  | ❌    | ❌     | ❌        | ✅      |

### Usage Examples

#### Example 1: Basic Validation

```powershell
function Test-CertificateBasic {
    param(
        [string]$Thumbprint,
        [CertificateValidationLevel]$Level = [CertificateValidationLevel]::Basic
    )

    $cert = Get-ChildItem Cert:\CurrentUser\My |
            Where-Object { $_.Thumbprint -eq $Thumbprint }

    if (-not $cert) {
        throw "Certificate not found: $Thumbprint"
    }

    if ($Level -ge [CertificateValidationLevel]::Basic) {
        ### Check expiration
        if ((Get-Date) -gt $cert.NotAfter) {
            throw "Certificate has expired: $($cert.NotAfter)"
        }
        if ((Get-Date) -lt $cert.NotBefore) {
            throw "Certificate not yet valid: $($cert.NotBefore)"
        }
    }

    return $cert
}
```

#### Example 2: Standard Validation (Recommended)

```powershell
function Test-CertificateStandard {
    param(
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,
        [CertificateValidationLevel]$Level = [CertificateValidationLevel]::Standard
    )

    $certInfo = [CertificateInfo]::new($Certificate)

    ### Basic checks (expiration)
    if ($Level -ge [CertificateValidationLevel]::Basic) {
        if (-not $certInfo.IsValid) {
            throw "Certificate validation failed: $($certInfo.ValidationErrors -join ', ')"
        }
    }

    ### Standard checks (key usage)
    if ($Level -ge [CertificateValidationLevel]::Standard) {
        ### Check for client authentication
        $hasClientAuth = $Certificate.EnhancedKeyUsageList |
                        Where-Object { $_.ObjectId -eq "1.3.6.1.5.5.7.3.2" }

        if (-not $hasClientAuth) {
            Write-Log "Certificate lacks Client Authentication key usage" -Level Warning
        }
    }

    return $certInfo
}
```

#### Example 3: Strict Validation (High Security)

```powershell
function Test-CertificateStrict {
    param(
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
    )

    ### Build certificate chain
    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
    $chain.ChainPolicy.RevocationMode = "Online"
    $chain.ChainPolicy.RevocationFlag = "EntireChain"
    $chain.ChainPolicy.VerificationFlags = "NoFlag"

    ### Validate chain
    $isValid = $chain.Build($Certificate)

    if (-not $isValid) {
        $errors = @()
        foreach ($status in $chain.ChainStatus) {
            $errors += "$($status.Status): $($status.StatusInformation)"
        }

        throw "Certificate chain validation failed: $($errors -join '; ')"
    }

    ### Check revocation
    foreach ($element in $chain.ChainElements) {
        foreach ($status in $element.ChainElementStatus) {
            if ($status.Status -eq "Revoked") {
                throw "Certificate has been revoked"
            }
        }
    }

    Write-Log "Certificate passed strict validation" -Level Success
    return $true
}
```

#### Example 4: Environment-Based Validation

```powershell
function Get-ValidationLevel {
    param([string]$Environment)

    switch ($Environment) {
        "Development" { [CertificateValidationLevel]::Basic }
        "Test"        { [CertificateValidationLevel]::Standard }
        "Production"  { [CertificateValidationLevel]::Strict }
        default       { [CertificateValidationLevel]::Standard }
    }
}

### Use appropriate validation for environment
$level = Get-ValidationLevel -Environment $env:ENVIRONMENT
$cert = Get-Certificate -Thumbprint $thumbprint -ValidationLevel $level
```

#### Example 5: Expiration Warning Check

```powershell
function Test-CertificateExpiration {
    param(
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,
        [int]$WarningDays = 30
    )

    $certInfo = [CertificateInfo]::new($Certificate)
    $daysLeft = $certInfo.DaysUntilExpiration()

    if ($daysLeft -le 0) {
        Write-Log "Certificate EXPIRED: $($certInfo.Subject)" -Level Error
        return $false
    }
    elseif ($daysLeft -le $WarningDays) {
        Write-Log "Certificate expires in $daysLeft days: $($certInfo.Subject)" -Level Warning
        return $true
    }
    else {
        Write-Log "Certificate valid for $daysLeft days: $($certInfo.Subject)" -Level Success
        return $true
    }
}
```

### Best Practices

1. **Use Standard for production** - Best balance of security and performance
2. **Use Strict for high-security** - Financial, healthcare, compliance scenarios
3. **Never use None in production** - Only for local testing
4. **Implement expiration warnings** - Alert 30-60 days before expiration
5. **Cache validation results** - Don't re-validate on every call
6. **Handle offline scenarios** - Strict validation requires internet for CRL/OCSP

---

## ErrorHandlingStrategy Enum

**File:** `Enums/ErrorHandlingStrategy.ps1`

### Description

Defines strategies for handling errors in module functions. Controls how errors are reported and whether execution continues.

### Definition

```powershell
enum ErrorHandlingStrategy {
    Silent = 0  ### Suppress errors, return null or default value
    Warn = 1    ### Write warning message, continue execution
    Throw = 2   ### Throw exception, stop execution immediately
    Retry = 3   ### Retry operation with exponential backoff
}
```

### Values

| Value    | Numeric Code | Behavior                     | Execution       | Use Case                                        |
| -------- | ------------ | ---------------------------- | --------------- | ----------------------------------------------- |
| `Silent` | 0            | Suppress errors, return null | Continues       | Optional operations, non-critical failures      |
| `Warn`   | 1            | Write warning, return null   | Continues       | Degraded functionality, fallback available      |
| `Throw`  | 2            | Throw exception              | **Stops**       | **Critical errors**, data corruption prevention |
| `Retry`  | 3            | Retry with backoff           | Continues/Stops | Transient failures, network issues              |

### Usage Examples

#### Example 1: Silent Error Handling

```powershell
function Get-UserSafely {
    param(
        [string]$UserId,
        [ErrorHandlingStrategy]$ErrorStrategy = [ErrorHandlingStrategy]::Silent
    )

    try {
        return Get-MgUser -UserId $UserId
    }
    catch {
        if ($ErrorStrategy -eq [ErrorHandlingStrategy]::Silent) {
            return $null
        }
    }
}

### Returns null without error if user doesn't exist
$user = Get-UserSafely -UserId "nonexistent@domain.com"
if ($null -eq $user) {
    Write-Log "User not found, using default" -Level Verbose
}
```

#### Example 2: Warning Strategy

```powershell
function Import-UsersFromCsv {
    param(
        [string]$CsvPath,
        [ErrorHandlingStrategy]$ErrorStrategy = [ErrorHandlingStrategy]::Warn
    )

    $users = Import-Csv -Path $CsvPath
    $imported = 0
    $failed = 0

    foreach ($user in $users) {
        try {
            New-MgUser -UserPrincipalName $user.UPN -DisplayName $user.Name
            $imported++
        }
        catch {
            $failed++
            if ($ErrorStrategy -eq [ErrorHandlingStrategy]::Warn) {
                Write-Log "Failed to create user $($user.UPN): $($_.Exception.Message)" -Level Warning
                ### Continue with next user
            }
        }
    }

    Write-Log "Import complete: $imported successful, $failed failed"
}
```

#### Example 3: Throw Strategy (Critical Operations)

```powershell
function Remove-CriticalData {
    param(
        [string]$DataId,
        [ErrorHandlingStrategy]$ErrorStrategy = [ErrorHandlingStrategy]::Throw
    )

    ### For critical operations, fail fast
    try {
        ### Verify data exists
        $data = Get-Data -Id $DataId
        if (-not $data) {
            throw "Data not found: $DataId"
        }

        ### Perform deletion
        Remove-Data -Id $DataId
    }
    catch {
        if ($ErrorStrategy -eq [ErrorHandlingStrategy]::Throw) {
            ### Stop everything, alert operators
            Write-Log "CRITICAL: Failed to remove data $DataId" -Level Error
            throw
        }
    }
}
```

#### Example 4: Retry Strategy with Exponential Backoff

```powershell
function Invoke-WithRetry {
    param(
        [scriptblock]$Action,
        [int]$MaxAttempts = 3,
        [int]$InitialDelayMs = 1000,
        [ErrorHandlingStrategy]$ErrorStrategy = [ErrorHandlingStrategy]::Retry
    )

    $attempt = 0
    $delay = $InitialDelayMs

    while ($attempt -lt $MaxAttempts) {
        $attempt++
        try {
            return & $Action
        }
        catch {
            if ($ErrorStrategy -eq [ErrorHandlingStrategy]::Retry -and $attempt -lt $MaxAttempts) {
                Write-Log "Attempt $attempt failed, retrying in $delay ms..." -Level Warning
                Start-Sleep -Milliseconds $delay
                $delay *= 2  ### Exponential backoff
            }
            else {
                ### Max attempts reached or not using retry strategy
                throw "Operation failed after $attempt attempts: $($_.Exception.Message)"
            }
        }
    }
}

### Usage
$users = Invoke-WithRetry -Action {
    Get-MgUser -All
} -ErrorStrategy Retry
```

#### Example 5: Strategy Selection Based on Context

```powershell
function Get-ErrorStrategy {
    param(
        [string]$OperationType,
        [bool]$IsBatchOperation
    )

    ### Critical operations always throw
    if ($OperationType -in @("Delete", "Modify")) {
        return [ErrorHandlingStrategy]::Throw
    }

    ### Batch operations use warn to continue processing
    if ($IsBatchOperation) {
        return [ErrorHandlingStrategy]::Warn
    }

    ### Network operations use retry
    if ($OperationType -in @("API", "Network")) {
        return [ErrorHandlingStrategy]::Retry
    }

    ### Default to throw for safety
    return [ErrorHandlingStrategy]::Throw
}

### Example usage
$strategy = Get-ErrorStrategy -OperationType "API" -IsBatchOperation $false
Invoke-Operation -ErrorStrategy $strategy
```

### Best Practices

1. **Default to Throw** - Fail fast for safety unless you have a specific reason
2. **Use Warn for batch operations** - Continue processing other items
3. **Use Retry for network operations** - Handle transient failures gracefully
4. **Never use Silent for critical data** - Could hide data corruption
5. **Log all errors** - Even with Silent, log for troubleshooting
6. **Combine with RetryPolicy class** - Use RetryPolicy for sophisticated retry logic

---

## Best Practices

### General Enum Usage

1. **Always use strongly-typed parameters**
   ```powershell
   ### Good
   function Write-Log {
       param([LogLevel]$Level)
   }

   ### Bad
   function Write-Log {
       param([string]$Level)
   }
   ```

2. **Leverage IntelliSense**
   - Type `[LogLevel]::` and press Ctrl+Space for auto-completion
   - Use in parameter sets for automatic validation

3. **Use numeric comparison for levels**
   ```powershell
   if ($currentLevel -ge [LogLevel]::Warning) {
       ### Log warnings and errors
   }
   ```

4. **Document enum values in function help**
   ```powershell
   <#
   .PARAMETER Level
   Log level for the message:
   - Verbose: Detailed diagnostic information
   - Info: General informational messages
   - Warning: Warning messages for potential issues
   - Error: Error messages for failures
   #>
   ```

5. **Use enums in configuration files**
   ```json
   {
       "logging": {
           "logMode": "Daily",
           "defaultLevel": "Info"
       }
   }
   ```

### Performance Considerations

1. **Enums are faster than string comparisons**
   ```powershell
   ### Fast
   if ($level -eq [LogLevel]::Error) { }

   ### Slower
   if ($level -eq "Error") { }
   ```

2. **Cache enum values in loops**
   ```powershell
   $errorLevel = [LogLevel]::Error
   foreach ($item in $items) {
       if ($item.Level -ge $errorLevel) { }
   }
   ```

### Validation and Error Handling

1. **PowerShell validates enum parameters automatically**
   ```powershell
   ### Invalid value will be rejected before function runs
   Write-Log -Level "InvalidValue"  ### Error: Cannot convert value
   ```

2. **Convert strings to enums safely**
   ```powershell
   $levelString = "Info"
   $level = [LogLevel]$levelString  ### Type cast

   ### Or with validation
   if ([Enum]::IsDefined([LogLevel], $levelString)) {
       $level = [LogLevel]$levelString
   }
   ```

---

## About

**Module:** Brennan.PowerShell.Core
**Version:** 1.0.0
**Author:** Chris Brennan
**Company:** Brennan Technologies, LLC
**Email:** chris@brennantechnologies.com
**Date:** December 14, 2025

---

### Related Documentation

- [Configuration Guide](./CONFIGURATION.md)
- [Classes Reference](./CLASSES.md)
- [Module README](../README.md)

---

*Copyright © 2025 Brennan Technologies, LLC. All rights reserved.*
