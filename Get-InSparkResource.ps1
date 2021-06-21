<#
.SYNOPSIS
    Check if the resource has an specific tag
.DESCRIPTION
    the script checks if the resource type exist with a specific tag en created a variable in azure pipeline
.EXAMPLE
    ./Get-InSparkResource.ps1 $env:resourceType $env:resourceType
.INPUTS
    
.OUTPUTS
    BOOLEAN: ##vso[task.setvariable variable=InSparkResourceExist;]
.NOTES
    
#>

$resource = $env:resourceType

write-host '##[section]ResourceType is:'
write-host $env:resourceType
write-host ''

write-host '##[section]Tag Name is:'
write-host $env:tagName
write-host ''

$query = "Resources
| where type =~ $resource
| where tags.$env:tagName =~ 'InSpark'
| summarize Count=count()" 

write-host '##[section]Query is:'
write-host $query
write-host ''

# Execute the Azure graph explorer query
$queryResult = Search-AzGraph -Query $query

$resource = $resource.trim("`'")
Write-Host "##[section]$resource is:"
Write-Host $queryResult.count
write-host ''

# Create Boolean in azure pipeline
if($queryResult.count -gt 0 ){
    Write-Host "##[section]Setting variable InSparkResourceExist to:"
    write-host 'True'
    write-host ''
    Write-Host "##vso[task.setvariable variable=InSparkResourceExist;]true"
}
else{
    Write-Host "##[section]Setting variable InSparkResourceExist to:"
    write-host 'False'
    write-host ''
    Write-Host "##vso[task.setvariable variable=InSparkResourceExist;]false"
}
