
#################################################################
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
    
        Add-PSSnapin vmware*
        
    }
        
 if($snapin)
 
     {
 
        Write-Host "VMWare Snap in were imported already"  -ForegroundColor Green
        
      }

$vcenter = Read-Host "Enter vCenter Server Name or IP Address Here"
$connect = Connect-VIServer $vcenter -WarningAction SilentlyContinue
if ($connect) {
    Write-Host -ForegroundColor Green "Successfully connected to vCenter $vcenter ...."
}
else {
    Write-Host -ForegroundColor Yellow "Could not connect  to vCenter $vcenter .... Exiting"
    break
}
#######################################################################
Import-Csv c:\Temp\SvMotion.csv | Foreach {
    Get-VM $_.Name | Move-VM -DiskStorageFormat Thin -Datastore $_.NewDatastore -RunAsync
}

