### Initialize-Module.ps1
### Helper script for first-time module setup

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

<#
.SYNOPSIS
    Initialize Brennan.PowerShell.Core module for first use

.DESCRIPTION
    Sets up configuration files, creates log directory, and validates prerequisites
    for the Brennan.PowerShell.Core module.

.EXAMPLE
    .\Initialize-Module.ps1
    Performs initial module setup

.NOTES
    Run this script after installing the module for the first time
#>

[CmdletBinding()]
param()

$ModuleRoot = Split-Path -Parent $PSScriptRoot

Write-Host "`n" -NoNewline
Get-Content (Join-Path $ModuleRoot "Resources\ascii-art\banner.txt") | Write-Host -ForegroundColor Cyan
Write-Host "`n"

Write-Host "Initializing Brennan.PowerShell.Core module..." -ForegroundColor Cyan
Write-Host ""

### Create Logs directory
$LogPath = Join-Path $ModuleRoot "Logs"
if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
    Write-Host "✓ Created Logs directory: $LogPath" -ForegroundColor Green
} else {
    Write-Host "✓ Logs directory already exists: $LogPath" -ForegroundColor Gray
}

### Copy template settings if needed
$SettingsPath = Join-Path $ModuleRoot "settings.json"
$TemplatePath = Join-Path $ModuleRoot "Config\settings-template.json"
if (-not (Test-Path $SettingsPath) -and (Test-Path $TemplatePath)) {
    Copy-Item -Path $TemplatePath -Destination $SettingsPath
    Write-Host "✓ Created settings.json from template" -ForegroundColor Green
    Write-Host "  Please edit settings.json with your configuration" -ForegroundColor Yellow
} else {
    Write-Host "✓ settings.json already exists" -ForegroundColor Gray
}

### Validate required modules
Write-Host "`nChecking required modules..." -ForegroundColor Cyan
$RequiredModules = @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Users"
)

foreach ($module in $RequiredModules) {
    if (Get-Module -ListAvailable -Name $module) {
        Write-Host "✓ $module is installed" -ForegroundColor Green
    } else {
        Write-Host "✗ $module is NOT installed" -ForegroundColor Yellow
        Write-Host "  Install with: Install-Module -Name $module" -ForegroundColor Gray
    }
}

Write-Host "`nModule initialization complete!" -ForegroundColor Green
Write-Host ""
