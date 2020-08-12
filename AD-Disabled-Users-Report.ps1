# Disabled AD Users Report
# Exports a list of users currently disabled in Active Directory.

import-module ActiveDirectory
$date = Get-Date -Format "MM_dd_yyyy_HH_mm"
$name = "Disabled_Accounts_Report_$date"
Search-ADAccount -AccountDisabled | Select-Object Name >> \\SERVER\FILEPATH\$name.csv
"The Report of disabled user has been placed in \\SERVER\FILEPATH" 
cmd /c pause | out-null
