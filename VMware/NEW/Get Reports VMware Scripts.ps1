
#### Get VM list with Datastore for a specific Resource Pool ####

Get-resourcepool 20-L-BEACH-02 |Get-Vm | select Name, @{ Name = “Datastore”; Expression = {$_ | Get-Datastore} } | Export-Csv c:\temp\VM_BEACH_report.csv -NoTypeInformation -UseCulture


Connect-VIServer 192.168.60.68

#### Cluster Health Report Full ####

Get-Cluster | Select Name, @{N="A001US03-Staging";E={Get-Cluster -VM $_}}, `
@{N="ESX Host";E={Get-VMHost -VM $_}}, `
@{N="DNSName"; E={$_.ExtensionData.Guest.Hostname}}
@{N="Datastore";E={Get-Datastore -VM $_}} | `
Export-Csv -NoTypeInformation D:\Compute\VM_CLuster_Host_Datastore.csv

#### Get Datastore for a particular Cluster ####
Get-Cluster A001US03CB | Get-Datastore | select Name, @{N="Datastore";E={Get-Datastore -VM $_}} | `
Export-Csv -NoTypeInformation D:\Compute\VM_CLuster_Datastore.csv

@{N="IP Address";E={@($_.guest.IPAddress[0])}}


Get-VMHost | Select Name, @{ Name = "a001us033esx001"; Expression = {Get-VMHost -VM $_}} , `


### Script will pull VM list with Datastore, IP Address VM Name from specific ESXi host ###
Get-VMHost a001us033esx002.usp01.xstream360.cloud | Get-Vm | Select Name, @{ Name = "Datastore"; Expression = {$_ | Get-Datastore}}, `
@{N="IP Address";E={@($_.guest.IPAddress[0])}}| `
Export-Csv D:\Christian\a001us033esx002_VM_Inventory.csv -NoTypeInformation -UseCulture

Get-VM A07BUS012TMP001 | Get-VMResourceConfiguration

Get-VM | Select Name, @{ Name = "A07BUS012TMP001"; Expresion = {$_ | Get-VM}}

Get-VMResourceConfiguration -VM Get-VM A07BUS012TMP001

Get-VM -Name "A001US012VCS001" | Get-Stat -CPU -Memory -Realtime


Connect-VIServer p01vcenter.lifenet.org
Get-DatastoreCluster -Name VSI-Production-02 | Get-Vm | select Name, @{ Name = "VMName"; Expression = {$_ | Get-VM} } | Export-Csv c:\temp\Pure_Storage_VM_V2.csv -NoTypeInformation -UseCulture


