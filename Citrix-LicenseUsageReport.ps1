<#
Script  :  Citrix-LicenseUsageReport.ps1
Version :  1.0
Date    :  6/28/2021
Author: Jody Ingram
Pre-reqs: N/A
Notes: This scripts queries your Citrix license server, exports specified license data, and e-mails to recipients automatically. 
#>

# License Server to pull data from. 
$CitrixLicenseServer = “CitrixLicenseServer.DOMAIN.COM”

# If you wish to define a second Citrix License server, remove the comment # from the line below and add your server name.
#$CitrixLicenseServer2 = "SERVER2.DOMAIN.COM"

# Displays licenses from pools that have no usage. Currently set to off. Change to $true to enable
$ShowUnusedLicenses = $false

# If enabled, it will activate an alert for when you are within 10% of your remaining licenses
$UsageAlertThreshold = 0

# This section collects data from your defined $CitrixLicenseServer. 
$LicenseData = Get-WmiObject -class “Citrix_GT_License_Pool” -namespace “ROOT\CitrixLicensing” -ComputerName $CitrixLicenseServer
$CTXLicenseReport = @()
$LicenseData | select-object pld -unique | foreach {
$CurrentLicenseInfo = “” | Select-Object License, Count, Usage, PercentUsed
$CurrentLicenseInfo.License = $_.pld
$CurrentLicenseInfo.Count = ($LicenseData | where-object {$_.PLD -eq $CurrentLicenseInfo.License } | measure-object -property Count -sum).sum
$CurrentLicenseInfo.Usage = ($LicenseData | where-object {$_.PLD -eq $CurrentLicenseInfo.License } | measure-object -property InUseCount -sum).sum
$CurrentLicenseInfo.PercentUsed = [Math]::Round($CurrentLicenseInfo.Usage / $CurrentLicenseInfo.Count * 100,2)

# If you wish to query the license usage threshold (which is 10%), uncomment the below line out. For a cleaner e-mail, I have disabled this by default.
#$CurrentLicenseInfo.Alert = ($CurrentLicenseInfo.PercentUsed -gt $UsageAlertThreshold) 

if ($ShowUnusedLicenses -and $CurrentLicenseInfo.Usage -eq 0) {
$CTXLicenseReport += $CurrentLicenseInfo
} elseif ($CurrentLicenseInfo.Usage -ne 0) {
$CTXLicenseReport += $CurrentLicenseInfo
}
}

# This exports the Citrix License Usage file to a directory on your server. Please modify accordingly.
$CTXLicenseReport |Select-Object @{name=’Date-Time’;Expression={Get-Date} },License,Count,Usage,PercentUsed|ft -AutoSize|Out-File -Append C:\Tools\CitrixLicenseReport\$(get-date -uformat “CTX-LIC-Report-%Y-%m-%d”).txt

# If you use the Threshold Report from above, enable this. 
#$CTXLicenseReport | Format-Table -AutoSize | out-file “C:\Reports\CTX-LIC-Threshold-Report.txt”

# This sends an e-mail with the above data. Please modify to add in the sender, recipient, and smtp for e-mail as well as location to attach the report from.
Send-MailMessage -From “CitrixLicensing@company.com” -To “Recipient@company.com” -Subject “Citrix License Usage Report” -Body “Attached is a Citrix License Usage Report!” -SmtpServer “smtp.company.com” -Attachments “C:\Tools\CitrixLicenseReport\$(get-date -uformat “CTX-LIC-Report-%Y-%m-%d””).txt”
