# This script will delete all files in the network folders older than <Specified Days>. The time can be adjusted below.

$Path = “LOCATION HERE”
$Daysback = “-1”
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item
