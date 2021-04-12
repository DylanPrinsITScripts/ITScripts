<#
.SYNOPSIS
    Powershell script voor het clonen van de repo naar de worker
.DESCRIPTION
    Long description
.EXAMPLE
    ./cloneWiki.ps1 -PAT $PAT
.INPUTS
    $PAT
.OUTPUTS
    Output (if any)
.NOTES
    Er wordt gebruikt gemaakt van Git om de Repo te clonen
#>

Write-Host "Checking Policy definitions"
$localPolicies = get-childitem .\policies\IAAS\
$azurePolicies = Get-AzPolicyDefinition | select-object -ExpandProperty  Properties | where-object -property PolicyType -eq "Custom" | select-object displayName

foreach ($policy in $localPolicies){

    $policyPath = "policies\IAAS\" + $policy.name + "\policy.json"
    $parameterPath = "policies\IAAS\" + $policy.name + "\parameter.json"

    if($azurePolicies.displayName -contains $policy.name){
        write-host -ForegroundColor Green "Already Exists" $policy.name
        if (Test-Path $parameterPath){
            Set-AzPolicyDefinition -name $policy.name -Policy $policyPath -Parameter $parameterPath
            #remove-AzPolicyDefinition -name $policy.name -force
        }
        else{
            Set-AzPolicyDefinition -name $policy.name -Policy $policyPath
            #remove-AzPolicyDefinition -name $policy.name -force
        }
    }
    else{

        Write-Host -ForegroundColor Yellow "creating" + $policy.name
        if (Test-Path $parameterPath){
            New-AzPolicyDefinition -name $policy.name -DisplayName $policy.name -Policy $policyPath -Description "Auto created by InSpark Pipeline" -Parameter $parameterPath
        }
        else{
            New-AzPolicyDefinition -name $policy.name -DisplayName $policy.name -Policy $policyPath -Description "Auto created by InSpark Pipeline"
        }
    }

}

Write-Host "Checking Initiatives"
$policySetName = "InSpark-Infra-IAAS"
$policySetPath = "initiatives\" + $policySetName + "\policyset.json"

$azureSetPolicies = Get-AzPolicySetDefinition | select-object -ExpandProperty  Properties | where-object -property DisplayName -eq $policySetName | select-object displayName

if($azureSetPolicies.displayName -contains $policySetName){
    write-host -ForegroundColor Green "Already exists" $policySet.name
    Set-AzPolicySetDefinition -name $policySetName -PolicyDefinition $policySetPath
}
else{
    Write-Host -ForegroundColor Yellow "creating" $policySetName
    New-AzPolicySetDefinition -name $policySetName -DisplayName $policySetName -PolicyDefinition $policySetPath -Description "Auto created by InSpark Pipeline"
}