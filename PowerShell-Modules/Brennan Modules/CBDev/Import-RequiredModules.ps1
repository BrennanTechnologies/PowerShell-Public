function Import-RequiredModules {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $requiredModules = @(
            #"Brennan"
            "Brennan.Core"
        )
    )
    ### Import Required Modules.
    ###------------------------------------------------
    foreach($RequiredModule in $RequiredModules){
        try {
            if( [bool](Get-Module -Name $RequiredModule -ListAvailable) -eq $true ){
                #Write-Host "Importing Module: " $RequiredModule -ForegroundColor Magenta
                Import-Module -Name $RequiredModule -Force
                Get-Module -Name $RequiredModule #| Select-Object -Property Name, ModuleType, Version
            }    
            else {
                Write-Error -Message "Required Module $RequiredModule isnt available." 
            }
        }
        catch {
            Write-Warning -Message ("ERROR Importing required module: $RequiredModule" + $global:Error[0].Exception.Message) -ErrorAction Stop
        }
    }
}