# Prompt for user input

# Define a list of available OUs
$firstName = Read-Host "Enter First Name"
$lastName = Read-Host "Enter Last Name"
$username = Read-Host "Enter Username - without @ or domain name"
$passwordInput = Read-Host "Enter Password - Complix" -AsSecureString

# Convert the SecureString to a normal string for password handling (if necessary)
$password = $passwordInput

# Define other information for the user
$displayName = "$firstName $lastName"
$userPrincipalName = "$username@example.com"  # Logon name (UPN)

# if you have a few location and want user to be in one of them select the location
# Location selection menu
$stateOptions = @(
    "Illinois",
    "Wisconsin"
)

Write-Host "`nSelect the user's state/location from the list below:`n"
for ($i = 0; $i -lt $stateOptions.Count; $i++) {
    Write-Host "$($i + 1): $($stateOptions[$i])"
}

$stateChoice = Read-Host "Enter the number corresponding to the user's location"

if ($stateChoice -match '^\d+$' -and $stateChoice -ge 1 -and $stateChoice -le $stateOptions.Count) {
    $selectedLocation = $stateOptions[$stateChoice - 1]
    Write-Host "You selected: $selectedLocation"
} else {
    Write-Host "Invalid selection. Exiting script."
    exit
}

# Auto-fill address based on location
switch ($selectedLocation) {
    "Illinois" {
        $state = "IL"
        $streetAddress = "your address here"
        $city = "city"
        $postalCode = "1234"
        $country = "US"
    }
    "Wisconsin - DeForest" {
        $state = "WI"
        $streetAddress = "your address here"
        $city = "city"
        $postalCode = "123"
        $country = "US"
    }
    default {
        Write-Host "Location not recognized. Exiting."
        exit
    }
}

# Prompt for department and title
$department = Read-Host "Enter Department"
$title = Read-Host "Enter Title"
#$office = Read-Host "Enter Office Location"

# Predefined list of OUs
$ouList = @(
    "OU=test2,OU=example.com Users,DC=example.com,DC=com",
    "OU=test3,OU=example.comUsers,DC=example.com,DC=com",
    "OU=test4,OU=example.comUsers,DC=example.com,DC=com",                                   
    "OU=Test Users,OU=example.com Users,DC=example.com,DC=com"                                                                                                 
   
)

Write-Host "`nPlease choose an OU by entering a number:"
for ($i = 0; $i -lt $ouList.Length; $i++) {
    Write-Host "$($i + 1): $($ouList[$i])"
}

$selection = Read-Host "Enter the number corresponding to the OU"
if ($selection -ge 1 -and $selection -le $ouList.Count) {
    $selectedOU = $ouList[$selection - 1]
    Write-Host "You selected: $selectedOU"
} else {
    Write-Host "Invalid selection, exiting script."
    exit
}

# Create the new user in Active Directory
New-ADUser -SamAccountName $username `
           -UserPrincipalName $userPrincipalName `
           -Name $displayName `
           -GivenName $firstName `
           -Surname $lastName `
           -DisplayName $displayName `
           -EmailAddress $userPrincipalName `
           -AccountPassword $password `
           -PassThru `
           -Enabled $true `
           -Path $selectedOU `
           -StreetAddress $streetAddress `
           -City $city `
           -State $state `
           -PostalCode $postalCode `
           -Country $country `
           -Office $city `
           -Department $department `
           -Title $title `
           -ChangePasswordAtLogon $true

# Enable user
Enable-ADAccount -Identity $username

# Ask for Manager's email and assign
$managerEmail = Read-Host "Enter Manager's email address (UPN)"
$managerUser = Get-ADUser -Filter { UserPrincipalName -eq $managerEmail }
    if ($managerUser) {
        Set-ADUser -Identity $username -Manager $managerUser.DistinguishedName
        Write-Host "Manager has been set to: $managerEmail"
    } else {
        Write-Host "Manager with email $managerEmail not found. Manager not set."
    }

# Group copy prompt
$copyGroups = Read-Host "Do you want to copy user groups from an existing user to this new user? (yes/no)"
if ($copyGroups -eq "yes") {
    $sourceUser = Read-Host "Enter the username of the user whose groups you want to copy"
    $userGroups = Get-ADUser -Identity $sourceUser -Properties memberOf | Select-Object -ExpandProperty memberOf
    if ($userGroups) {
        foreach ($group in $userGroups) {
            Add-ADGroupMember -Identity $group -Members $username
            Write-Host "Added $username to group $group"
        }
    } else {
        Write-Host "The source user does not belong to any groups."
    }
} else {
    Write-Host "You did not add this user to any groups."
}

# Start AD Sync
Import-Module ADSync
Start-ADSyncSyncCycle -PolicyType Delta

Write-Host "User account successfully created, added to the specified groups, and Azure AD sync completed."
