
$ScriptStartTime = Get-Date

write-host "Testing UnSigned Script" -ForegroundColor Red

$ScriptRunTime =  ( (Get-Date) - $ScriptStartTime )
Write-Host "ScriptRuneTime: " $ScriptRunTime -ForegroundColor DarkCyan

Start-Sleep -s 60