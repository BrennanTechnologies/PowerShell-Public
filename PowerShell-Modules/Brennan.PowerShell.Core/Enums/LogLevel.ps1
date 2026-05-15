### LogLevel Enum
### Defines severity levels for logging operations

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

enum LogLevel {
	Verbose = 0    ### Detailed diagnostic information
	Info = 1       ### General informational messages
	Warning = 2    ### Warning messages for potential issues
	Error = 3      ### Error messages for failures
	Success = 4    ### Success confirmation messages
	Header = 5     ### Section headers for log organization
	SubItem = 6    ### Sub-items under headers
	Debug = 7      ### Debug-level diagnostic information
}
