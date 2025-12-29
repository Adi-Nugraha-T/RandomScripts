# Description: check if current user is local admin
# Execution Context: CURRENTUSER
# Execution Architecture: EITHER64OR32BIT
# Return Type: BOOLEAN
$currentuser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$isMember = (Get-LocalGroupMember Administrators| Where-Object { $_.Name -eq $currentuser }) -ne $null
return $isMember
