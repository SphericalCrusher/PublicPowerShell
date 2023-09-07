<#
Script  :  Azure-Arc-Onboard.ps1
Version :  1.0
Date    :  9/7/23
Author: Jody Ingram
Pre-reqs: HTTPS (Port 443) to Azure services, local admin rights on the VM, private endpoint and link scope in Azure
Notes: This script downloads and installs the Azure Arc Hybrid Agent and connects it back to Azure Arc.
#>

try {
    $env:SUBSCRIPTION_ID = "Subscription ID";
    $env:RESOURCE_GROUP = "RG-ArcTest-01";
    $env:TENANT_ID = "Tenant ID";
    $env:LOCATION = "eastus";
    $env:AUTH_TYPE = "token";
    $env:CORRELATION_ID = "Azure Portal Correlation ID - Not Required";
    $env:CLOUD = "AzureCloud";
    

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;

    # This downloads the install package. This may be excluded if deployed directly from Altiris.
    Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1";

    # This installs the Azure Arc hybrid agent to the local VM
    & "$env:TEMP\install_windows_azcmagent.ps1";
    if ($LASTEXITCODE -ne 0) { exit 1; }

    # Runs the commmand to connect the VM to Azure Arc service
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --private-link-scope "/subscriptions/SUBSCRIPTION_ID/resourceGroups/RG-ArcTest-01/providers/Microsoft.HybridCompute/privateLinkScopes/PRIVATE-ENDPOINT-NAME" --tags "Application=Infrastructure,'Application Group'=Group,'Business Unit'=IT,'Application Tier'='Tier 0','Contact Group'=az-alerts-test,Environment=Dev,LOALevel=LOA4,Owner=username@company.com,Role=Arc" --correlation-id "$env:CORRELATION_ID";
}
catch {
    $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";correlationId="$env:CORRELATION_ID";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";};
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null;
    Write-Host  -ForegroundColor red $_.Exception;
}
