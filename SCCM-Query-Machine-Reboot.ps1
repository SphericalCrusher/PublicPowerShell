<#
Script  :  SCCM-Query-Machine-Reboot.ps1
Version :  1.0
Date    :  11/16/2016
Author: Jody Ingram
Pre-reqs: SCCM PowerShell Module or run on a server with SCCM console installed.
Notes: Microsoft System Center Configuration Manager Reboot Query. This will report on machines that require a restart after updates were successfully installed.
#>

# Import SCCM PowerShell Module. Change file path if install location is different.

Import-Module ‘C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1’
$CMSite=”$(Get-PSDrive –PSProvider CMSite)`:”
Set-Location $CMSite

# Start Query. Can also be ran directly in SCCM Device Collections. 

select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,
 SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,
 SMS_R_SYSTEM.Client from SMS_R_System join sms_combineddeviceresources on
 sms_combineddeviceresources.resourceid = sms_r_system.resourceid
 where sms_combineddeviceresources.clientstate != 0
# End Query
