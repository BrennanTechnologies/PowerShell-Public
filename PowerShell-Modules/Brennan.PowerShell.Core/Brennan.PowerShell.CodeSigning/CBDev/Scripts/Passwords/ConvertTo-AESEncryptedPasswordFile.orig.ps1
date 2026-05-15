function ConvertTo-AESEncryptedPasswordFile.orig {
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserName
        ,
        [Parameter(Mandatory = $True)]
        [System.Security.SecureString]
        $Password
        ,
        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FilePath = ".\Keys\Password.txt"
        ,
        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AESKey = ".\Keys\AES.key"
    )

    ###################################
    ### 256-bit AES Encryption
    ###################################

    # Create 256-bit AES Encryption Key
    ### -----------------------------------------------------------------
    $Key = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
    $Key | out-file $AESKey

    ### Create Password File - Using Get-Credentials
    ### -----------------------------------------------------------------
    #(Get-Credential).Password | ConvertFrom-SecureString -Key (Get-Content $AESKey) | Set-Content -Path $FilePath
    
    ### Create Password File - Using System.Security.SecureString
    ### -----------------------------------------------------------------
    $Password  | ConvertFrom-SecureString -Key (Get-Content $AESKey) | Set-Content -Path $FilePath




}