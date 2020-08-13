<#
Script  :  Azure-AD-Delta-Sync.ps1
Version :  1.0
Date    :  11/16/2018
Author: Jody Ingram
Pre-reqs: N/A
Notes: Azure Active Directory Delta Sync for Hybrid Environments
#>

# Export the Azure Administrator Domain Credentials
CD "C:\TEMP" # Change location as needed
Get-Credential | Export-Clixml "AADCreds.xml"

# Import the credentials into a variable
$cred = Import-Clixml "AADCreds.xml"

# Runs a PowerShell session on your Azure Domain Controller

Enter-PSSession -ComputerName Azure-DC-VM-NAME -credential $cred #Change VM Server Name

# Runs Azure AD Delta Sync - This only synchronizes on-prim AD changes - not a full sync!

Start-AdSyncSyncCycle -PolicyType Delta # Change "Delta" to "Full" to do a Full Sync if needed
