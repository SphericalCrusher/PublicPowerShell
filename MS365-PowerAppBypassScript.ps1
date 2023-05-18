<#
Script  : MS365-PowerAppBypassScript.ps1
Version : 1.0
Date    : 5/18/23
Author  : Jody Ingram
Pre-reqs: PowerShell 5.x
Notes   : This changes the consent bypass so that users are not required to authorize API connections made to the application.
#>

# This imports the PowerApps module into PowerShell. PowerShell must be ran as Administrator for this.
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -A


# Set the -EnvironmentName and -AppName parameters to the specific app you need to make this change to. 
Set-AdminPowerAppApisToBypassConsent -EnvironmentName "Default-ENV-Name" -AppName "Default-APP-Name"



<# Additonal Notes:
# This is to be ran if user does not have local admin rights: 
# Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
#> 
