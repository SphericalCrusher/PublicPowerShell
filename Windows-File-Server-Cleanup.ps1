<#
Script  :  Windows-File-Server-Cleanup.ps1
Version :  1.0
Date    :  11/16/2018
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script will delete all files in the network folders older than <Specified Days>. The time can be adjusted below.
#>

$Path = “LOCATION HERE”
$Daysback = “-1”
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item
