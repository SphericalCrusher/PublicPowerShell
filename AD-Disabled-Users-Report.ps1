<#
Script  :  AD-Disabled-Users-Report.ps1
Version :  1.0
Date    :  11/16/2015
Author: Jody Ingram
Pre-reqs: N/A
Notes: This will export a list of users that are currently disabled in Active Directory to a .csv file.
#>

import-module ActiveDirectory
$date = Get-Date -Format "MM_dd_yyyy_HH_mm"
$name = "Disabled_Accounts_Report_$date"
Search-ADAccount -AccountDisabled | Select-Object Name >> \\SERVER\FILEPATH\$name.csv
"The Report of disabled users has been placed in \\SERVER\FILEPATH" 
cmd /c pause | out-null
