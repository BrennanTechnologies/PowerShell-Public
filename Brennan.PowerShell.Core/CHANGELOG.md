# Changelog

All notable changes to the Brennan.PowerShell.Core module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Add support for managed identity authentication
- Implement retry logic for Graph API calls
- Add performance monitoring and metrics
- Create Pester tests for all functions
- Publish to PowerShell Gallery

---

## [1.0.0] - 2025-12-14

### Added
- Initial release of Brennan.PowerShell.Core module
- **Graph API Authentication Functions:**
  - `Connect-MgGraphAPI` - Certificate-based authentication to Microsoft Graph
  - `Disconnect-MgGraphAPI` - Safe disconnection from Graph sessions
  - `Get-MgGraphAPIPermissions` - Permission discovery and reporting
- **Module Management:**
  - `Import-RequiredModules` - Automatic module installation and import with pipeline support
- **Logging System:**
  - `Write-Log` - Advanced logging with multiple modes (Continuous/Daily/Session)
  - Color-coded console output with severity levels
  - Automatic log file management
- **Type Safety:**
  - 7 custom enumerations for consistent parameter values
  - 5 reusable classes for connection management and data structures
- **Configuration System:**
  - JSON-based configuration with schema validation
  - Template files for easy setup
  - Multiple environment support (dev/test/prod)
- **Resources:**
  - HTML report templates
  - CSV export templates
  - Email notification templates
  - Localization support (English, Spanish)
  - Reference data for Graph permissions and certificates
- **Documentation:**
  - Comprehensive README with quick start guide
  - Getting Started guide with step-by-step setup
  - Full function reference documentation
  - Configuration guide with all options
  - Real-world examples and scenarios
  - Contributing guidelines with coding standards
- **Compatibility:**
  - PowerShell 5.1+ support for Azure Functions and Automation Runbooks
  - PowerShell Core 7+ support for cross-platform scenarios
  - .NET Framework 4.7.2 compatibility

### Features
- ✅ Certificate-based authentication for unattended scenarios
- ✅ Automatic module dependency management
- ✅ Multi-mode logging with timestamp and color coding
- ✅ Pipeline support for batch operations
- ✅ Comprehensive error handling and logging
- ✅ JSON schema validation for configuration files
- ✅ Professional templates for reports and notifications
- ✅ Localization-ready message system
- ✅ Author attribution on all components
- ✅ Standardized comment format (###)

### Technical Details
- **Module Structure:**
  - Public/ - 5 exported functions
  - Private/ - 1 internal function (Test-CertificateValidity)
  - Enums/ - 7 type-safe enumerations
  - Classes/ - 5 reusable object types
  - Config/ - Configuration files with schemas
  - Resources/ - Templates, localization, and reference data
  - Docs/ - Comprehensive documentation
- **Loading Order:** Enums → Classes → Private → Public
- **Comment Standard:** All inline comments use ### (three hashes)
- **Help System:** Full comment-based help for all functions
- **Error Codes:** Standardized error code system (AUTH_*, GRAPH_*, MODULE_*, CONFIG_*)

### Best Practices Implemented
- 🎯 PowerShell approved verb naming conventions
- 🎯 Begin/Process/End blocks for pipeline support
- 🎯 Comprehensive parameter validation
- 🎯 ShouldProcess support where appropriate
- 🎯 Detailed verbose logging
- 🎯 Error handling with try/catch blocks
- 🎯 Private/Public function separation
- 🎯 Module manifest with metadata
- 🎯 Schema validation for JSON files

### Known Limitations
- Requires certificate with private key for authentication
- Currently supports certificate authentication only (no managed identity yet)
- Windows certificate store only (Cert:\CurrentUser\My)
- No built-in retry logic for transient failures (planned for 1.1.0)

### Security
- Certificate-based authentication prevents credential exposure
- Settings files protected with .gitignore
- Sensitive data excluded from logs
- Secure credential handling
- Admin consent required for app permissions

---

## Version Comparison

| Version | Release Date | Major Changes   | Breaking Changes |
| ------- | ------------ | --------------- | ---------------- |
| 1.0.0   | 2025-12-14   | Initial release | N/A              |

---

## Upgrade Guide

### From No Version (New Installation)
This is the initial release. Follow the [Getting Started Guide](Docs/GETTING-STARTED.md).

---

## Migration Notes

### Future Versions
Migration notes will be provided here for major version upgrades.

---

## Deprecation Notices

### Current Version (1.0.0)
No deprecations in initial release.

---

## Support

For issues, questions, or feature requests:
- **Email:** chris@brennantechnologies.com
- **GitHub:** https://github.com/BrennanTechnologies/PowerShell
- **Documentation:** [README.md](README.md)

---

## Attribution

**Author:** Chris Brennan
**Company:** Brennan Technologies, LLC
**Email:** chris@brennantechnologies.com
**License:** Proprietary - Copyright © 2025 Brennan Technologies, LLC

---

## References

- [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
- [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
- [Microsoft Graph API Documentation](https://docs.microsoft.com/graph/)
- [PowerShell Best Practices](https://docs.microsoft.com/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines)

---

**Last Updated:** December 14, 2025
