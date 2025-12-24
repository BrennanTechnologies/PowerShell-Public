![Brennan Technologies Logo](./Brennan.PowerShell.Core/Resources/images/BrennanLogo_BizCard_White.png)

# PowerShell-Public

A collection of PowerShell scripts, modules, and technical documentation for server management, automation, and reporting. This repository provides practical examples for automating VMware, Veeam, SQL Server, and other related infrastructure tasks.

- Modular, reusable code components and advanced functions to accelerate scripting projects.
- Real-world examples and best practices for PowerShell development, including robust error handling, configuration management, and logging.
- Custom classes and enums to enable structured, maintainable, and type-safe scripting.
- Extensive documentation and configuration templates to help you get started quickly and adapt solutions to your environment.

## Technical Design Documentation

The **Technical Design Docs** section contains detailed documentation and workflow diagrams for key solutions and scripts in this repository. These documents provide in-depth technical overviews, process flows, and implementation details to support development, troubleshooting, and knowledge transfer.

**OneDrive Prep Script**
- [One Drive Prep Script - Logic Diagram](Technical%20Design%20Docs/One%20Drive%20Prep%20Script%20-%20Logic%20Diagram.pdf)
- [One Drive Prep Script - Technical Documentation](Technical%20Design%20Docs/One%20Drive%20Prep%20Script%20-%20Technical%20Documentation.pdf)

**Deleted Teams Sites Report**
- [Get Deleted Teams Sites - Workflow](Technical%20Design%20Docs/Get%20Deleted%20Teams%20Sites%20-%20Technical%20Documentation%20-%20Workflow.pdf)
- [Get Deleted Teams Sites - Technical Documentation](Technical%20Design%20Docs/Get%20Deleted%20Teams%20Sites%20-%20Technical%20Documentation%202025-12-12.pdf)


## Features
- **[Scripts & Utilities:](PowerShell-Scripts)**
  - Standalone PowerShell scripts for system tasks, automation, and demonstrations
  - Examples include registry management, date calculations, file operations, and more
- **[Modules:](PowerShell-Modules)**
  - `Brennan.PowerShell.Core` module with reusable functions and classes
  - Organized into Public, Private, Classes, Config, Enums, and Resources folders
- **[Documentation:](Technical%20Design%20Docs)**
  - Markdown files for classes, functions, enums, configuration, and usage examples
  - Getting started guide and module documentation
- **Classes & Enums:**
  - Custom PowerShell classes for structured scripting
  - Enum definitions for robust, type-safe scripting
- **Configuration:**
  - JSON configuration files for settings, error codes, and logging formats


## Core Module Structure
```
PowerShell-Public/
├── Brennan.PowerShell.Core/      # Main module with subfolders for organization
│   ├── Classes/
│   ├── Config/
│   ├── Dev/
│   ├── Docs/
│   ├── Enums/
│   ├── Private/
│   ├── Public/
│   ├── Resources/
│   └── ...
├── _Misc PowerShell Scripts/     # Standalone scripts and utilities
├── Classes/                     # Additional class definitions
├── Config/                      # JSON config files
├── Enums/                       # Enum definitions
├── Resources/                   # Supporting resources
├── *.md                         # Documentation
├── *.ps1                        # Top-level scripts
└── ...
```

