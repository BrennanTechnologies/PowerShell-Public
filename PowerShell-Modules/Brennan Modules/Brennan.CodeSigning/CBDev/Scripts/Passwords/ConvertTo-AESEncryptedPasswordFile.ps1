function ConvertTo-AESEncryptedPasswordFile {
    Param(
        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FilePath = ".\Keys\Password.txt"
        ,`
        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AESKey = ".\Keys\AES.key"
    )

    ###################################
    ### Using 256-bit AES Encryption
    ###################################

    # Create 256-bit AES Encryption Key
    ### -----------------------------------------------------------------
    $Key = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
    $Key | Out-File $AESKey

    ### Create Password File - Using Get-Credentials
    ### -----------------------------------------------------------------
    (Get-Credential).Password | ConvertFrom-SecureString -Key (Get-Content $AESKey) | Set-Content -Path $FilePath
    
    ### Create Password File - Using System.Security.SecureString
    ### -----------------------------------------------------------------
    #$Password  | ConvertFrom-SecureString -Key (Get-Content $AESKey) | Set-Content -Path $FilePath
}