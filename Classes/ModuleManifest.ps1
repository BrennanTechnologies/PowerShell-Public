### ModuleManifest Class
### Represents module configuration and metadata

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

class ModuleManifest {
	[string]$Name
	[version]$Version
	[string]$Author
	[string]$CompanyName
	[string]$Description
	[string[]]$RequiredModules
	[hashtable]$Settings

	### Constructor
	ModuleManifest([string]$name, [version]$version) {
		$this.Name = $name
		$this.Version = $version
		$this.RequiredModules = @()
		$this.Settings = @{}
	}

	### Load from PSD1 file
	static [ModuleManifest]FromFile([string]$path) {
		if (-not (Test-Path $path)) {
			throw "Manifest file not found: $path"
		}

		$data = Import-PowerShellDataFile -Path $path
		$manifest = [ModuleManifest]::new($data.RootModule, [version]$data.ModuleVersion)
		$manifest.Author = $data.Author
		$manifest.CompanyName = $data.CompanyName
		$manifest.Description = $data.Description

		### Import required modules if present
		if ($data.RequiredModules) {
			$manifest.RequiredModules = $data.RequiredModules
		}

		return $manifest
	}

	### Validate required modules are loaded
	[bool]ValidateRequirements() {
		foreach ($module in $this.RequiredModules) {
			if (-not (Get-Module -Name $module -ListAvailable)) {
				return $false
			}
		}
		return $true
	}

	### Get missing required modules
	[string[]]GetMissingModules() {
		$missing = @()
		foreach ($module in $this.RequiredModules) {
			if (-not (Get-Module -Name $module -ListAvailable)) {
				$missing += $module
			}
		}
		return $missing
	}
}
