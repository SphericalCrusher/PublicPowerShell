<#
Script  :  Azure-Quota-Usage-Search.ps1
Version :  1.0
Date    :  10/21/2024
Author: Jody Ingram
Notes: This script allows you to search your Azure account for specific SKUs, to see if they are in use.
#>

Connect-AzAccount -Subscription "SUBSCRIPTION_NAME" # Set your scription appropriately 

$AzureSKU = Get-AzVMUsage -Location <location>

$AzureQuota = $AzureSKU | Where-Object {$_.Name.Value -eq 'P1V3'} # Change the SKU as needed

if ($AzureQuota) {
    Write-Host "Quota for $AzureQuota exists in $($AzureQuota.Name.LocalizedValue)"
    $AzureQuota | Format-List  # If found, it displays the quota information in a list
} else {
    Write-Host "Quota for $AzureQuota is not found."
}
