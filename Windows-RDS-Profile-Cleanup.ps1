<#
Script  :  Windows-RDS-Profile-Cleanup.ps1
Version :  1.0
Date    :  1/12/23
Author: Jody Ingram
Notes: This script automatically does a recursive cleanup of older Windows or Citrix user profiles on the Citrix profile servers, local VDAs, or C:\Users directory of the machine.
#>

$ErrorActionPreference= 'silentlycontinue'
$Users = Get-WmiObject -Class Win32_UserProfile
$IgnoreList = "LocalAdmin", "Default", "Public"

:OuterLoop
foreach ($User in $Users) {
    foreach ($name in $IgnoreList) {
        if ($User.localpath -like "*\$name") {
            continue OuterLoop
        }
    }

    $User.Delete()
}
