# Classes

This folder contains custom PowerShell classes used throughout the Brennan.PowerShell.Core module.

## Purpose

Classes are loaded before functions and provide:
- Custom object types with methods and properties
- Type definitions for strongly-typed parameters
- Reusable data structures

## Usage

Classes are automatically loaded by the module's `.psm1` file during import.

## Structure

Each class should be in its own `.ps1` file named after the class:
- `ClassName.ps1` - Contains the class definition

## Example

```powershell
class GraphAPIConnection {
    [string]$TenantId
    [string]$ClientId
    [datetime]$ConnectedAt

    [void]Disconnect() {
        ### Disconnect logic
    }
}
```

## Best Practices

- One class per file
- Use meaningful names (PascalCase)
- Document properties and methods with comments
- Keep classes focused on single responsibility
