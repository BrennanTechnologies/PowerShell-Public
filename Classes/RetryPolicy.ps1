### RetryPolicy Class
### Defines retry behavior for operations

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

class RetryPolicy {
	[int]$MaxAttempts
	[int]$DelayMilliseconds
	[double]$BackoffMultiplier
	[ErrorHandlingStrategy]$OnFailure

	### Default constructor with sensible defaults
	RetryPolicy() {
		$this.MaxAttempts = 3
		$this.DelayMilliseconds = 1000
		$this.BackoffMultiplier = 2.0
		$this.OnFailure = [ErrorHandlingStrategy]::Throw
	}

	### Constructor with custom values
	RetryPolicy([int]$maxAttempts, [int]$delay, [double]$backoff) {
		$this.MaxAttempts = $maxAttempts
		$this.DelayMilliseconds = $delay
		$this.BackoffMultiplier = $backoff
		$this.OnFailure = [ErrorHandlingStrategy]::Throw
	}

	### Calculate delay for specific attempt
	[int]GetDelay([int]$attemptNumber) {
		return [int]($this.DelayMilliseconds * [Math]::Pow($this.BackoffMultiplier, $attemptNumber - 1))
	}

	### Execute action with retry logic
	[object]Execute([scriptblock]$action) {
		$attempt = 0
		$lastError = $null

		while ($attempt -lt $this.MaxAttempts) {
			$attempt++
			try {
				return & $action
			}
			catch {
				$lastError = $_
				if ($attempt -lt $this.MaxAttempts) {
					$delay = $this.GetDelay($attempt)
					Write-Verbose "Retry attempt $attempt failed. Waiting $delay ms before retry..."
					Start-Sleep -Milliseconds $delay
				}
			}
		}

		### All attempts failed
		if ($this.OnFailure -eq [ErrorHandlingStrategy]::Throw) {
			throw "Operation failed after $($this.MaxAttempts) attempts. Last error: $($lastError.Exception.Message)"
		}
		elseif ($this.OnFailure -eq [ErrorHandlingStrategy]::Warn) {
			Write-Warning "Operation failed after $($this.MaxAttempts) attempts. Last error: $($lastError.Exception.Message)"
		}

		return $null
	}
}
