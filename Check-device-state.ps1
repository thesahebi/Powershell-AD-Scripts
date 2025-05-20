# Run this on the target PC 
# Get full output of dsregcmd /status
$dsreg = dsregcmd /status

# Find the line number where "Device State" section starts
$startIndex = ($dsreg | Select-String "^\| Device State").LineNumber

# From that line forward, find the next header line (which ends the section)
$sectionLines = $dsreg[$startIndex..($dsreg.Length - 1)]
$endIndex = ($sectionLines | Select-String "^\+.*$" | Select-Object -Skip 1 -First 1).LineNumber

# Extract lines between start and end
if ($endIndex -gt 0) {
    $deviceState = $sectionLines[1..($endIndex - 2)]
    $deviceState
} else {
    Write-Host "Device State section not found."
}
