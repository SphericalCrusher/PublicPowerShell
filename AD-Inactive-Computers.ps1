<#
Script  :  AD-Inactive-Computers.ps1
Version :  1.0
Date    :  11/16/2015
Author: Jody Ingram
Pre-reqs: N/A
Notes: Checks AD for any computers that have not had user logon for $DaysInactive. Automatically moves them to another AD container.
# ----------------------------------------------------
#>

function SearchInactiveComputers{
import-module ActiveDirectory
$domain = "Company.com" 
$DaysInactive = 90 # Adjust inactive days if needed
$time = (Get-Date).Adddays(-($DaysInactive))
$searchb = "OU=COMPANY OU,OU=COMPANY OU,DC=Company,DC=Com"
$computers = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp -SearchBase $searchb 

return $computers, $time
}

function MoveComputers($object){
import-module ActiveDirectory
$OU = "OU=Computers,OU=Inactive Accounts,DC=Company,DC=Com" # Change AD OU location here
Logging($object)
foreach ($computer in $object){
AppendHistory($computer)
$computer | Move-ADObject -TargetPath $OU 
Set-ADComputer -Identity $computer.SamAccountName -Enabled $false
}
}

function CleanList($object){ 

$array = @()
$group = "CN=NoAutoPurge,CN=Users,DC=Company,DC=Com" # Change AD security group here
foreach ($user in $object){
if ((Get-ADComputer $user.SamAccountName -Properties MemberOf | Select -ExpandProperty MemberOf) -contains $group){
Write-Host $user.SamAccountName "is a member of NoAutoPurge.. Skipping User"
}else{
$array = $array + $user
}

}
return $array
}

function AppendHistory($computer)
{
$lastUsed = $computer | select-object @{Name="LastAuthentication"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} 
$infoString = "per " + $env:USERNAME + " on " + (get-date).DateTime + "  " + $lastUsed
$computer.DistinguishedName
Set-ADComputer -Identity $computer.SamAccountName -Add @{accountNameHistory =$computer.DistinguishedName}
Set-ADComputer -Identity $computer.SamAccountName -Description $infoString 
}
function Logging($object){
$date = get-date
$filename = "sc_" + $date.month + "-" + $date.day + "-" + $date.year + ".csv"
$logObject = $object | select-object Name,@{Name="LastAuthentication"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | Export-CSV $filename -notypeinformation
}
function MoveNumber($x){
if (!$x){ #if null
$comp = (SearchInactiveComputers)[0]
Write-Host "Moving all " + $comp.count + " computers"
MoveComputers $comp
} else {
$comp = (SearchInactiveComputers)[0] | Select-Object -First $x
Write-Host "Moving "  $comp.count  " computers"
MoveComputers $comp
}

}
MoveNumber
