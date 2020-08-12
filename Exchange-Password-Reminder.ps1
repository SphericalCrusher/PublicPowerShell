<#
This is a PowerShell script used to send out Password Reminder e-mails across a company. This has parameters from Robert Pearman's repo.

# Launch Code: PasswordReminder.ps1 -smtpServer SERVER_ADDRESS -expireInDays 14 -from "Service Desk <ServiceDesk@Email.com>" 
# Test Code: PasswordReminder.ps1 -smtpServer SERVER_ADDRESS -expireInDays 14 -from "Service Desk <ServiceDesk@Email.com>" -Logging -LogPath "C:\Exchange\PWD_Logs" -testing -testRecipient superadmin@email.com
#>

param(
    [Parameter(Mandatory=$True,Position=0)]
    [ValidateNotNull()]
    [string]$smtpServer,
    [Parameter(Mandatory=$True,Position=1)]
    [ValidateNotNull()]
    [int]$expireInDays,
    [Parameter(Mandatory=$True,Position=2)]
    [ValidateNotNull()]
    [string]$from,
    [Parameter(Position=3)]
    [switch]$logging,
    # Defines the path for log files
    [Parameter(Position=4)]
    [string]$logPath,
    # Parameter that controls test mode
    [Parameter(Position=5)]
    [switch]$testing,
    [Parameter(Position=6)]
    [string]$testRecipient,
    [Parameter(Position=7)]
    [switch]$status,
    # Defines storage of log files
    [Parameter(Position=8)]
    [string]$reportto
)
#######################################################################
$start = [datetime]::Now
$midnight = $start.Date.AddDays(1)
$timeToMidnight = New-TimeSpan -Start $start -end $midnight.Date
$midnight2 = $start.Date.AddDays(2)
$timeToMidnight2 = New-TimeSpan -Start $start -end $midnight2.Date
# System Settings
$textEncoding = [System.Text.Encoding]::UTF8
$today = $start
# End System Settings

# Uses the ActiveDirectory module from RSAT to import AD user groups
Import-Module ActiveDirectory
$padVal = "20"
Write-Output "Script Loaded"
Write-Output "*** Settings Summary ***"
$smtpServerLabel = "SMTP Server".PadRight($padVal," ")
$expireInDaysLabel = "Expire in Days".PadRight($padVal," ")
$fromLabel = "From".PadRight($padVal," ")
$testLabel = "Testing".PadRight($padVal," ")
$testRecipientLabel = "Test Recipient".PadRight($padVal," ")
$logLabel = "Logging".PadRight($padVal," ")
$logPathLabel = "Log Path".PadRight($padVal," ")
$reportToLabel = "Report Recipient".PadRight($padVal," ")
# Testing is enabled during the launcher to run this script
if($testing)
{
    if(($testRecipient) -eq $null)
    {
        Write-Output "No Test Recipient Specified"
        Exit
    }
}
if($logging)
{
    if(($logPath) -eq $null)
    {
        $logPath = $PSScriptRoot
    }
}
Write-Output "$smtpServerLabel : $smtpServer"
Write-Output "$expireInDaysLabel : $expireInDays"
Write-Output "$fromLabel : $from"
Write-Output "$logLabel : $logging"
Write-Output "$logPathLabel : $logPath"
Write-Output "$testLabel : $testing"
Write-Output "$testRecipientLabel : $testRecipient"
Write-Output "$reportToLabel : $reportto"
Write-Output "*".PadRight(25,"*")
$users = get-aduser -filter {(Enabled -eq $true) -and (PasswordNeverExpires -eq $false)} -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress | where { $_.passwordexpired -eq $false }
# usersCount reports back the amount of users that will be getting notified
$usersCount = ($users | Measure-Object).Count
Write-Output "Found $usersCount User Objects"
# Uses the ADDefaultDomainPasswordPolicy attribute for password policy requirements
$defaultMaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy -ErrorAction Stop).MaxPasswordAge.Days 
Write-Output "Domain Default Password Age: $defaultMaxPasswordAge"
# Pulls in a list of AD users
$colUsers = @()
# Scans and processes each AD user for Password Expiration
Write-Output "Process User Objects"
foreach ($user in $users)
# Defined variables. The name variable is not currently being used; it was left as referencing givenName (first name) 
{
    $Name = $user.givenName
    $emailaddress = $user.emailaddress
    $passwordSetDate = $user.PasswordLastSet
    $samAccountName = $user.SamAccountName
    $pwdLastSet = $user.PasswordLastSet
    $maxPasswordAge = $defaultMaxPasswordAge
    $PasswordPol = (Get-AduserResultantPasswordPolicy $user) 
    if (($PasswordPol) -ne $null)
    {
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge.Days
    }
    # Create User Object
    $userObj = New-Object System.Object
    $expireson = $pwdLastSet.AddDays($maxPasswordAge)
    $daysToExpire = New-TimeSpan -Start $today -End $Expireson
    # Round Up or Down
    if(($daysToExpire.Days -eq "0") -and ($daysToExpire.TotalHours -le $timeToMidnight.TotalHours))
    {
        $userObj | Add-Member -Type NoteProperty -Name UserMessage -Value "today."
    }
    if(($daysToExpire.Days -eq "0") -and ($daysToExpire.TotalHours -gt $timeToMidnight.TotalHours) -or ($daysToExpire.Days -eq "1") -and ($daysToExpire.TotalHours -le $timeToMidnight2.TotalHours))
    {
        $userObj | Add-Member -Type NoteProperty -Name UserMessage -Value "tomorrow."
    }
    if(($daysToExpire.Days -ge "1") -and ($daysToExpire.TotalHours -gt $timeToMidnight2.TotalHours))
    {
        $days = $daysToExpire.TotalDays
        $days = [math]::Round($days)
        $userObj | Add-Member -Type NoteProperty -Name UserMessage -Value "in $days days."
    }
    $daysToExpire = [math]::Round($daysToExpire.TotalDays)
    $userObj | Add-Member -Type NoteProperty -Name UserName -Value $samAccountName
    $userObj | Add-Member -Type NoteProperty -Name Name -Value $Name
    $userObj | Add-Member -Type NoteProperty -Name EmailAddress -Value $emailAddress
    $userObj | Add-Member -Type NoteProperty -Name PasswordSet -Value $pwdLastSet
    $userObj | Add-Member -Type NoteProperty -Name DaysToExpire -Value $daysToExpire
    $userObj | Add-Member -Type NoteProperty -Name ExpiresOn -Value $expiresOn
    $colUsers += $userObj
}
$colUsersCount = ($colUsers | Measure-Object).Count
Write-Output "$colusersCount Users processed"
$notifyUsers = $colUsers | where { $_.DaysToExpire -le $expireInDays}
$notifiedUsers = @()
$notifyCount = ($notifyUsers | Measure-Object).Count
Write-Output "$notifyCount Users to notify"
foreach ($user in $notifyUsers)
{

# This section of the script controls the Password Reminder e-mail. Please modify as needed.

    $samAccountName = $user.UserName
    $emailAddress = $user.EmailAddress
    $name = $user.name
    $messageDays = $user.UserMessage
    # Password Reminder E-mail - Subject
    $subject="Your Password will expire $messageDays"
    # Password Reminder E-mail - Body
    $body ="
    <font face=""calibri"">
    <center><img src=""YOURLOGOPATH.PNG""></center>
    <p> Your Windows Password will expire $messageDays To change your password, please visit our <a href=""HTTPS://YOURSSPR"">Password Reset Portal</a>.<br>
    After changing your password, please don't forget to update it on your mobile devices as well.<br>
    <p>Thank you. <br> 
    </P>
    IT | <a href=""mailto:IT@Email.com""?Subject=Password Assistance"">ServiceDesk@Email.com</a> | 706-XXX-XXXX
    </font>"
       
    # Module for testing 
    if($testing)
    {
        $emailaddress = $testRecipient
    } # End test mode

  
    if(($emailaddress) -eq $null)
    {
        $emailaddress = $testRecipient    
    }
    $samLabel = $samAccountName.PadRight($padVal," ")
    if($status)
    {
        Write-Output "Sending Email : $samLabel : $emailAddress"
    }
    try
    {
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding -ErrorAction Stop
        $user | Add-Member -MemberType NoteProperty -Name SendMail -Value "OK"
    }
    catch
    {
        $errorMessage = $_.exception.Message
        if($status)
        {
           $errorMessage
        }
        $user | Add-Member -MemberType NoteProperty -Name SendMail -Value $errorMessage    
    }
    $notifiedUsers += $user
}
if($logging)
{
    # Generates and saves the log file, if enabled
    Write-Output "Creating Log File"
    $day = $today.Day
    $month = $today.Month
    $year = $today.Year
    $date = "$day-$month-$year"
    $logFileName = "$date-PasswordLog.csv"
    if(($logPath.EndsWith("\")))
    {
       $logPath = $logPath -Replace ".$"
    }
    $logFile = $logPath, $logFileName -join "\"
    Write-Output "Log Output: $logfile"
    $notifiedUsers | Export-CSV $logFile
    if($reportTo)
    {
        $reportSubject = "Password Expiration Report"
        $reportBody = "Password Expiration Report Attached"
        try {
            Send-Mailmessage -smtpServer $smtpServer -from $from -to $reportTo -subject $reportSubject -body $reportbody -bodyasHTML -priority High -Encoding $textEncoding -Attachments $logFile -ErrorAction Stop 
        }
        catch
        {
            $error = $_.Exception.Message
            Write-Output $error
        }
    }
}
$notifiedUsers | select UserName,Name,EmailAddress,PasswordSet,DaysToExpire,ExpiresOn | sort DaystoExpire | FT -autoSize
# Calculates the overall runtime of the script
$stop = [datetime]::Now
$runTime = New-TimeSpan $start $stop
Write-Output "Script Runtime: $runtime"
