<#
Script  :  AD-Lockout-Notify.ps1
Version :  1.0
Date    :  1/16/2019
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script sends an e-mail when any Active Directory Account gets locked out. It can also automatically unlock a specific username. Run instructions are below.

INSTRUCTIONS:
-------------

To run this script, you will need to create a scheduled task:

Triggers: On an event - On event - Log: Security, Source: Microsoft Windows Security Auditing, EventID: 4740

Action: PowerShell.exe -nologo -File "C:\TEMP\AD-Lockout-Notify.ps1 (Location of this script)

Click the "Run with highest privileges" box.

#>

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
$AccountLockOutEvent = Get-EventLog -LogName "Security" -InstanceID 4740 -Newest 1
$LockedAccount = $($AccountLockOutEvent.ReplacementStrings[0])
$AccountLockOutEventTime = $AccountLockOutEvent.TimeGenerated
$AccountLockOutEventMessage = $AccountLockOutEvent.Message
$messageParameters = @{ 
Subject = "Account Locked Out: $LockedAccount" 
Body = "Account $LockedAccount was locked out on $AccountLockOutEventTime.`n`nEvent Details:`n`n$AccountLockOutEventMessage"
From = "LockOut@Email.com" 
To = "USER@Email.com" 
SmtpServer = "SMTP-SERVER-ADDRESS" 
} 
Send-MailMessage @messageParameters

# This can be used to automatically unlock a user in a worst case scenario

Unlock-ADAccount -identity USERNAME
