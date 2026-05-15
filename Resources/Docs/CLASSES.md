# Classes Reference

![Brennan Technologies Logo](../Resources/Images/Brennan%20Logo%20--%20Transparent%20--%20SMALL.png)

## Table of Contents

- [Overview](#overview)
- [GraphAPIConnection Class](#graphapiconnection-class)
- [LogEntry Class](#logentry-class)
- [CertificateInfo Class](#certificateinfo-class)
- [ModuleManifest Class](#modulemanifest-class)
- [RetryPolicy Class](#retrypolicy-class)
- [Best Practices](#best-practices)
- [About](#about)

---

## Overview

The Brennan.PowerShell.Core module includes five PowerShell classes that provide object-oriented functionality for common operations. These classes encapsulate state and behavior, making code more maintainable and reusable.

**Module Classes:**
- **GraphAPIConnection** - Manages Microsoft Graph API connection state
- **LogEntry** - Represents structured log entries
- **CertificateInfo** - Wraps X509Certificate2 with validation
- **ModuleManifest** - Manages module configuration and metadata
- **RetryPolicy** - Implements retry logic with exponential backoff

**Benefits of Using Classes:**
- **Encapsulation**: Bundle related data and methods
- **Type Safety**: Strong typing with property validation
- **Reusability**: Create instances for different contexts
- **IntelliSense**: Auto-completion for properties and methods
- **Maintainability**: Centralized logic and state management

---

## GraphAPIConnection Class

**File:** `Classes/GraphAPIConnection.ps1`

### Description

Manages Microsoft Graph API connection state and context. Tracks authentication details, connection status, token expiration, and authorized scopes.

### Properties

| Property      | Type               | Description                               | Default      |
| ------------- | ------------------ | ----------------------------------------- | ------------ |
| `TenantId`    | string             | Azure AD Tenant ID (GUID)                 | -            |
| `ClientId`    | string             | Application Client ID (GUID)              | -            |
| `AuthType`    | AuthenticationType | Authentication method used                | -            |
| `Status`      | ConnectionStatus   | Current connection status                 | Disconnected |
| `ConnectedAt` | datetime           | Timestamp when connection was established | -            |
| `ExpiresAt`   | datetime           | Token expiration timestamp                | -            |
| `Scopes`      | string[]           | Authorized Microsoft Graph scopes         | @()          |

### Constructor

```powershell
GraphAPIConnection([string]$tenantId, [string]$clientId, [AuthenticationType]$authType)
```

**Parameters:**
- `tenantId` - Azure AD Tenant ID
- `clientId` - Application Client ID
- `authType` - Authentication method (Certificate, Interactive, etc.)

**Example:**
```powershell
$connection = [GraphAPIConnection]::new(
    "12345678-1234-1234-1234-123456789abc",
    "abcdef12-abcd-abcd-abcd-abcdef123456",
    [AuthenticationType]::Certificate
)
```

### Methods

#### IsValid()

Checks if the connection is currently valid and not expired.

**Signature:**
```powershell
[bool]IsValid()
```

**Returns:** `$true` if connected and not expired, `$false` otherwise

**Example:**
```powershell
if ($connection.IsValid()) {
    ### Proceed with Graph API operations
    Get-MgUser -All
}
else {
    Write-Log "Connection invalid or expired" -Level Warning
    ### Reconnect
}
```

---

#### UpdateStatus()

Updates the connection status and sets connection timestamp if status is Connected.

**Signature:**
```powershell
[void]UpdateStatus([ConnectionStatus]$newStatus)
```

**Parameters:**
- `newStatus` - New connection status to set

**Example:**
```powershell
### After successful connection
$connection.UpdateStatus([ConnectionStatus]::Connected)

### Connection timestamp automatically set
Write-Log "Connected at: $($connection.ConnectedAt)"

### When disconnecting
$connection.UpdateStatus([ConnectionStatus]::Disconnected)
```

---

#### AddScopes()

Adds Microsoft Graph API scopes to the connection. Prevents duplicate scopes.

**Signature:**
```powershell
[void]AddScopes([string[]]$scopes)
```

**Parameters:**
- `scopes` - Array of Graph API permission scopes to add

**Example:**
```powershell
### Add initial scopes
$connection.AddScopes(@("User.Read.All", "Group.Read.All"))

### Add more scopes (duplicates ignored)
$connection.AddScopes(@("Group.Read.All", "Directory.Read.All"))

### Result: User.Read.All, Group.Read.All, Directory.Read.All
Write-Log "Authorized scopes: $($connection.Scopes -join ', ')"
```

---

### Usage Examples

#### Example 1: Basic Connection Management

```powershell
### Create connection instance
$connection = [GraphAPIConnection]::new(
    "tenant-id",
    "client-id",
    [AuthenticationType]::Certificate
)

### Add required scopes
$connection.AddScopes(@("User.Read.All", "Group.Read.All"))

### Update status during connection
$connection.UpdateStatus([ConnectionStatus]::Connecting)

try {
    ### Attempt connection
    Connect-MgGraph -TenantId $connection.TenantId `
                    -ClientId $connection.ClientId `
                    -CertificateThumbprint $thumbprint

    ### Connection successful
    $connection.UpdateStatus([ConnectionStatus]::Connected)
    $connection.ExpiresAt = (Get-Date).AddHours(1)

    Write-Log "Connected to Microsoft Graph" -Level Success
}
catch {
    $connection.UpdateStatus([ConnectionStatus]::Failed)
    Write-Log "Connection failed: $($_.Exception.Message)" -Level Error
}
```

---

#### Example 2: Connection Validation and Auto-Reconnect

```powershell
function Invoke-GraphOperation {
    param(
        [GraphAPIConnection]$Connection,
        [scriptblock]$Operation
    )

    ### Validate connection before operation
    if (-not $Connection.IsValid()) {
        Write-Log "Connection invalid, attempting reconnect..." -Level Warning

        ### Reconnect
        Connect-MgGraph -TenantId $Connection.TenantId `
                       -ClientId $Connection.ClientId

        $Connection.UpdateStatus([ConnectionStatus]::Connected)
        $Connection.ExpiresAt = (Get-Date).AddHours(1)
    }

    ### Execute operation
    try {
        & $Operation
    }
    catch {
        Write-Log "Operation failed: $($_.Exception.Message)" -Level Error
        throw
    }
}

### Usage
$connection = [GraphAPIConnection]::new("tenant", "client", [AuthenticationType]::Interactive)

Invoke-GraphOperation -Connection $connection -Operation {
    Get-MgUser -All
}
```

---

#### Example 3: Multi-Tenant Connection Manager

```powershell
class GraphConnectionManager {
    [hashtable]$Connections = @{}

    [void]AddConnection([string]$name, [GraphAPIConnection]$connection) {
        $this.Connections[$name] = $connection
    }

    [GraphAPIConnection]GetConnection([string]$name) {
        if (-not $this.Connections.ContainsKey($name)) {
            throw "Connection not found: $name"
        }
        return $this.Connections[$name]
    }

    [bool]ValidateAll() {
        $allValid = $true
        foreach ($name in $this.Connections.Keys) {
            $connection = $this.Connections[$name]
            if (-not $connection.IsValid()) {
                Write-Log "Connection '$name' is invalid" -Level Warning
                $allValid = $false
            }
        }
        return $allValid
    }
}

### Usage
$manager = [GraphConnectionManager]::new()

### Add multiple tenant connections
$prodConnection = [GraphAPIConnection]::new("prod-tenant", "prod-client", [AuthenticationType]::Certificate)
$testConnection = [GraphAPIConnection]::new("test-tenant", "test-client", [AuthenticationType]::Certificate)

$manager.AddConnection("Production", $prodConnection)
$manager.AddConnection("Test", $testConnection)

### Validate all connections
if ($manager.ValidateAll()) {
    Write-Log "All connections valid" -Level Success
}
```

---

#### Example 4: Connection Status Monitoring

```powershell
function Start-ConnectionMonitor {
    param(
        [GraphAPIConnection]$Connection,
        [int]$IntervalSeconds = 300
    )

    while ($true) {
        ### Check connection status
        if ($Connection.Status -eq [ConnectionStatus]::Connected) {
            if (-not $Connection.IsValid()) {
                Write-Log "Connection expired, reconnecting..." -Level Warning
                $Connection.UpdateStatus([ConnectionStatus]::Expired)
                ### Trigger reconnection logic here
            }
            else {
                $timeRemaining = ($Connection.ExpiresAt - (Get-Date)).TotalMinutes
                Write-Log "Connection valid, expires in $([Math]::Round($timeRemaining, 1)) minutes" -Level Verbose
            }
        }

        Start-Sleep -Seconds $IntervalSeconds
    }
}

### Start monitoring in background job
$connection = [GraphAPIConnection]::new("tenant", "client", [AuthenticationType]::Certificate)
Start-Job -ScriptBlock ${function:Start-ConnectionMonitor} -ArgumentList $connection, 60
```

---

#### Example 5: Scope Management and Validation

```powershell
function Assert-RequiredScopes {
    param(
        [GraphAPIConnection]$Connection,
        [string[]]$RequiredScopes
    )

    $missingScopes = @()
    foreach ($scope in $RequiredScopes) {
        if ($Connection.Scopes -notcontains $scope) {
            $missingScopes += $scope
        }
    }

    if ($missingScopes.Count -gt 0) {
        throw "Missing required scopes: $($missingScopes -join ', ')"
    }

    Write-Log "All required scopes present" -Level Success
}

### Usage
$connection = [GraphAPIConnection]::new("tenant", "client", [AuthenticationType]::Certificate)
$connection.AddScopes(@("User.Read.All", "Group.Read.All"))

### Verify scopes before operation
Assert-RequiredScopes -Connection $connection -RequiredScopes @("User.Read.All", "Group.Read.All")

### This would throw an error
Assert-RequiredScopes -Connection $connection -RequiredScopes @("Directory.ReadWrite.All")
```

---

## LogEntry Class

**File:** `Classes/LogEntry.ps1`

### Description

Represents a single log entry with metadata. Captures timestamp, level, message, caller information, and custom metadata for structured logging.

### Properties

| Property         | Type      | Description                     | Default       |
| ---------------- | --------- | ------------------------------- | ------------- |
| `Timestamp`      | datetime  | When the log entry was created  | Current time  |
| `Level`          | LogLevel  | Severity level of the log entry | -             |
| `Message`        | string    | Log message text                | -             |
| `CallerFunction` | string    | Name of the calling function    | Auto-detected |
| `ScriptName`     | string    | Name of the calling script      | Auto-detected |
| `Metadata`       | hashtable | Custom key-value metadata       | @{}           |

### Constructors

#### Default Constructor

```powershell
LogEntry()
```

Creates a new log entry with timestamp and empty metadata.

**Example:**
```powershell
$entry = [LogEntry]::new()
$entry.Level = [LogLevel]::Info
$entry.Message = "Custom message"
```

---

#### Parameterized Constructor

```powershell
LogEntry([string]$message, [LogLevel]$level)
```

Creates a log entry with message and level, automatically capturing caller information.

**Parameters:**
- `message` - Log message text
- `level` - Severity level

**Example:**
```powershell
$entry = [LogEntry]::new("User created successfully", [LogLevel]::Success)
### CallerFunction and ScriptName automatically populated
```

---

### Methods

#### ToString()

Converts the log entry to a formatted string for display or file output.

**Signature:**
```powershell
[string]ToString()
```

**Returns:** Formatted string: `[timestamp] [level] message`

**Example:**
```powershell
$entry = [LogEntry]::new("Test message", [LogLevel]::Info)
$formatted = $entry.ToString()
### Output: [2025-12-14 14:30:22] [Info] Test message
```

---

#### ToJson()

Converts the log entry to compressed JSON format for structured logging.

**Signature:**
```powershell
[string]ToJson()
```

**Returns:** JSON representation of the log entry

**Example:**
```powershell
$entry = [LogEntry]::new("API call completed", [LogLevel]::Success)
$entry.AddMetadata("Duration", 1.23)
$entry.AddMetadata("StatusCode", 200)

$json = $entry.ToJson()
### Output: {"Timestamp":"2025-12-14T14:30:22","Level":4,"Message":"API call completed",...}
```

---

#### AddMetadata()

Adds a key-value pair to the metadata hashtable.

**Signature:**
```powershell
[void]AddMetadata([string]$key, [object]$value)
```

**Parameters:**
- `key` - Metadata key name
- `value` - Metadata value (any object type)

**Example:**
```powershell
$entry = [LogEntry]::new("User login", [LogLevel]::Info)
$entry.AddMetadata("UserName", "john.doe@company.com")
$entry.AddMetadata("IPAddress", "192.168.1.100")
$entry.AddMetadata("LoginAttempts", 1)
```

---

### Usage Examples

#### Example 1: Basic Structured Logging

```powershell
function Write-StructuredLog {
    param(
        [string]$Message,
        [LogLevel]$Level,
        [hashtable]$Metadata = @{}
    )

    ### Create log entry
    $entry = [LogEntry]::new($Message, $Level)

    ### Add metadata
    foreach ($key in $Metadata.Keys) {
        $entry.AddMetadata($key, $Metadata[$key])
    }

    ### Output to console
    Write-Host $entry.ToString()

    ### Append to JSON log file
    $entry.ToJson() | Add-Content -Path ".\Logs\structured.json"
}

### Usage
Write-StructuredLog -Message "User created" -Level Success -Metadata @{
    UserId = "12345"
    UserName = "john.doe"
    Department = "IT"
}
```

---

#### Example 2: Performance Tracking

```powershell
function Measure-OperationWithLogging {
    param(
        [string]$OperationName,
        [scriptblock]$Operation
    )

    $startTime = Get-Date
    $entry = [LogEntry]::new("$OperationName started", [LogLevel]::Info)
    $entry.AddMetadata("StartTime", $startTime)

    try {
        ### Execute operation
        $result = & $Operation

        ### Log success
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds

        $successEntry = [LogEntry]::new("$OperationName completed", [LogLevel]::Success)
        $successEntry.AddMetadata("Duration", $duration)
        $successEntry.AddMetadata("Result", $result)

        Write-Host $successEntry.ToString()
        $successEntry.ToJson() | Add-Content ".\Logs\performance.json"

        return $result
    }
    catch {
        ### Log error
        $errorEntry = [LogEntry]::new("$OperationName failed", [LogLevel]::Error)
        $errorEntry.AddMetadata("Error", $_.Exception.Message)
        $errorEntry.AddMetadata("Duration", ($endTime - $startTime).TotalSeconds)

        Write-Host $errorEntry.ToString() -ForegroundColor Red
        throw
    }
}

### Usage
$users = Measure-OperationWithLogging -OperationName "Get-MgUser" -Operation {
    Get-MgUser -All
}
```

---

#### Example 3: Correlation ID Tracking

```powershell
function New-LogContext {
    param([string]$CorrelationId = [guid]::NewGuid().ToString())

    return [PSCustomObject]@{
        CorrelationId = $CorrelationId
        Entries = [System.Collections.ArrayList]::new()
    }
}

function Write-ContextualLog {
    param(
        [PSCustomObject]$Context,
        [string]$Message,
        [LogLevel]$Level
    )

    $entry = [LogEntry]::new($Message, $Level)
    $entry.AddMetadata("CorrelationId", $Context.CorrelationId)

    [void]$Context.Entries.Add($entry)

    Write-Host $entry.ToString()
}

### Usage - Track related operations
$context = New-LogContext
Write-ContextualLog $context "Starting user import" Info
Write-ContextualLog $context "Validated 100 users" Success
Write-ContextualLog $context "Created 95 users" Success
Write-ContextualLog $context "5 users failed validation" Warning

### Export all related log entries
$context.Entries | ForEach-Object { $_.ToJson() } | Set-Content ".\Logs\import-$($context.CorrelationId).json"
```

---

#### Example 4: Log Aggregation and Analysis

```powershell
function Get-LogStatistics {
    param([string]$LogPath)

    ### Read JSON log entries
    $entries = Get-Content $LogPath | ForEach-Object {
        $_ | ConvertFrom-Json
    }

    ### Calculate statistics
    $stats = [PSCustomObject]@{
        TotalEntries = $entries.Count
        ByLevel = @{}
        TimeSpan = $null
        ErrorRate = 0
    }

    ### Count by level
    foreach ($entry in $entries) {
        $level = $entry.Level
        if (-not $stats.ByLevel.ContainsKey($level)) {
            $stats.ByLevel[$level] = 0
        }
        $stats.ByLevel[$level]++
    }

    ### Calculate time span
    if ($entries.Count -gt 0) {
        $firstTimestamp = [datetime]$entries[0].Timestamp
        $lastTimestamp = [datetime]$entries[-1].Timestamp
        $stats.TimeSpan = $lastTimestamp - $firstTimestamp

        ### Error rate
        $errorCount = $stats.ByLevel[[LogLevel]::Error] ?? 0
        $stats.ErrorRate = [Math]::Round(($errorCount / $entries.Count) * 100, 2)
    }

    return $stats
}

### Usage
$stats = Get-LogStatistics -LogPath ".\Logs\structured.json"
Write-Host "Total Entries: $($stats.TotalEntries)"
Write-Host "Error Rate: $($stats.ErrorRate)%"
```

---

#### Example 5: Custom Log Formatters

```powershell
function Format-LogEntry {
    param(
        [LogEntry]$Entry,
        [string]$Format = "Standard"
    )

    switch ($Format) {
        "Simple" {
            return "[$($Entry.Level)] $($Entry.Message)"
        }
        "Detailed" {
            return "[$($Entry.Timestamp)] [$($Entry.Level)] [$($Entry.CallerFunction)] $($Entry.Message)"
        }
        "Json" {
            return $Entry.ToJson()
        }
        "Xml" {
            return @"
<LogEntry>
    <Timestamp>$($Entry.Timestamp)</Timestamp>
    <Level>$($Entry.Level)</Level>
    <Message>$($Entry.Message)</Message>
    <Caller>$($Entry.CallerFunction)</Caller>
</LogEntry>
"@
        }
        default {
            return $Entry.ToString()
        }
    }
}

### Usage
$entry = [LogEntry]::new("Application started", [LogLevel]::Info)

Format-LogEntry $entry -Format Simple
### Output: [Info] Application started

Format-LogEntry $entry -Format Detailed
### Output: [2025-12-14 14:30:22] [Info] [Main] Application started
```

---

## CertificateInfo Class

**File:** `Classes/CertificateInfo.ps1`

### Description

Wraps X509Certificate2 with validation and metadata. Provides convenient methods for certificate validation, expiration checking, and information retrieval.

### Properties

| Property           | Type             | Description                           |
| ------------------ | ---------------- | ------------------------------------- |
| `Thumbprint`       | string           | Certificate thumbprint (40-char hex)  |
| `Subject`          | string           | Certificate subject DN                |
| `Issuer`           | string           | Certificate issuer DN                 |
| `NotBefore`        | datetime         | Certificate validity start date       |
| `NotAfter`         | datetime         | Certificate validity end date         |
| `IsValid`          | bool             | Whether certificate passed validation |
| `ValidationErrors` | string[]         | List of validation error messages     |
| `Certificate`      | X509Certificate2 | Underlying certificate object         |

### Constructor

```powershell
CertificateInfo([System.Security.Cryptography.X509Certificates.X509Certificate2]$cert)
```

**Parameters:**
- `cert` - X509Certificate2 object to wrap

**Example:**
```powershell
$cert = Get-ChildItem Cert:\CurrentUser\My | Select-Object -First 1
$certInfo = [CertificateInfo]::new($cert)
```

### Methods

#### Validate()

Validates the certificate and populates ValidationErrors array.

**Signature:**
```powershell
[void]Validate()
```

**Validation Checks:**
- Certificate not yet valid (before NotBefore date)
- Certificate expired (after NotAfter date)

**Example:**
```powershell
$certInfo = [CertificateInfo]::new($cert)
### Validation automatically called in constructor

if (-not $certInfo.IsValid) {
    Write-Log "Certificate validation failed:" -Level Error
    foreach ($error in $certInfo.ValidationErrors) {
        Write-Log "  - $error" -Level Error
    }
}
```

---

#### DaysUntilExpiration()

Calculates days remaining until certificate expires.

**Signature:**
```powershell
[int]DaysUntilExpiration()
```

**Returns:** Number of days until expiration (negative if expired)

**Example:**
```powershell
$certInfo = [CertificateInfo]::new($cert)
$daysLeft = $certInfo.DaysUntilExpiration()

if ($daysLeft -lt 0) {
    Write-Log "Certificate EXPIRED $([Math]::Abs($daysLeft)) days ago" -Level Error
}
elseif ($daysLeft -le 30) {
    Write-Log "Certificate expires in $daysLeft days" -Level Warning
}
else {
    Write-Log "Certificate valid for $daysLeft days" -Level Success
}
```

---

#### IsExpiringSoon()

Checks if certificate is expiring within specified threshold.

**Signature:**
```powershell
[bool]IsExpiringSoon([int]$daysThreshold)
```

**Parameters:**
- `daysThreshold` - Number of days to consider as "expiring soon"

**Returns:** `$true` if expiring within threshold, `$false` otherwise

**Example:**
```powershell
$certInfo = [CertificateInfo]::new($cert)

if ($certInfo.IsExpiringSoon(30)) {
    Write-Log "Certificate renewal required" -Level Warning
    Send-MailMessage -Subject "Certificate Expiring" -Body "Please renew certificate"
}
```

---

#### GetCommonName()

Extracts the Common Name (CN) from the certificate subject.

**Signature:**
```powershell
[string]GetCommonName()
```

**Returns:** Common Name if found, otherwise full subject string

**Example:**
```powershell
$certInfo = [CertificateInfo]::new($cert)
$cn = $certInfo.GetCommonName()

Write-Log "Certificate for: $cn"
### Output: Certificate for: *.brennantechnologies.com
```

---

### Usage Examples

#### Example 1: Certificate Validation Before Use

```powershell
function Connect-WithCertificate {
    param(
        [string]$Thumbprint,
        [string]$TenantId,
        [string]$ClientId
    )

    ### Get certificate
    $cert = Get-ChildItem Cert:\CurrentUser\My |
            Where-Object { $_.Thumbprint -eq $Thumbprint }

    if (-not $cert) {
        throw "Certificate not found: $Thumbprint"
    }

    ### Validate certificate
    $certInfo = [CertificateInfo]::new($cert)

    if (-not $certInfo.IsValid) {
        throw "Certificate validation failed: $($certInfo.ValidationErrors -join ', ')"
    }

    if ($certInfo.IsExpiringSoon(30)) {
        Write-Log "WARNING: Certificate expires in $($certInfo.DaysUntilExpiration()) days" -Level Warning
    }

    ### Proceed with connection
    Connect-MgGraph -TenantId $TenantId `
                    -ClientId $ClientId `
                    -CertificateThumbprint $Thumbprint

    Write-Log "Connected using certificate: $($certInfo.GetCommonName())" -Level Success
}
```

---

#### Example 2: Certificate Inventory Report

```powershell
function Export-CertificateInventory {
    param(
        [string]$OutputPath = ".\Reports\Certificates.csv"
    )

    $certificates = Get-ChildItem Cert:\CurrentUser\My
    $inventory = @()

    foreach ($cert in $certificates) {
        $certInfo = [CertificateInfo]::new($cert)

        $inventory += [PSCustomObject]@{
            CommonName = $certInfo.GetCommonName()
            Thumbprint = $certInfo.Thumbprint
            Issuer = $certInfo.Issuer
            ValidFrom = $certInfo.NotBefore
            ValidUntil = $certInfo.NotAfter
            DaysRemaining = $certInfo.DaysUntilExpiration()
            IsValid = $certInfo.IsValid
            Status = if (-not $certInfo.IsValid) {
                "Invalid"
            } elseif ($certInfo.IsExpiringSoon(30)) {
                "Expiring Soon"
            } else {
                "Valid"
            }
            ValidationErrors = $certInfo.ValidationErrors -join "; "
        }
    }

    $inventory | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Log "Certificate inventory exported to: $OutputPath" -Level Success
}
```

---

#### Example 3: Automated Certificate Renewal Alerts

```powershell
function Start-CertificateMonitoring {
    param(
        [int]$WarningDays = 30,
        [int]$CriticalDays = 7,
        [string]$AlertEmail = "admin@company.com"
    )

    $certificates = Get-ChildItem Cert:\CurrentUser\My
    $alerts = @()

    foreach ($cert in $certificates) {
        $certInfo = [CertificateInfo]::new($cert)

        if (-not $certInfo.IsValid) {
            $alerts += [PSCustomObject]@{
                Severity = "Critical"
                Certificate = $certInfo.GetCommonName()
                Message = "Certificate is INVALID: $($certInfo.ValidationErrors -join ', ')"
                DaysLeft = $certInfo.DaysUntilExpiration()
            }
        }
        elseif ($certInfo.IsExpiringSoon($CriticalDays)) {
            $alerts += [PSCustomObject]@{
                Severity = "Critical"
                Certificate = $certInfo.GetCommonName()
                Message = "Certificate expires in $($certInfo.DaysUntilExpiration()) days"
                DaysLeft = $certInfo.DaysUntilExpiration()
            }
        }
        elseif ($certInfo.IsExpiringSoon($WarningDays)) {
            $alerts += [PSCustomObject]@{
                Severity = "Warning"
                Certificate = $certInfo.GetCommonName()
                Message = "Certificate expires in $($certInfo.DaysUntilExpiration()) days"
                DaysLeft = $certInfo.DaysUntilExpiration()
            }
        }
    }

    if ($alerts.Count -gt 0) {
        ### Send alert email
        $body = $alerts | Format-Table -AutoSize | Out-String
        Send-MailMessage -To $AlertEmail `
                        -Subject "Certificate Expiration Alerts" `
                        -Body $body `
                        -SmtpServer "smtp.company.com"

        Write-Log "Sent $($alerts.Count) certificate alerts to $AlertEmail" -Level Warning
    }
    else {
        Write-Log "All certificates valid" -Level Success
    }
}

### Run as scheduled task
Start-CertificateMonitoring -WarningDays 30 -CriticalDays 7
```

---

#### Example 4: Certificate Key Usage Validation

```powershell
function Test-CertificateKeyUsage {
    param(
        [CertificateInfo]$CertificateInfo,
        [string[]]$RequiredUsages = @("Digital Signature", "Key Encipherment")
    )

    $cert = $CertificateInfo.Certificate
    $missingUsages = @()

    foreach ($usage in $RequiredUsages) {
        $hasUsage = $cert.Extensions |
                   Where-Object { $_.Oid.FriendlyName -eq "Key Usage" } |
                   ForEach-Object { $_.Format($false) -match $usage }

        if (-not $hasUsage) {
            $missingUsages += $usage
        }
    }

    if ($missingUsages.Count -gt 0) {
        Write-Log "Certificate missing key usages: $($missingUsages -join ', ')" -Level Warning
        return $false
    }

    Write-Log "Certificate has all required key usages" -Level Success
    return $true
}

### Usage
$cert = Get-ChildItem Cert:\CurrentUser\My | Select-Object -First 1
$certInfo = [CertificateInfo]::new($cert)

Test-CertificateKeyUsage -CertificateInfo $certInfo
```

---

#### Example 5: Certificate Chain Validation

```powershell
function Test-CertificateChain {
    param([CertificateInfo]$CertificateInfo)

    $cert = $CertificateInfo.Certificate
    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain

    ### Configure chain policy
    $chain.ChainPolicy.RevocationMode = "Online"
    $chain.ChainPolicy.RevocationFlag = "EntireChain"

    ### Build and validate chain
    $isValid = $chain.Build($cert)

    $result = [PSCustomObject]@{
        IsValid = $isValid
        ChainElements = @()
        Errors = @()
    }

    ### Collect chain information
    foreach ($element in $chain.ChainElements) {
        $result.ChainElements += [PSCustomObject]@{
            Subject = $element.Certificate.Subject
            Issuer = $element.Certificate.Issuer
            NotAfter = $element.Certificate.NotAfter
        }

        foreach ($status in $element.ChainElementStatus) {
            $result.Errors += "$($status.Status): $($status.StatusInformation)"
        }
    }

    return $result
}

### Usage
$cert = Get-ChildItem Cert:\CurrentUser\My | Select-Object -First 1
$certInfo = [CertificateInfo]::new($cert)
$chainResult = Test-CertificateChain -CertificateInfo $certInfo

if ($chainResult.IsValid) {
    Write-Log "Certificate chain is valid" -Level Success
}
else {
    Write-Log "Certificate chain validation failed:" -Level Error
    $chainResult.Errors | ForEach-Object { Write-Log "  $_" -Level Error }
}
```

---

## ModuleManifest Class

**File:** `Classes/ModuleManifest.ps1`

### Description

Represents module configuration and metadata. Loads and validates PowerShell module manifests (.psd1 files) and manages module dependencies.

### Properties

| Property          | Type      | Description                   |
| ----------------- | --------- | ----------------------------- |
| `Name`            | string    | Module name                   |
| `Version`         | version   | Module version                |
| `Author`          | string    | Module author                 |
| `CompanyName`     | string    | Company name                  |
| `Description`     | string    | Module description            |
| `RequiredModules` | string[]  | List of required module names |
| `Settings`        | hashtable | Custom settings dictionary    |

### Constructors

#### Basic Constructor

```powershell
ModuleManifest([string]$name, [version]$version)
```

**Parameters:**
- `name` - Module name
- `version` - Module version

**Example:**
```powershell
$manifest = [ModuleManifest]::new("Brennan.PowerShell.Core", [version]"1.0.0")
$manifest.Author = "Chris Brennan"
$manifest.RequiredModules = @("Microsoft.Graph.Authentication")
```

---

### Static Methods

#### FromFile()

Loads a module manifest from a .psd1 file.

**Signature:**
```powershell
static [ModuleManifest]FromFile([string]$path)
```

**Parameters:**
- `path` - Path to .psd1 manifest file

**Returns:** ModuleManifest instance populated from file

**Example:**
```powershell
$manifest = [ModuleManifest]::FromFile(".\Brennan.PowerShell.Core.psd1")

Write-Host "Module: $($manifest.Name) v$($manifest.Version)"
Write-Host "Author: $($manifest.Author)"
Write-Host "Required: $($manifest.RequiredModules -join ', ')"
```

---

### Methods

#### ValidateRequirements()

Validates that all required modules are available.

**Signature:**
```powershell
[bool]ValidateRequirements()
```

**Returns:** `$true` if all requirements met, `$false` otherwise

**Example:**
```powershell
$manifest = [ModuleManifest]::FromFile(".\module.psd1")

if ($manifest.ValidateRequirements()) {
    Write-Log "All module requirements met" -Level Success
    Import-Module $manifest.Name
}
else {
    Write-Log "Missing required modules" -Level Error
    $missing = $manifest.GetMissingModules()
    Write-Log "Install: $($missing -join ', ')" -Level Info
}
```

---

#### GetMissingModules()

Returns list of required modules that are not installed.

**Signature:**
```powershell
[string[]]GetMissingModules()
```

**Returns:** Array of missing module names

**Example:**
```powershell
$manifest = [ModuleManifest]::FromFile(".\module.psd1")
$missing = $manifest.GetMissingModules()

if ($missing.Count -gt 0) {
    Write-Log "Installing missing modules..." -Level Info
    foreach ($module in $missing) {
        Install-Module -Name $module -Force -AllowClobber
    }
}
```

---

### Usage Examples

#### Example 1: Module Dependency Validation

```powershell
function Initialize-ModuleWithDependencies {
    param([string]$ManifestPath)

    ### Load manifest
    $manifest = [ModuleManifest]::FromFile($ManifestPath)

    Write-Log "Loading module: $($manifest.Name) v$($manifest.Version)" -Level Header

    ### Check dependencies
    if (-not $manifest.ValidateRequirements()) {
        $missing = $manifest.GetMissingModules()

        Write-Log "Missing dependencies: $($missing -join ', ')" -Level Warning
        Write-Log "Installing dependencies..." -Level Info

        foreach ($module in $missing) {
            Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
            Write-Log "  Installed: $module" -Level Success
        }
    }

    ### Import module
    Import-Module -Name $manifest.Name
    Write-Log "Module loaded successfully" -Level Success
}

### Usage
Initialize-ModuleWithDependencies -ManifestPath ".\Brennan.PowerShell.Core.psd1"
```

---

#### Example 2: Multi-Module Environment Setup

```powershell
function Initialize-ModuleEnvironment {
    param([string[]]$ManifestPaths)

    $manifests = @()
    $allMissing = @()

    ### Load all manifests
    foreach ($path in $ManifestPaths) {
        $manifest = [ModuleManifest]::FromFile($path)
        $manifests += $manifest

        $missing = $manifest.GetMissingModules()
        $allMissing += $missing
    }

    ### Get unique missing modules
    $uniqueMissing = $allMissing | Select-Object -Unique

    if ($uniqueMissing.Count -gt 0) {
        Write-Log "Installing $($uniqueMissing.Count) missing modules..." -Level Info

        foreach ($module in $uniqueMissing) {
            Install-Module -Name $module -Force -AllowClobber
        }
    }

    ### Import all modules
    foreach ($manifest in $manifests) {
        Import-Module -Name $manifest.Name
        Write-Log "Loaded: $($manifest.Name) v$($manifest.Version)" -Level Success
    }
}

### Usage
Initialize-ModuleEnvironment -ManifestPaths @(
    ".\Brennan.PowerShell.Core.psd1",
    ".\Brennan.PowerShell.Reporting.psd1"
)
```

---

#### Example 3: Module Version Compatibility Check

```powershell
function Test-ModuleCompatibility {
    param(
        [ModuleManifest]$Manifest,
        [hashtable]$MinimumVersions
    )

    $incompatible = @()

    foreach ($requiredModule in $Manifest.RequiredModules) {
        $installed = Get-Module -Name $requiredModule -ListAvailable |
                    Sort-Object Version -Descending |
                    Select-Object -First 1

        if ($installed) {
            if ($MinimumVersions.ContainsKey($requiredModule)) {
                $minVersion = [version]$MinimumVersions[$requiredModule]
                if ($installed.Version -lt $minVersion) {
                    $incompatible += [PSCustomObject]@{
                        Module = $requiredModule
                        Installed = $installed.Version
                        Required = $minVersion
                    }
                }
            }
        }
    }

    if ($incompatible.Count -gt 0) {
        Write-Log "Version compatibility issues found:" -Level Warning
        $incompatible | Format-Table -AutoSize | Out-String | Write-Log -Level Warning
        return $false
    }

    Write-Log "All module versions compatible" -Level Success
    return $true
}

### Usage
$manifest = [ModuleManifest]::FromFile(".\module.psd1")
$minVersions = @{
    "Microsoft.Graph.Authentication" = "2.0.0"
    "Microsoft.Graph.Users" = "2.0.0"
}

Test-ModuleCompatibility -Manifest $manifest -MinimumVersions $minVersions
```

---

#### Example 4: Custom Settings Management

```powershell
### Extend ModuleManifest with custom settings
$manifest = [ModuleManifest]::FromFile(".\module.psd1")

### Add custom application settings
$manifest.Settings["ConnectionString"] = "Server=localhost;Database=MyDB"
$manifest.Settings["LogLevel"] = "Info"
$manifest.Settings["Features"] = @{
    "EnableCaching" = $true
    "CacheExpiration" = 3600
}

### Use settings in application
function Get-ModuleSetting {
    param(
        [ModuleManifest]$Manifest,
        [string]$SettingName
    )

    if ($Manifest.Settings.ContainsKey($SettingName)) {
        return $Manifest.Settings[$SettingName]
    }

    Write-Log "Setting not found: $SettingName" -Level Warning
    return $null
}

$logLevel = Get-ModuleSetting -Manifest $manifest -SettingName "LogLevel"
Write-Log "Configured log level: $logLevel"
```

---

#### Example 5: Module Manifest Comparison

```powershell
function Compare-ModuleManifests {
    param(
        [string]$Path1,
        [string]$Path2
    )

    $manifest1 = [ModuleManifest]::FromFile($Path1)
    $manifest2 = [ModuleManifest]::FromFile($Path2)

    $comparison = [PSCustomObject]@{
        Module1 = $manifest1.Name
        Module2 = $manifest2.Name
        Version1 = $manifest1.Version
        Version2 = $manifest2.Version
        SharedDependencies = @()
        UniqueTo1 = @()
        UniqueTo2 = @()
    }

    ### Find shared and unique dependencies
    foreach ($dep in $manifest1.RequiredModules) {
        if ($manifest2.RequiredModules -contains $dep) {
            $comparison.SharedDependencies += $dep
        }
        else {
            $comparison.UniqueTo1 += $dep
        }
    }

    foreach ($dep in $manifest2.RequiredModules) {
        if ($manifest1.RequiredModules -notcontains $dep) {
            $comparison.UniqueTo2 += $dep
        }
    }

    return $comparison
}

### Usage
$comparison = Compare-ModuleManifests -Path1 ".\Core.psd1" -Path2 ".\Reporting.psd1"

Write-Log "Shared dependencies: $($comparison.SharedDependencies -join ', ')"
Write-Log "Unique to $($comparison.Module1): $($comparison.UniqueTo1 -join ', ')"
Write-Log "Unique to $($comparison.Module2): $($comparison.UniqueTo2 -join ', ')"
```

---

## RetryPolicy Class

**File:** `Classes/RetryPolicy.ps1`

### Description

Defines retry behavior for operations. Implements exponential backoff and configurable error handling strategies.

### Properties

| Property            | Type                  | Description                        | Default |
| ------------------- | --------------------- | ---------------------------------- | ------- |
| `MaxAttempts`       | int                   | Maximum number of retry attempts   | 3       |
| `DelayMilliseconds` | int                   | Initial delay between retries (ms) | 1000    |
| `BackoffMultiplier` | double                | Exponential backoff multiplier     | 2.0     |
| `OnFailure`         | ErrorHandlingStrategy | What to do when all retries fail   | Throw   |

### Constructors

#### Default Constructor

```powershell
RetryPolicy()
```

Creates retry policy with sensible defaults (3 attempts, 1 second delay, 2x backoff).

**Example:**
```powershell
$policy = [RetryPolicy]::new()
### MaxAttempts = 3, DelayMilliseconds = 1000, BackoffMultiplier = 2.0
```

---

#### Parameterized Constructor

```powershell
RetryPolicy([int]$maxAttempts, [int]$delay, [double]$backoff)
```

**Parameters:**
- `maxAttempts` - Maximum retry attempts
- `delay` - Initial delay in milliseconds
- `backoff` - Exponential backoff multiplier

**Example:**
```powershell
$policy = [RetryPolicy]::new(5, 500, 1.5)
### 5 attempts, 500ms initial delay, 1.5x backoff
```

---

### Methods

#### GetDelay()

Calculates delay for a specific retry attempt using exponential backoff.

**Signature:**
```powershell
[int]GetDelay([int]$attemptNumber)
```

**Parameters:**
- `attemptNumber` - Attempt number (1-based)

**Returns:** Delay in milliseconds for that attempt

**Formula:** `delay * (backoff ^ (attempt - 1))`

**Example:**
```powershell
$policy = [RetryPolicy]::new(5, 1000, 2.0)

$policy.GetDelay(1)  ### Returns: 1000 ms (1 second)
$policy.GetDelay(2)  ### Returns: 2000 ms (2 seconds)
$policy.GetDelay(3)  ### Returns: 4000 ms (4 seconds)
$policy.GetDelay(4)  ### Returns: 8000 ms (8 seconds)
$policy.GetDelay(5)  ### Returns: 16000 ms (16 seconds)
```

---

#### Execute()

Executes a scriptblock with retry logic and exponential backoff.

**Signature:**
```powershell
[object]Execute([scriptblock]$action)
```

**Parameters:**
- `action` - Scriptblock to execute with retries

**Returns:** Result of successful execution, or `$null` if all attempts fail (depending on OnFailure strategy)

**Example:**
```powershell
$policy = [RetryPolicy]::new()
$policy.OnFailure = [ErrorHandlingStrategy]::Retry

$result = $policy.Execute({
    Get-MgUser -All
})
```

---

### Usage Examples

#### Example 1: Basic API Call with Retry

```powershell
function Get-UsersWithRetry {
    ### Create retry policy
    $policy = [RetryPolicy]::new()
    $policy.MaxAttempts = 5
    $policy.DelayMilliseconds = 1000
    $policy.OnFailure = [ErrorHandlingStrategy]::Throw

    ### Execute with retries
    $users = $policy.Execute({
        Get-MgUser -All
    })

    return $users
}

### Usage
try {
    $users = Get-UsersWithRetry
    Write-Log "Retrieved $($users.Count) users" -Level Success
}
catch {
    Write-Log "Failed to retrieve users after retries: $($_.Exception.Message)" -Level Error
}
```

---

#### Example 2: Custom Retry Policy for Different Operations

```powershell
function Get-RetryPolicyForOperation {
    param([string]$OperationType)

    $policy = [RetryPolicy]::new()

    switch ($OperationType) {
        "FastAPI" {
            $policy.MaxAttempts = 3
            $policy.DelayMilliseconds = 500
            $policy.BackoffMultiplier = 1.5
        }
        "SlowAPI" {
            $policy.MaxAttempts = 5
            $policy.DelayMilliseconds = 2000
            $policy.BackoffMultiplier = 2.0
        }
        "Database" {
            $policy.MaxAttempts = 10
            $policy.DelayMilliseconds = 100
            $policy.BackoffMultiplier = 1.2
        }
        "FileSystem" {
            $policy.MaxAttempts = 3
            $policy.DelayMilliseconds = 1000
            $policy.BackoffMultiplier = 2.0
        }
        default {
            ### Default policy
            $policy.MaxAttempts = 3
            $policy.DelayMilliseconds = 1000
            $policy.BackoffMultiplier = 2.0
        }
    }

    return $policy
}

### Usage
$policy = Get-RetryPolicyForOperation -OperationType "SlowAPI"
$data = $policy.Execute({ Invoke-RestMethod -Uri "https://api.example.com/slow" })
```

---

#### Example 3: Retry with Custom Error Handling

```powershell
function Invoke-WithCustomRetry {
    param(
        [scriptblock]$Operation,
        [int]$MaxAttempts = 3
    )

    $policy = [RetryPolicy]::new($MaxAttempts, 1000, 2.0)
    $attempt = 0

    while ($attempt -lt $policy.MaxAttempts) {
        $attempt++
        try {
            Write-Log "Attempt $attempt of $($policy.MaxAttempts)..." -Level Verbose

            $result = & $Operation

            Write-Log "Operation succeeded on attempt $attempt" -Level Success
            return $result
        }
        catch {
            $errorMessage = $_.Exception.Message
            Write-Log "Attempt $attempt failed: $errorMessage" -Level Warning

            ### Check if error is retryable
            if ($errorMessage -match "429|503|timeout|temporarily") {
                if ($attempt -lt $policy.MaxAttempts) {
                    $delay = $policy.GetDelay($attempt)
                    Write-Log "Retrying in $delay ms..." -Level Info
                    Start-Sleep -Milliseconds $delay
                }
                else {
                    Write-Log "Max attempts reached, giving up" -Level Error
                    throw
                }
            }
            else {
                ### Non-retryable error, fail immediately
                Write-Log "Non-retryable error, aborting" -Level Error
                throw
            }
        }
    }
}

### Usage
$users = Invoke-WithCustomRetry -Operation {
    Get-MgUser -All
} -MaxAttempts 5
```

---

#### Example 4: Batch Operations with Individual Retry

```powershell
function Invoke-BatchWithRetry {
    param(
        [array]$Items,
        [scriptblock]$Operation,
        [RetryPolicy]$Policy
    )

    $results = @{
        Successful = @()
        Failed = @()
    }

    foreach ($item in $Items) {
        try {
            $result = $Policy.Execute({
                & $Operation -Item $using:item
            })

            $results.Successful += [PSCustomObject]@{
                Item = $item
                Result = $result
            }
        }
        catch {
            $results.Failed += [PSCustomObject]@{
                Item = $item
                Error = $_.Exception.Message
            }
        }
    }

    return $results
}

### Usage
$policy = [RetryPolicy]::new(3, 500, 2.0)
$policy.OnFailure = [ErrorHandlingStrategy]::Warn

$userIds = @("user1@domain.com", "user2@domain.com", "user3@domain.com")

$results = Invoke-BatchWithRetry -Items $userIds -Policy $policy -Operation {
    param($Item)
    Get-MgUser -UserId $Item
}

Write-Log "Successful: $($results.Successful.Count)" -Level Success
Write-Log "Failed: $($results.Failed.Count)" -Level Warning
```

---

#### Example 5: Circuit Breaker Pattern with Retry

```powershell
class CircuitBreaker {
    [int]$FailureThreshold = 5
    [int]$SuccessThreshold = 2
    [int]$TimeoutSeconds = 60
    [int]$FailureCount = 0
    [int]$SuccessCount = 0
    [datetime]$LastFailureTime
    [string]$State = "Closed"  ### Closed, Open, HalfOpen

    [object]Execute([scriptblock]$action, [RetryPolicy]$policy) {
        ### Check circuit state
        if ($this.State -eq "Open") {
            $timeSinceFailure = (Get-Date) - $this.LastFailureTime
            if ($timeSinceFailure.TotalSeconds -lt $this.TimeoutSeconds) {
                throw "Circuit breaker is OPEN, rejecting request"
            }
            else {
                $this.State = "HalfOpen"
                Write-Log "Circuit breaker entering HalfOpen state" -Level Info
            }
        }

        try {
            ### Execute with retry policy
            $result = $policy.Execute($action)

            ### Success
            $this.OnSuccess()
            return $result
        }
        catch {
            ### Failure
            $this.OnFailure()
            throw
        }
    }

    [void]OnSuccess() {
        $this.FailureCount = 0
        $this.SuccessCount++

        if ($this.State -eq "HalfOpen" -and $this.SuccessCount -ge $this.SuccessThreshold) {
            $this.State = "Closed"
            $this.SuccessCount = 0
            Write-Log "Circuit breaker CLOSED" -Level Success
        }
    }

    [void]OnFailure() {
        $this.SuccessCount = 0
        $this.FailureCount++
        $this.LastFailureTime = Get-Date

        if ($this.FailureCount -ge $this.FailureThreshold) {
            $this.State = "Open"
            Write-Log "Circuit breaker OPENED after $($this.FailureCount) failures" -Level Error
        }
    }
}

### Usage
$circuitBreaker = [CircuitBreaker]::new()
$retryPolicy = [RetryPolicy]::new(3, 1000, 2.0)

try {
    $result = $circuitBreaker.Execute({
        Invoke-RestMethod -Uri "https://api.example.com/data"
    }, $retryPolicy)
}
catch {
    Write-Log "Operation failed: $($_.Exception.Message)" -Level Error
}
```

---

## Best Practices

### General Class Usage

1. **Use classes for stateful operations**
   - Graph connections that track authentication
   - Log entries with metadata
   - Certificate validation with caching

2. **Prefer composition over inheritance**
   ```powershell
   ### Good - Compose classes
   class Application {
       [GraphAPIConnection]$Connection
       [RetryPolicy]$RetryPolicy
       [LogEntry[]]$LogHistory
   }

   ### Less flexible - Inheritance
   class Application : GraphAPIConnection {
   }
   ```

3. **Initialize objects properly**
   ```powershell
   ### Always use constructors
   $connection = [GraphAPIConnection]::new($tenant, $client, $authType)

   ### Not recommended - manual property assignment
   $connection = [GraphAPIConnection]::new()
   $connection.TenantId = $tenant
   ```

4. **Type your parameters and variables**
   ```powershell
   function Connect-Graph {
       param([GraphAPIConnection]$Connection)
       ### Strong typing provides validation and IntelliSense
   }
   ```

5. **Handle null gracefully**
   ```powershell
   ### Check for null before using
   if ($null -ne $connection -and $connection.IsValid()) {
       ### Safe to use
   }
   ```

### Performance Considerations

1. **Reuse class instances**
   ```powershell
   ### Good - Reuse connection
   $connection = [GraphAPIConnection]::new(...)
   foreach ($operation in $operations) {
       Invoke-GraphOperation -Connection $connection -Operation $operation
   }

   ### Bad - Create new connection each time
   foreach ($operation in $operations) {
       $connection = [GraphAPIConnection]::new(...)
   }
   ```

2. **Cache validation results**
   ```powershell
   ### Cache certificate validation
   $script:CertCache = @{}

   function Get-ValidatedCertificate {
       param([string]$Thumbprint)

       if (-not $script:CertCache.ContainsKey($Thumbprint)) {
           $cert = Get-ChildItem Cert:\CurrentUser\My |
                  Where-Object { $_.Thumbprint -eq $Thumbprint }
           $script:CertCache[$Thumbprint] = [CertificateInfo]::new($cert)
       }

       return $script:CertCache[$Thumbprint]
   }
   ```

### Error Handling

1. **Validate in constructors**
   ```powershell
   class CustomClass {
       [string]$Value

       CustomClass([string]$value) {
           if ([string]::IsNullOrWhiteSpace($value)) {
               throw "Value cannot be null or empty"
           }
           $this.Value = $value
       }
   }
   ```

2. **Return meaningful error messages**
   ```powershell
   if (-not $connection.IsValid()) {
       throw "Connection invalid: Status=$($connection.Status), ExpiresAt=$($connection.ExpiresAt)"
   }
   ```

3. **Use appropriate error handling strategies**
   ```powershell
   ### Critical operations - Throw
   $policy = [RetryPolicy]::new()
   $policy.OnFailure = [ErrorHandlingStrategy]::Throw

   ### Optional operations - Warn
   $policy.OnFailure = [ErrorHandlingStrategy]::Warn
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
- [Enumerations Reference](./ENUMS.md)
- [Module README](../README.md)

---

*Copyright © 2025 Brennan Technologies, LLC. All rights reserved.*
