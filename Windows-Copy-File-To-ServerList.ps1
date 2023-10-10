<#
Script  :  Windows-Copy-File-To-ServerList.ps1
Version :  1.0
Date    :  10/10/2023
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script copies a file in a network share to a specific location across a list of servers.
#>

# Source File Location
$SourceFile = “\\NetworkFileShare\NetworkFolder\file.config”

# Server List
$ServerList = Import-Csv -Path "C:\Temp\ServerList.csv" # Change this to the location of your CSV file; make sure CSV file only has one server per line. No blank lines.

# Loops through each server in the list and copies the config file from $SourceFile to the $destinationPath location
foreach ($server in $ServerList) {
    $destinationPath = “\\$server\C$\Program Files (x86)\FOLDER” # Change to the directory on the server(s) you wish to copy to

    # Checks server connectivity before copying; if successful, copies file
    if (Test-Connection -ComputerName $server -Count 3 -Quiet) {
        Copy-Item -Path $SourceFile -Destination $destinationPath -Force
        Write-Host "The SourceFile has copied to $server successfully!"
    } else {
        Write-Host "Unable to reach $server. Skipping the file copy."
    }
}
