<#
Script  :  AD-GetLoggedOnUser.ps1
Version :  1.0
Date    :  7/27/22
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script creates a new PowerShell function which can be called to display the active username per computer name per device.
#>

function Get-LoggedOnUser
 {
     [CmdletBinding()]
     param
     (
         [Parameter()]
         [ValidateScript({ Test-Connection -ComputerName $_ -Quiet -Count 1 })]
         [ValidateNotNullOrEmpty()]
         [string[]]$ComputerName = $env:COMPUTERNAME
     )
     foreach ($comp in $ComputerName)
     {
         $output = @{ 'ComputerName' = $comp }
         $output.UserName = (Get-WmiObject -Class win32_computersystem -ComputerName $comp).UserName
         [PSCustomObject]$output
     }
 }

 # Call the defined function above to display the ComputerName and the Username.
 Get-LoggedOnUser
