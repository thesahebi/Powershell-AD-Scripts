function Get-AllEnabledReports {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ManagerUsername
    )

    # Get manager user object
    $manager = Get-ADUser -Identity $ManagerUsername -Properties DistinguishedName

    if (-not $manager) {
        Write-Host "Manager not found." -ForegroundColor Red
        return
    }

    # Recursive function to get enabled reports
    function Get-Reports($managerDN) {
        $directReports = Get-ADUser -Filter {
            Manager -eq $managerDN -and Enabled -eq $true
        } -Properties DisplayName, DistinguishedName, Enabled

        foreach ($report in $directReports) {
            $report
            Get-Reports -managerDN $report.DistinguishedName
        }
    }

    # Start with top-level manager
    $allReports = Get-Reports -managerDN $manager.DistinguishedName

    # Output list
    $allReports | Select-Object Name, SamAccountName, Enabled
    Write-Host "`nTotal ENABLED reports (direct + indirect): $($allReports.Count)" -ForegroundColor Green
}

# Example usage:
Get-AllEnabledReports -ManagerUsername "bisbi"
