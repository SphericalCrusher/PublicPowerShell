<#
Script  :  AD-Export-and-Import-Objects-in-CSV.ps1
Version :  1.0
Date    :  2/20/2023
Author: Jody Ingram
Pre-reqs: Active Directory Access
Notes: This script exports all AD objects in one AD group as a .csv and imports them into another AD group.
#>


# AD Group - Export and Import CSV

# This part of the script exports the AD objects in the specified AD group to the specified location.
Get-ADGroupmember -identity "AD Group" | select name | Export-Csv -path C:\LOCATION\ADUsers.csv


# This part of the script imports the contents of the .csv file to a specified AD group.
Import-Module ActiveDirectory
$Users = Import-Csv "C:\Location\ADUsers.csv"

$Group = "AD Group Name" # Change this to destination AD group

foreach ($User in $Users) {

    $ADUser = Get-aduser $user.samaccountname # Users are added via samaccountname AD attribute
    if($ADUser.enabled){ # Only adds enabled AD users. Keeps it clean.
        Add-ADGroupMember -Identity $group -Members $ADUser
    }
}
