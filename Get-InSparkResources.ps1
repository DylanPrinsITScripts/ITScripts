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

$resources = @(
    "'Microsoft.apimanagement/service'", # API Management
    "'Microsoft.Network/applicationGateway'", # Application Gateway
    "'Microsoft.Network/applicationSecurityGroups'", # Application Security Groups
    "'Microsoft.Web/sites'", # Application Service
    "'Microsoft.Web/hostingEnvironments'", # Application Service Environment
    "'Microsoft.Web/serverfarms'", # Application Service Plan
    "'Microsoft.Web/sites/slots'", # Application Service Slot
    "'Microsoft.automation/automationaccounts'", # Automation Account
    "'Microsoft.Compute/availabilitySets'", # Availability Set
    "'Microsoft.aad/domainservices'", # AADDS
    "'Microsoft.ContainerInstance/containerGroups'", # Azure Container Instances
    "'Microsoft.ContainerRegistry/registries'", # Azure Container Registry
    "'Microsoft.Network/azureFirewalls'", # Azure Firewalls
    "'Microsoft.Network/frontdoors'", # Azure Front Doors
    "'Microsoft.ContainerService/managedClusters'", # Azure Kubernetes Service
    "'Microsoft.Compute/bastionHosts'", # Bastian Hosts
    "'Microsoft.Network/expressRouteCircuits'", # Express Route Circuits
    "'Microsoft.KeyVault/vaults'", # Key Vault
    "'Microsoft.Network/LoadBalancers'", # Load Balancers
    "'Microsoft.Network/localNetworkGateways'", # Local Network Gateways
    "'Microsoft.network/networksecuritygroups'", # Network Security Groups
    "'Microsoft.Network/networkWatchers'", # Network Watchers
    "'Microsoft.Network/publicIPAddresses'", # Public IP's
    "'Microsoft.RecoveryServices/vaults'", # Recovery Service Vault
    "'Microsoft.network/routetables'", # Route Tables
    "'Microsoft.Sql/servers/databases'", # SQL Databases
    "'Microsoft.Sql/servers/elasticpools'", # SQL Elastic Pools
    "'Microsoft.Sql/managedInstances'", # SQL Instances
    "'Microsoft.Sql/servers'", # SQL Servers
    "'Microsoft.Storage/storageAccounts'", # Storage Acounts
    "'microsoft.storagesync/storagesyncservices'", # Storage Sync Service
    "'Microsoft.Compute/VirtualMachines'", # Virtual Machines
    "'Microsoft.Network/virtualNetworks'", # Virtual Networks
    "'Microsoft.Network/virtualNetworkGateways'" # Virtual Network Gateways
    )

foreach ($resource in $resources){
    $query = "Resources
    | where type =~ $resource
    | where tags.$env:tagName =~ 'InSpark'
    | summarize Count=count()" 

    # Uitvoeren van de query
    $queryResult = Search-AzGraph -Query $query

    $resource = $resource.trim("`'")
    Write-Host ""
    Write-Host $resource "is:" $queryResult.count

    $var = $resource.replace(".", "_")
    $var = $var.replace("/", "_")

    if($queryResult.count -gt 0 ){
        Write-Host "##[section]Setting variable" $var "to: True"  
        Write-Host "##vso[task.setvariable variable=$var;isOutput=true;]true"
    }
    else{
        Write-Host "##[command]Setting variable " $var "to: False"
        Write-Host "##vso[task.setvariable variable=$var;isOutput=true;]false"
    }

}