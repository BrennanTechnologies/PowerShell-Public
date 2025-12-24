# New-SignedScript #

### Description ###
Sign a PowerShell script with a Code Signing Certificate.

### Requirements ###
Requires the Brennan-ScriptSigning module.

```powershell
Import-Brennan-ScriptSigning
or
RequiredModules = @('Brennan-ScriptSigning')
```

### Syntax ###
```powershell
New-SignedScript
    -FilePath <String>
    [-CertFilePath <String>]
    [-TimeStampServer <String>]
```
 [ ] = Optional Parameter

**Example 1:**

* You **must** specify the full path of the script to be signed.

```powershell
$FilePath = "\\management.corp\Shares\Temp\Test.ps1"
New-SignedScript -FilePath $FilePath
```

**Example 2:**

Optional Parameters:

* Optionally, you can specify the code signing certificate to use, and the time stamp server.

```powershell
New-SignedScript -FilePath $FilePath -CertFilePath $CertFilePath -TimeStampServer $TimeStampServer
```

### Output:

- This cmdlet will create a signed copy of the original script in the same folder, and append “-Signed” to the file name.

    - MyScript.ps1 → MyScript-Signed.ps1


```html
PS > New-SignedScript -FilePath \\management.corp\Shares\Temp\test.ps1

    Directory: \\management.corp\Shares\Temp

SignerCertificate                            Status    Path
-----------------                            ------    ----
852909CCF83A2037BB1ED408B175529AE1E2662D     Valid     test-Signed.ps1
The script was successfully signed.
Signed Script:  \\management.corp\Shares\Temp\test-Signed.ps1
```

### Parameters

##### -FilePath

A string that specifies the full path of the script to sign.

Example:
` $FilePath = "\\management.corp\Shares\Temp\Test.ps1"`


##### -CertFilePath

A string that specifies the full path of certificate to use for signing. It defaults to the Brennan Code Signing Certificate.

Example:
`$CertFilePath = "\\management.corp\shares\Kits\Certificates\CodeSigning\CodeSigningCert.pfx"`


##### -TimeStampServer

The TimeStampServer parameter will allow the signed script to execute even after the Cert expires because the Cert was valid at the time of the signing.

Example:
` $TimeStampServer = 'http://timestamp.digicert.com'`

### Audit Logs ###

[DevOps].[dbo].[ScriptSigning]


### Author ###
Author: Chris Brennan

Date: 4-4-2020

### Support ###
**Known Bugs**

None

**Report Bugs**

bugs.devops@Brennangroupllc.com
