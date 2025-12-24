### ModuleImportBehavior Enum
### Defines behavior for module import operations

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

enum ModuleImportBehavior {
	SkipIfPresent = 0  ### Don't import if module is already loaded
	ForceReload = 1    ### Always reload module, removing existing version first
	AutoInstall = 2    ### Automatically install from PSGallery if missing, then import
}
