# Import-ABAPfxCertificate #

### Description ###
Import the Brennan Code Signing Certificate.


### Requirements ###
Requires the Brennan-ScriptSigning module.

```powershell
Import-Brennan-ScriptSigning
or
RequiredModules = @('Brennan-ScriptSigning')
```

### Syntax ###
```powershell
Import-ABAPfxCertificate
    [-CertFilePath <String>]
    [-CertStoreLocation <String>]
    [-CertThumbprint <String>]
    -Password
```
 [ ] = Optional Parameter

**Example 1:**

```
Import-ABAPfxCertificate
```

* You do not need to enter any parameters.
* You will be prompted to enter the password for the certificate. (the password is stored in secret server as Secret Name :   DigiCert - Brennan Code Signing Cert )


**Example 2:**


Optional Parameters:

* Optionally, you can specify another certificate file, and the local certificate store location.

```
Import-ABAPfxCertificate -CertFilePath "\\management.corp\shares\Kits\Certificates\CodeSigning\CodeSigningCert.pfx" -CertStoreLocation  "Cert\localmachine\TrustedPublisher\"
```

### Parameters

##### -CertFilePath

Specify the full path too a code signing certificate.

Example:
` $CertFilePath = "\\management.corp\shares\Kits\Certificates\CodeSigning\CodeSigningCert.pfx"`


##### -CertStoreLocation

Specify the LocalMachine Certificate Store location to import the cert.

Example:
` $CertStoreLocation = "Cert\localmachine\TrustedPublisher\"  `



### Author ###
Author: Chris Brennan

Date: 4-4-2020`

### Support ###
**Known Bugs**

None

**Report Bugs**

bugs.devops@Brennangroupllc.com
