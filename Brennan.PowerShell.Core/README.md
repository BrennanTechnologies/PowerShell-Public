![Brennan Technologies Logo](Resources/Images/Brennan%20Logo%20--%20Transparent%20--%20SMALL.png)

# Brennan.PowerShell.Core

[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-green.svg)](CHANGELOG.md)

**Core PowerShell utilities for Brennan Technologies** - Enterprise-grade module providing Microsoft Graph connectivity, logging, and common functions optimized for Azure Functions, Azure Automation Runbooks, and legacy PowerShell 5.1+ environments.

---

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Documentation](#-documentation)
- [Module Structure](#-module-structure)
- [Exported Functions](#-exported-functions)
- [Examples](#-examples)
- [Requirements](#-requirements)
- [Support](#-support)
- [License](#-license)

---

## ✨ Features

### Core Capabilities
- ✅ **Microsoft Graph API Integration** - Certificate-based authentication with automatic module management
- ✅ **Advanced Logging System** - Multi-mode logging (Continuous/Daily/Session) with color-coded console output
- ✅ **Module Management** - Automatic installation and import of required modules
- ✅ **PowerShell 5.1+ Compatible** - Fully compatible with Azure Functions and Azure Automation Runbooks
- ✅ **Type Safety** - Custom enumerations for consistent parameter values
- ✅ **Reusable Classes** - Object-oriented design with connection state management
- ✅ **Comprehensive Configuration** - JSON-based settings with schema validation
- ✅ **Localization Ready** - Multi-language support (English, Spanish)
- ✅ **Professional Templates** - HTML reports, CSV exports, email notifications

### Best Practices
- 🎯 Follows PowerShell approved verb naming conventions
- 🎯 Comprehensive help documentation with examples
- 🎯 Error handling with detailed logging
- 🎯 Pipeline support where appropriate
- 🎯 Standardized comment format (###)
- 🎯 Author attribution on all components

---

## 🚀 Quick Start

### 1. Import the Module
```powershell
Import-Module .\Brennan.PowerShell.Core.psd1
```

### 2. Configure Settings
Copy the template and add your Azure AD app registration details:
```powershell
Copy-Item .\Config\settings-template.json .\settings.json

### Edit settings.json with your values:
### - TenantId: Your Azure AD tenant ID
### - ClientId: Your app registration client ID
### - CertificateThumbprint: Certificate thumbprint for authentication
```

### 3. Connect to Microsoft Graph
```powershell
### Connect using certificate authentication
Connect-MgGraphAPI -SettingsPath ".\settings.json" -Verbose

### Verify permissions
Get-MgGraphAPIPermissions

### Disconnect when finished
Disconnect-MgGraphAPI
```

### 4. Use Logging
```powershell
### Set log mode (Continuous, Daily, or Session)
$script:LogMode = 'Daily'

### Write log messages
Write-Log "Processing started" -Level Info
Write-Log "Operation completed successfully" -Level Success
Write-Log "Warning: Low disk space" -Level Warning
Write-Log "Error occurred during operation" -Level Error
```

---

## 📦 Installation

### Prerequisites
- **PowerShell 5.1 or higher** (PowerShell Core 7+ supported)
- **Administrator rights** for module installation (CurrentUser scope supported)
- **Microsoft.Graph.Authentication module** (auto-installed if missing)
- **Azure AD App Registration** with certificate authentication configured

### Standard Installation
```powershell
### Clone or download the repository
git clone https://github.com/BrennanTechnologies/PowerShell.git

### Navigate to module directory
cd PowerShell\BrennanTechnologies\Brennan.PowerShell.Core

### Import the module
Import-Module .\Brennan.PowerShell.Core.psd1 -Force

### Verify installation
Get-Module Brennan.PowerShell.Core
```

### Manual Installation to PowerShell Modules Path
```powershell
### Copy module to user modules directory
$modulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\Brennan.PowerShell.Core"
Copy-Item -Path ".\Brennan.PowerShell.Core" -Destination $modulePath -Recurse -Force

### Import from modules path
Import-Module Brennan.PowerShell.Core
```

---

## 📚 Documentation

### Complete Documentation
| Document                                   | Description                                       |
| ------------------------------------------ | ------------------------------------------------- |
| [Getting Started](Docs/GETTING-STARTED.md) | Installation, prerequisites, and first connection |
| [Configuration](Docs/CONFIGURATION.md)     | Settings files, environment setup, and options    |
| [Functions](Docs/FUNCTIONS.md)             | All public functions with parameters and examples |
| [Enumerations](Docs/ENUMS.md)              | Type-safe enums for consistent parameters         |
| [Classes](Docs/CLASSES.md)                 | Reusable classes with properties and methods      |
| [Examples](Docs/EXAMPLES.md)               | Real-world usage scenarios and code samples       |
| [Contributing](CONTRIBUTING.md)            | Coding standards and contribution guidelines      |
| [Changelog](CHANGELOG.md)                  | Version history and release notes                 |

### Quick References
- **Need help connecting?** → [Getting Started Guide](Docs/GETTING-STARTED.md)
- **Configuration issues?** → [Configuration Guide](Docs/CONFIGURATION.md)
- **Looking for examples?** → [Examples Documentation](Docs/EXAMPLES.md)
- **Want to contribute?** → [Contributing Guidelines](CONTRIBUTING.md)

---

## 📁 Module Structure

```
Brennan.PowerShell.Core/
│
├── 📄 Brennan.PowerShell.Core.psd1    # Module manifest
├── 📄 Brennan.PowerShell.Core.psm1    # Module loader
├── 📄 README.md                        # This file
├── 📄 CHANGELOG.md                     # Version history
├── 📄 CONTRIBUTING.md                  # Contribution guidelines
│
├── 📂 Public/                          # Exported functions
│   ├── Connect-MgGraphAPI.ps1
│   ├── Disconnect-MgGraphAPI.ps1
│   ├── Get-MgGraphAPIPermissions.ps1
│   ├── Import-RequiredModules.ps1
│   └── Write-Log.ps1
│
├── 📂 Private/                         # Internal functions
│   └── Test-CertificateValidity.ps1
│
├── 📂 Enums/                           # Type-safe enumerations
│   ├── LogLevel.ps1
│   ├── LogMode.ps1
│   ├── ConnectionStatus.ps1
│   ├── AuthenticationType.ps1
│   ├── ModuleImportBehavior.ps1
│   ├── CertificateValidationLevel.ps1
│   └── ErrorHandlingStrategy.ps1
│
├── 📂 Classes/                         # Reusable object types
│   ├── GraphAPIConnection.ps1
│   ├── LogEntry.ps1
│   ├── CertificateInfo.ps1
│   ├── ModuleManifest.ps1
│   └── RetryPolicy.ps1
│
├── 📂 Config/                          # Configuration files
│   ├── default-settings.json
│   ├── settings-template.json
│   ├── app-registration.json
│   ├── error-codes.json
│   ├── log-formats.json
│   └── schemas/
│       ├── settings-schema.json
│       └── app-registration-schema.json
│
├── 📂 Resources/                       # Templates and data
│   ├── templates/
│   │   ├── html-report.html
│   │   ├── csv-export-template.txt
│   │   └── email-notification.html
│   ├── localization/
│   │   ├── en-US.psd1
│   │   └── es-ES.psd1
│   ├── ascii-art/
│   │   └── banner.txt
│   ├── scripts/
│   │   └── Initialize-Module.ps1
│   ├── data/
│   │   ├── graph-permissions.json
│   │   └── certificate-purposes.json
│   └── Images/
│       └── Brennan Logo -- Transparent -- SMALL.png
│
├── 📂 Docs/                            # Documentation
│   ├── GETTING-STARTED.md
│   ├── CONFIGURATION.md
│   ├── FUNCTIONS.md
│   ├── ENUMS.md
│   ├── CLASSES.md
│   └── EXAMPLES.md
│
└── 📂 Logs/                            # Log file output directory
    └── (auto-generated log files)
```

---

### Graph API Authentication
| Function                    | Description                                                 |
| --------------------------- | ----------------------------------------------------------- |
| `Connect-MgGraphAPI`        | Connect to Microsoft Graph using certificate authentication |
| `Disconnect-MgGraphAPI`     | Disconnect from Microsoft Graph and clear session           |
| `Get-MgGraphAPIPermissions` | Display current Graph API permissions and scopes            |

### Module Management
| Function                 | Description                                                         |
| ------------------------ | ------------------------------------------------------------------- |
| `Import-RequiredModules` | Import or install required PowerShell modules with pipeline support |

### Logging
| Function    | Description                                                      |
| ----------- | ---------------------------------------------------------------- |
| `Write-Log` | Write formatted log messages with timestamps and severity levels |

> **Note:** All functions include comprehensive help documentation. Use `Get-Help <FunctionName> -Full` for detailed information.

---

## 💡 Examples

### Example 1: Connect to Graph and Log Activity
```powershell
### Import module
Import-Module .\Brennan.PowerShell.Core.psd1

### Set daily logging mode
$script:LogMode = 'Daily'

### Connect with logging
Write-Log "Connecting to Microsoft Graph..." -Level Info
Connect-MgGraphAPI -SettingsPath ".\settings.json" -Verbose
Write-Log "Connected successfully" -Level Success

### Check permissions
$permissions = Get-MgGraphAPIPermissions
Write-Log "Current permissions: $($permissions -join ', ')" -Level Info

### Disconnect
Disconnect-MgGraphAPI
Write-Log "Disconnected from Graph API" -Level Info
```

### Example 2: Import Required Modules with Pipeline
```powershell
### Import multiple modules at once
$modules = @('Microsoft.Graph.Users', 'Microsoft.Graph.Groups', 'Microsoft.Graph.Reports')
$modules | Import-RequiredModules -Verbose

### Or import from an array
Import-RequiredModules -Modules $modules -Behavior InstallIfMissing
```

### Example 3: Advanced Logging with Custom Path
```powershell
### Use session-based logging with custom path
$logPath = "C:\Logs\MyScript_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

Write-Log "Script Started" -Level Header -LogPath $logPath
Write-Log "Processing user data..." -Level Info -LogPath $logPath
Write-Log "  Found 150 users" -Level SubItem -LogPath $logPath
Write-Log "Process completed successfully" -Level Success -LogPath $logPath
```

### Example 4: Using Enumerations and Classes
```powershell
### Create a connection object
$connection = [GraphAPIConnection]::new(
    "your-tenant-id",
    "your-client-id",
    [AuthenticationType]::Certificate
)

### Update connection status
$connection.UpdateStatus([ConnectionStatus]::Connected)

### Check if connection is valid
if ($connection.IsValid()) {
    Write-Log "Connection is active" -Level Success
}

### Add scopes
$connection.AddScopes(@("User.Read.All", "Group.Read.All"))
```

> **More Examples:** See [Docs/EXAMPLES.md](Docs/EXAMPLES.md) for comprehensive real-world scenarios.

---

## ⚙️ Requirements

### System Requirements
- **Operating System:** Windows 10/11, Windows Server 2016+, or Linux/macOS with PowerShell Core
- **PowerShell Version:** 5.1 or higher (PowerShell Core 7+ recommended)
- **.NET Framework:** 4.7.2 or higher (for PowerShell 5.1)

### Module Dependencies
- **Microsoft.Graph.Authentication** (v2.0.0+) - Auto-installed if missing

### Azure Requirements
- **Azure AD App Registration** with configured certificate authentication
- **Certificate** with private key installed in certificate store
- **Graph API Permissions** assigned to app registration
- **Admin Consent** granted for required permissions

### Optional Tools
- **Visual Studio Code** with PowerShell extension (recommended for development)
- **Azure CLI** for managing app registrations
- **Git** for version control

---

## 🆘 Support

### Getting Help
- **Documentation:** Check the [Docs/](Docs/) folder for detailed guides
- **Examples:** See [Docs/EXAMPLES.md](Docs/EXAMPLES.md) for code samples
- **Issues:** Report bugs or request features via GitHub Issues
- **Contact:** chris@brennantechnologies.com

### Troubleshooting
| Issue                  | Solution                                                              |
| ---------------------- | --------------------------------------------------------------------- |
| Certificate not found  | Verify thumbprint and ensure certificate is in `Cert:\CurrentUser\My` |
| Module import fails    | Check PowerShell version (5.1+ required)                              |
| Graph connection fails | Verify app registration permissions and tenant ID                     |
| Log files not created  | Ensure write permissions to Logs folder                               |

### Common Commands
```powershell
### Check module version
Get-Module Brennan.PowerShell.Core

### View all exported functions
Get-Command -Module Brennan.PowerShell.Core

### Get help for a function
Get-Help Connect-MgGraphAPI -Full

### View module manifest
Test-ModuleManifest .\Brennan.PowerShell.Core.psd1
```

---

## 📄 License

**Proprietary License**
Copyright © 2025 Brennan Technologies, LLC. All rights reserved.

This module is proprietary software developed by Brennan Technologies, LLC. Unauthorized copying, modification, distribution, or use of this software is strictly prohibited.

---

## 👨‍💻 Author

**Chris Brennan**
Email: chris@brennantechnologies.com
Company: Brennan Technologies, LLC
Website: [www.brennantechnologies.com](https://www.brennantechnologies.com)

---

## 🔄 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and release notes.

**Current Version:** 1.0.0
**Release Date:** December 14, 2025
**Status:** Production Ready

---

## 🤝 Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, coding standards, and the process for submitting pull requests.

### Key Standards
- Use `###` for all inline comments
- Follow PowerShell approved verb naming
- Include comprehensive help documentation
- Add author headers to all new files
- Test with PowerShell 5.1 and PowerShell Core

---

## 🙏 Acknowledgments

- Microsoft Graph API Team for excellent documentation
- PowerShell Community for best practices and guidance
- Azure Functions Team for PowerShell 5.1 compatibility guidance

---

**Made with ❤️ by Brennan Technologies, LLC**

