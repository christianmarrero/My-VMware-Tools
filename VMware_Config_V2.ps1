



$snapin = Get-PSSnapin -Name vmware* -ErrorAction SilentlyContinue

if (!$snapin)

    {
        Add-PSSnapin vmware*
    }

if ($snapin)

    {
        Write-Host "VMWare Snap in were imported Already"
    }

######## Variables #######
$vlan_ID = Read-Host "Enter Secomdary VLAN ID Here"
$vcenter = Read-Host "Enter vCenter Server Name or IP Address Here"
Connect-VIServer $vcenter -WarningAction SilentlyContinue

######### DO Work ############

$clustername = Get-Cluster | Where-Object {$_.Name -eq "Cluster1"} 
    $clustername | Set-Cluster -DrsEnabled:$true -Confirm:$false -HAAdmissionControlEnabled:$false
$vswitch = Get-VirtualSwitch | Where-Object {$_.Name -eq "vSwitch0"} 
        $vswitch | New-VirtualPortGroup -Name "LAB Network" -VlanId $vlan_ID

###### Create VM Template #######

New-VM -Name 'WIN2016VM' `
    -ResourcePool Cluster1 `
    -NumCPU 2 `
    -MemoryGB 8 `
    -DiskStorageFormat thin `
    -DiskGB 80 `
    -NetworkName "LAB Network"

##### Convert VM to Template ####

Set-VM -VM WIN2016VM -ToTemplate -Name "WIN2016_Template"

#### Create VMs Module ####

$vmNameTemplate = "VM-{0:D3}"
$template = Get-Template WIN2016_Template

$vmlist = @()

for ($i = 1; $i -le 10; $i++) {

    $vmName = $vmNameTemplate -f $i
    $vmList += New-VM -Name $vmName -ResourcePool $clustername -Template $template
}