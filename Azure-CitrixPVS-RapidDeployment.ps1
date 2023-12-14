<#
Script  :  Azure-CitrixPVS-RapidVMDeployment.ps1
Version :  1.0
Date    :  12/7/23
Author: Jody Ingram
Notes: This script deploys a Managed Disk in Azure using a Citrix BDM image configuration. It then takes the Managed Disk and deploys a VM from it.
#>

# Define the Variables
$rgName = "Resource-Group-Name"
$subscription = "Subscription_Name"
$diskName = "BOOTDISK-VMNAME"
$diskSize = 4  # Size is in GB
$location = "eastus" # Specify location, although it will read location from defined RG
$citrixBDM = "https://STORAGE-ACCOUNT-NAME.blob.core.windows.net/CONTAINER-NAME/CITRIX-BDM-NAME.vhd" # Location of Storage account, container, and blob for image
$storageSKU = "Premium_LRS"
$osType = "Windows"
$diskGen = "v2"
$publicNetworkAccess = "Disabled"
$vmName = "VM-NAME"
$vnetName = "VNET-NAME"
$snetName = "SNET-NAME"

# Authenticates with Azure
az login

az account set --subscription $subscription


# Creates a new Managed Disk using the .VHD image config in the Storage Blob
az disk create --resource-group $rgName --name $diskName --source $citrixBDM --os-type $osType --hyper-v-generation $diskGen --public-network-access $publicNetworkAccess --size-gb $diskSize --sku $storageSKU

# Gets the resource Id of the managed disk, for attaching the disk to the VM
$diskId = (az disk show --name $diskName --resource-group $rgName --query [id] -o tsv)

# Deploys VM by attaching existing managed disks as OS
az vm create --name $vmName --resource-group $rgName --attach-os-disk $diskId --os-type $osType --vnet-name $vnetName --subnet $snetName --public-ip-address '""' --nsg '""'

Write-Host "Virtual Machine '$vmName' has been created."
