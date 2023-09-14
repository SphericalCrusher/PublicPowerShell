<#
Script  :  ConfigMan-QueryHostnamePerUser.ps1
Version :  1.0
Date    :  7/28/21
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script imports a list of usernames and exports a list of computer names that those users are associated with.
Instructions: Run this script as a report query in your config manager: SCCM/MCM, Altiris, etc"
#>

# Imports a file containing a list of usernames, seperated by line
$InputFile = 'C:\Tools\UserList.txt' 

# Exports the file containing the requested information
$OutputFile = 'C:\Tools\OutputList.txt' 

Get-ADUser -Filter {Emailaddress -eq $InputFile} | Select-Object SamAccountName | Export-Csv $OutputFile -Append 


# Config Manager SQL Query 
SELECT  

                    cs.Name0 AS Hostname 

                    , cs.Manufacturer0 AS Manufacturer 

                    , cs.Model0 AS Model 

                    , net.DefaultIPGateway0 AS DefaultIPGateway 

                    , vru.Name0 AS PrimaryUser  

FROM  

                    v_GS_COMPUTER_SYSTEM AS cs 

                    INNER JOIN v_GS_NETWORK_ADAPTER_CONFIGURATION AS net ON net.ResourceID = cs.ResourceID  

                    INNER JOIN v_UsersPrimaryMachines AS upm ON upm.MachineID=cs.ResourceID  

                                         AND  

                                         upm.MachineID = cs.ResourceID 

                    LEFT JOIN v_R_User vru on upm.UserResourceID = vru.ResourceID 

                    LEFT JOIN v_R_System vrs on upm.MachineID = vrs.ResourceID 

WHERE  

                    vru.Name0 IS NOT NULL 

                    AND 

                    net.DefaultIPGateway0 IS NOT NULL 

ORDER BY 

                    Hostname 
