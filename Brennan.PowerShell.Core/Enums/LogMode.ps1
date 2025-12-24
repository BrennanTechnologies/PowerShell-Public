### LogMode Enum
### Defines logging behavior and file management strategies

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

enum LogMode {
	Continuous = 0  ### Single log file, appends indefinitely
	Daily = 1       ### New log file created each day (YYYYMMDD format)
	Session = 2     ### New log file per PowerShell session
}
