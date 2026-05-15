### LogEntry Class
### Represents a single log entry with metadata

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

class LogEntry {
	[datetime]$Timestamp
	[LogLevel]$Level
	[string]$Message
	[string]$CallerFunction
	[string]$ScriptName
	[hashtable]$Metadata

	### Default constructor
	LogEntry() {
		$this.Timestamp = Get-Date
		$this.Metadata = @{}
	}

	### Constructor with message and level
	LogEntry([string]$message, [LogLevel]$level) {
		$this.Timestamp = Get-Date
		$this.Message = $message
		$this.Level = $level
		$this.Metadata = @{}

		### Get caller information from stack
		$caller = Get-PSCallStack | Select-Object -Skip 1 -First 1
		if ($caller) {
			$this.CallerFunction = $caller.Command
			$this.ScriptName = Split-Path -Leaf $caller.ScriptName
		}
	}

	### Convert to formatted string
	[string]ToString() {
		return "[$($this.Timestamp.ToString('yyyy-MM-dd HH:mm:ss'))] [$($this.Level)] $($this.Message)"
	}

	### Convert to JSON for structured logging
	[string]ToJson() {
		return $this | ConvertTo-Json -Compress
	}

	### Add metadata key-value pair
	[void]AddMetadata([string]$key, [object]$value) {
		$this.Metadata[$key] = $value
	}
}
