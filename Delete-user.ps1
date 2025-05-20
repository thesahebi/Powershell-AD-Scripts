# Prompt for the username (SamAccountName)
$username = Read-Host "Enter the Username of the user to disable"

# Set the search base to the "test" OU
$searchBase = "DC=example,DC=com"

# Define the "Disabled Users" OU
$disabledOU = "OU=Disabled Users,DC=example,DC=com"

# Search the user within the "test" OU and all sub-OUs
$user = Get-ADUser -Filter "SamAccountName -eq '$username'" -SearchBase $searchBase -SearchScope Subtree -Properties MemberOf

# Check if the user was found
if (-not $user) {
    Write-Host "❌ User '$username' not found under" -ForegroundColor Red
    exit
}

# Disable the user account
Disable-ADAccount -Identity $user
Write-Host "✅ User account '$username' has been disabled." -ForegroundColor Yellow

# Get all group memberships
$userGroups = $user.MemberOf

# Remove the user from all groups
if ($userGroups -and $userGroups.Count -gt 0) {
    foreach ($group in $userGroups) {
        Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
        Write-Host "➡️  Removed $username from group: $group"
    }
} else {
    Write-Host "ℹ️  User '$username' is not a member of any groups."
}

# Move the user to the Disabled Users OU
Move-ADObject -Identity $user -TargetPath $disabledOU
Write-Host "📁 User '$username' has been moved to: $disabledOU"

# Summary
Write-Host "`n✅ User '$username' has been successfully disabled, removed from groups, and moved to the Disabled Users OU." -ForegroundColor Green
