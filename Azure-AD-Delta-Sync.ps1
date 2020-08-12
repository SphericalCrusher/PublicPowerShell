# Azure Active Directory Delta Sync for Hybrid Environments

# -------------------------------------------------
# Export the Azure Administrator Domain Credentials
CD "C:\TEMP"
Get-Credential | Export-Clixml "AADCreds.xml"

# Import the credentials into a variable
$cred = Import-Clixml "AADCreds.xml"

# Runs a PowerShell session on your Azure Domain Controller

Enter-PSSession -ComputerName Azure-DC-VM-NAME -credential $cred

# Runs Azure AD Delta Sync - This only synchronizes on-prim AD changes - not a full sync!

Start-AdSyncSyncCycle -PolicyType Delta
