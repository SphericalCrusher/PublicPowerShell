<#
Script  :  Windows-Data-Copy-Monitor.ps1
Version :  1.0
Date    :  5/2/2024
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script checks a Windows file share and reports back if there has been on new copy activity over a certain interval.
#>

# Change fileShare to the directory of your choice
$fileShare = "\\SERVERNAME\FILESHARE01\VOL1"

$thresholdMinutes = 15  # Adjust time for inactivity alert
$smtpServer = "smtp.company.org"  # Replace with your SMTP server
$fromAddress = "FileShare.Notice@company.org"  # Replace with your email address
$toAddress = "jody.ingram@company.org"  # Replace with recipient email address

while ($true) {
  $lastWriteTime = Get-ChildItem -Path $fileShare -Recurse -File | Select-Object LastWriteTime | Sort-Object LastWriteTime -Descending | Select-Object -First 1

  # Check if no new files for threshold time
  if ((Get-Date) -gt ($lastWriteTime.LastWriteTime.AddMinutes($thresholdMinutes))) {
    $body = "No new files written to '$fileShare' for $thresholdMinutes minutes. Data transfer to the folder might be incomplete."

    # Send email notification
    Send-MailMessage -From $fromAddress -To $toAddress -Subject "Potential Data Transfer Completion" -Body $body -SmtpServer $smtpServer

    Write-Host "Sent e-mail regarding Potential Data Transfer Completion."
    break
  }

  # Update last write time for next iteration
  Start-Sleep -Seconds 60  # Adjust wait time as needed
  $lastWriteTime = Get-ChildItem -Path $fileShare -Recurse -File | Select-Object LastWriteTime | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}
