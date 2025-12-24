
![Brennan Technologies Logo](../Resources/images/BrennanLogo_BizCard_White.png)

# Brennan.PowerShell.Core - Examples and Scenarios

This document provides comprehensive real-world examples for using the Brennan.PowerShell.Core module.

---

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Authentication Examples](#authentication-examples)
- [Logging Examples](#logging-examples)
- [Module Management Examples](#module-management-examples)
- [Advanced Scenarios](#advanced-scenarios)
- [Azure Integration](#azure-integration)
- [Production Patterns](#production-patterns)
- [Troubleshooting Examples](#troubleshooting-examples)

---

## Quick Start

### Example 1: First Connection

```powershell
### Import the module
Import-Module .\Brennan.PowerShell.Core.psd1

### Configure settings (first time only)
Copy-Item .\Config\settings-template.json .\settings.json
### Edit settings.json with your Azure AD values

### Connect to Microsoft Graph
Connect-MgGraphAPI -SettingsPath ".\settings.json" -Verbose

### Verify connection
Get-MgGraphAPIPermissions

### Disconnect
Disconnect-MgGraphAPI
```

**Output:**
```
VERBOSE: Reading settings from: .\settings.json
VERBOSE: Connecting to Microsoft Graph API...
✓ Successfully connected to Microsoft Graph
Permissions: User.Read.All, Group.Read.All
✓ Disconnected from Microsoft Graph
```

---

## Authentication Examples

### Example 2: Certificate-Based Authentication with Error Handling

```powershell
### Set up logging
$script:LogMode = 'Daily'

### Connection with comprehensive error handling
function Connect-WithRetry {
    param([int]$MaxAttempts = 3)

    $attempt = 0
    while ($attempt -lt $MaxAttempts) {
        $attempt++

        try {
            Write-Log "Connection attempt $attempt of $MaxAttempts" -Level Info
            Connect-MgGraphAPI -SettingsPath ".\settings.json" -Verbose
            Write-Log "Successfully connected to Microsoft Graph" -Level Success
            return $true
        }
        catch {
            Write-Log "Connection failed: $($_.Exception.Message)" -Level Error

            if ($attempt -lt $MaxAttempts) {
                $delay = $attempt * 5
                Write-Log "Waiting $delay seconds before retry..." -Level Warning
                Start-Sleep -Seconds $delay
            }
        }
    }

    Write-Log "All connection attempts failed" -Level Error
    return $false
}

### Execute connection with retry
if (Connect-WithRetry -MaxAttempts 3) {
    ### Your code here
    Get-MgGraphAPIPermissions
    Disconnect-MgGraphAPI
}
```

### Example 3: Multi-Environment Configuration

```powershell
### Select environment
$Environment = "Production"  ### Or "Development" or "Test"

### Load environment-specific settings
$settingsPath = ".\Config\settings-$Environment.json"

if (-not (Test-Path $settingsPath)) {
    throw "Settings file not found for environment: $Environment"
}

Write-Log "Connecting to $Environment environment..." -Level Info
Connect-MgGraphAPI -SettingsPath $settingsPath -Verbose

### Verify correct tenant
$context = Get-MgContext
Write-Log "Connected to tenant: $($context.TenantId)" -Level Info
```

### Example 4: Connection State Management with Classes

```powershell
### Create connection object
$connection = [GraphAPIConnection]::new(
    "your-tenant-id",
    "your-client-id",
    [AuthenticationType]::Certificate
)

### Connect and track status
try {
    Connect-MgGraphAPI -SettingsPath ".\settings.json"

    $connection.UpdateStatus([ConnectionStatus]::Connected)
    $connection.ExpiresAt = (Get-Date).AddHours(1)
    $connection.AddScopes(@("User.Read.All", "Group.Read.All"))

    ### Check connection validity
    if ($connection.IsValid()) {
        Write-Log "Connection is active and valid" -Level Success

        ### Your operations here
        Get-MgGraphAPIPermissions
    }
}
catch {
    $connection.UpdateStatus([ConnectionStatus]::Failed)
    Write-Log "Connection failed" -Level Error
}
finally {
    Disconnect-MgGraphAPI
    $connection.UpdateStatus([ConnectionStatus]::Disconnected)
}
```

---

## Logging Examples

### Example 5: Daily Logging for Scheduled Tasks

```powershell
### Configure for daily logging (creates new file each day)
$script:LogMode = 'Daily'

### Log file will be: Logs\ScriptName_yyyyMMdd_Log.log
Write-Log "Scheduled task started" -Level Header

Write-Log "Processing users..." -Level Info
$users = 1..100
foreach ($user in $users) {
    if ($user % 10 -eq 0) {
        Write-Log "Processed $user users..." -Level SubItem
    }
}

Write-Log "Task completed successfully" -Level Success
```

**Log File:** `Logs\MyScript_20251214_Log.log`
```
[2025-12-14 10:30:15] [HEADER] ========================================
[2025-12-14 10:30:15] [HEADER] Scheduled task started
[2025-12-14 10:30:15] [HEADER] ========================================
[2025-12-14 10:30:15] [INFO] Processing users...
[2025-12-14 10:30:16] [SUBITEM]   Processed 10 users...
[2025-12-14 10:30:17] [SUBITEM]   Processed 20 users...
[2025-12-14 10:30:20] [SUCCESS] ✓ Task completed successfully
```

### Example 6: Session Logging for Interactive Sessions

```powershell
### New log file for each session (timestamp in filename)
$script:LogMode = 'Session'

### Log file will be: Logs\ScriptName_yyyyMMdd_HHmmss_Log.log
Write-Log "Interactive session started" -Level Header
Write-Log "User: $env:USERNAME" -Level Info
Write-Log "Computer: $env:COMPUTERNAME" -Level Info

### Your interactive commands...
```

### Example 7: Structured Logging with Metadata

```powershell
### Create structured log entries
$logEntry = [LogEntry]::new(
    [LogLevel]::Info,
    "User data retrieved",
    "UserImport"
)
$logEntry.AddMetadata("UserCount", 150)
$logEntry.AddMetadata("Duration", "2.5s")
$logEntry.AddMetadata("Source", "Azure AD")

### Format and write to log
$message = $logEntry.FormatMessage()
Write-Log $message -Level Info

### Output: [INFO] [UserImport] User data retrieved | UserCount=150 | Duration=2.5s | Source=Azure AD
```

### Example 8: Custom Log Paths and Silent Logging

```powershell
### Log to custom path without console output
$customLogPath = "C:\Reports\AuditLog_$(Get-Date -Format 'yyyyMMdd').log"

Write-Log "Starting audit process..." -Level Info -LogPath $customLogPath -NoConsole
Write-Log "Processed 500 items" -Level Info -LogPath $customLogPath -NoConsole
Write-Log "Audit complete" -Level Success -LogPath $customLogPath -NoConsole

### Console-only logging (no file)
Write-Log "Debug message for console only" -Level Verbose -NoLog
```

---

## Module Management Examples

### Example 9: Import Multiple Graph Modules

```powershell
### Define required modules
$requiredModules = @(
    'Microsoft.Graph.Users'
    'Microsoft.Graph.Groups'
    'Microsoft.Graph.Reports'
    'Microsoft.Graph.Sites'
)

### Import all modules (auto-install if missing)
Write-Log "Importing required Graph modules..." -Level Header
Import-RequiredModules -Modules $requiredModules -Verbose

### Verify imports
foreach ($module in $requiredModules) {
    if (Get-Module -Name $module) {
        Write-Log "Module loaded: $module" -Level Success
    }
}
```

### Example 10: Pipeline-Based Module Import

```powershell
### Import modules via pipeline
@(
    'Microsoft.Graph.Authentication'
    'Microsoft.Graph.Users'
    'Az.Accounts'
    'Az.KeyVault'
) | Import-RequiredModules -Scope CurrentUser -Force

### Or from a configuration file
$config = Get-Content .\Config\required-modules.json | ConvertFrom-Json
$config.Modules | Import-RequiredModules -Verbose
```

### Example 11: Version-Specific Module Loading

```powershell
### Load specific module versions
function Import-ModuleVersion {
    param(
        [string]$ModuleName,
        [string]$RequiredVersion
    )

    Write-Log "Checking for $ModuleName v$RequiredVersion" -Level Info

    $module = Get-Module -ListAvailable -Name $ModuleName |
              Where-Object { $_.Version -eq $RequiredVersion }

    if (-not $module) {
        Write-Log "Installing $ModuleName v$RequiredVersion..." -Level Warning
        Install-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force
    }

    Import-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Force
    Write-Log "Loaded $ModuleName v$RequiredVersion" -Level Success
}

### Import specific versions
Import-ModuleVersion -ModuleName "Microsoft.Graph.Authentication" -RequiredVersion "2.0.0"
```

---

## Advanced Scenarios

### Example 12: Retry Policy for Resilient Operations

```powershell
### Create retry policy with exponential backoff
$retryPolicy = [RetryPolicy]::new(5, 1000, 2.0)  ### 5 attempts, 1s initial delay, 2x backoff

### Use retry policy for Graph API calls
$users = $retryPolicy.Execute({
    Get-MgUser -All -ErrorAction Stop
})

Write-Log "Retrieved $($users.Count) users with retry protection" -Level Success
```

### Example 13: Batch Processing with Progress and Error Handling

```powershell
$script:LogMode = 'Daily'

### Get list of users to process
$users = 1..1000

### Initialize counters
$processed = 0
$errors = 0
$errorList = @()

Write-Log "Starting batch processing of $($users.Count) users" -Level Header

### Process in batches
$batchSize = 50
for ($i = 0; $i -lt $users.Count; $i += $batchSize) {
    $batch = $users[$i..([Math]::Min($i + $batchSize - 1, $users.Count - 1))]

    Write-Log "Processing batch $($i / $batchSize + 1) ($($batch.Count) users)" -Level Info

    foreach ($user in $batch) {
        try {
            ### Process user (your logic here)
            Start-Sleep -Milliseconds 100
            $processed++

            if ($processed % 100 -eq 0) {
                Write-Log "Progress: $processed / $($users.Count) users processed" -Level SubItem
            }
        }
        catch {
            $errors++
            $errorList += [PSCustomObject]@{
                User  = $user
                Error = $_.Exception.Message
                Time  = Get-Date
            }
            Write-Log "Error processing user $user : $($_.Exception.Message)" -Level Error
        }
    }
}

### Summary
Write-Log "Batch processing complete" -Level Header
Write-Log "Total processed: $processed" -Level Success
Write-Log "Total errors: $errors" -Level Warning

if ($errors -gt 0) {
    $errorReport = ".\Logs\Errors_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $errorList | Export-Csv -Path $errorReport -NoTypeInformation
    Write-Log "Error report saved to: $errorReport" -Level Info
}
```

### Example 14: Configuration-Driven Script

```powershell
### Load configuration
$config = Get-Content .\Config\app-registration.json | ConvertFrom-Json

### Select environment
$env = $config.Environments | Where-Object { $_.Name -eq "Production" }

### Configure logging from config
$script:LogMode = $config.Logging.Mode

### Connect using environment settings
$settingsObj = @{
    TenantId             = $env.TenantId
    ClientId             = $env.ClientId
    CertificateThumbprint = $env.CertificateThumbprint
}

### Create temporary settings file
$tempSettings = ".\temp-settings.json"
$settingsObj | ConvertTo-Json | Set-Content $tempSettings

try {
    Connect-MgGraphAPI -SettingsPath $tempSettings -Verbose

    ### Your operations
    Get-MgGraphAPIPermissions
}
finally {
    Disconnect-MgGraphAPI
    Remove-Item $tempSettings -Force
}
```

---

## Azure Integration

### Example 15: Azure Function Integration

```powershell
### Azure Function - TimerTrigger

using namespace System.Net

param($Timer)

### Import module
Import-Module "$PSScriptRoot\Modules\Brennan.PowerShell.Core" -Force

### Configure logging for Azure
$script:LogMode = 'Session'

Write-Log "Azure Function triggered" -Level Header
Write-Log "Trigger time: $(Get-Date)" -Level Info

try {
    ### Connect using certificate from Key Vault or environment variables
    $settings = @{
        TenantId             = $env:AZURE_TENANT_ID
        ClientId             = $env:AZURE_CLIENT_ID
        CertificateThumbprint = $env:AZURE_CERT_THUMBPRINT
    } | ConvertTo-Json

    $settingsPath = "$env:TEMP\settings.json"
    $settings | Set-Content $settingsPath

    Connect-MgGraphAPI -SettingsPath $settingsPath -Verbose

    ### Perform operations
    $users = Get-MgUser -Top 10
    Write-Log "Retrieved $($users.Count) users" -Level Success

    ### Return success
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = "Function completed successfully"
    })
}
catch {
    Write-Log "Function failed: $($_.Exception.Message)" -Level Error

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::InternalServerError
        Body       = "Function failed: $($_.Exception.Message)"
    })
}
finally {
    Disconnect-MgGraphAPI
    Remove-Item $settingsPath -Force -ErrorAction SilentlyContinue
}
```

### Example 16: Azure Automation Runbook

```powershell
### Azure Automation Runbook

### Import modules (already installed in Automation Account)
Import-Module Brennan.PowerShell.Core

### Set logging mode for runbook
$script:LogMode = 'Daily'

Write-Log "Runbook started" -Level Header

### Get automation connection (certificate)
$connection = Get-AutomationConnection -Name 'AzureRunAsConnection'

### Create settings from automation connection
$settings = @{
    TenantId             = $connection.TenantId
    ClientId             = $connection.ApplicationId
    CertificateThumbprint = $connection.CertificateThumbprint
} | ConvertTo-Json

$settingsPath = "$env:TEMP\automation-settings.json"
$settings | Set-Content $settingsPath

try {
    ### Connect to Microsoft Graph
    Connect-MgGraphAPI -SettingsPath $settingsPath -Verbose

    ### Perform automated tasks
    Write-Log "Performing scheduled maintenance..." -Level Info

    ### Your automation logic here

    Write-Log "Runbook completed successfully" -Level Success
}
catch {
    Write-Log "Runbook failed: $($_.Exception.Message)" -Level Error
    throw
}
finally {
    Disconnect-MgGraphAPI
    Remove-Item $settingsPath -Force -ErrorAction SilentlyContinue
}
```

---

## Production Patterns

### Example 17: Complete User Reporting Script

```powershell
<#
.SYNOPSIS
    Generate comprehensive user report with Copilot licenses
.DESCRIPTION
    Connects to Graph API, retrieves all users, identifies Copilot license holders,
    generates report, and sends email notification
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = ".\settings.json",

    [Parameter(Mandatory = $false)]
    [string]$ReportPath = ".\Reports\UserReport_$(Get-Date -Format 'yyyyMMdd').html"
)

### Import module
Import-Module .\Brennan.PowerShell.Core.psd1 -Force

### Configure logging
$script:LogMode = 'Daily'

###region Initialize
Write-Log "User Report Generation Script" -Level Header
Write-Log "Started at: $(Get-Date)" -Level Info

### Import required modules
$modules = @(
    'Microsoft.Graph.Users'
    'Microsoft.Graph.Groups'
)
Import-RequiredModules -Modules $modules -Verbose
###endregion Initialize

###region Connect
try {
    Connect-MgGraphAPI -SettingsPath $ConfigPath -Verbose
    Write-Log "Successfully connected to Microsoft Graph" -Level Success
}
catch {
    Write-Log "Failed to connect to Graph API: $($_.Exception.Message)" -Level Error
    exit 1
}
###endregion Connect

###region Data Collection
try {
    Write-Log "Retrieving all users..." -Level Info
    $allUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses"
    Write-Log "Retrieved $($allUsers.Count) total users" -Level Success

    ### Filter for Copilot license (example SKU)
    $copilotSku = "c5928f49-12ba-48f7-ada3-0d743a3601d5"  ### Microsoft 365 Copilot
    $copilotUsers = $allUsers | Where-Object {
        $_.AssignedLicenses.SkuId -contains $copilotSku
    }

    Write-Log "Found $($copilotUsers.Count) users with Copilot licenses" -Level Info
}
catch {
    Write-Log "Error retrieving users: $($_.Exception.Message)" -Level Error
    Disconnect-MgGraphAPI
    exit 1
}
###endregion Data Collection

###region Report Generation
try {
    ### Load HTML template
    $template = Get-Content .\Resources\templates\html-report.html -Raw

    ### Build user table
    $userRows = foreach ($user in $copilotUsers) {
        "<tr><td>$($user.DisplayName)</td><td>$($user.UserPrincipalName)</td></tr>"
    }

    ### Replace placeholders
    $report = $template -replace '{{REPORT_DATE}}', (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    $report = $report -replace '{{TOTAL_USERS}}', $allUsers.Count
    $report = $report -replace '{{COPILOT_USERS}}', $copilotUsers.Count
    $report = $report -replace '{{USER_ROWS}}', ($userRows -join "`n")

    ### Save report
    $reportDir = Split-Path $ReportPath
    if (-not (Test-Path $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }

    $report | Set-Content -Path $ReportPath -Encoding UTF8
    Write-Log "Report saved to: $ReportPath" -Level Success
}
catch {
    Write-Log "Error generating report: $($_.Exception.Message)" -Level Error
}
###endregion Report Generation

###region Cleanup
Disconnect-MgGraphAPI
Write-Log "Script completed successfully" -Level Success
Write-Log "Ended at: $(Get-Date)" -Level Info
###endregion Cleanup
```

### Example 18: Scheduled Task Wrapper with Email Alerts

```powershell
###region Configuration
$script:LogMode = 'Daily'
$ErrorActionPreference = 'Stop'
$scriptName = "DailyUserSync"
$adminEmail = "admin@yourdomain.com"
###endregion Configuration

###region Execution
$startTime = Get-Date
Write-Log "Starting $scriptName" -Level Header

try {
    ### Your script logic here
    Import-Module .\Brennan.PowerShell.Core.psd1
    Connect-MgGraphAPI -SettingsPath ".\settings.json"

    ### Perform operations
    # ... your code ...

    $status = "Success"
    $message = "Script completed successfully"
    Write-Log $message -Level Success
}
catch {
    $status = "Failed"
    $message = $_.Exception.Message
    Write-Log "Script failed: $message" -Level Error
}
finally {
    Disconnect-MgGraphAPI

    ### Calculate duration
    $duration = (Get-Date) - $startTime
    Write-Log "Duration: $($duration.TotalMinutes) minutes" -Level Info
}
###endregion Execution

###region Send Email Alert
if ($status -eq "Failed") {
    ### Load email template
    $template = Get-Content .\Resources\templates\email-notification.html -Raw

    ### Replace placeholders
    $email = $template -replace '{{SCRIPT_NAME}}', $scriptName
    $email = $email -replace '{{STATUS}}', $status
    $email = $email -replace '{{MESSAGE}}', $message
    $email = $email -replace '{{DURATION}}', "$($duration.TotalMinutes) minutes"

    ### Send email (using Send-MailMessage or Graph API)
    # Send-MailMessage -To $adminEmail -Subject "Script Alert: $scriptName" -Body $email -BodyAsHtml
}
###endregion Send Email Alert
```

---

## Troubleshooting Examples

### Example 19: Diagnose Connection Issues

```powershell
### Diagnostic script for connection problems

Write-Host "=== Brennan.PowerShell.Core Connection Diagnostics ===" -ForegroundColor Cyan

### Check 1: Module installed
Write-Host "`n[1/5] Checking module installation..." -ForegroundColor Yellow
if (Get-Module -ListAvailable -Name Brennan.PowerShell.Core) {
    Write-Host "✓ Module found" -ForegroundColor Green
} else {
    Write-Host "✗ Module not found" -ForegroundColor Red
    exit
}

### Check 2: Settings file exists
Write-Host "`n[2/5] Checking settings file..." -ForegroundColor Yellow
$settingsPath = ".\settings.json"
if (Test-Path $settingsPath) {
    Write-Host "✓ Settings file exists" -ForegroundColor Green
    $settings = Get-Content $settingsPath | ConvertFrom-Json
} else {
    Write-Host "✗ Settings file not found" -ForegroundColor Red
    exit
}

### Check 3: Certificate exists
Write-Host "`n[3/5] Checking certificate..." -ForegroundColor Yellow
$cert = Get-ChildItem Cert:\CurrentUser\My\$($settings.CertificateThumbprint) -ErrorAction SilentlyContinue
if ($cert) {
    Write-Host "✓ Certificate found" -ForegroundColor Green
    Write-Host "  Subject: $($cert.Subject)" -ForegroundColor Gray
    Write-Host "  Expires: $($cert.NotAfter)" -ForegroundColor Gray
    Write-Host "  Has Private Key: $($cert.HasPrivateKey)" -ForegroundColor Gray

    if (-not $cert.HasPrivateKey) {
        Write-Host "✗ Certificate does not have private key!" -ForegroundColor Red
    }

    if ($cert.NotAfter -lt (Get-Date)) {
        Write-Host "✗ Certificate has expired!" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Certificate not found with thumbprint: $($settings.CertificateThumbprint)" -ForegroundColor Red
}

### Check 4: Graph module installed
Write-Host "`n[4/5] Checking Microsoft.Graph.Authentication..." -ForegroundColor Yellow
if (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication) {
    Write-Host "✓ Graph Authentication module found" -ForegroundColor Green
} else {
    Write-Host "✗ Graph Authentication module not found" -ForegroundColor Red
}

### Check 5: Test connection
Write-Host "`n[5/5] Testing connection..." -ForegroundColor Yellow
try {
    Connect-MgGraphAPI -SettingsPath $settingsPath -Verbose
    Write-Host "✓ Connection successful!" -ForegroundColor Green

    $context = Get-MgContext
    Write-Host "  Tenant: $($context.TenantId)" -ForegroundColor Gray
    Write-Host "  App: $($context.ClientId)" -ForegroundColor Gray
    Write-Host "  Scopes: $($context.Scopes -join ', ')" -ForegroundColor Gray

    Disconnect-MgGraphAPI
} catch {
    Write-Host "✗ Connection failed!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Diagnostics Complete ===" -ForegroundColor Cyan
```

### Example 20: Performance Monitoring

```powershell
### Monitor function performance with detailed timing

function Measure-FunctionPerformance {
    param(
        [scriptblock]$ScriptBlock,
        [string]$FunctionName
    )

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        $result = & $ScriptBlock
        $stopwatch.Stop()

        Write-Log "[$FunctionName] Completed in $($stopwatch.ElapsedMilliseconds)ms" -Level Success
        return $result
    }
    catch {
        $stopwatch.Stop()
        Write-Log "[$FunctionName] Failed after $($stopwatch.ElapsedMilliseconds)ms" -Level Error
        throw
    }
}

### Usage
$users = Measure-FunctionPerformance -FunctionName "Get-MgUser" -ScriptBlock {
    Get-MgUser -Top 1000
}

Write-Log "Retrieved $($users.Count) users" -Level Info
```

---

## Related Documentation

- [Functions Reference](FUNCTIONS.md) - Complete function documentation
- [Configuration Guide](CONFIGURATION.md) - Settings and config files
- [Classes & Enums](CLASSES.md) - Advanced types reference
- [Getting Started](GETTING-STARTED.md) - Installation and setup

---

## Support

**Need help with these examples?**
- Email: chris@brennantechnologies.com
- Documentation: [Full Docs](../README.md)
- GitHub: https://github.com/BrennanTechnologies/PowerShell

---

**Author:** Chris Brennan
**Company:** Brennan Technologies, LLC
**Last Updated:** December 14, 2025
