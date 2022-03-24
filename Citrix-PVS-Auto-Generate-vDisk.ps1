<#
Script  :  Citrix-PVS-Auto-Generate-vDisk.ps1
Version :  1.0
Date    :  3/24/2022
Author: Jody Ingram
Notes: This script is used to automatically generate PVS images to be modified on the PVS Updater VM by an Engineer.
#>

#Citrix PowerShell Snap-Ins
asnp Citrix.*

# Defines Citrix Site Variables. Do not edit unless making a new script.

$StoreName = "STORE-NAME"
$SiteName = "SITE-NAME"
$PVSServerName = "Citrix-PVS-Server-Name"


# Defines the Citrix PVS vDISK name. This can be changed although it will update as a string. DO NOT ADD FILE EXTENSION.

$vDiskName = "vDISK-Name"
$PVSUpdater = "Enter The PVS Updater Device Name Here."

# Defines the name of the Device Collection for automation purposes. Change as needed. 

$DeviceCollection = "Device Collection"


# Creates the new vDisk to the Citrix PVS Store. Modify SizeinMB to your requirements.

Start-PVSCreateDisk -Name "$vDiskName" -Size "SizeinMB" -StoreName "$StoreName" -ServerName "$PVSServerName" -SiteName "$SiteName" -VHDX


# Adds new vDisk to PVS Store

New-PVSDiskLocator -Name "$vDiskName" -StoreName "$StoreName" -ServerName "$PVSServerName" -SiteName "$SiteName" -VHDX


# Adds details to the vDisk. Please customize as necessary; example - if you don't label company name or original file, just remove that parameter.

Set-PVSDisk -Name "$vDiskName" -StoreName "$StoreName" -SiteName "$SiteName" -longDescription "ADD THE DESCRIPTION FOR VDISK IMAGE HERE" -date "CHANGE THE DATE HERE" -author "Jody Ingram (Change as needed)" -title "Title of Author if necessary." -company "Company if necessary" -internalName "InternalName if necessary" -originalFile "Image being replaced if you use this process"


# Assigns the vDisk to a Device Collection

Add-PVSDiskLocatorToDevice -SiteName "$SiteName" -StoreName "$StoreName" -DiskLocatorName "$vDiskName" -CollectionName "$DeviceCollection" -RemoveExisting


# Assigns the vDisk to devices. Configure as needed.

Add-PVSDiskLocatorToDevice -SiteName "$SiteName" -StoreName "$StoreName" -DiskLocatorName "$vDiskName" -DeviceName "$PVSUpdater" -RemoveExisting


# Disables VMWare's Customer Experience Program Prompt

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false


# Powers on the VM using VMWare CLI

Start-VM -VM $PVSUpdater -RunAsync
