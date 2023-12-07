<#
Script  :  Azure-CitrixPVS-RapidDeployment.ps1
Version :  1.0
Date    :  12/7/23
Author: Jody Ingram
Pre-reqs: 
Notes: This script deploys a Managed Disk in Azure using a Citrix BDM image configuration.
#>

# Creates the Managed Disk
$resourceGroup = "RESOURCE GROUP NAME"
$subscription = "SUBSCRIPTION NAME"
$diskName = "BOOTDISK-VM NAME"
$diskSize = 4  # Size is in GB
$location = "REGION"
$citrixBDM = "https://STORAGEACCOUNT.blob.core.windows.net/CONTAINER/Blob-CitrixBDM.vhd"
$storageSKU = "Premium_LRS"
$osType = "Windows"
$publicNetworkAccess = "Disabled"


# Authenticates with Azure
az login

# Changes to defined subscription
az account set --subscription $subscription

# Creates a new Managed Disk using the .VHD image config in the Storage Blob
az disk create --resource-group $resourceGroup --name $diskName --source $citrixBDM --os-type $osType --public-network-access $publicNetworkAccess --size-gb $diskSize --sku $storageSKU
