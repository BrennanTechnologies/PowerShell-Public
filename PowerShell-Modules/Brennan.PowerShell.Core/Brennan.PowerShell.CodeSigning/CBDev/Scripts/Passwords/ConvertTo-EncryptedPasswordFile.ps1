function ConvertTo-EncryptedPasswordFile {
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
    )
    
    ###################################
    ### Windows Data Protection API
    ###################################

    ### Convert Secure Password to Text
    ### -----------------------------------------------------------------
    $Plain = (New-Object System.Management.AUtomation.PSCredential('ImNotNull',$Password)).`
    GetNetworkCredential().password
    #Write-Host "You entered: " $Plain

    ### Create Password File - Using Get-Credentials
    ### -----------------------------------------------------------------
    #(Get-Credential).Password | ConvertFrom-SecureString | Set-Content -Path $FileName

    ### Create Password File - Using System.Security.SecureString
    ### -----------------------------------------------------------------
    $Password | ConvertFrom-SecureString | Set-Content -Path $FilePath
}