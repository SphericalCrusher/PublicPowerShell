<#
Script  :  Azure-Arc-Machine-Automation-Report.ps1
Version :  1.0
Date    :  5/20/24
Author: Jody Ingram
Pre-reqs: Az.ConnectedMachine PowerShell Module
Notes: This script runs an Azure Arc report to pull a list of Machines, exports as a CSV and e-mails it.
#>

# Connect to Azure Account
Connect-AzAccount

# Imports the Azure Arc Connected Machine PowerShell Module
Import-Module Az.ConnectedMachine

# Gets all Azure Arc-enabled machines
$arcMachines = Get-AzConnectedMachine

# Gets the date for the report
$date = get-date


# Create a custom object array for the report
$reportData = @()
foreach ($machine in $arcMachines) {
    $reportObject = [PSCustomObject]@{
        'Name' = $machine.Name
        'Resource Group' = $machine.ResourceGroupName
        'Location' = $machine.Location
        'OS Type' = $machine.OsType
        'Status' = $machine.Status
        'Agent Version' = $machine.AgentVersion
    }
    $reportData += $reportObject
}

# Export the report to a CSV file
$reportFilePath = "C:\Tools\ArcMachineReport.csv"
$reportData | Export-Csv -Path $reportFilePath -NoTypeInformation

# Update Info, including SMTP Server.
Send-MailMessage -To 'jody.ingram@company.org' -Subject 'Azure Arc Weekly Machine Report' -Body "Attached is the Azure Arc Machine Report for the week of $date." -SmtpServer 'smtp.company.org' -From 'AzureReports@company.org' -Attachments 'C:\Tools\ArcMachineReport.csv'
