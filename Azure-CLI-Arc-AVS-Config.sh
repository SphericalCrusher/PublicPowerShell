# Script  :  Azure-CLI-Arc-AVS-Config.sh
# Version :  N/A
# Date    :  3/28/22
# Author: Jody Ingram
# Pre-reqs: Azure Arc Agent on your AVS VM
# Notes: This script is used for updating the config_avs.json file prior to using Arc with VMWare.
# Please note; JSON is data only, but you can use CLI or shell to pull the script in for editing to truncate the comment code.


# Example. Please modify to match your environment

{ 
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", 
  "resourceGroup": "Resource-Group-Name", 
  "applianceControlPlaneIpAddress": "10.14.10.101", 
  "privateCloud": "Test-VM-Name", 
  "isStatic": true, 
  "staticIpNetworkDetails": { 
   "networkForApplianceVM": "Company-Arc-Network-Name", 
   "networkCIDRForApplianceVM": "10.14.10.1/24", 
   "k8sNodeIPPoolStart": "10.14.10.20", 
   "k8sNodeIPPoolEnd": "10.14.10.30", 
   "gatewayIPAddress": "10.14.10.1" 
  } 
}