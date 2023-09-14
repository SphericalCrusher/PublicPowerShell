<#
Script  :  AD-FindLastComputerLogon.ps1
Version :  1.0
Date    :  6/1/22
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script creates a new PowerShell function which can be called to find the last user who logged into a computer.
Instructions: This script can be used by running the following command: .\AD-FindLastComputerLogon.ps1 -ComputerName "ComputerName"
#>

param (
    [string]$ComputerName
)

# Query Event Viewer Security logs for the Event ID 4624: "An account was successfully logged on"
$lastLogonEvent = Get-WinEvent -ComputerName $ComputerName -LogName Security -FilterXPath "*[System[(EventID=4624)]]" | 
    Sort-Object TimeCreated -Descending | Select-Object -First 1

# Pulls the user account from the most recent event log
$userAccount = $lastLogonEvent.Properties[5].Value

# Displays the last user account that logged into the device
Write-Host "The last user account to log into $ComputerName was: $userAccount"
