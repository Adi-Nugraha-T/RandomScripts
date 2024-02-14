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

Import-Csv $OGCSV | foreach { 
		$item1 = ($_ | select-object -Property * -ExcludeProperty ParentID)
		$item2 = ConvertTo-Json($item1)
		$OrgGroupName = $_.ParentID
		#write-host "OrgGroupNameID="$OrgGroupName
		$PogID = Get-OrganizationIDbyGID ($OrgGroupName)
		$endpointURL = $URL + "/system/groups/" + $PogID
		write-host "creating OG" $_.Name "with" $_.ParentID "as ParentOG"
#Comment the line below and uncomment the last 3 lines to test parsing without actually creating the OG
		if ($testrun -eq $false){
		$webReturn = Invoke-RestMethod -Method POST -Uri $endpointURL -Headers $headerv2 -body $item2
		}
		if ($testrun -eq $true){
		write-host "uri:"$endpointURL 
		write-host "header:"$headerv2
		write-host "Body:"$item2
		}
}


