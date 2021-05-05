# Export IP Addresses from Server List
# Jody Ingram


# Import the list of servers you have. You can do CSV or TXT files.
$servers = Get-Content C:\temp\powershell\ServerList.txt

# Exports your serverleted list of IPs
$ServerResults = "C:\Temp\powershell\ServerList_EXPORT.txt"

function get-dnsres{
foreach ($server in $servers) {
$IP = ([system.net.dns]::GetHostAddresses($server)) | select IPAddressToString

$status = "Processing system {0} of {1}: {2}" -f $counter,$servers.Count,$server

$counter++
$server |
select @{Name='serverName';Expression={$server}}, `
@{Name='ResolvesToIP';Expression={[system.net.dns]::GetHostAddresses($server)}}, `
@{Name='IPResolvesTo';Expression={([system.net.dns]::GetHostEntry($IP.IPAddressToString)).HostName}}, `
@{Name='PingResults'; Expression={ `
if ((get-wmiobject -query "SELECT * FROM Win32_PingStatus WHERE Address='$server'").statuscode -eq 0) {'Host Online'} `
elseif ((get-wmiobject -query "SELECT * FROM Win32_PingStatus WHERE Address='$server'").statuscode -eq 11003) {'Destination Host Unreachable'} `
elseif ((get-wmiobject -query "SELECT * FROM Win32_PingStatus WHERE Address='$server'").statuscode -eq 11010) {'Request Timed Out'} `
elseif ((get-wmiobject -query "SELECT * FROM Win32_PingStatus WHERE Address='$server'").statuscode -eq $Null) {'No DNS Record'}
}
}
}
}

get-dnsres | export-csv $ServerResults -notypeinformation
invoke-item $ServerResults