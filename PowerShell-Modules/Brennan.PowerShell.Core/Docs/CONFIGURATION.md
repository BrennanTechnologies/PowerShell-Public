
![Brennan Technologies Logo](../Resources/images/BrennanLogo_BizCard_White.png)

# Configuration Guide

## Table of Contents

- [Configuration Guide](#configuration-guide)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Configuration Files](#configuration-files)
    - [default-settings.json](#default-settingsjson)
    - [settings-template.json](#settings-templatejson)
    - [app-registration.json](#app-registrationjson)
    - [error-codes.json](#error-codesjson)
    - [log-formats.json](#log-formatsjson)
  - [Schema Validation](#schema-validation)
    - [settings-schema.json](#settings-schemajson)
    - [app-registration-schema.json](#app-registration-schemajson)
  - [Environment Configuration](#environment-configuration)
    - [Development Environment](#development-environment)
    - [Testing Environment](#testing-environment)
    - [Production Environment](#production-environment)
  - [Settings Hierarchy and Override Behavior](#settings-hierarchy-and-override-behavior)
    - [Override Example](#override-example)
    - [Loading Configuration](#loading-configuration)
  - [Security Best Practices](#security-best-practices)
    - [1. Protect Sensitive Configuration Files](#1-protect-sensitive-configuration-files)
    - [2. Never Store Secrets in Configuration Files](#2-never-store-secrets-in-configuration-files)
    - [3. Use Environment Variables for Secrets](#3-use-environment-variables-for-secrets)
    - [4. Encrypt Configuration Files](#4-encrypt-configuration-files)
    - [5. Certificate-Based Authentication](#5-certificate-based-authentication)
    - [6. Version Control Exclusions](#6-version-control-exclusions)
    - [7. Audit Configuration Changes](#7-audit-configuration-changes)
  - [Troubleshooting](#troubleshooting)
    - [Configuration File Not Found](#configuration-file-not-found)
    - [Invalid JSON Syntax](#invalid-json-syntax)
    - [Schema Validation Failures](#schema-validation-failures)
    - [Certificate Thumbprint Format](#certificate-thumbprint-format)
    - [Module Loading Issues](#module-loading-issues)
    - [Environment-Specific Loading](#environment-specific-loading)
    - [Log Path Permissions](#log-path-permissions)
  - [About](#about)
    - [Related Documentation](#related-documentation)

---

## Overview

The Brennan.PowerShell.Core module uses a comprehensive JSON-based configuration system that provides flexibility, validation, and environment-specific settings. Configuration files are located in the `Config/` directory and support schema validation for data integrity.

**Key Features:**
- JSON Schema validation for all configuration files
- Environment-specific configuration support (Dev/Test/Prod)
- Hierarchical settings with override capabilities
- Secure credential management
- Standardized error codes and logging formats

---

## Configuration Files

### default-settings.json

The default settings file contains module-wide defaults that are used when no custom configuration is provided.

**Location:** `Config/default-settings.json`

**Structure:**

```json
{
  "$schema": "./schemas/settings-schema.json",
  "module": {
    "name": "Brennan.PowerShell.Core",
    "version": "1.0.0",
    "author": "Chris Brennan",
    "email": "chris@brennantechnologies.com",
    "company": "Brennan Technologies, LLC"
  },
  "logging": {
    "enabled": true,
    "logPath": "./Logs",
    "logMode": "Session",
    "defaultLevel": "Info",
    "includeTimestamp": true,
    "includeCallerInfo": true,
    "maxLogFileSizeMB": 10,
    "maxLogFileCount": 5
  },
  "graphAPI": {
    "defaultAuthType": "Certificate",
    "defaultScopes": ["User.Read.All", "Group.Read.All"],
    "connectionTimeout": 30,
    "retryAttempts": 3,
    "retryDelayMs": 1000
  },
  "certificates": {
    "validationLevel": "Standard",
    "expirationWarningDays": 30,
    "storeName": "My",
    "storeLocation": "CurrentUser"
  },
  "modules": {
    "autoInstall": true,
    "importBehavior": "SkipIfPresent",
    "requiredModules": [
      "Microsoft.Graph.Authentication",
      "Microsoft.Graph.Users"
    ]
  }
}
```

**Properties:**

| Section          | Property              | Type    | Default                             | Description                                      |
| ---------------- | --------------------- | ------- | ----------------------------------- | ------------------------------------------------ |
| **module**       | name                  | string  | "Brennan.PowerShell.Core"           | Module name                                      |
|                  | version               | string  | "1.0.0"                             | Module version                                   |
|                  | author                | string  | "Chris Brennan"                     | Author name                                      |
|                  | email                 | string  | "chris@brennantechnologies.com"     | Contact email                                    |
|                  | company               | string  | "Brennan Technologies, LLC"         | Company name                                     |
| **logging**      | enabled               | boolean | true                                | Enable/disable logging                           |
|                  | logPath               | string  | "./Logs"                            | Directory for log files                          |
|                  | logMode               | enum    | "Session"                           | Logging mode (Continuous, Daily, Session)        |
|                  | defaultLevel          | enum    | "Info"                              | Default log level                                |
|                  | includeTimestamp      | boolean | true                                | Include timestamps in logs                       |
|                  | includeCallerInfo     | boolean | true                                | Include caller function info                     |
|                  | maxLogFileSizeMB      | integer | 10                                  | Maximum log file size (1-100 MB)                 |
|                  | maxLogFileCount       | integer | 5                                   | Maximum number of log files (1-50)               |
| **graphAPI**     | tenantId              | string  | ""                                  | Azure AD Tenant ID (GUID)                        |
|                  | clientId              | string  | ""                                  | Application Client ID (GUID)                     |
|                  | certificateThumbprint | string  | ""                                  | Certificate thumbprint (40-char hex)             |
|                  | defaultAuthType       | enum    | "Certificate"                       | Authentication type                              |
|                  | defaultScopes         | array   | ["User.Read.All", "Group.Read.All"] | Default Graph API scopes                         |
|                  | connectionTimeout     | integer | 30                                  | Connection timeout (5-300 seconds)               |
|                  | retryAttempts         | integer | 3                                   | Number of retry attempts (0-10)                  |
|                  | retryDelayMs          | integer | 1000                                | Retry delay in milliseconds (100-10000)          |
| **certificates** | validationLevel       | enum    | "Standard"                          | Validation level (None, Basic, Standard, Strict) |
|                  | expirationWarningDays | integer | 30                                  | Days before expiration to warn (1-365)           |
|                  | storeName             | enum    | "My"                                | Certificate store name                           |
|                  | storeLocation         | enum    | "CurrentUser"                       | Certificate store location                       |
| **modules**      | autoInstall           | boolean | true                                | Auto-install missing modules                     |
|                  | importBehavior        | enum    | "SkipIfPresent"                     | Module import behavior                           |
|                  | requiredModules       | array   | [...]                               | List of required modules                         |

---

### settings-template.json

A minimal template for creating custom environment-specific settings files. Copy this file and customize for your environment.

**Location:** `Config/settings-template.json`

**Structure:**

```json
{
  "$schema": "./schemas/settings-schema.json",
  "logging": {
    "logPath": "C:\\Logs\\PowerShell",
    "logMode": "Daily"
  },
  "graphAPI": {
    "tenantId": "YOUR-TENANT-ID-HERE",
    "clientId": "YOUR-CLIENT-ID-HERE",
    "certificateThumbprint": "YOUR-CERT-THUMBPRINT-HERE"
  }
}
```

**Usage Example:**

1. Copy `settings-template.json` to `settings-production.json`
2. Update with your production credentials
3. Load in your script:

```powershell
$settings = Get-Content ".\Config\settings-production.json" | ConvertFrom-Json
```

---

### app-registration.json

Manages multiple Azure AD app registrations for different environments or purposes.

**Location:** `Config/app-registration.json`

**Structure:**

```json
{
  "$schema": "./schemas/app-registration-schema.json",
  "applications": [
    {
      "name": "Production",
      "tenantId": "",
      "clientId": "",
      "certificateThumbprint": "",
      "permissions": [
        "User.Read.All",
        "Group.Read.All",
        "Directory.Read.All"
      ]
    },
    {
      "name": "Development",
      "tenantId": "",
      "clientId": "",
      "certificateThumbprint": "",
      "permissions": ["User.Read.All"]
    }
  ],
  "defaultApplication": "Production"
}
```

**Properties:**

| Property                             | Type   | Required | Description                          |
| ------------------------------------ | ------ | -------- | ------------------------------------ |
| applications                         | array  | Yes      | Array of application configurations  |
| applications[].name                  | string | Yes      | Friendly name for the application    |
| applications[].tenantId              | string | No       | Azure AD Tenant ID (GUID format)     |
| applications[].clientId              | string | No       | Application Client ID (GUID format)  |
| applications[].certificateThumbprint | string | No       | Certificate thumbprint (40-char hex) |
| applications[].permissions           | array  | No       | Required Microsoft Graph permissions |
| defaultApplication                   | string | No       | Name of default application to use   |

**Usage Example:**

```powershell
### Load app registrations
$appConfig = Get-Content ".\Config\app-registration.json" | ConvertFrom-Json

### Get production app
$prodApp = $appConfig.applications | Where-Object { $_.name -eq "Production" }

### Connect using production credentials
Connect-MgGraph -TenantId $prodApp.tenantId `
                -ClientId $prodApp.clientId `
                -CertificateThumbprint $prodApp.certificateThumbprint
```

---

### error-codes.json

Standardized error codes for consistent error handling and troubleshooting.

**Location:** `Config/error-codes.json`

**Structure:**

```json
{
  "errors": {
    "AUTH_001": {
      "code": "AUTH_001",
      "message": "Certificate not found in certificate store",
      "severity": "Error",
      "remedy": "Ensure certificate is installed in CurrentUser\\My store"
    },
    "AUTH_002": {
      "code": "AUTH_002",
      "message": "Certificate has expired",
      "severity": "Error",
      "remedy": "Renew certificate and update configuration"
    },
    "GRAPH_001": {
      "code": "GRAPH_001",
      "message": "Failed to connect to Microsoft Graph",
      "severity": "Error",
      "remedy": "Check network connectivity and credentials"
    }
  }
}
```

**Error Categories:**

| Prefix     | Category          | Description                              |
| ---------- | ----------------- | ---------------------------------------- |
| AUTH_xxx   | Authentication    | Certificate and authentication errors    |
| GRAPH_xxx  | Graph API         | Microsoft Graph connection errors        |
| MODULE_xxx | Module Management | Module loading and versioning errors     |
| CONFIG_xxx | Configuration     | Configuration file and validation errors |

**Error Codes Reference:**

| Code       | Message                                          | Severity | Remedy                                                  |
| ---------- | ------------------------------------------------ | -------- | ------------------------------------------------------- |
| AUTH_001   | Certificate not found in certificate store       | Error    | Ensure certificate is installed in CurrentUser\My store |
| AUTH_002   | Certificate has expired                          | Error    | Renew certificate and update configuration              |
| AUTH_003   | Invalid certificate thumbprint format            | Error    | Provide a valid 40-character hexadecimal thumbprint     |
| GRAPH_001  | Failed to connect to Microsoft Graph             | Error    | Check network connectivity and credentials              |
| GRAPH_002  | Insufficient permissions for requested operation | Error    | Ensure app has required Graph API permissions           |
| GRAPH_003  | Connection token has expired                     | Warning  | Reconnect to Microsoft Graph                            |
| MODULE_001 | Required module not found                        | Warning  | Install missing module using Install-Module             |
| MODULE_002 | Module version mismatch                          | Warning  | Update module to required version                       |
| CONFIG_001 | Configuration file not found                     | Warning  | Create configuration file from template                 |
| CONFIG_002 | Invalid configuration format                     | Error    | Validate JSON syntax and schema compliance              |

**Usage Example:**

```powershell
### Load error codes
$errorCodes = Get-Content ".\Config\error-codes.json" | ConvertFrom-Json

### Throw standardized error
$error = $errorCodes.errors.AUTH_001
throw "[$($error.code)] $($error.message). $($error.remedy)"
```

---

### log-formats.json

Defines logging format templates for console and file output.

**Location:** `Config/log-formats.json`

**Structure:**

```json
{
  "formats": {
    "simple": "[{timestamp}] [{level}] {message}",
    "detailed": "[{timestamp}] [{level}] [{caller}] {message}",
    "json": {
      "timestamp": "{timestamp}",
      "level": "{level}",
      "message": "{message}",
      "caller": "{caller}",
      "metadata": "{metadata}"
    },
    "console": {
      "colors": {
        "Verbose": "Gray",
        "Info": "White",
        "Warning": "Yellow",
        "Error": "Red",
        "Success": "Green",
        "Header": "Cyan",
        "SubItem": "DarkGray",
        "Debug": "Magenta"
      },
      "symbols": {
        "Success": "✓",
        "Error": "✗",
        "Warning": "⚠",
        "Info": "ℹ",
        "Debug": "🔍"
      }
    }
  },
  "timestampFormat": "yyyy-MM-dd HH:mm:ss",
  "fileEncoding": "UTF8"
}
```

**Format Templates:**

| Format   | Template                                       | Use Case                               |
| -------- | ---------------------------------------------- | -------------------------------------- |
| simple   | `[{timestamp}] [{level}] {message}`            | Basic logging                          |
| detailed | `[{timestamp}] [{level}] [{caller}] {message}` | Debug and troubleshooting              |
| json     | Structured JSON object                         | Machine-readable logs, log aggregation |

**Console Colors:**

| Log Level | Color    | Symbol |
| --------- | -------- | ------ |
| Verbose   | Gray     | -      |
| Info      | White    | ℹ      |
| Warning   | Yellow   | ⚠      |
| Error     | Red      | ✗      |
| Success   | Green    | ✓      |
| Header    | Cyan     | -      |
| SubItem   | DarkGray | -      |
| Debug     | Magenta  | 🔍      |

**Usage Example:**

```powershell
### Load log formats
$logFormats = Get-Content ".\Config\log-formats.json" | ConvertFrom-Json

### Use simple format
$timestamp = Get-Date -Format $logFormats.timestampFormat
$logEntry = $logFormats.formats.simple -replace '{timestamp}', $timestamp `
                                       -replace '{level}', 'Info' `
                                       -replace '{message}', 'Test message'

Write-Host $logEntry
```

---

## Schema Validation

### settings-schema.json

JSON Schema for validating settings files. Ensures configuration files conform to expected structure.

**Location:** `Config/schemas/settings-schema.json`

**Key Validation Rules:**

| Property                           | Validation                                                                                     |
| ---------------------------------- | ---------------------------------------------------------------------------------------------- |
| logging.logMode                    | Must be one of: "Continuous", "Daily", "Session"                                               |
| logging.defaultLevel               | Must be one of: "Verbose", "Info", "Warning", "Error", "Success", "Header", "SubItem", "Debug" |
| logging.maxLogFileSizeMB           | Integer between 1 and 100                                                                      |
| logging.maxLogFileCount            | Integer between 1 and 50                                                                       |
| graphAPI.tenantId                  | GUID format: `^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`                  |
| graphAPI.clientId                  | GUID format: `^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`                  |
| graphAPI.certificateThumbprint     | 40-character hex: `^[0-9A-F]{40}$`                                                             |
| graphAPI.defaultAuthType           | Must be one of: "Interactive", "Certificate", "ClientSecret", "ManagedIdentity", "DeviceCode"  |
| graphAPI.connectionTimeout         | Integer between 5 and 300 seconds                                                              |
| graphAPI.retryAttempts             | Integer between 0 and 10                                                                       |
| graphAPI.retryDelayMs              | Integer between 100 and 10000 milliseconds                                                     |
| certificates.validationLevel       | Must be one of: "None", "Basic", "Standard", "Strict"                                          |
| certificates.expirationWarningDays | Integer between 1 and 365                                                                      |
| certificates.storeName             | Must be one of: "My", "Root", "CA", "Trust"                                                    |
| certificates.storeLocation         | Must be one of: "CurrentUser", "LocalMachine"                                                  |
| modules.importBehavior             | Must be one of: "SkipIfPresent", "ForceReload", "AutoInstall"                                  |

**Validation Example:**

```powershell
### Validate settings file against schema
$settings = Get-Content ".\Config\custom-settings.json" -Raw
$schema = Get-Content ".\Config\schemas\settings-schema.json" -Raw

### Using Test-Json (PowerShell 6+)
if (Test-Json -Json $settings -Schema $schema) {
    Write-Host "Configuration is valid" -ForegroundColor Green
} else {
    Write-Host "Configuration validation failed" -ForegroundColor Red
}
```

---

### app-registration-schema.json

JSON Schema for validating app registration configuration files.

**Location:** `Config/schemas/app-registration-schema.json`

**Key Validation Rules:**

| Property                             | Validation                                         |
| ------------------------------------ | -------------------------------------------------- |
| applications                         | Required array with minimum 1 item                 |
| applications[].name                  | Required string                                    |
| applications[].tenantId              | Optional GUID format                               |
| applications[].clientId              | Optional GUID format                               |
| applications[].certificateThumbprint | Optional 40-character hex string                   |
| applications[].permissions           | Optional array of strings                          |
| defaultApplication                   | Optional string (should match an application name) |

---

## Environment Configuration

### Development Environment

**File:** `settings-development.json`

```json
{
  "$schema": "./schemas/settings-schema.json",
  "logging": {
    "enabled": true,
    "logPath": "C:\\Dev\\Logs",
    "logMode": "Session",
    "defaultLevel": "Debug",
    "includeCallerInfo": true
  },
  "graphAPI": {
    "tenantId": "12345678-1234-1234-1234-123456789abc",
    "clientId": "abcdef12-abcd-abcd-abcd-abcdef123456",
    "certificateThumbprint": "1234567890ABCDEF1234567890ABCDEF12345678",
    "defaultScopes": ["User.Read.All"],
    "connectionTimeout": 60
  },
  "modules": {
    "autoInstall": true,
    "importBehavior": "ForceReload"
  }
}
```

**Characteristics:**
- Debug logging enabled
- Session-based log files
- Extended connection timeout
- Force reload modules for testing
- Minimal Graph API permissions

---

### Testing Environment

**File:** `settings-test.json`

```json
{
  "$schema": "./schemas/settings-schema.json",
  "logging": {
    "enabled": true,
    "logPath": "C:\\Test\\Logs",
    "logMode": "Daily",
    "defaultLevel": "Info"
  },
  "graphAPI": {
    "tenantId": "23456789-2345-2345-2345-23456789abcd",
    "clientId": "bcdef123-bcde-bcde-bcde-bcdef1234567",
    "certificateThumbprint": "234567890ABCDEF1234567890ABCDEF123456789",
    "defaultScopes": ["User.Read.All", "Group.Read.All"]
  },
  "certificates": {
    "validationLevel": "Standard"
  }
}
```

**Characteristics:**
- Daily log rotation
- Info-level logging
- Standard certificate validation
- Testing-specific credentials
- Broader permissions for integration testing

---

### Production Environment

**File:** `settings-production.json`

```json
{
  "$schema": "./schemas/settings-schema.json",
  "logging": {
    "enabled": true,
    "logPath": "D:\\Production\\Logs\\PowerShell",
    "logMode": "Daily",
    "defaultLevel": "Warning",
    "maxLogFileSizeMB": 50,
    "maxLogFileCount": 30
  },
  "graphAPI": {
    "tenantId": "34567890-3456-3456-3456-34567890abcd",
    "clientId": "cdef1234-cdef-cdef-cdef-cdef12345678",
    "certificateThumbprint": "34567890ABCDEF1234567890ABCDEF1234567890",
    "defaultAuthType": "Certificate",
    "retryAttempts": 5,
    "retryDelayMs": 2000
  },
  "certificates": {
    "validationLevel": "Strict",
    "expirationWarningDays": 60
  },
  "modules": {
    "autoInstall": false,
    "importBehavior": "SkipIfPresent"
  }
}
```

**Characteristics:**
- Warning-level logging (reduce noise)
- Daily log rotation with 30-day retention
- Larger log files (50 MB)
- Strict certificate validation
- More aggressive retry policy
- Manual module management
- Extended expiration warnings (60 days)

---

## Settings Hierarchy and Override Behavior

The module uses a hierarchical configuration system with the following precedence (highest to lowest):

1. **Runtime Parameters** - Values passed directly to functions
2. **Environment-Specific Settings** - `settings-{environment}.json`
3. **User Settings** - `settings.json` (if present)
4. **Default Settings** - `default-settings.json`

### Override Example

```powershell
### default-settings.json
{
  "logging": {
    "logMode": "Session",
    "defaultLevel": "Info"
  }
}

### settings-production.json
{
  "logging": {
    "logMode": "Daily"
  }
}

### Runtime
Write-Log -Message "Test" -Level Warning

### Effective Configuration:
### - logMode: "Daily" (from production settings)
### - defaultLevel: "Info" (from default settings)
### - Level: "Warning" (from runtime parameter)
```

### Loading Configuration

```powershell
function Get-ModuleSettings {
    param(
        [string]$Environment = "Production"
    )

    ### Start with defaults
    $settings = Get-Content ".\Config\default-settings.json" | ConvertFrom-Json

    ### Check for environment-specific settings
    $envFile = ".\Config\settings-$Environment.json"
    if (Test-Path $envFile) {
        $envSettings = Get-Content $envFile | ConvertFrom-Json

        ### Merge settings (simplified)
        foreach ($property in $envSettings.PSObject.Properties) {
            $settings.($property.Name) = $property.Value
        }
    }

    return $settings
}

### Usage
$settings = Get-ModuleSettings -Environment "Production"
```

---

## Security Best Practices

### 1. Protect Sensitive Configuration Files

```powershell
### Set restrictive ACLs on production settings
$acl = Get-Acl ".\Config\settings-production.json"
$acl.SetAccessRuleProtection($true, $false)
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) }

### Add only necessary permissions
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "DOMAIN\ServiceAccount", "Read", "Allow"
)
$acl.AddAccessRule($rule)
Set-Acl ".\Config\settings-production.json" $acl
```

### 2. Never Store Secrets in Configuration Files

**❌ NEVER DO THIS:**

```json
{
  "graphAPI": {
    "clientSecret": "MySecretPassword123!"
  }
}
```

**✓ DO THIS INSTEAD:**

```powershell
### Use Azure Key Vault
$secret = Get-AzKeyVaultSecret -VaultName "MyVault" -Name "GraphClientSecret"

### Or use Windows Credential Manager
$cred = Get-StoredCredential -Target "GraphAPI"
```

### 3. Use Environment Variables for Secrets

```powershell
### Set environment variable (one-time setup)
[Environment]::SetEnvironmentVariable(
    "GRAPH_TENANT_ID",
    "12345678-1234-1234-1234-123456789abc",
    "User"
)

### Reference in code
$tenantId = $env:GRAPH_TENANT_ID
```

### 4. Encrypt Configuration Files

```powershell
### Encrypt sensitive configuration
$settings = Get-Content ".\Config\settings-production.json"
$encrypted = $settings | ConvertTo-SecureString -AsPlainText -Force |
             ConvertFrom-SecureString
Set-Content ".\Config\settings-production.encrypted" $encrypted

### Decrypt when needed
$encrypted = Get-Content ".\Config\settings-production.encrypted"
$settings = $encrypted | ConvertTo-SecureString |
            ConvertFrom-SecureString -AsPlainText
```

### 5. Certificate-Based Authentication

Always prefer certificate-based authentication over client secrets:

```json
{
  "graphAPI": {
    "defaultAuthType": "Certificate",
    "certificateThumbprint": "1234567890ABCDEF1234567890ABCDEF12345678"
  }
}
```

### 6. Version Control Exclusions

Add to `.gitignore`:

```
# Exclude sensitive configuration files
Config/settings-*.json
!Config/settings-template.json
Config/app-registration.json
*.encrypted
```

### 7. Audit Configuration Changes

```powershell
### Enable file system auditing on config directory
$acl = Get-Acl ".\Config"
$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule(
    "Everyone",
    "Write,Delete,ChangePermissions",
    "Success,Failure"
)
$acl.AddAuditRule($auditRule)
Set-Acl ".\Config" $acl
```

---

## Troubleshooting

### Configuration File Not Found

**Error:** `CONFIG_001 - Configuration file not found`

**Solution:**

```powershell
### Copy template to create new settings file
Copy-Item ".\Config\settings-template.json" ".\Config\settings-production.json"

### Edit with your values
notepad ".\Config\settings-production.json"
```

---

### Invalid JSON Syntax

**Error:** `CONFIG_002 - Invalid configuration format`

**Solution:**

```powershell
### Validate JSON syntax
$json = Get-Content ".\Config\settings-production.json" -Raw
try {
    $json | ConvertFrom-Json | Out-Null
    Write-Host "JSON is valid" -ForegroundColor Green
}
catch {
    Write-Host "JSON Error: $($_.Exception.Message)" -ForegroundColor Red
}

### Use an online JSON validator
### https://jsonlint.com/
```

---

### Schema Validation Failures

**Error:** Configuration doesn't match schema

**Solution:**

```powershell
### PowerShell 6+ has built-in JSON schema validation
$settings = Get-Content ".\Config\settings-production.json" -Raw
$schema = Get-Content ".\Config\schemas\settings-schema.json" -Raw

if (-not (Test-Json -Json $settings -Schema $schema)) {
    Write-Host "Schema validation failed" -ForegroundColor Red

    ### Check common issues:
    ### 1. GUID format (lowercase, with hyphens)
    ### 2. Certificate thumbprint (uppercase, 40 chars)
    ### 3. Enum values (exact case match)
    ### 4. Integer ranges
}
```

---

### Certificate Thumbprint Format

**Error:** `AUTH_003 - Invalid certificate thumbprint format`

**Solution:**

```powershell
### Get correctly formatted thumbprint
$cert = Get-ChildItem Cert:\CurrentUser\My |
        Where-Object { $_.Subject -like "*YourCert*" } |
        Select-Object -First 1

### Thumbprint is automatically uppercase and 40 characters
$thumbprint = $cert.Thumbprint
Write-Host "Thumbprint: $thumbprint"

### Update configuration
$settings = Get-Content ".\Config\settings-production.json" | ConvertFrom-Json
$settings.graphAPI.certificateThumbprint = $thumbprint
$settings | ConvertTo-Json -Depth 10 | Set-Content ".\Config\settings-production.json"
```

---

### Module Loading Issues

**Error:** `MODULE_001 - Required module not found`

**Solution:**

```powershell
### Check required modules from configuration
$settings = Get-Content ".\Config\default-settings.json" | ConvertFrom-Json
$required = $settings.modules.requiredModules

foreach ($module in $required) {
    if (-not (Get-Module -Name $module -ListAvailable)) {
        Write-Host "Installing $module..." -ForegroundColor Yellow
        Install-Module -Name $module -Force -AllowClobber
    }
}
```

---

### Environment-Specific Loading

**Problem:** Wrong configuration being loaded

**Solution:**

```powershell
### Create environment-aware loader
function Get-EnvironmentSettings {
    param(
        [ValidateSet('Development', 'Test', 'Production')]
        [string]$Environment
    )

    ### Auto-detect if not specified
    if (-not $Environment) {
        $Environment = if ($env:COMPUTERNAME -like '*-PROD-*') {
            'Production'
        } elseif ($env:COMPUTERNAME -like '*-TEST-*') {
            'Test'
        } else {
            'Development'
        }
    }

    $settingsFile = ".\Config\settings-$Environment.json"
    if (Test-Path $settingsFile) {
        Get-Content $settingsFile | ConvertFrom-Json
    } else {
        Write-Warning "Settings file not found: $settingsFile"
        Get-Content ".\Config\default-settings.json" | ConvertFrom-Json
    }
}

### Usage
$settings = Get-EnvironmentSettings -Environment Production
```

---

### Log Path Permissions

**Problem:** Cannot write to log path

**Solution:**

```powershell
### Verify and create log directory
$logPath = "C:\Logs\PowerShell"
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force
}

### Check write permissions
$testFile = Join-Path $logPath "test.txt"
try {
    "test" | Out-File $testFile
    Remove-Item $testFile
    Write-Host "Log path is writable" -ForegroundColor Green
}
catch {
    Write-Host "Cannot write to log path: $($_.Exception.Message)" -ForegroundColor Red
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

- [Enumerations Reference](./ENUMS.md)
- [Classes Reference](./CLASSES.md)
- [Module README](../README.md)

---

*Copyright © 2025 Brennan Technologies, LLC. All rights reserved.*
