<#
Script  :  AD-GetMostFrequentUser.ps1
Version :  1.0
Date    :  6/1/22
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script creates a new PowerShell function which can be called to display the user with the most logons to a computer.
Instructions: This script can be used by running the following command: .\AD-GetMostFrequentUser.ps1 -ComputerName "ComputerName"
#>

param (
    [string]$ComputerName
)

# Query Event Viewer Security logs for the Event ID 4624: "An account was successfully logged on"
$events = Get-WinEvent -ComputerName $ComputerName -LogName Security -FilterXPath "*[System[(EventID=4624)]]" -ErrorAction Stop

# Groups up the events by AccountName; used to count the occurrences
$userLogonCounts = $events | Group-Object -Property TimeCreated, @{Name='AccountName';Expression={($_.Properties[5].Value)}} | 
    Select-Object -Property Name, Count

# Sorts the user logon counts in descending order
$sortedUserLogonCounts = $userLogonCounts | Sort-Object -Property Count -Descending

# Displays the user with the most logons
$mostFrequentUser = $sortedUserLogonCounts | Select-Object -First 1
Write-Host "The user with the most logons on $ComputerName is $($mostFrequentUser.Name.AccountName) with $($mostFrequentUser.Count) logons."
