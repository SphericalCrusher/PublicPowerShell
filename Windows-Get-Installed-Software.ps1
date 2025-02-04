<#
Script  :  Windows-Get-Installed-Software.ps1
Version :  1.0
Date    :  2/4/2025
Author: Jody Ingram; modules originally from PSGallery
Pre-reqs: PSExec.exe to run remotely
Notes: This script pulls a list of currently installed software on Windows machines.
#>

# Defines custom parameters used in script
Param(
    [Parameter(Position=0)]
    [Alias("ProgramName","PN")]
        [String[]]$Name,

    [Parameter(Position=1,ParameterSetName="UserDefined")]
        [String[]]$Property=@("DisplayName","DisplayVersion"),
    
    [Parameter(Position=2,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias("CN")]
        [String[]]$ComputerName=$env:COMPUTERNAME,

    [Parameter(Mandatory=$true,ParameterSetName="All")]
        [Switch]$All
)

Begin {
    $ProgCmd = {
        Param($prog,$props)
        $programs = @()
        $Is64Bit = (Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit"

        if ($prog) {
            if ($Is64Bit) {
                $tempProgs = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*
                foreach ($tp in $tempProgs) {
                    if ($tp.DisplayName -like $prog) {$programs += $tp}
                }
            }
            else {
                $tempProgs = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*
                foreach ($tp in $tempProgs) {
                    if ($tp.DisplayName -like $prog) {$programs += $tp}
                }
            }
        }
        else {
            if ($Is64Bit) {$programs += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*}
            else {$programs += Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*}
        }

        if ($props -eq "All" -or $props -contains "All" -or $All) {$programs}
        else {$programs | Select-Object -Property $props}
    }

    Function Choose-Invocation($ProgName, $CompName) {
        if ($CompName -eq "." -or $CompName -eq "localhost" -or $CompName -eq $env:COMPUTERNAME) {
            & $ProgCmd $ProgName $Property
        }
        else {Invoke-Command -ScriptBlock $ProgCmd -ArgumentList $ProgName,$Property -ComputerName $CompName}
    }

    Function Get-ProgramFromRegistry ($ProgName, $CompName) {
        if ($ProgName) {
            foreach ($n in $ProgName) {
                Choose-Invocation -ProgName $n -CompName $CompName
            }
        }
        else {
            Choose-Invocation -CompName $CompName
        }
    }
}

Process {
    foreach ($comp in $ComputerName) {
        Get-ProgramFromRegistry -ProgName $Name -CompName $comp
    }
}

# Exports a list to CSV

Export-Csv -Path X:\PATH\SoftwareReport.csv -NoTypeInformation
