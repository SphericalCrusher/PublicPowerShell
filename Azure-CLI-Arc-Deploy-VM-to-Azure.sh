# Script  :  Azure-SLI-Deploy-VM-via-ARC.sh
# Version :  1.0
# Date    :  5/1/2021
# Author: Jody Ingram
# Pre-reqs: N/A
# Notes: Use this Azure CLI script to automatically deploy a VM using Azure Arc.

New-AzResourceGroupDeployment `
  -ResourceGroupName 'Name of Resource Group' `
  -TemplateFile ~/AzureArcTemplateFileName.json `
  -TemplateParameterObject @{
    MachineName = 'Machine Name of ARC'
    Location = 'Location of ARM VM'
    WorkspaceId = 'Customer/Workspace ID'
    WorkspaceKey = 'Customer/Workspace Key'
  }
