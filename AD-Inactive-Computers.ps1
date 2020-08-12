# Checks AD for any computers that have not had user logon for $DaysInactive. Automatically moves them to another AD container. 
# Modify as needed. -Jody Ingram

function SearchInactiveComputers{
import-module activedirectory 
$domain = "company.com" 
$DaysInactive = 90 
$time = (Get-Date).Adddays(-($DaysInactive))
$searchb = "OU=COMPANY OU,OU=COMPANY OU,DC=company,DC=com"
$computers = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp -SearchBase $searchb 

return $computers, $time
}
# This works. The $time is verified to be 90 days ago, and the logon stamps seem to be right.
# Example:
# $list = (SearchInactiveComputers)[0]  #<-- select only first property
# $sorted = $list | sort-object stamp

function MoveComputers($object){ #Takes List of computer objects
import-module activedirectory
$OU = "OU=Computers,OU=StaleAccounts,DC=Clinic,DC=Com"
Logging($object)
foreach ($computer in $object){
AppendHistory($computer)
$computer | Move-ADObject -TargetPath $OU 
Set-ADComputer -Identity $computer.SamAccountName -Enabled $false
}
}

function CleanList($object){ 

$array = @()
$group = "CN=NoAutoPurge,CN=Users,DC=company,DC=com"
foreach ($user in $object){
if ((Get-ADComputer $user.SamAccountName -Properties MemberOf | Select -ExpandProperty MemberOf) -contains $group){
Write-Host $user.SamAccountName "is a member of NoAutoPurge.. Skipping"
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
