# Config

This folder contains configuration files for the Brennan.PowerShell.Core module.

## Purpose

Configuration files provide:
- Module settings and defaults
- Environment-specific configurations
- Template configurations for users

## Supported Formats

- **JSON** - Preferred for structured configuration
- **XML** - For complex hierarchical settings
- **PSD1** - PowerShell data files for PowerShell-native config

## Usage

Configuration files are typically loaded by module functions as needed, not automatically imported.

## Structure

```
Config/
├── default-settings.json       ### Default module configuration
├── settings-template.json      ### Template for user customization
└── schemas/                    ### JSON schemas for validation
    └── settings-schema.json
```

## Example Configuration

**default-settings.json:**
```json
{
  "LogPath": "./Logs",
  "LogMode": "Session",
  "DefaultTenantId": null,
  "Verbose": false
}
```

## Best Practices

- Never commit sensitive data (credentials, keys, certificates)
- Provide template files for user customization
- Use `.gitignore` to exclude user-specific config files
- Validate configuration on load
- Document all configuration options
