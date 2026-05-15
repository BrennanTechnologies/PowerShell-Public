function ConvertFrom-EncryptedPasswordFile {
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserName
        ,
        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FilePath = ".\Keys\Password.txt"
    )

    ###################################
    ### Windows Data Protection API
    ###################################

    ### Get Password from Encrypted File
    ### -----------------------------------------------------------------
    $Password   = Get-Content $FilePath | ConvertTo-SecureString 
    $Credential = New-Object System.Management.Automation.PsCredential($UserName,$Password)

    $Password = $Credential.Password | ConvertFrom-SecureString
    Return $Password
}