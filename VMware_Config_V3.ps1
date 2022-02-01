#-----------------------------------------------------------
#	Script: VMware Env Config Script
#	 																							
#	Date: 2.1.2022																						
#	
#	By: Chritian Marrero IT Guru
#
#------------------------------------------------------------

<# Description
This script will configure the VMware Env 
by creating PortGroup, Set Cluster specs and create
VM Template along with some VMs
#>

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
$clustername = Get-Cluster | Where-Object {$_.Name -eq "Cluster1"}

foreach ($item in $clustername){

    Write-Host "Looking for Cluster Named Cluster 1..." -ForegroundColor Yellow
    
        if ($clustername)

            {
                Write-Host "The Cluster named Cluster 1 exists and available" -ForegroundColor Green
                $clustername | Set-Cluster -DrsEnabled:$true -Confirm:$false -HAAdmissionControlEnabled:$false
                    $vswitch = Get-VirtualSwitch | Where-Object {$_.Name -eq "vSwitch0"} 
                        $vswitch | New-VirtualPortGroup -Name "LAB Network" -VlanId $vlan_ID
            }
        
        if (!$clustername)

            {
                Wirte-Host "THe Cluster named Cluster 1 doesn't exists and need to be created" -ForegroundColor Red
            }

}
$portgroup = Get-VirtualPortGroup | Where-Object {$_.Name -eq "LAB Network"}

    foreach ($item in $portgroup) 
    {
    
         if ($portgroup)
            
            {

                Write-Host "LAB Network Port Group already exists Continue with Script" -ForegroundColor Green

            }

        else 
        
        {
            Write-Host "LAB Port Group still missing, waiting to be available...."

        }        
    }

    start-sleep -Seconds 30

###### Create VM Template #######
$clustername = Get-Cluster | Where-Object {$_.Name -eq "Cluster1"}

    foreach ($item in $cluster)
   
       {

        $vm = Get-VM | Where-Object {$_.Name -eq "WIN2016VM"}

        if (!$vm)
        {

             New-VM -Name 'WIN2016VM' `
                -ResourcePool Cluster1 `
                -NumCPU 2 `
                -MemoryGB 8 `
                -DiskStorageFormat thin `
                -DiskGB 80 `
                -NetworkName "LAB Network"
                 
            Set-VM -VM WIN2016VM -ToTemplate -Name "WIN2016_Template" -Confirm:$false
        }
    
        if ($vm) 
        {

            Write-Host "Virtual Machine Already Exists Creating VMs" -ForegroundColor Yellow

        }
    }

    start-sleep -Seconds 15
 
#### Create VMs Module ####

$vmNameTemplate = "VM-{0:D3}"
$template = Get-Template WIN2016_Template

$vmlist = @()

for ($i = 1; $i -le 10; $i++) {

    $vmName = $vmNameTemplate -f $i
    $vmList += New-VM -Name $vmName -ResourcePool $clustername -Template $template
}