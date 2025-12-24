
# User Guide - Brennan-ScriptSigning #

## Overview ##

---

The Brennan-ScriptSigning module provides tools to secure and sign PowerShell scripts.


**UAT** - This module is currently in it’s early stages and subject to change.


## Requirements ##

---

#### Import Module ####

To use these tools you will need to import the Brennan-ScriptSigning module.

**UAT**  - These tools are currently only available in the DevOps UAT PowerShell Toolset.

~~~
Import-Module Brennan-ScriptSigning
~~~

## Commands ##

---

This module provides the following commands:

- New-SignedScript

- New-Encrypted Password


### New-SignedScript ###

This command will sign a PowerShell script with the Brennan Code Signing Certificate.


- You **must** provide the full path of the script you want to sign.

- This cmdlet will create a signed copy of the original script in the same folder, and append “-Signed” to the file name.

    - MyScript.ps1 → MyScript-Signed.ps1

**Example:**

```powershell
# Create a New Signed Script
New-SignedScript -FilePath <path to the script to be signed>
```

**Output:**
```powershell
PS > New-SignedScript -FilePath \\management.corp\Shares\Kits\Chocolatey\Scripts\Test\test.ps1

    Directory: \\management.corp\Shares\Kits\Chocolatey\Scripts\Test

SignerCertificate                         Status    Path
-----------------                         ------    ----
852909CCF83A2037BB1ED408B175529AE1E2662D  Valid     test-Signed.ps1
The script was sucessfully signed.
Signed Script:  \\management.corp\Shares\Kits\Chocolatey\Scripts\Test\test-Signed.ps1
```

### New-EncryptedPassword ###

This command will create a 256-bit AES encrypted password key pair.

- You will be prompted for the password.

- By default, this cmdlet will create a key pair in the default directory shown below, with the date/time appended to the folder name.

**Example 1:**
```powershell
New-EncryptedPassword
```

**Output:**

 - By default, this cmdlet will create a key pair in the default directory shown below, with the date/time appended to the folder name.
 - You can specify another destination folder by using the  `-KeyFolder ` parameter.

```powershell
PS > New-EncryptedPassword
Encrypting Password.
The Encrypted Password File was Created in the Folder: \\management.corp\shares\Kits\AESKeys\04-07-2020.07-57-24
PasswordFile :  \\management.corp\shares\Kits\AESKeys\04-07-2020.07-57-24\Password.txt
AESKey       :  \\management.corp\shares\Kits\AESKeys\04-07-2020.07-57-24\AES.key
```

**Example 2:**
- Optionally you can specify the folder, the password filename, and the key nane.

```powershell
New-EncryptedPassword -KeyFolder "C:\Keys" -PasswordFile "Password.txt" -AESKey "AES.key"
```


## Using an Encrypted Password File with PowerShell ##
---

The following code examples show how to use an encrypted password files in your PowerShell scripts.

#### Convert to Secure-String ####
(Use this for most PowerShell commands)

- Most PowerShell commands will require this command to convert the encrypted password to a "Secure-String".


```powershell
$PasswordFile = "C:\PDQScripts\Password.txt"
$AESKey = "C:\PDQScripts\AES.key"
$SecurePassword = Get-Content $PasswordFile | ConvertTo-SecureString -Key (Get-Content $AESKey)
```

#### Convert to Plain-Text String ####
(Use this for non PowerShell commands (i.e Choco))

- The following commands will convert the encrypted password to plain text.

- This is not usually required for PowerShell commands, but may be required for some 3rd party apps, like Chocolatey.

```powershell
$PasswordFile = "C:\PDQScripts\Password.txt"
$AESKey = "C:\PDQScripts\AES.key"
$SecurePassword = Get-Content $PasswordFile | ConvertTo-SecureString -Key (Get-Content $AESKey)
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordFile )
$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
```


**Example of a command that requires a pLain text password:**

```powershell
C:\ProgramData\chocolatey\bin\choco source add ... -u="srv-user" -p="$PlainPassword"
```


### Support ###

**Known Bugs**

None

**Report Bugs**

bugs.devops@Brennangroupllc.com