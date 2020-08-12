# Use this Azure CLI script to automatically create a Windows VM in Azure. It also enables the Chef extension for DevOps Automation. 
# Customize as needed

$vm1 = "AzureVMName"
$svc = "ServiceName"
$username = 'AzureUserName'
$password = 'PASSWORD'

$img = "YourCustomVMImage.vhd"

$vmObj1 = New-AzureVM -Name $vm1 -InstanceSize Small -ImageName $img

$vmObj1 = Add-AzureProvisioning -VM $vmObj1 -Password $password -AdminUsername $username -Windows

# Enables Chef extension to Azure

$vmObj1 = Set-AzureVMChefExtension -VM $vmObj1 -ValidationPem "C:\users\username\msazurechef-validator.pem" -ClientRb
"C:\users\username\client.rb" -RunList "getting-started" -Windows

New-AzureVM -Location 'East US' -ServiceName $svc -VM $vmObj1
