

#################### Add Pure SATP Custom Rule ######################################
#                                                                                   #
#    Created By: Christian Marrero Bonilla                                          #
#    CVENT Systems Engineering Team                                                 #
#                                                                                   #
#####################################################################################

# Description

The following script will reset the ESXi host root password. Use it at your own Risk

#>

###########################################################################################

Clear-Host
Write-Output 'WARNING!!!! Running this Script will reset the Root Account Password.'
cmd /c pause
Add-PSSnapin VMware*
    $esxi = Read-Host "Enter ESXi host IP or FQDN"
    $password = Read-Host "Enter Root Password"
        Connect-VIServer $esxi -User root -Password $password -WarningAction SilentlyContinue
            Clear-Host
$newpsswd = Read-Host "Enter New Root Password"
    Set-VMHostAccount –UserAccount root –Password $newpsswd

############################################################################################
    Clear-Host
Write-Output 'Root Password was changed. Good Luck!'