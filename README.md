# Active Directory User Management Scripts

A collection of PowerShell scripts I use to manage Active Directory users in real-world environments.

## 🔧 Scripts

- `Create-user.ps1` script helps you create a new Active Directory user, place them in the correct organizational unit, apply profile settings, and copy group memberships from an existing user..
- `Delete-user.ps1` script safely disables a user account, removes the user from all AD groups, and moves the account to a designated OU for disabled users.
- `Find-manager.ps1` script prompts you for a username, searches Active Directory, and displays the user's manager information.
- `Reset-password.ps1` Reset a user password and force password change on next login.

## 📦 Requirements

- PowerShell (5.1+)
- ActiveDirectory module
- Admin privileges

## 🚀 Usage

```powershell
