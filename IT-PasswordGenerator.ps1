<#
Script  :  IT-PasswordGenerator.ps1
Version :  1.0
Date    :  7/29/24
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script generates a random password to be used in Azure Key Vault, resource deployments, etc.
#>

# Set the length of the password
$passwordLength = 16

# Defines the characters that will be used in the password
$characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()'

# Generates the password
$password = -join ((1..$passwordLength) | ForEach-Object { $characters[(Get-Random -Minimum 0 -Maximum $characters.Length)] })

# Outputs the password
$password

# Copies the generated password to your clipboard automatically
$password | Set-Clipboard

Read-Host -Prompt "Your password has been generated and copied to your clipboard. Press Enter to close this window"
