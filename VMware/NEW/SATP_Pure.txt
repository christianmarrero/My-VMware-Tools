

dd-PSSnapin VMware*
$vcenter = Read-Host "Enter vCenter"
Connect-VIServer $vcenter -WarningAction SilentlyContinue
$hosts = Get-Cluster HQ-UCS-DEV01 | Select Name, @{N="HQ-UCS-DEV01";E={Get-Cluster -VMHost $_}}, `
@{N="ESX Host";E={Get-VMHost -Location HQ-UCS-DEV01}}
foreach ($esx in $hosts)
{
$esxcli=get-esxcli -VMHost $esx
$esxcli.storage.nmp.satp.rule.add($null, $null, "PURE FlashArray RR IO Operation Limit Rule", $null, $null, $null, "FlashArray",
$null, "VMW_PSP_RR", "iops=1", "VMW_SATP_ALUA", $null, $null, "PURE")
}