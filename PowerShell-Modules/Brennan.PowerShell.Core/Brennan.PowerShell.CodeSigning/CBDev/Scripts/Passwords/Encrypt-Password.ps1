# https://www.altaro.com/msp-dojo/encrypt-password-powershell/


    ConvertTo-AESEncryptedPasswordFile



    ### Windows Data Protection API
    ### ----------------------------
    #ConvertTo-EncryptedPasswordFile -UserName cbrennan
    #ConvertFrom-EncryptedPasswordFile -UserName cbrennan

    ### 256-bit AES Encryption
    ### ----------------------------
    ConvertTo-AESEncryptedPasswordFile -UserName cbrennan
    ConvertFrom-AESEncryptedPasswordFile -UserName cbrennan

