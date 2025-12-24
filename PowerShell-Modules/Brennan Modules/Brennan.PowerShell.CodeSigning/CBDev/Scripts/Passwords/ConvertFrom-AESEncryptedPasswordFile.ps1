function ConvertFrom-AESEncryptedPasswordFile {
    Param(
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
    ### Using 256-bit AES Encryption
    ###################################

    #### Get Password from 256 bit AES Encrypted File
    ### -----------------------------------------------------------------
    $Password = Get-Content $FilePath | ConvertTo-SecureString -Key (Get-Content $AESKey)

    Return $Password
}