### ErrorHandlingStrategy Enum
### Defines strategies for handling errors in module functions

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

enum ErrorHandlingStrategy {
	Silent = 0  ### Suppress errors, return null or default value
	Warn = 1    ### Write warning message, continue execution
	Throw = 2   ### Throw exception, stop execution immediately
	Retry = 3   ### Retry operation with exponential backoff
}
