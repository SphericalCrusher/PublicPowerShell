<#
Script  :  AD-SearchForCustomAttribute.ps1
Version :  1.0
Date    :  3/5/2024
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script searches Active Directory for a custom attribute, returns the values, and exports it to CSV.
#>

# Imports the Active Directory module
Import-Module ActiveDirectory

# Define the attribute you want to search for (e.g., "Manager")
$attributeToSearch = "Manager"

# Define the value of the attribute you are searching for (e.g., the manager's distinguished name)
$valueToSearch = "CN=<USERNAME>,OU=People,OU=Accounts,DC=company,DC=org"

# Search Active Directory for users with the specified attribute and value
$usersWithAttribute = Get-ADUser -Filter "$attributeToSearch -eq '$valueToSearch'" -Properties *

# Display the results into the PowerShell session. Uncomment if you want this available.
# $usersWithAttribute | export-csv 

# Exports the results to a CSV file
$exportPath = "C:\Temp\UsersWithCustomAttribute.csv"
$usersWithAttribute | Select-Object SamAccountName, Name, GivenName, Surname, EmailAddress | Export-Csv -Path $exportPath -NoTypeInformation

Write-Host "Custom Search Complete! Results saved to: $exportPath"
