# Brennan.ps1

<#
	Description:
    ------------------------------------------------------------
	Boot Strap - "Login Script"

    Version: 
    ------------------------------------------------------------
	11.22.21
	5:55PM

	Author      = 'Chris Brennan'
	CompanyName = 'Brennan Technologies'
	Copyright   = '(c) 2021 Brennan Technologies, LLC "All rights reserved, for Use with Permission Only"'


    NOTES:
    ------------------------------------------------------------
	ScriptsToProcess = @(
		"Brennan.ps1" 			<-- This script
		#,
		#"Brennan.Core"
		#,
		#"Brennan.Common"
		#,
		#"Brennan.SQL"
		#,
		#"Brennan.Reporting"
		#,
		#"Brennan.CodeSigning"
		)

#>

[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$ParameterName
)


function New-FunctionTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [Alias("")]
        [TypeName]
        $ParameterName
    )
        begin {
            Write-Host "Function: " $((Get-PSCallStack)[0].Command) -ForegroundColor DarkGray
        }
        process{
        }
        end{}
}

function Test-Function {
    Write-Host "Function: " $((Get-PSCallStack)[0].Command) -ForegroundColor DarkGray
}

&{
	begin {}
	process {

		Write-Host "Executing Script    : "  "Brennan.ps1"                     -ForegroundColor Blue
		Write-Host "Module Version      : "  $((Get-Module Brennan).Version)   -ForegroundColor Blue
		Write-Host "Module Description  : "  'Bootstrap "Login Script"'        -ForegroundColor Blue
		Write-Host "Module Description  : "  'Bootstrap "Login Script"'        -ForegroundColor Blue

		Get-Module Brennan
        Write-Host `r`n`r`n
	}
	end{}
}
