<#
Script  :  Windows-Remotely-Install-Software.ps1
Version :  1.0
Date    :  6/21/2024
Author: Jody Ingram
Pre-reqs: N/A
Notes: Deploys a software package to remote machines silently
#>

$softwarePath = 'X:\Tools\softwarePackage.exe'  # Replace with the actual path to your software package
$serverListFile = 'X:\ServerList.txt' # Replace with the path to your server list file
$logPath = 'X:\DeploymentLog.txt'    # Replace with the desired log file path

# Read server list from file
$serverList = Get-Content $serverListFile

# Create log file
New-Item -Path $logPath -Force | Out-Null

# Deploy to each server
foreach ($server in $serverList) {
    $startTime = Get-Date

    try {
        # Copy the package to the remote server
        Copy-Item -Path $softwarePath -Destination "\\$server\c$\Temp\" -Force

        # Execute the installer silently
        Invoke-Command -ComputerName $server -ScriptBlock {
            Start-Process -FilePath "C:\Temp\softwarePackage.exe" -ArgumentList "/S" -Wait # Change softwarePackage.exe to the name of your software
        }

        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds

        Write-Output "$startTime: Deployment to $server completed successfully in $duration seconds" | Out-File -FilePath $logPath -Append
    }
    catch {
        Write-Output "$startTime: Error deploying to $server: $($_.Exception.Message)" | Out-File -FilePath $logPath -Append
    }
}
