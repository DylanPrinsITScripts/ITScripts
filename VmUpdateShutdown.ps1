Param(
    [string]$VmUpdateGroup
)

$Vms = get-azvm -Status | where-object { $_.PowerState -match "running" }

foreach ($VM in $Vms) {
    $tags = $VM.tags
    if ($tags["InSpark_InfrastructureManagedBy"] -match "InSpark") {
        If (($tags["InSpark_VMstatus"] -match "Deallocated" -or $tags["InSpark_VMstatus"] -match "Stopped") -and ($tags["InSpark_VirtualMachineUpdateGroup"] -eq $VmUpdateGroup)) {
            Write-Host -NoNewline -ForegroundColor Yellow "Removing Tag: " 
            Write-Host $VM.Name
            
            $tags.Remove("InSpark_VMstatus")
            Set-AzResource -ResourceId $VM.Id -Tag $tags -Force

            Write-Host -NoNewline -ForegroundColor Yellow "Stopping VM: " 
            Write-Host $VM.Name
            Stop-AzVM -Id $VM.Id -NoWait -Force
        }
    }
}