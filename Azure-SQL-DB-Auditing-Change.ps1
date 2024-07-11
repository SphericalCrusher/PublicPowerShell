<#
Script  :  Azure-SQL-DB-Auditing-Change.ps1
Version :  1.0
Date    :  7/11/24
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script pulls a list of Azure Databases from a SQL Server, exluding a select few, and enables SQL Database Auditing.
#>

# Configuration Settings. Adjust as needed. 
$resourceGroupName = "RG-Website-eus2"
$azureSQLServerName = "sql-eus2-website-01"
$excludedDBs = "db-Website-01", "db-Website-02", "db-Website-03"

# Pulls list of databases into variable
$azDatabases = Get-AzSqlServerDatabase -ResourceGroupName $resourceGroupName -ServerName $azureSQLServerName

# Excludes databases from list
$filteredDatabases = $azDatabases | Where-Object { $excludedDBs -notcontains $_.Name }

# Enables DB auditing only for select databases
$filteredDatabases | ForEach-Object {
    Set-AzSqlDatabaseAudit -ResourceGroupName $resourceGroupName -ServerName $azureSQLServerName -DatabaseName $_.Name
    Write-Output "Auditing enabled for database: $($_.Name)"
}
