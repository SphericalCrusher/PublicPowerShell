<#
Script  :  Citrix-Deploy-VM-Anywhere.ps1
Version :  1.0
Date    :  3/23/2022
Author: Jody Ingram
Notes: Citrix Automation Script for deploying a Citrix Virtual Machine to Specific Hypervisor
#>

# -----------------------------------------
# DEPLOY TO VMWARE
# -----------------------------------------

# Import PowerCLI Modules
Install-Module VMware.PowerCLI -Scope CurrentUser

# Disables PowerCLI untrusted cert and CEIP warnings 
Set-PowerCLIConfiguration -Scope AllUsers -ParticipateInCeip $false -InvalidCertificateAction Ignore

# Connect to your desired vCenter; you will be prompted for credentials
connect-viserver -server "https://vCenter.company.com"

# Creates new VM; modify resource properties as needed
New-VM -VM "CTX_TEMPLATE_VM_NAME" -Name "CTX-NEW-VM-NAME" -ResourcePool "CLUSTER_NAME" -VMHost "*" -Datastore "DATASTORE_NAME"


# -----------------------------------------
# DEPLOY TO AZURE
# -----------------------------------------

# Connect to Azure
Install-Module AzureAD
Connect-Azure AD -Credential (Get-Credential)

# Deploy using your resource management method such as ARM, Terraform,etc. The IaC can be called or added to this script.

# -----------------------------------------
# DEPLOY TO AWS
# -----------------------------------------

# Connect to AWS
# Note: You will need to generate an access key & secret key to safely store external credentials. This is done via the AWS console.
Install-Module -Name AWSPowerShell.NetCore
Set-AWSCredentails -AccessKey ACCESS_KEY -SecretKey SECRET_KEY -StoreAs PROFILE_NAME

# Deploy using your resource management method such as Terraform. The IaC can be called or added to this script.


# -----------------------------------------
# DEPLOY TO GCP 
# -----------------------------------------

# Connect to GCP
Install-Module GoogleCloud

# Authenticate with Google Cloud. Will launch your default browser to login with.
gcloud init

# Deploy using your resource management method such as Terraform. The IaC can be called or added to this script.
