function Write-Log {
	<#
	.SYNOPSIS
	    Write formatted log messages to console and log file with timestamp and severity levels.

	.DESCRIPTION
	    Outputs log messages with consistent formatting including timestamp and color-coded severity levels.
	    Supports multiple message types including info, success, warning, error, headers, and sub-items.
	    Automatically creates a Logs folder in the script root and writes to a timestamped log file.
	    Log file paths are cached per session to ensure consistent file naming.

	.PARAMETER Message
	    The message text to log. This is a required parameter.

	.PARAMETER Level
	    The severity/formatting level. Valid values: Info, Success, Warning, Error, Verbose, Header, SubItem.
	    Default: Info

	.PARAMETER LogPath
	    Custom path to the log file. If not specified, automatically generates path based on calling script name.
	    Format: $ModuleRoot\Logs\{ScriptName}[_timestamp]_Log.log

	.PARAMETER NoConsole
	    Switch parameter. If specified, only writes to log file and skips console output.

	.PARAMETER NoLog
	    Switch parameter. If specified, only writes to console and skips file logging.

	.INPUTS
	    None. This function does not accept pipeline input.

	.OUTPUTS
	    None. Writes to console and/or log file based on parameters.

	.EXAMPLE
	    Write-Log "Processing started" -Level Info
	    Writes an informational message to console and log file.

	.EXAMPLE
	    Write-Log "Operation completed" -Level Success
	    Writes a success message with green checkmark to console.

	.EXAMPLE
	    Write-Log "Section Name" -Level Header
	    Writes a formatted section header with separator lines.

	.EXAMPLE
	    Write-Log "Error occurred" -Level Error -LogPath "C:\CustomLogs\mylog.log"
	    Writes error message to custom log file location.

	.EXAMPLE
	    Write-Log "Debug info" -Level Verbose -NoLog
	    Writes verbose message to console only, skips file logging.

	.EXAMPLE
	    $script:LogMode = 'Session'
	    Write-Log "Starting process"
	    Uses session-based logging (timestamp in filename) for all subsequent Write-Log calls.

	.NOTES
	    Author: Chris Brennan, chris@brennantechnologies.com
	    Company: Brennan Technologies, LLC
	    Date: December 14, 2025
	    Version: 1.0

	    Compatibility:
	    - Compliant w/ PowerShell 5.1+ and PowerShell Core to support automation for Azure Functions and Azure RunBooks, etc.

	    Filename Formats:
	    - Continuous: ScriptName_Log.log
	    - Daily: ScriptName_yyyyMMdd_Log.log (e.g., Brennan.PowerShell.Core_20251214_Log.log)
	    - Session: ScriptName_yyyyMMdd_HHmmss_Log.log (e.g., Brennan.PowerShell.Core_20251214_143530_Log.log)
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, Position = 0)]
		[string]$Message,

		[Parameter(Mandatory = $false)]
		[ValidateSet('Info', 'Success', 'Warning', 'Error', 'Verbose', 'Header', 'SubItem')]
		[string]$Level = 'Info',

		[Parameter(Mandatory = $false)]
		[string]$LogFolder,

		[Parameter(Mandatory = $false)]
		[switch]$NoConsole,

		[Parameter(Mandatory = $false)]
		[switch]$NoLog
	)	$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

	# Set $caller to show call stack info for log output
	$caller = (Get-PSCallStack)[1].FunctionName
	if (-not $caller) { $caller = $MyInvocation.InvocationName }

	### Determine LogFolder - use parameter, script variable, or default
	### Use LogFolder parameter if IsPresent, otherwise use global variable, otherwise default to script root
	$LogFolder = if ($LogFolder) {
		$LogFolder
	}
	elseif ($script:LogFolder) {
		$script:LogFolder
	}
	else {
		Join-Path -Path (Get-Location) -ChildPath 'Logs'
	}

	# Ensure log folder exists
	if ($LogFolder -and -not (Test-Path -Path $LogFolder)) {
		try {
			New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
		}
		catch {
			Write-Warning "Could not create log folder: $LogFolder. $_"
		}
	}

	# Always use $global:LogMode for log file naming
	$resolvedLogMode = if ($global:LogMode) { $global:LogMode } else { 'Continuous' }
	$baseFileName = if ($global:ScriptName) {
		$global:ScriptName
	}
	elseif ($script:ScriptName) {
		$script:ScriptName
	}
	elseif ($MyInvocation.PSCommandPath) {
		[System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.PSCommandPath)
	}
	else {
		'PowerShell'
	}
	$sessionCacheVar = "LogFileName_${baseFileName}_$resolvedLogMode"
	if ($resolvedLogMode -eq 'Session') {
		if (Get-Variable -Name $sessionCacheVar -Scope Script -ErrorAction SilentlyContinue) {
			$fileName = Get-Variable -Name $sessionCacheVar -Scope Script -ValueOnly
		}
		else {
			$fileName = "${baseFileName}_$(Get-Date -Format 'yyyyMMdd_HHmmss')_Log.log"
			Set-Variable -Name $sessionCacheVar -Value $fileName -Scope Script -Force
		}
	}
	elseif ($resolvedLogMode -eq 'Daily') {
		$fileName = "${baseFileName}_$(Get-Date -Format 'yyyyMMdd')_Log.log"
	}
	else {
		$fileName = "${baseFileName}_Log.log"
	}
	$LogPath = Join-Path -Path $LogFolder -ChildPath $fileName

	### Prepare log message for file (format: timestamp, caller, level, message)
	$fileMessage = switch ($Level) {
		'Info' { "$timestamp`t[callstacktrace: $caller]`t[INFO]`t$Message" }
		'Success' { "$timestamp`t[callstacktrace: $caller]`t[SUCCESS]`t$Message" }
		'Warning' { "$timestamp`t[callstacktrace: $caller]`t[WARNING]`t$Message" }
		'Error' { "$timestamp`t[callstacktrace: $caller]`t[ERROR]`t$Message" }
		'Verbose' { "$timestamp`t[callstacktrace: $caller]`t[VERBOSE]`t$Message" }
		'Header' { "`n$timestamp`t[callstacktrace: $caller]`t[HEADER]`t=== $Message ===" }
		'SubItem' { "$timestamp`t[callstacktrace: $caller]`t[SUBITEM]`t  $Message" }
	}

	### Write to console with color coding
	if (-not $NoConsole) {
		switch ($Level) {
			'Info' { Write-Host "[$timestamp] [callstacktrace: $caller] [INFO] { $Message }" }
			'Success' { Write-Host "[$timestamp] [callstacktrace: $caller] [SUCCESS] { ✓ $Message }" -ForegroundColor Green }
			'Warning' { Write-Host "[$timestamp] [callstacktrace: $caller] [WARNING] { ⚠ $Message }" -ForegroundColor Yellow }
			'Error' { Write-Host "[$timestamp] [callstacktrace: $caller] [ERROR]{ ✗ $Message }" -ForegroundColor Red }
			'Verbose' { Write-Verbose "[$timestamp] [callstacktrace: $caller] [VERBOSE] { $Message }" }
			'Header' { Write-Host "`n[$timestamp] [callstacktrace: $caller] [HEADER] { === $Message === }" -ForegroundColor Yellow }
			'SubItem' { Write-Host "[$timestamp] [callstacktrace: $caller] [SUBITEM] { $Message }" -ForegroundColor Cyan }
		}
	}

	### Write to log file
	if (-not $NoLog) {
		try {
			Add-Content -Path $LogPath -Value $fileMessage -ErrorAction Stop

			### Display log file location on first write (check if file was just created)
			if (-not $NoConsole -and (Get-Item $LogPath).Length -eq $fileMessage.Length + 2) {
				Write-Host "  [Log file: $LogPath]" -ForegroundColor DarkGray
			}
		}
		catch {
			Write-Warning "Failed to write to log file: $($_.Exception.Message)"
		}
	}
}