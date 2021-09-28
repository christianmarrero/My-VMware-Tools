


#### elect the VMs on a certain datastore and move them to a new datastore and change the disk format to thin along the way ####

Get-Datastore "CurrentDatastoreName" | Get-VM | Move-VM -DiskStorageFormat Thin -Datastore "NewDatastoreName" –RunAsync

##### Import a CSV with Name, NewDatastore headings and move each one of these converting the disk along the way #####
Import-Csv c:\Tmp\SvMotion.csv | Foreach {
    Get-VM $_.Name | Move-VM -DiskStorageFormat Thin -Datastore $_.NewDatastore -RunAsync
}

#### To check these have completed successfully you can use the following ####
Get-VM | Select Name, @{N="Datastore";E={$_ | Get-Datastore}}

