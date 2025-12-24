# Configuring Execution Policies


## Overview
The behavior of signed scripts is determined by the Execution Policy settings and Scope.

| Execution Policy | Behavior                                                                     |
| ---------------- | ---------------------------------------------------------------------------- |
| Restricted       | No Script either local, remote, or downloaded can be executed on the system. |
| AllSigned        | All scripts that are run are required to be digitally signed.                |
| RemoteSigned     | All remote scripts (UNC) or downloaded need to be signed.                    |
| Unrestricted     | No signature for any type of script is required.                             |

### AllSigned
- **Only** allows signed scripts to be run.
- Hashed scripts are **enforced**. Changes made to the script require it to be resigned.
- The Code Signing Cert **must** be in the local machine certificate store.

### RemoteSigned
- All remote scripts (UNC), or downloaded need to be signed.
- Hashed scripts are **NOT** enforced.
- If using a Self Signed Cert, it **must** be in local machine certificate store.
- If using a 3rd Party Certificate Authority, the Signing Cert does **NOT** need to be in local machine certificate store.




## Default Client Settings

- By default the Windows 10 client Execution Policy is set to "Restricted".
- By default Windows Server Execution Policy is set to "RemoteSigned".


## Execution Policy Restrictions

| Level of Restriction | Execution Policy | Notes                                                                                                                                                                   |
| -------------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Highest              | Restricted       | Doesn't load configuration files or run scripts.  *** Default execution policy Windows client computers. ***                                                            |
|                      | AllSigned        | Requires that all scripts and configuration files are signed by a trusted publisher, including scripts written on the local computer.                                   |
|                      | RemoteSigned     | Requires that all scripts and configuration files downloaded from the Internet are signed by a trusted publisher. *** Default execution policy for Windows servers. *** |
|                      | Unrestricted     | Loads all configuration files and runs all scripts. If you run an unsigned script that was downloaded from the internet, you're prompted for permission before it runs. |
| Lowest               | ByPass           | Nothing is blocked and there are no warnings or prompts.                                                                                                                |
| System               | Undefined        | Removes an assigned execution policy from a scope that is not set by a Group Policy                                                                                     |
| System               | Default          | Sets the default execution policy. Restricted for Windows clients or RemoteSigned for Windows servers.                                                                  |


## Execution Policy Scope

| Order of Precedence | Scope         | Notes                                                                   |
| ------------------- | ------------- | ----------------------------------------------------------------------- |
| Highest             | MachinePolicy | Set in GPO. Set by a Group Policy for all users of the computer.        |
|                     | UserPolicy    | Set in GPO. Set by a Group Policy for the current user of the computer. |
|                     | Process       | Current Session. Affects only the current PowerShell session.           |
|                     | CurrentUser   | Affects only the current user.                                          |
| Lowest              | LocalMachine  | Default scope that affects all users of the computer.                   |



## Unblock-File
---
- The Unblock-File cmdlet unblocks scripts so they can run, but doesn't change the execution policy.

Example:
~~~
Unblock-File -Path .\Start-ActivityTracker.ps1
~~~

### Author ###
Author: Chris Brennan

Date: 4-4-2020

### Support ###
**Known Bugs**

None

**Report Bugs**

bugs.devops@Brennangroupllc.com


