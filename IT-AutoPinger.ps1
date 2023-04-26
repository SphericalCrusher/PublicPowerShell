<#
Script  :  IT-AutoPinger.ps1
Version :  1.0
Date    :  7/1/2020
Author: Jody Ingram
Pre-reqs: N/A
Notes: Pings a list of machines and exports which are up and down to a CSV.
#>

$Output= @()
# Change MACHINELIST.txt to the list of machines you have
$names = Get-content "C:\Temp\MACHINELIST.txt"
foreach ($name in $names){
  if (Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue){
   $Output+= "$name,up"
   Write-Host "$Name,up"
  }
  else{
    $Output+= "$name,down"
    Write-Host "$Name,down"
  }
}
# Change this location to where you want your CSV export to go
$Output | Out-file "C:\Users\%username%\Desktop\MachineList.csv"
