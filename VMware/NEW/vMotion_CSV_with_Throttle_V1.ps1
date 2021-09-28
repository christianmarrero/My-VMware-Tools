#-----------------------------------------------------------
#	Script: vMotion from CSV with Throttle
#	 																							
#	Date: 8.31.16																						
#	
#	Revisions:
#
#------------------------------------------------------------

<# Description
vMotions VM's to a target cluster from CSV file and uses throttle
#>

# Load Modules and Snapins

if ( (Get-PSSnapin -Name vmware.VimAutomation.core -ErrorAction SilentlyContinue) -eq $null )
{
    Add-PsSnapin vmware.VimAutomation.core
}

# Variables 
$vcenter = Read-Host "Enter IP of vCenter"
$targetcluster = Read-Host "Enter name of target cluster"
$vmotionthrottle = Read-Host "How many concurrent vMotions?"
$filepath = Read-Host "Enter full filepath to CSV"

# Connect and Populate - Check for variable errors
$connect = Connect-VIServer $vcenter
if ($connect) {
    Write-Host -ForegroundColor Green "Successfully connected to vCenter $vcenter..."
}
else {
    Write-Host -ForegroundColor Yellow "Could not connect to vCenter $vCenter .. Exiting"
    break
}
$clustercheck = Get-Cluster $targetcluster
if ($clustercheck) {
    Write-Host -ForegroundColor Green "Successfully connected to cluster $targetcluster..."
}
else {
    Write-Host -ForegroundColor Yellow "Could not connect to cluster $targetcluster  .. Exiting"
    break
}
$csv = Import-Csv $filepath
if ($csv) {
    Write-Host -ForegroundColor Green "Successfully imported CSV from $filepath ..."
}
else {
    Write-Host -ForegroundColor Yellow "Could not load CSV from $filepath .. Exiting"
    break
}

# Do Work
foreach ($item in $csv) {
    $vm = Get-VM $item.VMName
    $cluster = $vm | Get-Cluster
    if ($cluster -notmatch $targetcluster) {
	    $hostdev = $vm.cddrives | Select-Object -ExpandProperty hostdevice
		if ($hostdev -ne $null) {
			$vm | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$false
        }
        # Later write in so that accounts for different blade models (total minuse used)
        do {
            $vmotions = (Get-Task | Where-Object {$_.name -match "RelocateVM_Task" -and $_.state -match "running"} | Measure-Object ).count
            Start-Sleep -second 10
            if ($vmotions -ge $vmotionthrottle) {
                Write-Host -ForegroundColor Cyan "$vmotions vMotions running... Waiting.."
            }
        }
        until ($vmotions -lt $vmotionthrottle)
        $vmhost = Get-Cluster $targetcluster | Get-VMHost | Sort-Object memoryusagegb | Select-Object -First 1
        Write-Host -ForegroundColor Cyan "Attempting move of $vm to $targetcluster..."
	    $vmotion = Move-VM -VM $vm -Destination $vmhost -Confirm:$false -RunAsync
        if ($vmotion) {
            Write-Host -ForegroundColor Green "vMotion for $VM successfully started.."
        }
        else {
            Write-Host -ForegroundColor Yellow "vMotion for $vm did not start.. check vsphere client for error"
        }
    }
    else {
        Write-Host -ForegroundColor Cyan "$vm already exists in $targetcluster"
    }
}

    
