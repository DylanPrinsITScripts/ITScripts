$policy = 
# Get policy definitions
$policyset = Get-AzPolicySetDefinition -Name $env:initiativeName -SubscriptionId $env:subscriptionID -ErrorAction SilentlyContinue
if ($policyset) {
    $policyIDs = $policyset.Properties.PolicyDefinitions

    # Delete policy from initiative
    $policyToAdd = $policyIDs | Where-Object { $_.policyDefinitionId -notmatch $env:policy }
    $policyIDsJSON = $policyToAdd | Select-Object policyDefinitionId | convertto-json -Depth 10

    Write-Host ''
    Write-Host '##[section]Delete policy from initiative'
    Write-Host '##[command]Set-AzPolicySetDefinition -Name ' $env:initiativeName

    Set-AzPolicySetDefinition -Name $env:initiativeName -SubscriptionId $env:subscriptionID -PolicyDefinition $policyIDsJSON

    # delete policy definition
    $policyToDelete = $policyIDs | Where-Object { $_.policyDefinitionId -match $env:policy }
    foreach ($policyID in $policyToDelete) {
        Write-Host ''
        Write-Host '##[command] Remove-AzPolicyDefinition -id $policyID.policyDefinitionId'

        Remove-AzPolicyDefinition -id $policyID.policyDefinitionId -force -verbose
    }
}