![Brennan Technologies Logo](../Resources/Images/Brennan%20Logo%20--%20Transparent%20--%20SMALL.png)

# Getting Started with Brennan.PowerShell.Core

This guide will help you set up and start using the Brennan.PowerShell.Core module for Microsoft Graph API authentication and logging.

---

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Azure AD Configuration](#azure-ad-configuration)
- [Module Configuration](#module-configuration)
- [First Connection](#first-connection)
- [Verify Installation](#verify-installation)
- [Next Steps](#next-steps)

---

## Prerequisites

### System Requirements
- **Windows 10/11** or **Windows Server 2016+** (or PowerShell Core on Linux/macOS)
- **PowerShell 5.1** or higher (PowerShell Core 7+ recommended)
- **.NET Framework 4.7.2** or higher (for PowerShell 5.1)
- **Internet connection** for module downloads

### Required Access
- **Azure AD tenant** with administrative access
- **Permissions** to create app registrations in Azure AD
- **Certificate management** access (for creating/installing certificates)

### Knowledge Prerequisites
- Basic PowerShell scripting experience
- Understanding of Azure AD concepts
- Familiarity with certificate-based authentication

---

## Installation

### Step 1: Download the Module

```powershell
### Clone from repository
git clone https://github.com/BrennanTechnologies/PowerShell.git

### Or download ZIP and extract to a local folder
### Example: C:\Modules\PowerShell\BrennanTechnologies\Brennan.PowerShell.Core
```

### Step 2: Import the Module

```powershell
### Navigate to module directory
cd "C:\Path\To\PowerShell\BrennanTechnologies\Brennan.PowerShell.Core"

### Import module
Import-Module .\Brennan.PowerShell.Core.psd1 -Force -Verbose

### Verify module loaded
Get-Module Brennan.PowerShell.Core
```

### Step 3: Optional - Install to Modules Path

For permanent installation:

```powershell
### Copy to user modules directory
$modulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\Brennan.PowerShell.Core"
Copy-Item -Path ".\Brennan.PowerShell.Core" -Destination $modulePath -Recurse -Force

### Import from modules path
Import-Module Brennan.PowerShell.Core

### Now you can import from any location
```

---

## Azure AD Configuration

### Step 1: Create Azure AD App Registration

1. Navigate to [Azure Portal](https://portal.azure.com)
2. Go to **Azure Active Directory** → **App registrations**
3. Click **New registration**
4. Enter application details:
   - **Name:** `BrennanPowerShellCore` (or your preferred name)
   - **Supported account types:** Single tenant
   - **Redirect URI:** Leave blank
5. Click **Register**
6. **Copy the following values:**
   - **Application (client) ID**
   - **Directory (tenant) ID**

### Step 2: Configure API Permissions

1. In your app registration, go to **API permissions**
2. Click **Add a permission** → **Microsoft Graph** → **Application permissions**
3. Add required permissions based on your needs:
   - `User.Read.All` - Read all user profiles
   - `Group.Read.All` - Read all groups
   - `Directory.Read.All` - Read directory data
   - Add additional permissions as needed
4. Click **Grant admin consent** for your tenant
5. Verify status shows **Granted for [Your Tenant]**

### Step 3: Create and Upload Certificate

#### Option A: Create Self-Signed Certificate (Development)

```powershell
### Create self-signed certificate
$cert = New-SelfSignedCertificate `
    -Subject "CN=BrennanPowerShellCore" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddYears(2)

### Display thumbprint
Write-Host "Certificate Thumbprint: $($cert.Thumbprint)" -ForegroundColor Green

### Export public key for Azure
$certPath = "$env:TEMP\BrennanPowerShellCore.cer"
Export-Certificate -Cert $cert -FilePath $certPath

### Open certificate file location
explorer.exe (Split-Path $certPath)
```

#### Option B: Use Existing Certificate (Production)

```powershell
### List available certificates
Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.HasPrivateKey -eq $true}

### Note the thumbprint of your certificate
```

### Step 4: Upload Certificate to Azure AD

1. In your app registration, go to **Certificates & secrets**
2. Click **Upload certificate**
3. Select the `.cer` file created in Step 3
4. Add description: "PowerShell Authentication Certificate"
5. Click **Add**
6. Verify certificate appears in the list

---

## Module Configuration

### Step 1: Create Settings File

```powershell
### Copy template to working directory
Copy-Item .\Config\settings-template.json .\settings.json

### Open in editor
notepad .\settings.json
```

### Step 2: Configure Settings

Edit `settings.json` with your Azure AD values:

```json
{
	"_comment": "Brennan.PowerShell.Core Module Settings",
	"_author": "Chris Brennan",
	"_email": "chris@brennantechnologies.com",
	"_company": "Brennan Technologies, LLC",
	"_version": "1.0",
	"_date": "2025-12-14",

	"TenantId": "your-tenant-id-here",
	"ClientId": "your-client-id-here",
	"CertificateThumbprint": "your-certificate-thumbprint-here",
	"Organization": "yourdomain.onmicrosoft.com",
	"SharePointAdminUrl": "https://yourdomain-admin.sharepoint.com",

	"Logging": {
		"Enabled": true,
		"LogMode": "Daily",
		"LogPath": "./Logs",
		"LogLevel": "Info"
	},

	"GraphAPI": {
		"Scopes": [
			"User.Read.All",
			"Group.Read.All"
		]
	}
}
```

### Step 3: Secure Settings File

```powershell
### Restrict file permissions (Windows)
$acl = Get-Acl .\settings.json
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $env:USERNAME, "FullControl", "Allow"
)
$acl.AddAccessRule($rule)
Set-Acl .\settings.json $acl

### Verify permissions
Get-Acl .\settings.json | Format-List
```

---

## First Connection

### Test Connection

```powershell
### Import module
Import-Module .\Brennan.PowerShell.Core.psd1 -Force

### Set logging mode
$script:LogMode = 'Daily'

### Connect to Microsoft Graph
Write-Log "Testing connection to Microsoft Graph..." -Level Info

try {
    Connect-MgGraphAPI -SettingsPath ".\settings.json" -Verbose
    Write-Log "Connection successful!" -Level Success

    ### Get current permissions
    $permissions = Get-MgGraphAPIPermissions
    Write-Log "Granted permissions: $($permissions -join ', ')" -Level Info

    ### Disconnect
    Disconnect-MgGraphAPI
    Write-Log "Disconnected successfully" -Level Info
}
catch {
    Write-Log "Connection failed: $($_.Exception.Message)" -Level Error
}
```

### Expected Output

```
[2025-12-14 10:30:15] [INFO] Testing connection to Microsoft Graph...
VERBOSE: Reading settings from: .\settings.json
VERBOSE: Connecting to Microsoft Graph API...
VERBOSE: Using certificate authentication
[2025-12-14 10:30:18] [SUCCESS] ✓ Connection successful!
[2025-12-14 10:30:18] [INFO] Granted permissions: User.Read.All, Group.Read.All
[2025-12-14 10:30:19] [INFO] Disconnected successfully
```

---

## Verify Installation

### Check Module Components

```powershell
### List all exported functions
Get-Command -Module Brennan.PowerShell.Core

### View module details
Get-Module Brennan.PowerShell.Core | Select-Object Name, Version, ModuleType, ExportedFunctions

### Test each function help
Get-Help Connect-MgGraphAPI -Full
Get-Help Write-Log -Examples
Get-Help Import-RequiredModules -Detailed
```

### Verify Certificate

```powershell
### Get certificate by thumbprint
$thumbprint = "your-thumbprint-here"
$cert = Get-ChildItem Cert:\CurrentUser\My\$thumbprint

### Check certificate properties
$cert | Select-Object Subject, NotBefore, NotAfter, HasPrivateKey, Thumbprint
```

### Check Log Files

```powershell
### List log files
Get-ChildItem .\Logs

### View latest log
Get-Content .\Logs\Brennan.PowerShell.Core_$(Get-Date -Format 'yyyyMMdd')_Log.log -Tail 20
```

---

## Next Steps

### Learn More
- [Configuration Guide](CONFIGURATION.md) - Deep dive into all configuration options
- [Functions Reference](FUNCTIONS.md) - Complete function documentation
- [Examples](EXAMPLES.md) - Real-world usage scenarios
- [Classes & Enums](CLASSES.md) - Using advanced types

### Common Tasks
- **Set up automated scripts** - Use in Azure Functions or Automation Runbooks
- **Configure advanced logging** - Customize log formats and levels
- **Import additional modules** - Use `Import-RequiredModules` for Graph modules
- **Create custom reports** - Use templates in Resources folder

### Troubleshooting
- [Configuration Issues](CONFIGURATION.md#troubleshooting)
- [Connection Problems](#troubleshooting-connection-issues)
- [Certificate Issues](#troubleshooting-certificates)

---

## Troubleshooting Connection Issues

### Certificate Not Found

**Error:** `Certificate with thumbprint 'xxxx' not found`

**Solution:**
```powershell
### List all certificates
Get-ChildItem Cert:\CurrentUser\My | Format-Table Thumbprint, Subject

### Verify thumbprint matches settings.json
```

### Access Denied

**Error:** `AADSTS700016: Application with identifier 'xxxx' was not found`

**Solution:**
- Verify `ClientId` in settings.json matches Azure AD app registration
- Check `TenantId` is correct
- Ensure app registration is not deleted

### Permission Errors

**Error:** `Insufficient privileges to complete the operation`

**Solution:**
- Verify API permissions are granted in Azure AD
- Ensure admin consent is provided
- Check certificate is uploaded to app registration

### Module Not Found

**Error:** `The specified module 'Brennan.PowerShell.Core' was not loaded`

**Solution:**
```powershell
### Verify module path
$env:PSModulePath -split ';'

### Import with full path
Import-Module "C:\Full\Path\To\Brennan.PowerShell.Core.psd1" -Force
```

---

## Troubleshooting Certificates

### Certificate Expired

```powershell
### Check certificate expiration
$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Thumbprint -eq "your-thumbprint"}
if ($cert.NotAfter -lt (Get-Date)) {
    Write-Host "Certificate expired on: $($cert.NotAfter)" -ForegroundColor Red
}
```

### Missing Private Key

```powershell
### Verify private key exists
$cert = Get-ChildItem Cert:\CurrentUser\My\your-thumbprint
if (-not $cert.HasPrivateKey) {
    Write-Host "ERROR: Certificate does not have a private key!" -ForegroundColor Red
}
```

---

## Support

**Need help?**
- Email: chris@brennantechnologies.com
- Documentation: [Full Docs](../README.md)
- Examples: [EXAMPLES.md](EXAMPLES.md)

---

**Author:** Chris Brennan
**Company:** Brennan Technologies, LLC
**Last Updated:** December 14, 2025
