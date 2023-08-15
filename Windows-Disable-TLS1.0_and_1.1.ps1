<#
Script  :  Windows-Disable-TLS1.0_and_1.1.ps1
Version :  1.0
Date    :  8/15/2023
Author: Jody Ingram
Pre-reqs: Run the PowerShell Terminal as Administrator
Notes: This script creates or modifies registry keys in Windows to disable TLS 1.0 and TLS 1.2.
#>

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "You do not have Admin rights. `nPlease open PowerShell as Admin and run it again."
    Break
}

# Defines the protocol variable; in this case, TLS 1.0 and 1.1
$protocols = @("TLS 1.0", "TLS 1.1")

# Defines the SCHANNEL locations; in this case - both Client and Server
$locations = @("Client", "Server")

foreach ($protocol in $protocols) {
    foreach ($location in $locations) {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\$location"
        
        # Checks for the registry path; creates it if it does not exist
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force
        }

        # Disables the protocols as well as sets the "DisabledByDefault" key.
        New-ItemProperty -Path $regPath -Name "DisabledByDefault" -PropertyType "DWORD" -Value 1 -Force
        New-ItemProperty -Path $regPath -Name "Enabled" -PropertyType "DWORD" -Value 0 -Force
    }
}

# If successful, this will write an output message and reboot the server in 15 seconds
Write-Output "TLS 1.0 and TLS 1.1 have been disabled. This script will now reboot the server in 15 seconds."
Restart-Computer –delay 15
