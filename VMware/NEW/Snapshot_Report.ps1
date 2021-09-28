#-----------------------------------------------------------
#	Script: VM Snapshot Creation
#	 																							
#	Date: 10.23.2017																						
#	
#	By: Chritian Marrero IS Systems Engineer
#
#------------------------------------------------------------

<# Description
Create snapshot Report and Email to IS Ifrastructure Team
#>


Add-PSSnapin vmware*
Connect-VIServer P01vcenter.lifenet.org -WarningAction SilentlyContinue

$From = "SnapShot_Report@lifenet.org"
$To = "Christian_Marrero@lifenethealth.org"
$EmailServer = "P01Exchange.lifenet.org"
$Subject = "Virtual Machines Snapshot Report"
$Output = get-vm -location “Concert” | get-snapshot | format-table vm,name

Send-MailMessage -From $From -To $To -Body ($output | Out-String) -SmtpServer $EmailServer -Subject $Subject


