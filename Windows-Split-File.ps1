<#
Script  :  Windows-Split-File.ps1
Version :  1.0
Date    :  2/6/2025
Author: Jody Ingram
Pre-reqs: PowerShell
Notes: This script splits an .html file or another text file into multiple files, to reduce the overall file size for viewing.
#>

# Install PowerShell Module FileSplitter
Install-Module -name FileSplitter

$filePath = "C:\Users\USERNAME\Desktop\FilePath.html" # Change to the correct file path location of the file you wish to split up
$destinationFolder = "C:\Users\USERNAME\Desktop\EXPORT" # Change to where you want the files to be exported to
$partSize = 10MB # Adjust as needed

Split-File -Path $filePath -PartSizeBytes $partSize -DestinationFolder $destinationFolder
