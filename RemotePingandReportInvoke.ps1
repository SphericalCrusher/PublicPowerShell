<#
Script  :  RemotePingandReportInvoke.ps1
Version :  1.0
Date    :  8/21/2024
Author: Jody Ingram
Pre-reqs: PingandReport.ps1
Notes: This script imports a list of machines and runs the "PingandReport.ps1" script against them. This could be useful if you need to verify connectivity from a list of VMs in different subnets to a list of Domain Controllers, etc.
#>

# Define your list of devices you wish to run "PingandReport.ps1" on.
$serverList = @(
    "Server1",
    "Server2",
    "Server3"
)

# Path to the PingandReport.ps1 script
$scriptPath = "C:\Temp\PingandReport.ps1"

# Iterate through each device in the list
foreach ($computer in $serverList) {
    # Invoke the PingandReport.ps1 script on the remote computer
    Invoke-Command -ComputerName $computer -FilePath $scriptPath 
}
