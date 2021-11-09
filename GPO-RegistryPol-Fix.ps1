<#
Script: GPO-RegistryPol-Fix.ps1
Version: 1.0
Date: 11/8/2021
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script queries the Registry.pol file to see if it has not been modified longer than X days. If it has not, it will wipe it and pull a new one down using GPUpdate.
#>

# Defines the local machine name of the computer you are running this script on.
$MachineName="$env:ComputerName"

# Defines the Registry.pol Location.
$regpol= Get-ChildItem C:\Windows\System32\GroupPolicy\Machine\Registry.pol

# The below statement checks the age of the Registry.pol file. If it's older than the defined date, it will delete it and redownload a new one using GPUpdate /force.
# If it has been updated recently, it will report that it will not be modified.  

if ($regpol.LastWriteTime -lt (get-date).AddDays(-3)) #Change .AddDays(-3) if you want to increase the amount of days it checks the age of. Currently set to 3 days.
{ 
Write-Host "$MachineName The Registry.pol file has not been updated in over ("$regpol.LastWriteTime"). This script will force delete it and run a GPUpdate /force to pull a new one down."
Remove-Item $regpol
Invoke-WmiMethod –Name create –Path win32_process –ArgumentList "GPUpdate /target:Computer /force" –AsJob –ComputerName $MachineName | out-null
}

else
{
Write-Host "$MachineName The Registry.pol file has no issues and will not be modified. ("$regpol.LastWriteTime")"
} 