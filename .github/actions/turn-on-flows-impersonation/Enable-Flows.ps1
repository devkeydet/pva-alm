# Enable flows based on connection references
# Flows can only be turned on if the user turning them on has permissions to connections being referenced by the connection reference
# As of authoring this script, the Service Principal (SPN) we use to connect to the Dataverse API cannot turn on the Flow
# The temporary workaround is use a brute force approach for now.  We use the identity of the connection for the first connection
# reference we find to turn on the Flow.  This may have side effects or unintended consequences we haven't fully tested.

function Enable-Flows ($tenantId, $clientId, $clientSecret, $environmentUrl, $solutionName, $deploymentSettingsFile) {
    Import-Module Microsoft.Xrm.Data.PowerShell
    Import-Module  Microsoft.PowerApps.Administration.PowerShell

    Add-PowerAppsAccount -TenantID $tenantId -ApplicationId "$clientId" -ClientSecret "$clientSecret"

    $connectionString = "AuthType=ClientSecret;url=$environmentUrl;ClientId=$clientId;ClientSecret=$clientSecret"
    $conn = Get-CrmConnection -ConnectionString $connectionString
    $impersonationConn = Get-CrmConnection -ConnectionString $connectionString
              
    $environmentName = $conn.EnvironmentId
    $solutions = Get-CrmRecords -conn $conn -EntityLogicalName solution -FilterAttribute "uniquename" -FilterOperator "eq" -FilterValue "$solutionName"
    if ($solutions.Count -gt 0) {
        $solutionId = $solutions.CrmRecords[0].solutionid
        $result = Get-CrmRecords -conn $conn -EntityLogicalName solutioncomponent -FilterAttribute "solutionid" -FilterOperator "eq" -FilterValue $solutionId -Fields objectid, componenttype
        $solutionComponents = $result.CrmRecords
            
        $deploymentSettings = Get-Content $deploymentSettingsFile | ConvertFrom-Json
            
        foreach ($connectionRefConfig in $deploymentSettings.ConnectionReferences) {
            if ($connectionRefConfig.LogicalName -ne '' -and $connectionRefConfig.ConnectionId -ne '') {
                # Get the connection reference
                $connRefs = Get-CrmRecords -conn $conn -EntityLogicalName connectionreference -FilterAttribute "connectionreferencelogicalname" -FilterOperator "eq" -FilterValue $connectionRefConfig.LogicalName
                if ($connRefs.Count -gt 0) {      
                    # Get connection
                    $connections = Get-AdminPowerAppConnection -EnvironmentName $environmentName -Filter $connectionRefConfig.ConnectionId
                        
                    # Get Dataverse systemuserid for the system user that maps to the aad user guid that created the connection 
                    $systemusers = Get-CrmRecords -conn $conn -EntityLogicalName systemuser -FilterAttribute "azureactivedirectoryobjectid" -FilterOperator "eq" -FilterValue $connections[0].CreatedBy.id
                    if ($systemusers.Count -gt 0) {
                        # Impersonate the Dataverse systemuser that created the connection when turning on the flow
                        $impersonationCallerId = $systemusers.CrmRecords[0].systemuserid
                        foreach ($solutionComponent in $solutionComponents) {
                            if ($solutionComponent.componenttype -eq "Workflow") {
                                $workflow = Get-CrmRecord -conn $conn -EntityLogicalName workflow -Id $solutionComponent.objectid -Fields clientdata, category, statecode
                                if ($workflow.clientdata.Contains($connectionRefConfig.LogicalName) -and $workflow.statecode -ne "Activated") {
                                    $impersonationConn.OrganizationWebProxyClient.CallerId = $impersonationCallerId 
                                    Set-CrmRecordState -conn $impersonationConn -EntityLogicalName workflow -Id $solutionComponent.objectid -StateCode Activated -StatusCode Activated
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}