<#
Script  :  SCCM-Query-No-Client.ps1
Version :  1.0
Date    :  11/16/2016
Author: Jody Ingram
Pre-reqs: SCCM PowerShell Module or run on a server with SCCM console installed.
Notes: Microsoft System Center Configuration Manager SCCM Client Detector. This will report on machines that do not have the SCCM client installed or is corrupt.
#>

# Import SCCM PowerShell Module. Change file path if install location is different.

Import-Module ‘C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1’
$CMSite=”$(Get-PSDrive –PSProvider CMSite)`:”
Set-Location $CMSite

# Start Query. Can also be ran directly in SCCM Device Collections.

select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.Client = "0"
# End Query
