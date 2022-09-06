<#
Script  :  Windows-Get-BuiltIn-Admin.ps1
Version :  1.0
Date    :  9/6/22
Author: Jody Ingram
Notes: Checks a list of servers for their built-in Windows Administrator accounts and reports back.
#>

# Imports VM Server List to CSV
$ServerList = Import-Csv -Path .\VMServerList.csv # Change path and file name as needed

function Get-SWLocalAdmin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $ServerList
    )
    Process {
        Foreach ($Computer in $ServerList) {
            Try {
                Add-Type -AssemblyName System.DirectoryServices.AccountManagement
                $PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine, $Computer)
                $UserPrincipal = New-Object System.DirectoryServices.AccountManagement.UserPrincipal($PrincipalContext)
                $Searcher = New-Object System.DirectoryServices.AccountManagement.PrincipalSearcher
                $Searcher.QueryFilter = $UserPrincipal
                $Searcher.FindAll() | Where-Object {$_.Sid -Like "*-500"}
            }
            Catch {
                Write-Warning -Message "$($_.Exception.Message)"
            }
        }
    }
}

# Displays the built-in Administrator account
(Get-LocalUser | Where-Object {$_.SID -like 'S-1-5-*-500'}).Name
