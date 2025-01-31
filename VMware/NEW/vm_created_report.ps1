
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction 'SilentlyContinue'
Connect-VIServer p01vcenter -WarningAction SilentlyContinue
Get-VIEvent -maxsamples 10000 -Start (Get-Date).AddDays(–14) | where {$_.Gettype().Name-eq "VmCreatedEvent" -or $_.Gettype().Name-eq "VmBeingClonedEvent" -or $_.Gettype().Name-eq "VmBeingDeployedEvent"} |Sort CreatedTime -Descending |Select CreatedTime, UserName,FullformattedMessage