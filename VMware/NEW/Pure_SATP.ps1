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
" 
##################################################################

Add-PSSnapin VMware*
$vcenter = Read-Host "Enter vCenter"
Connect-VIServer $vcenter -WarningAction SilentlyContinue
$hosts=Get-Cluster | Where-Object {$_.Name -eq "Production_02"} | Get-VMhost
foreach ($esx in $hosts)
{
$esxcli=get-esxcli -VMHost $esx
$esxcli.storage.nmp.satp.rule.add($null, $null, "PURE FlashArray RR IO Operation Limit Rule", $null, $null, $null, "FlashArray",
$null, "VMW_PSP_RR", "iops=1", "VMW_SATP_ALUA", $null, $null, "PURE")
}