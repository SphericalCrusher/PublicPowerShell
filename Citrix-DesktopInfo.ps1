<#
Script  :  Citrix-DesktopInfo.ps1
Version :  1.0
Date    :  8/20/2018
Author: Jody Ingram
Pre-reqs: DesktopInfo.exe and desktopinfo.ini 
Notes: This will deploy and run DesktopInfo.exe with a preference table you can modify. This works great in a Citrix or VDI environment.
#>

# Local machine file path for DesktopInfo
$DesktopInfoLocalPath = "C:\TEMP\DesktopInfo\"
# Path where DesktopInfo files are copied from
$DesktopInfoSourcePath = "\\SERVER\DesktopInfo\"
# DesktopInfo.exe => Default Name
$DesktopInfoExe = "DesktopInfo.exe"
# DesktopInfo.ini => Default Name
$DesktopInfoIniPath = "DesktopInfo.ini"

$DesktopInfoExePath = $DesktopInfoSourcePath + $DesktopInfoExe #DesktoInfo.exe Source Path
$DesktopInfoIniPath = $DesktopInfoSourcePath + $DesktopInfoIniPath #DesktoInfo.ini path
$DesktopInfoLocalExePath = $DesktopInfoLocalPath + $DesktopInfoExe #DesktoInfo.exe Local Path

#########################################################################################

# Check if the folder exists on the local machine, and if not, it will create it.

if (-NOT (Test-Path $DesktopInfoLocalPath)) {
    New-Item -ItemType Directory c:\TEMP\DesktopInfo #Create folder
    Copy-Item $DesktopInfoExePath -Destination $DesktopInfoLocalPath #Copy DesktopInfo.exe
    Copy-Item $DesktopInfoIniPath -Destination $DesktopInfoLocalPath #Copy DesktopInfo.ini
        
}
else {
    if (-NOT (Test-Path $DesktopInfoLocalExePath)) {
        Copy-Item $DesktopInfoExePath -Destination $DesktopInfoLocalPath #Copy DesktopInfo.exe
    }

        Copy-Item $DesktopInfoIniPath -Force -Destination $DesktopInfoLocalPath #Force Copy DesktopInfo.ini
}

$Command = $DesktopInfoLocalExePath
$Argument1 = "/ini=$DesktopInfoIniPath"

& $Command $Argument1
