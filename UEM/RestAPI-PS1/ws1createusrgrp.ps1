[CmdletBinding()]
    Param(

        [Parameter(Mandatory=$True)]
        [string]$WorkspaceONEServer,

        [Parameter(Mandatory=$True)]
        [string]$WorkspaceONEAdmin,

        [Parameter(Mandatory=$True)]
        [string]$WorkspaceONEAdminPW,

        [Parameter(Mandatory=$True)]
        [string]$WorkspaceONEAPIKey,

		[Parameter(Mandatory=$True)]
        [string]$TestRun,

        [Parameter(Mandatory=$False)]
        [string]$OGCSV,

        [Parameter(Mandatory=$False)]
        [string]$OrganizationGroupName, 

        [Parameter(Mandatory=$False)]
        [string]$OrganizationGroupID, 

        [Parameter(Mandatory=$False)]
        [string]$SensorsDirectory, 

        [Parameter(Mandatory=$False)]
        [int]$SmartGroupID, 

        [Parameter(Mandatory=$False)]
        [string]$SmartGroupName,  

        [Parameter(Mandatory=$False)]
        [switch]$UpdateSensors, 

        [Parameter(Mandatory=$False)]
        [switch]$DeleteSensors,

        [Parameter(Mandatory=$False)]
        [switch]$ExportSensors,

        [Parameter(Mandatory=$False)]
        [string]$TriggerType, 

        [Parameter(Mandatory=$False)]
        [string]$Platform, 

        [Parameter(Mandatory=$False)]
        [switch]$LOGIN,

        [Parameter(Mandatory=$False)]
        [switch]$LOGOUT,

        [Parameter(Mandatory=$False)]
        [switch]$STARTUP,

        [Parameter(Mandatory=$False)]
        [switch]$USER_SWITCH
)

# Forces the use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$URL = $WorkspaceONEServer + "/API"

$combined = $WorkspaceONEAdmin + ":" + $WorkspaceONEAdminPW
$encoding = [System.Text.Encoding]::ASCII.GetBytes($combined)
$cred = [Convert]::ToBase64String($encoding)


$headerv2 = @{
"Authorization"  = "Basic $cred";
"aw-tenant-code" = $WorkspaceONEAPIKey;
"Accept"		 = "application/json;version=2";
"Content-Type"   = "application/json";}

write-host $OGCSV

# Returns the Numerial Organization ID for the Organizational Group Name Provided
Function Get-OrganizationIDbyName {
    Write-Host("Getting Organization ID from Group Name")
    $endpointURL = $URL + "/system/groups/search?name=" + $OrgGroupName
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $headerv2
    $totalReturned = $webReturn.TotalResults
    $ogID = -1
    If ($webReturn.TotalResults = 1) {
        $ogID = $webReturn.OrganizationGroups.Id
        #Write-Host("Organization ID for " + $OrganizationGroupName + " = " + $ogID)
    } else {
        Write-host("Group Name: " + $OrganizationGroupName + " not found")
    }
    Return $ogID
}

Function Get-OrganizationIDbyGID ($DevOGId){
    Write-Host("Getting Organization ID from Group Name")
    $endpointURL = $URL + "/system/groups/search?groupid=" + $DevOGId
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $headerv2
    $totalReturned = $webReturn.TotalResults
    $ogID = -1
    If ($webReturn.TotalResults = 1) {
        $ogID = $webReturn.OrganizationGroups.Id
        #Write-Host("Organization ID for " + $DevOGId + " = " + $ogID)
    } else {
        Write-host("Group Name: " + $DevOGId + " not found")
    }
    Return $ogID
}

Function Get-CustomUserGroupByName ($usrgrpname){
    Write-Host("Getting Custom User GroupID from Group Name")
    $endpointURL = $URL + "/system/usergroups/custom/search?GroupName=" + $usrgrpname
    $webReturn = Invoke-RestMethod -Method Get -Uri $endpointURL -Headers $headerv2
    $totalReturned = $webReturn.Total
    $ogID = -1
    If ($webReturn.Total = 1) {
        $ogID = $webReturn.UserGroup.UserGroupId
        #Write-Host("Organization ID for " + $usrgrpname + " = " + $ogID)
    } else {
        Write-host("Custom User Group Name: " + $usrgrpname + " not found")
    }
    Return $ogID
}

#=============================================================================
#Start Execution
$grpcount = 0
Import-Csv $OGCSV | foreach { 
		$item1 = ($_)
		$item2 = ConvertTo-Json($item1)
		$OrgGroupName = $_.ManagedByOrganizationGroupID
		#write-host "ManagedByOrganizationGroupID="$OrgGroupName
		$PogID = Get-OrganizationIDbyGID ($OrgGroupName)
		$endpointURL = $URL + "/system/usergroups/createcustomusergroup"
		write-host "creating UserGroup" $_.GroupName "under" $_.ManagedByOrganizationGroupID "as ParentOG"
#Comment the line below and uncomment the last 3 lines to test parsing without actually creating the OG
		if ($testrun -eq $false){
		$webReturn = Invoke-RestMethod -Method POST -Uri $endpointURL -Headers $headerv2 -body $item2
		}
		$grpcount = $grpcount+1
		if ($testrun -eq $true){
		write-host "uri:"$endpointURL 
		write-host "header:"$headerv2
		write-host "Body:"$item2
		}
		write-host "NumberOfGroup:" $grpcount	
}
write-host "Total Group Created:" $grpcount


