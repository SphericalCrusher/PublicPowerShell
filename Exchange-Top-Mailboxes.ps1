# Top Exchange Mailboxes In Size


# Power-Shell Snapin for Exchange Management Shell

Add-PSsnapin Microsoft.Exchange.Management.PowerShell.E2010

# Pulls all Exchange Mailboxes in, sorts them Descending, and then displays them by 30 which can be altered. Exports to CSV.

Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object DisplayName,TotalItemSize -First 30 | export-csv C:\TEMP\Top30Mailboxes.csv
