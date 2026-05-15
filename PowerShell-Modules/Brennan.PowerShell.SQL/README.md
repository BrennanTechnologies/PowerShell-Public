# Brennan.SQL #
Brennan Technologies SQL Module


### Overview ###
This module provides functionality for integrating database connectivity with PowerShell.

### Requirements ###
Requires the Brennan.SQL module.

```powershell
Import-Brennan-SQL
or
RequiredModules = @('Brennan.SQL')
```

### Commands ###

##### Invoke-ADOcmd ####

Invoke a .NET ADO Database Connection & Runs a SQL Query.

### SQL Query Examples ###
Example 1:  Select  
    ```$Query = "Select * FROM [dbo].[$Table]" ```

Example 2:  Insert  
    ```$Query = "INSERT INTO [dbo].[$Table] ([FName],[LName]) VALUES ('$FName','$LName')" ```

Example 3:  Update  
    ```$Query = [string]" UPDATE [dbo].[$Table] SET [LName] = '$NewLName' WHERE ID ='$ID' " ```

Example 4:  Delete  
   ```$Query = [string]" DELETE FROM [dbo].[$Table] WHERE ID = '$ID' " ```  



### Author ###
Author: Chris Brennan

Date: 4-4-2020

Contact: cbrennan.brennantechnologies.com
