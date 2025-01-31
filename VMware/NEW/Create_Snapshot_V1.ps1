###### Start ########
$text = @"
 "ROFL:ROFL:ROFL:ROFL"

 
.____    .__  _____       _______          __      ___ ___                .__   __  .__     
|    |   |__|/ ____\____  \      \   _____/  |_   /   |   \   ____ _____  |  |_/  |_|  |__  
|    |   |  \   __\/ __ \ /   |   \_/ __ \   __\ /    ~    \_/ __ \\__  \ |  |\   __\  |  \ 
|    |___|  ||  | \  ___//    |    \  ___/|  |   \    Y    /\  ___/ / __ \|  |_|  | |   Y  \
|_______ \__||__|  \___  >____|__  /\___  >__|    \___|_  /  \___  >____  /____/__| |___|  /
        \/             \/        \/     \/              \/       \/     \/               \/ 

"@

##################################################################
Add-PSSnapin VMware*
$vcenter = Read-Host "Enter vCenter Server Name or IP Address Here"
Connect-VIServer $vcenter -WarningAction SilentlyContinue
$vmn = Read-Host "Enter VM Name Here"
$vms = Get-VM -Name $vmn
############# Do Work #################
foreach ($VM in $vmn){
    Write-Host "Gathering Snapshot Information for VM"
$Snap = Get-Snapshot -vm $vmn

    if ($Snap)

        {
            
            [System.Windows.MessageBox]::Show('Snapshot Completed')
            
            
        }
    if (!$Snap)

        {
        
            Write-Host "There is no snapshot created before, creating snapshot..." 
            New-Snapshot -VM $vmn -Name "Before_Updates" 
            [System.Windows.MessageBox]::Show('Snapshot Completed')                        

        }
          
    
    }


