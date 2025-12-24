$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$defaultLogMode = if ($script:LogMode) { $script:LogMode } else { 'Continuous' }
$scriptRoot
$scriptName
$defaultLogMode