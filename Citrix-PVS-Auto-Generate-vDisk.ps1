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

# START EDITING

# If creating or reconfiguring this script, only modify the below variables to customize to your Citrix environment and vDisk configurations.
# If you don't need to label all of the vDisk settings, just comment some out. Example: #$vDiskOriginalFile.

$StoreName = "STORE-NAME"
$SiteName = "SITE-NAME"
$PVSServerName = "Citrix-PVS-Server-Name"
$vDiskName = "vDISK-Name" # Defines the Citrix PVS vDISK name. DO NOT ADD FILE EXTENSION.
$PVSUpdater = "Enter The PVS Updater Device Name Here."
$DeviceCollection = "Device Collection" # Defines the name of the Device Collection for automation purposes. Change as needed. 

#vDisk Labels 
$vDiskSize = "Size-In-MB" # Enter the size in MB
$vDiskDescription = "ADD THE DESCRIPTION FOR VDISK IMAGE HERE"
$vDiskDate = "Date" # Date Format Example: 3/24/2022 11:16:19 AM
$vDiskAuthor = "Author Name"
$vDiskTitle = "Title"
$vDiskCompany = "Company Name"
$vDiskInternalName = "Internal Name"
$vDiskOriginalFile = "Original File Name"

# END EDITING 


# Creates the new vDisk to the Citrix PVS Store. Modify SizeinMB to your requirements.

Start-PVSCreateDisk -Name "$vDiskName" -Size "$vDiskSize" -StoreName "$StoreName" -ServerName "$PVSServerName" -SiteName "$SiteName" -VHDX


# Adds new vDisk to PVS Store

New-PVSDiskLocator -Name "$vDiskName" -StoreName "$StoreName" -ServerName "$PVSServerName" -SiteName "$SiteName" -VHDX


# Adds details to the vDisk. Please customize as necessary; example - if you don't label company name or original file, just remove that parameter.

Set-PVSDisk -Name "$vDiskName" -StoreName "$StoreName" -SiteName "$SiteName" -longDescription "$vDiskDescription" -date "$vDiskDate" -author "$vDiskAuthor" -title "$vDiskTitle" -company "$vDiskCompany" -internalName "$vDiskInternalName" -originalFile "$vDiskOriginalFile"


# Assigns the vDisk to a Device Collection

Add-PVSDiskLocatorToDevice -SiteName "$SiteName" -StoreName "$StoreName" -DiskLocatorName "$vDiskName" -CollectionName "$DeviceCollection" -RemoveExisting


# Assigns the vDisk to devices. Configure as needed.

Add-PVSDiskLocatorToDevice -SiteName "$SiteName" -StoreName "$StoreName" -DiskLocatorName "$vDiskName" -DeviceName "$PVSUpdater" -RemoveExisting


# Disables VMWare's Customer Experience Program Prompt

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false


# Powers on the VM using VMWare CLI

Start-VM -VM $PVSUpdater -RunAsync
