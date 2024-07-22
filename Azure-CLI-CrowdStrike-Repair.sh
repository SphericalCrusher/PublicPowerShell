# Script  :  Azure-CLI-CrowdStrike-Repair.sh
# Version :  1.0
# Date    :  7/20/2024
# Author: Jody Ingram
# Pre-reqs: Cloud Shell enabled VM
# Notes: This script is a quick fix for the CrowdStrike kernel update issue that is currently ongoing as of 7/20/2024.

az extension add -n vm-repair

$azureSubscription = "AZURE_SUBSCRIPTION_ID"
$resourcegroupName = "AZURE_RESOURCE_GROUP_NAME"
$vmName = "AZURE_VIRTUAL_MACHINE_NAME"

az login
az account set -s $azureSubscription

az vm repair create -g $resourcegroupName -n $vmName --unlock-encrypted-vm  --verbose --repair-username  LOCAL_ADMIN_ACCOUNT # Replace LOCAL_ADMIN_ACCOUNT with your built-in default SID-100 Administrator account for Windows OS
az vm repair run -g $resourcegroupName -n $vmName --run-id win-crowdstrike-fix-bootloop --run-on-repair --verbose # Runs the Microsoft mitigation back-end script
az vm repair restore -g $resourcegroupName -n $vmName --yes --verbose 
