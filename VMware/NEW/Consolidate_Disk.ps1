
################################################################


################################################################
<# Description
This script will setup NUMAP Configuration for Pure Storage FlashArray
by Adding a Custom SATP Custom Rule
#>
Write-Host = "

 
.____    .__  _____       _______          __      ___ ___                .__   __  .__     
|    |   |__|/ ____\____  \      \   _____/  |_   /   |   \   ____ _____  |  |_/  |_|  |__  
|    |   |  \   __\/ __ \ /   |   \_/ __ \   __\ /    ~    \_/ __ \\__  \ |  |\   __\  |  \ 
|    |___|  ||  | \  ___//    |    \  ___/|  |   \    Y    /\  ___/ / __ \|  |_|  | |   Y  \
|_______ \__||__|  \___  >____|__  /\___  >__|    \___|_  /  \___  >____  /____/__| |___|  /
        \/             \/        \/     \/              \/       \/     \/               \/ 
" -ForegroundColor Green
##################################################################

$snapin = Get-PSSnapin -Name vmware* -ErrorAction SilentlyContinue

if (!$snapin)
    {
        Add-PSSnapin VMware*
    }

if ($snapin)

    {
        Write-Host "VMware Snap In Already imported" -ForegroundColor Green
    }

$vcenter = Read-Host "Enter vCenter"
Connect-VIServer $vcenter -WarningAction SilentlyContinue
    Write-Host "Looking for VMs need Disk Consolidation" -ForegroundColor Yellow

$vmn = Get-VM

ForEach ($VM in $vmn){

    
    $VMs = Get-VM | Where-Object {$_.ExtensionData.RunTime.ConsolidationNeeded}
    if ($VMs)
        {
            $VMs = Get-VM | Where-Object {$_.ExtensionData.RunTime.ConsolidationNeeded} | Out-GridView -Title "Server Need Disk Consolidation"
        }

    if (!$VMs)
        {
            Write-Host "No VM need Disk Consolidation" -ForegroundColor Green
        }

    }