Get-Module -Name Brennan-Reporting

Import-Module -Name Brennan-Reporting -Force -RequiredVersion 1.2.0 -PassThru

$Module = Get-Module -Name "Brennan-Reporting"
#$Module.Name
#$Module.Version.ToString()
Write-Host "Importing Module: " $Module.Name  $Module.Version.ToString() -ForegroundColor yellow


# Import-Module -Name Brennan-Reporting -Force -MaximumVersion

Get-Command -Module Brennan-Reporting
# Requires -Module @{ModuleName = 'PSScriptAnalyzer'; RequiredVersion = '1.5.0'}

$Module = Get-Module -Name Brennan-Reporting
$Module.Name
$Module.Version.ToString()