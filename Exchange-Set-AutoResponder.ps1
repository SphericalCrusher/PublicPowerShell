<#
Script  :  Exchange-Set-AutoResponder.ps1
Version :  1.0
Date    :  11/16/2016
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script set a user's Outlook Auto Responder Remotely 
#>

# Run Add-PSSnapIn to add Exchange PowerShell Modules
Add-PSsnapin Microsoft.Exchange.Management.PowerShell.E2010

# Modify below configuration as needed.

Set-MailboxAutoReplyConfiguration -Identity USERNAME -AutoReplyState Enabled -InternalMessage "Internal auto-reply message." -ExternalMessage "External auto-reply message."
