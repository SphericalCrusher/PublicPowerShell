<#
Script  :  Azure-Conditional-Forwarder-OnPrem-DNS.ps1
Version :  1.0
Date    :  10/5/2023
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script creates a Conditional Forwarder to specific DNS servers. In this case, it's used to create Azure Conditional Forwarders to on-prem DNS servers to point to Azure Domain Controllers.
#>

# Define the On-Prem DNS Servers
$DNSserverGroup = "svdc1dc06.whs.int", "svdc1dc02.whs.int", "svdc1dc01.whs.int", "svdc1dc04.whs.int", "svdc2dc03.whs.int", "svdc2dc01.whs.int", "svdc2dc04.whs.int"

# Pulls in the details needed for creating the Conditional Forwarder
foreach ($DNSServer in $DNSserverGroup) {
    Write-Host "Configuring Conditional Forwarder on $DNSServer..." # Output for the current process
    
    $DNSDomain = "his.arc.azure.com" # Define the DNS domain(s)
    $ForwarderIPs = "10.244.0.165", "10.244.0.164", "10.245.0.165", "10.245.0.164"  # IPs of Azure Domain Controllers. Change if necessary.
    
    # Disables storing the Conditional Forwarder in Active Directory; also disables replication.
    $DisableADStore = $true
    
    # Creates the Conditional Forwarders
    try {
        Add-DnsServerConditionalForwarderZone -Name $DNSDomain -MasterServers $ForwarderIPs -ReplicationScope "Forest" -ZoneScope "Custom" -StoreInActiveDirectory:$DisableADStore -DnsServer $DNSServer
        Write-Host "Conditional Forwarder for $DNSDomain on $DNSServer has been configured successfully!"
    }
    catch {
        Write-Host "Error configuring Conditional Forwarder on $DNSServer. Please check the Event Logs."
    }
}
