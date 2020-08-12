# Microsoft System Center Configuration Manager SMB Detection Query
#------------------------------------------------------------
# To change the application this queries, change %APPLICATION%
#
# This query checks against the Programs and Features list. 
#------------------------------------------------------------

# Import SCCM PowerShell Module. Change file path if install location is different.

Import-Module ‘C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1’
$CMSite=”$(Get-PSDrive –PSProvider CMSite)`:”
Set-Location $CMSite

select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like "%APPLICATION%"
