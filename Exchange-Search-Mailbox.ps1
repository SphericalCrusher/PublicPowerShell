<#
Script  :  Exchange-Search-Mailbox.ps1
Version :  1.0
Date    :  11/16/2016
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script searches all Exchange mailboxes for specific criteria and copies the e-mail out to another user's mailbox.

INSTRUCTIONS
-----------------------------------------------------------------------------------------------------------------------
Change Subject: "E-MAIL SUBJECT" to whatever Subject string you want to lookup. Add a comma ";" between subjects to use multiple at once. 
Changed "And Received" date to the before and after dates you want to search for
Target MailBox is where the e-mails will be copied to. Target Folder is which Inbox folder it copies to.
Log Level "Full" adds a complete list of search results. Can be turned off by changing "Full" to "Suppress"
-----------------------------------------------------------------------------------------------------------------------
#>

# Run Add-PSSnapIn to add Exchange PowerShell Modules
Add-PSsnapin Microsoft.Exchange.Management.PowerShell.E2010

# Customize the below script as you see fit to modify results.

Get-Mailbox | Search-Mailbox -SearchQuery {Subject:"E-MAIL SUBJECT 1; E-MAIL SUBJECT 2; E-MAIL SUBJECT 3" And Received:04/14/2019..04/15/2019} -targetmailbox "USERNAME" -targetfolder "Phish" -loglevel "full"

# Add  -DeleteContent  to the end to delete the items from user's mailbox
