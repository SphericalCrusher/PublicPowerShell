<#
Script  :  Windows-CrowdStrikeFix.ps1
Version :  1.0
Date    :  7/19/2024
Author: Jody Ingram
Notes: This script deletes the CrowdStrike driver file that is causing BSODs and reboots back into Normal Mode. The machine will already need to be in Safe Mode at this point.
#>

$csFilePath = "C:\Windows\System32\drivers\C-00000291*.sys"
$csFile = Get-ChildItem -Path $csFilePath -ErrorAction SilentlyContinue

foreach ($file in $csFile) {
    try {
        Remove-Item -Path $file.FullName -Force
        Write-Output "Deleted: $($file.FullName)"
    } catch {
        Write-Output "Failed to delete file: $($file.FullName)"
    }
}

# Removes Safe Mode boot value, so Windows boots to Normal Mode on restart
bcdedit /deletevalue {current} safeboot

# Restart Windows OS. Uncomment this if you wish to use this part.
# shutdown -r -t 0
