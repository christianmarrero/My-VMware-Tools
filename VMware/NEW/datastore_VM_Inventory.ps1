
Add-PSSnapin VMware*
Connect-VIServer p01vcenter.lifenet.org

Get-Datastore vb-tintri-02 | Get-Vm | Select Name, @{N="VM";E={$_ | Get-Vm}}, `
    @{N="DNSName"; E={$_.ExtensionData.Guest.Hostname}} | `
Export-Csv -NoTypeInformation C:\Temp\Datasotre_VM_Inventory2.csv
    