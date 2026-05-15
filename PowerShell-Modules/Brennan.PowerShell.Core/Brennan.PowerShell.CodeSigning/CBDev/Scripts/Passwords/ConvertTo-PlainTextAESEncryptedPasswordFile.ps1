function ConvertTo-PlainTextAESEncryptedPasswordFile {
    $Password = ConvertFrom-AESEncryptedPasswordFile
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    Return $UnsecurePassword
}