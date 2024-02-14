# Description: Return the current list of localusers.
# Execution Context: SYSTEM
# Execution Architecture: EITHER64OR32BIT
# Return Type: STRING

$listuser = Get-LocalUser
$names = ($listuser.Name -join ";")
write-output $names