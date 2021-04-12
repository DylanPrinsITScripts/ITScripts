Param(
    [string]$VmUpdateGroup
)

$Vms = get-azvm -Status | where-object { ($_.PowerState -match "deallocated" -or $_.PowerState -match "stopped") -and ($tags["InSpark_VirtualMachineUpdateGroup"] -eq $VmUpdateGroup) }


foreach ($VM in $Vms) {
    $tags = $VM.tags
    if ($tags["InSpark_InfrastructureManagedBy"] -match "InSpark") {
        If ($tags.ContainsKey("InSpark_VMstatus")) {
            Write-Host -NoNewline -ForegroundColor Green "Already Tagged: " 
            Write-Host $VM.Name
        }
        else {
            Write-Host -NoNewline -ForegroundColor Yellow "Tagging VM: " 
            Write-Host $VM.Name
            $tags += @{InSpark_VMstatus = "Deallocated" }
            Set-AzResource -ResourceId $VM.Id -Tag $tags -Force
        }
        
        Write-Host -NoNewline -ForegroundColor Yellow "Starting: " 
        Write-Host $VM.Name
    
        Start-AzVM -name $VM.Name -ResourceGroupName $VM.ResourceGroupName -NoWait
    }
    else{
        Write-Host -NoNewline -ForegroundColor blue "Not Managed: " 
        Write-Host $VM.Name
    }
}

foreach ($VM in $VmStopped) {
    $tags = $VM.tags
    If ($tags.ContainsKey("InSpark_VMstatus")) {
        Write-Host "Already Tagged:" $VM.Name
    }
    else {
        Write-Host "Tagging VM: " $VM.Name
        $tags += @{InSpark_VMstatus = "Stopped" }
        Set-AzResource -ResourceId $VM.Id -Tag $tags -Force
    }
    #    Start-AzVM $VM -NoWait
}