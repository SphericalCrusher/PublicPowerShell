<#
Script  :  AD-Search-and-Export-Computer-Objects.ps1
Version :  1.0
Date    :  5/20/24
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script searches AD for Computer Objects with a specific name and exports those to a CSV.
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the search base, this should be adjusted to your specific AD structure. This searches the whole AD domain.
$searchBase = "DC=Company,DC=org"

# Search for computer objects that start with 'VM-' and export to CSV. Change name parameter as needed for search filter.
Get-ADComputer -Filter 'Name -like "VM-*"' -SearchBase $searchBase -Properties * | Select-Object Name,DistinguishedName | Export-Csv -Path "C:\Temp\AzureTestVMs.csv" -NoTypeInformation
