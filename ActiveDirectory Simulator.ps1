<#
.SYNOPSIS
    Active Directory & Local User Management Automation Script.
.DESCRIPTION
    This script automates common IT Help Desk user lifecycle management tasks:
    1. User Account Creation (Onboarding)
    2. Assigning User Security Groups
    3. Password Resets & Account Unlocking
    4. Account Disabling (Offboarding)
.NOTES
    Author: Mohamed Magdy
    Target Role: IT Help Desk / Systems Administrator
#>


# ----------------------------------------------------------------------
# 1. ONBOARDING: Create a New User Account
# ----------------------------------------------------------------------
Function New-CompanyUser {
    param (
        [string]$FirstName ,
        [string]$LastName ,
        [string]$Username ,
        [string]$OUPath 
    )

    Write-Host "[+] Creating new user: $FirstName $LastName ($Username)..." -ForegroundColor Green

    # Securely prompt for initial password (no hardcoded passwords)
    $SecurePassword = Read-Host -Prompt "Enter initial temporary password" -AsSecureString

    # Create the user in Active Directory
    New-ADUser -Name "$FirstName $LastName" `
               -GivenName $FirstName `
               -Surname $LastName `
               -AccountName $Username `
               -UserPrincipalName "$Username@company.local" `
               -Path $OUPath `
               -AccountPassword $SecurePassword `
               -Enabled $true `
               -ChangePasswordAtLogon $true

    Write-Host "[✓] Account $Username created successfully!" -ForegroundColor Cyan
}


# ----------------------------------------------------------------------
# 2. SECURITY: Assign User to Security Groups (Access Control)
# ----------------------------------------------------------------------
Function Add-UserToSecurityGroups {
    param (
        [string]$Username ,
        [string]$Group
    )

        Write-Host "[+] Adding $Username to group: $Group..." -ForegroundColor Yellow
        Add-ADGroupMember -Identity $Group -Members $Username
    
    Write-Host "[✓] Group permissions assigned." -ForegroundColor Cyan
}


# ----------------------------------------------------------------------
# 3. HELP DESK SUPPORT: Unlock Account & Reset Password
# ----------------------------------------------------------------------
Function Reset-UserAccount {
    param (
        [string]$Username 
    )

    Write-Host "[!] Unlocking account for $Username..." -ForegroundColor Yellow
    Unlock-ADAccount -Identity $Username

    Write-Host "[!] Prompting for new password reset..." -ForegroundColor Yellow
    $NewPassword = Read-Host -Prompt "Enter new password" -AsSecureString
    Set-ADAccountPassword -Identity $Username -NewPassword $NewPassword

    Write-Host "[✓] Account unlocked and password updated for $Username." -ForegroundColor Cyan
}


# ----------------------------------------------------------------------
# 4. OFFBOARDING: Disable Departing Employee Account
# ----------------------------------------------------------------------
Function Disable-CompanyUser {
    param (
        [string]$Username = "sconnor"
    )

    Write-Host "[!] Disabling account $Username for offboarding..." -ForegroundColor Red
    Disable-ADAccount -Identity $Username

    Write-Host "[✓] Account $Username has been disabled and secured." -ForegroundColor Cyan
}

# ----------------------------------------------------------------------
# Execution Instructions (Uncomment to test in a lab environment)
# ----------------------------------------------------------------------
# New-CompanyUser
# Add-UserToSecurityGroups
# Reset-UserAccount
# Disable-CompanyUser