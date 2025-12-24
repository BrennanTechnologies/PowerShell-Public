function Import-ModuleBootStrap{
    $Modules = Get-Module -Name Brennan* -ListAvailable
    foreach($Module in $Modules){
        try{
            Write-Host "Importing Module: " $Module.Name -ForegroundColor Magenta
            Import-Module -Name $Module
            Get-Module -Name $RequiredModule
        } catch {
            Write-Warning -Message ("ERROR Importing required module: $RequiredModule" + $global:Error[0].Exception.Message) -ErrorAction Stop
            Exit
        }
    }
}