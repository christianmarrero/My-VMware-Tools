###### Start ########

Clear-Host
Wirte-Output 'Greetings, this script will proceed to create a snapshot of a virtual machine'
cmd /c pause
##################################################################
Add-PSSnapin VMware*
Connect-VIServer $vcenter -WarningAction SilentlyContinue
$vmn = Read-Host "Enter VM Name Here"
$vms = Get-VM -Name $vmn
############# Do Work #################
foreach ($VM in $vmn){
    Write-Host "Gathering Snapshot Information for VM"
$Snap = Get-Snapshot -vm $vmn

    if ($Snap)

        {
            Write-Host "There is an snapshot on this VM please delete it" 
            
            
        }
    if (!$Snap)

        {
        
            Write-Host "There is no snapshot created before, creating snapshot..." 
            New-Snapshot -VM $vmn -Name "Before_Updates"

        }
    }


