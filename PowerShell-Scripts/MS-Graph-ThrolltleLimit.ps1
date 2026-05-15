MS-Graph-MaxThrottleLimit.ps1

Retry-After

foreqach()reeuest in request

if 429 {}


if response = 429 = TooManyRequests {
	$retrYTime = response.Retry-After +1
	Retry-After =  10
}
Retry-After

Do+ { Retry-After }+While+429	
Retry-After: RETRY-Time
{}