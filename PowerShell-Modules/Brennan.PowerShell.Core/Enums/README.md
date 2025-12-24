# Enums

This folder contains PowerShell enum definitions used by the Brennan.PowerShell.Core module.

## Purpose

Enums provide:
- Strongly-typed parameter validation
- Predefined constant values
- IntelliSense support in editors
- Type safety for function parameters

## Usage

Enums are automatically loaded by the module's `.psm1` file during import, before classes and functions.

## Structure

Each enum should be in its own `.ps1` file named after the enum:
- `EnumName.ps1` - Contains the enum definition

## Example

**LogLevel.ps1:**
```powershell
enum LogLevel {
    Verbose = 0
    Info = 1
    Warning = 2
    Error = 3
    Success = 4
    Header = 5
    SubItem = 6
}
```

## Usage in Functions

```powershell
function Write-CustomLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [LogLevel]$Level = [LogLevel]::Info
    )

    ### Function logic
}
```

## Best Practices

- One enum per file
- Use meaningful names (PascalCase)
- Provide numeric values for ordered enums
- Document enum values with comments
- Keep enums simple and focused
