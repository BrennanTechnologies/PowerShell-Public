# New-EncryptedPassword #

### Description ###
Create an encrypted password for use in PowerShell scripts.

* This cmdlet generates a 256-bit AES Encrypted Key Pair.

### Requirements ###
Requires the Brennan-ScriptSigning module.

```powershell
Import-Brennan-ScriptSigning
or
RequiredModules = @('Brennan-ScriptSigning')
```

### Syntax ###
```powershell
New-EncryptedPassword
    [-KeyFolder <String>]
    [-PasswordFile <String>]
    [-AESKey <String>]
```
 [ ] = Optional Parameter

**Example 1:**

* You do not need to enter any parameters.
* You will be prompted to enter the password that will be encrypted.

```powershell
New-EncryptedPassword
```
**Example 2:**

Optional Parameters:

* Optionally, you can specify the output folder for the key pair, and the name of the key files.

```powershell
New-EncryptedPassword -KeyFolder $myFolder -PasswordFile $myPassswordFile -AESKey $myAESKey
```

### Output ###

 - By default, this cmdlet will create a key pair in the default directory shown below, with the current date/time appended to the folder name.
 - You can specify another destination folder by using the  `-KeyFolder ` parameter.

```powershell
PS > New-EncryptedPassword
Encrypting Password.
The Encrypted Password File was Created in the Folder: \\management.corp\shares\Kits\AESKeys\04-07-2020.07-57-24
PasswordFile :  \\management.corp\shares\Kits\AESKeys\04-07-2020.07-57-24\Password.txt
AESKey       :  \\management.corp\shares\Kits\AESKeys\04-07-2020.07-57-24\AES.key
```


### Parameters

##### -KeyFolder

The output folder for the new key pair.

Example:
`$KeyFolder = "\\management.corp\shares\Kits\AESKeys"`


##### -PasswordFile

File name for the encrypted password file.

Example:
` $PasswordFile = "Password.txt"`


##### -AESKey

File name for the AES Key file.

Example:
` $AESKey = "AES.key" `


### Author ###
Author: Chris Brennan

Date: 4-4-2020

### Support ###
**Known Bugs**

None

**Report Bugs**

bugs.devops@Brennangroupllc.com
