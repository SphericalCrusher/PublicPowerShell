<#
Script  :  Citrix-VDA-Profile-Cleanup.ps1
Version :  1.0
Date    :  5/4/2022
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script runs recursive cleanup against user profiles on VDA servers that are older than 30 days and purges them.
#>

$Path = “C:\Users”
$Daysback = “-30”
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item