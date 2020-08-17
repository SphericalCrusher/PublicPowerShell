<#
Script  :  Exchange-Top-Mailboxes.ps1
Version :  1.0
Date    :  11/16/2016
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script reports the top Exchange mailboxes in size
#>

# Power-Shell Snapin for Exchange Management Shell

Add-PSsnapin Microsoft.Exchange.Management.PowerShell.E2010

# Pulls all Exchange Mailboxes in, sorts them Descending, and then displays them by 30 which can be altered. Exports to CSV.

Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object DisplayName,TotalItemSize -First 30 | export-csv C:\TEMP\Top30Mailboxes.csv
