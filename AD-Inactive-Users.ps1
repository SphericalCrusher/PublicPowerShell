# Checks AD for any computers that have not had user logon for $DaysInactive. Automatically moves them to another AD container. 
# Modify as needed. -Jody Ingram

Import-Module ActiveDirectory 

# Variables pulled from a previous script and Microsoft Git Repo.

$TestRun = $false #If true, only pretend to change the objects
$NullStamps = $true #Do we count users who have never
$SearchOU = "OU=COMPANY OU,OU=COMPANY OU,DC=COMPANY,DC=com"
$DaysInactive = 90; #How many days before an account is considered Inactive?
$StaleOU = "OU=Users,OU=StaleAccounts,DC=Clinic,DC=Com"; #OU to place stale user accounts
$ExceptionGroup = "CN=EXCEPTIONS-GROUP,CN=Users,DC=clinic,DC=com" #Place users in this group, and they will excluded from the purge.
$EmailRecipients = "EMAILGROUP1@company.com","EMAILGROUP2@company.com"
$EmailTestRun = "TestUser@company.com" #Who to send report to in a test run
$date = (Get-Date)
$ExcelFile = ($pwd.Path.toString()) + "\su_" + $date.month + "-" + $date.day + "-" + $date.year + ".xlsx"



[string]$file = ($pwd.Path.toString()) + "\su_" + (Get-Date).ticks.toString() + ".log"
$Global:output = @()
$Version = "2.0"
$Modified = "12/15/2018"
$List_StandardPurge = [System.Collections.ArrayList]@()
$List_PurgeExceptions = [System.Collections.ArrayList]@()
$List_NullAccounts = [System.Collections.ArrayList]@()
#Basic Functions
function Get-InactiveUsers{
	$time = (Get-Date).AddDays(-($DaysInactive))
	$users = Get-ADUser -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp,LastLogonDate -SearchBase $SearchOU | Sort-Object -property LastLogonTimeStamp
	$nulls = Get-ADUser -Filter {-not (LastLogonTimeStamp -like "*") -and (WhenCreated -lt $time)  } -Properties LastLogonTimeStamp,WhenCreated -SearchBase $SearchOU | Sort-Object -property WhenCreated
	if($NullStamps){
		foreach($object in $nulls){
			if(Check-Exception($object) -eq $true){
				$null = $List_NullAccounts.Add(($object.SamAccountName,$object.WhenCreated)) 
			}
		}
		$users = $users + $nulls
	}
	$users = CleanList $users
	if(!$users){ #if no users found
		Write-Log "Exiting, No Stale User Accounts Found"
		Finalize-Log -Clean
		exit
	}
	Write-Log("Finalized User List")
	foreach($user in $users){
		Write-Log("Moving: `t" + $user.Name)
	}
	return $users

}
function Write-Log($string){
	Write-Host $string
	$Global:output += $string + "`r`n"
}
function Finalize-Log{
	param([Switch]$Clean)
	if($TestRun){
		$to = $EmailTestRun
	}else{
		$to = $EmailRecipients
	}
	New-Item $file -type file
	$stream = New-Object System.IO.StreamWriter $file
	$stream.WriteLine("Inactive Users Purge Tool $version")
	$stream.WriteLine("Devon Dieffenbach - $modified")
	foreach ($line in $Global:output){
		$stream.WriteLine($line)
	}
	$stream.Close()
	SendEmail($clean)
}

function SendEmail($clean){
	$subject = "Active Directory Stale User Purge v$version"
	if($List_StandardPurge.count -gt 0){
		$body += "<B>The following Accounts have been inactive for 90 days or more:</b><br><br>`n"
		$body += "<table>`n"
		$body += "<tr><th>Account Name</th><th>Last Accessed</th></tr>"
		foreach($item in $List_StandardPurge){
			$body += "<tr><td>" + $item[0] + "</td><td>" + $item[1] + "</td></tr>"
		}
		$body += "</table>`n<br>"
	}
	if($List_NullAccounts.count -gt 0){
		$body += "<B>The following Accounts have never been used:</b><br><br>`n"
		$body += "<table>`n"
		$body += "<tr><th>Account Name</th><th>Creation Date</th></tr>"
		foreach($item in $List_NullAccounts){
			$body += "<tr><td>" + $item[0] + "</td><td>" + $item[1] + "</td></tr>"
		}
		$body += "</table>`n<br>"
	}
	if($List_PurgeExceptions.count -gt 0){
		$body += "<B>The following have not been active in over 90 days, but are members of the Exception Group:</b><br><br>`n"
		$body += "<table>`n"
		$body += "<tr><th>Account Name</th><th>Last Accessed</th></tr>"
		foreach($item in $List_PurgeExceptions){
			$body += "<tr><td>" + $item[0] + "</td><td>" + $item[1] + "</td></tr>"
		}
        $body += "</table>`n<br>"
	}
	if ($Clean){
		Send-MailMessage -to $to -from "EMAIL@Company.com" -BodyAsHTML -body $body -subject $subject -smtpServer EXCHANGESERVER
	}else{
		Send-MailMessage -to $to -from "EMAIL@Company.com" -BodyAsHTML -body $body -subject $subject -smtpServer EXCHANGESERVER -Attachments $ExcelFile
	}

}
function CleanList($object){ 
	#Removes anybody who is a member of $ExceptionGroup from the list. 
	$array = @()
	foreach ($user in $object){
	if ((Get-ADUser $user.SamAccountName -Properties MemberOf | Select -ExpandProperty MemberOf) -contains $ExceptionGroup){
		$null = $List_PurgeExceptions.Add(($user.SamAccountName,$user.LastLogonDate))
		Write-Log ($user.SamAccountName + " is a member of NoAutoPurge.. Skipping")
	}else{
		if($user.LastLogonDate -ne $null){
			$null = $List_StandardPurge.Add(($user.SamAccountName,$user.LastLogonDate))
		}
		$array = $array + $user
	}
}
return $array
}
function Check-Exception($object){
	# if ((Get-ADUser $object.SamAccountName -Properties MemberOf | Select -ExpandProperty MemberOf) -contains $ExceptionGroup){
		# return $true
	# }

	return $true
}
function MoveUsers($object){ #Takes List of User objects
	foreach ($user in $object){
		AppendHistory($user)
		if($TestRun){
			$user | Move-ADObject -TargetPath $StaleOU -WhatIf
			Set-ADUser -Identity $user.SamAccountName -Enabled $false -WhatIf
		}else{
			$user | Move-ADObject -TargetPath $StaleOU 
			Set-ADUser -Identity $user.SamAccountName -Enabled $false
		}
	}
	$object | select-object Name,@{Name="LastAuthentication"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}},DistinguishedName | .\Export-XLSX.ps1 -path $ExcelFile
}
function AppendHistory($user)
{
	$lastUsed = $user | select-object @{Name="LastAuthentication"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} 
	$infoString = "per " + $env:USERNAME + " on " + (get-date).DateTime + "  " + $lastUsed
	Write-Log($user.DistinguishedName)
	if($TestRun){
		Set-ADUser -Identity $user.SamAccountName -Add @{accountNameHistory=$user.DistinguishedName} -WhatIf
		Set-ADUser -Identity $user.SamAccountName -Description $infoString -WhatIf
	}else{
		Set-ADUser -Identity $user.SamAccountName -Add @{accountNameHistory=$user.DistinguishedName}
		Set-ADUser -Identity $user.SamAccountName -Description $infoString
	}
}
function MoveObjects{
		#Write-Log ("Moving all Inactive Users")
		$AD_Object = (Get-InactiveUsers)
		#Write-Host $AD_Object
		Write-Log ("Moving " + $AD_Object.count + " Users")
		MoveUsers $AD_Object

}

MoveObjects
Finalize-Log
