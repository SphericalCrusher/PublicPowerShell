<#
Script  :  SCCM-WSUS-Cleanup.ps1
Version :  1.0
Date    :  11/16/2014
Author: Jody Ingram
Pre-reqs: SCCM PowerShell Module or run on a server with SCCM & WSUS installed.
Notes: This script is used to cleanup WSUS for SCCM. This cleans up expired and superseded Windows updates from the WSUS server.
#>

Write-Host -Foreground Red "Type WSUS-Cleanup to begin!"
function WSUS-Cleanup(){

try{

Invoke-WsusServerCleanup -CleanupObsoleteComputers -CleanupObsoleteUpdates -CleanupUnneededContentFiles -CompressUpdates -DeclineExpiredUpdates -DeclineSupersededUpdates -Verbose

}

catch [System.Data.Common.DbException]{

$global:TimeoutCount++

Write-Host -foreground Red "$TimeoutCount `tSQL TIMEOUT Exception. Retrying"

WSUS-Cleanup

}
catch [System.InvalidOperationException]{
$global:TimeoutCount++
Write-Host -foreground Red "$TimeoutCount `tEncountered InvalidOperationException. Retrying"
WSUS-Cleanup
}
catch [System.SystemException]{
Write-Host "Failed to run. Please verify you have run PowerShell as Administrator."
}

}

Write-Host -Foreground Red "Type WSUS-Cleanup to start!"
function WSUS-Cleanup(){

try{

Invoke-WsusServerCleanup -CleanupObsoleteComputers -CleanupObsoleteUpdates -CleanupUnneededContentFiles -CompressUpdates -DeclineExpiredUpdates -DeclineSupersededUpdates -Verbose

}

catch [System.Data.Common.DbException]{

$global:TimeoutCount++

Write-Host -foreground Red "$TimeoutCount `tSQL TIMEOUT Exception. Retrying"

WSUS-Cleanup

}
catch [System.InvalidOperationException]{
$global:TimeoutCount++
Write-Host -foreground Red "$TimeoutCount `tEncountered InvalidOperationException. Retrying"
WSUS-Cleanup
}
catch [System.SystemException]{
Write-Host "Failed to run. Please verify you have run PowerShell as Administrator."
}

}
