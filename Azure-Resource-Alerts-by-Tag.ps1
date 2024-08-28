<#
Script  :  Azure-Resource-Alerts-by-Tag.ps1
Version :  1.0
Date    :  8/24/24
Author  :  Jody Ingram
Notes: This script pulls the tag value of "Owner" from a specific resource and sends an email, notifying of potential changes by Microsoft.
#>


# Connect to Azure
Connect-AzAccount

# Pull in details for the Azure Resource. Please change to match correct resource. The most common case is a Virtual Machine migration, but in the event its another resource, I will eventually have a list of commands to use. 
$affectedResource = Get-AzVM -ResourceGroupName "RG-RESOURCE-GROUP-NAME" -Name "AZURE-RESOURCE-NAME"

# Get the recipient email from the resource tag value
$recipientEmail = $affectedResource.Tags["Owner"]


# E-mail notification system. Please adjust accordingly.
Send-MailMessage -To $recipientEmail -Subject "Automated Alert - This notification is for upcoming scheduled maintenance for your Azure Resource." -Body "DETAILS OF ALERT HERE" -smtpserver smtp.company.org -From AzureAlerts@company.org


# Test - Use this to modify and test sending the details without affecting the primary email sender of this script. Uncomment to use.
# Send-MailMessage -To jody.ingram@company.org -Subject "SUBJECT DETAILS" -Body "DETAILS OF ALERT HERE" -smtpserver smtp.company.org -From AzureAlerts@company.org
