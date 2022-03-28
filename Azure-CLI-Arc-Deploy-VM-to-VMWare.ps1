<#
Script: Azure-CLI-Arc-Deploy-VM-to-VMWare.sh
Version: 1.0
Date: 3/28/2021
Author: Jody Ingram
Pre-reqs: VMWare vSphere CLI 6.7+, VMWare VM Template, and a completed config_avs.json configuration.
Notes: Use this Azure CLI PowerShell script to automatically deploy a VM using Azure Arc to your VMWare Environment. This service is called Azure VMWare Solution (AVS). 
#>


# Clones the Azure Arc repo from Github into the script

git clone https://github.com/microsoft/azure_arc.git


# Bypass execution policy unless signed

Set-ExecutionPolicy -Scope Process -ExecutionPolicy ByPass; .\Azure-CLI-Arc-Deploy-VM-to-VMWare.ps1 -Operation onboard -FilePath {config-json-path}


# Provider Registration features

az provider register --namespace 'Microsoft.ConnectedVMwarevSphere'
az provider register --namespace 'Microsoft.ExtendedLocation'
az provider register --namespace 'Microsoft.KubernetesConfiguration'
az provider register --namespace 'Microsoft.ResourceConnector'
az provider register --namespace 'Microsoft.AVS'
az provider register --namespace 'Microsoft.HybridCompute'
az provider register --namespace 'Microsoft.GuestConfiguration'


# Verifies your subscription is enabled for AVS

az feature show --name AzureArcForAVS --namespace Microsoft.AVS


# Connects to your vCenter Server

Connect-VIServer -Server jody.vcenter.com


# ***************************** 
# PART 1 - SERVICE PRINCIPAL
# ***************************** 

# Creates Service Principal for a resource group. Please customize as necessary. If you intend to generate a self-signed cert upon creation, add: --create-cert 

az ad sp create-for-rbac --name Resource-Group-Name \
                         --role reader \
                         --scopes /subscriptions/mySubscriptionID/resourceGroups/Resource-Group-Name
                          --cert @/path/to/CertName.pem
                          --keyvault KeyVaultName


# NOTE: If you intend to run this script with an existing Service Principal, remove the comment and use the following:
# az ad sp list --show-mine --query "[].{id:appId, tenant:appOwnerTenantId}"


# ***************************** 
# PART 2 - VM DEPLOYMENT
# ***************************** 

# This part will use an existing VM Template to deploy a VM to your vCenter. Please customize and add parameters as necessary.

New-VM -Template 'Your Existing VM Template Name' -Name 'VM Name' -Datastore 'Your Datastore' -NetworkName 'Network Name' -Notes "Labeling Is Important" -Portgroup "vSwitch Port Group" -ReplicationGroup "Replication Group" -ResourcePool 'Resource Container Pool' -VMHost 'VM Host Name'

# Customization Assistance If Needed: https://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.core/commands/new-vm/#Template


# ***************************** 
# PART 3 - AGENT INSTALL
# ***************************** 

# Downloads and installs the Azure Connected Machine Agent to your newly provisoned VM.


# Installs VMWare PowerCLI Modules

Install-Module VMware.PowerCLI -Force


# Downloads the Azure Connected Machine Agent

Invoke-WebRequest -Uri https://aka.ms/AzureConnectedMachineAgent -OutFile AzureConnectedMachineAgent.msi


# Runs the package installer for the Azure Connected Machine Agent

msiexec /i AzureConnectedMachineAgent.msi /l*v installationlog.txt /qn | Out-String

& "$env:ProgramFiles\AzureConnectedMachineAgent\azcmagent.exe" connect `
  --service-principal-id "Azure AD Service Principal ID" `
  --service-principal-secret "Super Secret Key" `
  --resource-group "Resource-Group=Name" `
  --tenant-id "Tenant ID Name" `
  --location "EastUS Or Please Modify" `
  --subscription-id "Subscription ID"

'@
