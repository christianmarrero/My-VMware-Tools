Add-PSSnapin Vmware* -ErrorAction SilentlyContinue

# Initialize variables
# vCenter connections
$vCenter = "a001us012vcs001.usp01.xstream360.cloud"
$user = "usp01\vcreporter"
$password = "ae~thaiPh9"

# schedule
$interval = 1 # time between collections, in hours

# mail settings
#$sendmail = $FALSE
$sendmail = $TRUE
$mailfrom = "usdc1-usp01-reports@virtustream.com"
$mailto = @("import@a001us014mon001.usp01.xstream360.cloud")
$mailcc = @()
$errorto = @("jon@virtustream.com")
$mailhost = "a001us014ems001.usp01.xstream360.cloud"

# do work - nothing to edit after this
######################################

#define temporary lock
$tmpdir = $Env:tmp
#$tmpfile = "$tmpdir\cc.tmp"
$lockfile = "$tmpdir\clustercapacity.lck"

function die($msg) {
	if (test-path $lockfile) {
		remove-item $lockfile
	}
	if ($sendmail) {
		$mailmessage = New-Object system.net.mail.mailmessage 
		$mailmessage.from = $mailfrom 
		foreach ($addr in $errorto) {
			$mailmessage.To.add($addr)
		}
		$mailmessage.Subject = "Cluster Capacity error"
		$mailmessage.Body = $msg
		$SMTPClient = New-Object Net.Mail.SmtpClient($mailhost,25)  
		$SMTPClient.Send($mailmessage)
	} else {
		write-error $msg
	}
	break
}

if (test-path $lockfile) {
	die("Previous instance still running")
} else {
	get-date | out-file $lockfile
}

function Get-Stat2 {
<#
.SYNOPSIS  Retrieve vSphere statistics
.DESCRIPTION The function is an alternative to the Get-Stat cmdlet.
  It's primary use is to provide functionality that is missing
  from the Get-Stat cmdlet.
.NOTES  Author:  Luc Dekens
.PARAMETER Entity
  Specify the VIObject for which you want to retrieve statistics
  This needs to be an SDK object
.PARAMETER Start
  Start of the interval for which to retrive statistics
.PARAMETER Finish
  End of the interval for which to retrive statistics
.PARAMETER Stat
  The identifiers of the metrics to retrieve
.PARAMETER Instance
  The instance property of the statistics to retrieve
.PARAMETER Interval
  Specify for which interval you want to retrieve statistics.
  Allowed values are RT, HI1, HI2, HI3 and HI4
.PARAMETER MaxSamples
  The maximum number of samples for each metric
.PARAMETER QueryMetrics
  Switch to indicate that the function should return the available
  metrics for the Entity specified
.PARAMETER QueryInstances
  Switch to indicate that the function should return the valid instances
  for a specific Entity and Stat
.EXAMPLE
  PS> Get-Stat2 -Entity $vm.Extensiondata -Stat "cpu.usage.average" -Interval "RT"
#>
 
  [CmdletBinding()]
  param (
  [parameter(Mandatory = $true,  ValueFromPipeline = $true)]
  [PSObject]$Entity,
  [DateTime]$Start,
  [DateTime]$Finish,
  [String[]]$Stat,
  [String]$Instance = "",
  [ValidateSet("RT","HI1","HI2","HI3","HI4")]
  [String]$Interval = "RT",
  [int]$MaxSamples,
  [switch]$QueryMetrics,
  [switch]$QueryInstances)
 
  # Test if entity is valid
  $EntityType = $Entity.GetType().Name
 
  if(!(("HostSystem",
        "VirtualMachine",
        "ClusterComputeResource",
        "Datastore",
        "ResourcePool") -contains $EntityType)) {
    Throw "-Entity parameters should be of type HostSystem, VirtualMachine, ClusterComputeResource, Datastore or ResourcePool"
  }
 
  $perfMgr = Get-View (Get-View ServiceInstance).content.perfManager
 
  # Create performance counter hashtable
  $pcTable = New-Object Hashtable
  $keyTable = New-Object Hashtable
  foreach($pC in $perfMgr.PerfCounter){
    if($pC.Level -ne 99){
      if(!$pctable.containskey($pC.GroupInfo.Key + "." + $pC.NameInfo.Key + "." + $pC.RollupType)){
        $pctable.Add(($pC.GroupInfo.Key + "." + $pC.NameInfo.Key + "." + $pC.RollupType),$pC.Key)
        $keyTable.Add($pC.Key, $pC)
      }
    }
  }
 
  # Test for a valid $Interval
  if($Interval.ToString().Split(" ").count -gt 1){
    Throw "Only 1 interval allowed."
  }
 
  $intervalTab = @{"RT"=$null;"HI1"=0;"HI2"=1;"HI3"=2;"HI4"=3}
  $dsValidIntervals = "HI2","HI3","HI4"
  $intervalIndex = $intervalTab[$Interval]
 
  if($EntityType -ne "datastore"){
    if($Interval -eq "RT"){
      $numinterval = 20
    }
    else{
      $numinterval = $perfMgr.HistoricalInterval[$intervalIndex].SamplingPeriod
    }
  }
  else{
    if($dsValidIntervals -contains $Interval){
      $numinterval = $null
      if(!$Start){
        $Start = (Get-Date).AddSeconds($perfMgr.HistoricalInterval[$intervalIndex].SamplingPeriod - $perfMgr.HistoricalInterval[$intervalIndex].Length)
      }
      if(!$Finish){
        $Finish = Get-Date
      }
    }
    else{
      Throw "-Interval parameter $Interval is invalid for datastore metrics."
    }
  }
 
  # Test if QueryMetrics is given
  if($QueryMetrics){
    $metrics = $perfMgr.QueryAvailablePerfMetric($Entity.MoRef,$null,$null,$numinterval)
    $metricslist = @()
    foreach($pmId in $metrics){
      $pC = $keyTable[$pmId.CounterId]
      $metricslist += New-Object PSObject -Property @{
        Group = $pC.GroupInfo.Key
        Name = $pC.NameInfo.Key
        Rollup = $pC.RollupType
        Id = $pC.Key
        Level = $pC.Level
        Type = $pC.StatsType
        Unit = $pC.UnitInfo.Key
      }
    }
    return ($metricslist | Sort-Object -unique -property Group,Name,Rollup)
  }
 
  # Test if start is valid
  if($Start -ne $null -and $Start -ne ""){
    if($Start.gettype().name -ne "DateTime") {
      Throw "-Start parameter should be a DateTime value"
    }
  }
 
  # Test if finish is valid
  if($Finish -ne $null -and $Finish -ne ""){
    if($Finish.gettype().name -ne "DateTime") {
      Throw "-Start parameter should be a DateTime value"
    }
  }
 
  # Test start-finish interval
  if($Start -ne $null -and $Finish -ne $null -and $Start -ge $Finish){
    Throw "-Start time should be 'older' than -Finish time."
  }
 
  # Test if stat is valid
  $unitarray = @()
  $InstancesList = @()
 
  foreach($st in $Stat){
    if($pcTable[$st] -eq $null){
      Throw "-Stat parameter $st is invalid."
    }
    $pcInfo = $perfMgr.QueryPerfCounter($pcTable[$st])
    $unitarray += $pcInfo[0].UnitInfo.Key
    $metricId = $perfMgr.QueryAvailablePerfMetric($Entity.MoRef,$null,$null,$numinterval)
 
    # Test if QueryInstances in given
    if($QueryInstances){
      $mKey = $pcTable[$st]
      foreach($metric in $metricId){
        if($metric.CounterId -eq $mKey){
          $InstancesList += New-Object PSObject -Property @{
            Stat = $st
            Instance = $metric.Instance
          }
        }
      }
    }
    else{
      # Test if instance is valid
      $found = $false
      $validInstances = @()
      foreach($metric in $metricId){
        if($metric.CounterId -eq $pcTable[$st]){
          if($metric.Instance -eq "") {$cInstance = '""'} else {$cInstance = $metric.Instance}
          $validInstances += $cInstance
          if($Instance -eq $metric.Instance){$found = $true}
        }
      }
      if(!$found){
        Throw "-Instance parameter invalid for requested stat: $st.`nValid values are: $validInstances"
      }
    }
  }
  if($QueryInstances){
    return $InstancesList
  }
 
  $PQSpec = New-Object VMware.Vim.PerfQuerySpec
  $PQSpec.entity = $Entity.MoRef
  $PQSpec.Format = "normal"
  $PQSpec.IntervalId = $numinterval
  $PQSpec.MetricId = @()
  foreach($st in $Stat){
    $PMId = New-Object VMware.Vim.PerfMetricId
    $PMId.counterId = $pcTable[$st]
    if($Instance -ne $null){
      $PMId.instance = $Instance
    }
    $PQSpec.MetricId += $PMId
  }
  $PQSpec.StartTime = $Start
  $PQSpec.EndTime = $Finish
  if($MaxSamples -eq 0 -or $numinterval -eq 20){
    $PQSpec.maxSample = $null
  }
  else{
    $PQSpec.MaxSample = $MaxSamples
  }
  $Stats = $perfMgr.QueryPerf($PQSpec)
 
  # No data available
  if($Stats[0].Value -eq $null) {return $null}
 
  # Extract data to custom object and return as array
  $data = @()
  for($i = 0; $i -lt $Stats[0].SampleInfo.Count; $i ++ ){
    for($j = 0; $j -lt $Stat.Count; $j ++ ){
      $data += New-Object PSObject -Property @{
        CounterId = $Stats[0].Value[$j].Id.CounterId
        CounterName = $Stat[$j]
        Instance = $Stats[0].Value[$j].Id.Instance
        Timestamp = $Stats[0].SampleInfo[$i].Timestamp
        Interval = $Stats[0].SampleInfo[$i].Interval
        Value = $Stats[0].Value[$j].Value[$i]
        Unit = $unitarray[$j]
        Entity = $Entity.Name
        EntityId = $Entity.MoRef.ToString()
      }
    }
  }
  if($MaxSamples -eq 0){
    $data | Sort-Object -Property Timestamp -Descending
  }
  else{
    $data | Sort-Object -Property Timestamp -Descending | select -First $MaxSamples
  }
}

if ($sendmail) {
	$nl = "\\n"
} else {
	$nl = "`r`n"
}

$finish = get-date
$start = $finish.addHours($interval * -1)

#Connect to vCenter Server
$vc = Connect-VIServer $vCenter -User $user -Password $password
if (-not $vc) {
	die("Cannot connect to vCenter: $vCenter")
}

# define SPEC ratings
$spec = @{
	"Intel(R) Xeon(R) CPU E5-4650 0 @ 2.70GHz" = "1.5"; 
	"Intel(R) Xeon(R) CPU E7- 2860  @ 2.27GHz" = "1.5"
}
# Get clusters
# output: cluster name|# hosts|CPU cap|CPU max|CPU avg|Mem cap|MEM max|MEM avg
$output = ""
$Clusters = Get-Cluster | sort
foreach ($Cluster in $Clusters) {
	$clName = $cluster.name
	if ( -not ($clName.tolower().Contains("-staging"))) {
		$clNumHosts = $cluster.ExtensionData.Summary.NumEffectiveHosts			# use effective to account for maintenance mode, etc
		if ( $clNumHosts -gt 0 ) {
			$vmhosts = Get-VMHost -location $Cluster
			$vmhost = $vmhosts[0]
			$cpuType = $vmhost.ProcessorType
			if ( $spec.ContainsKey($cpuType) ) {
				$specRating = $spec.get_item($cpuType)
			} else {
				$specRating = "1"
			}
		} else {
			$specRating = "1"
		}
		$clTotCPU = [math]::round(($cluster.ExtensionData.Summary.TotalCpu / 1000),2)
		$clTotMEM = [math]::round(($cluster.ExtensionData.Summary.TotalMemory / 1KB),2)
		$clCPUStat = Get-Stat2 -Entity $cluster.ExtensionData -Stat cpu.usagemhz.average -Start $start -Finish $finish -Interval "HI1"
		$clMEMStat = Get-Stat2 -Entity $cluster.ExtensionData -Stat mem.consumed.average -Start $start -Finish $finish -Interval "HI1"
		$clCPUAvg = [String]([Math]::Round((($clCPUStat | Measure-Object -Property Value -Average).Average),2))
		$clCPUMax = [String]([Math]::Round((($clCPUStat | Measure-Object -Property Value -Maximum).Maximum),2))
		$clMEMAvg = [String]([Math]::Round((($clMEMStat | Measure-Object -Property Value -Average).Average),2))
		$clMEMMax = [String]([Math]::Round((($clMEMStat | Measure-Object -Property Value -Maximum).Maximum),2))
		$output = $output + "$clName|$clNumHosts|$specRating|$clTotCPU|$clCPUMax|$clCPUAvg|$clTotMEM|$clMEMMax|$clMEMAvg$nl"
		#"$clName|$clNumHosts|$specRating|$clTotCPU|$clCPUMax|$clCPUAvg|$clTotMEM|$clMEMMax|$clMEMAvg`r`n" >> $tmpfile 
	}
}

Disconnect-VIServer -Confirm:$false
$collectionEnd = get-date
$runtime = $collectionEnd - $finish
$runMins = [String]([Math]::Round($runtime.TotalMinutes,2))

$output = $output + "RUNTIME|$runMins"
#"RUNTIME|$runMins" >> $tmpfile

if ($sendmail) {
$mailmessage = New-Object system.net.mail.mailmessage 
		$mailmessage.from = $mailfrom 
		foreach ($addr in $mailto) {
			$mailmessage.To.add($addr)
		}
		foreach ($addr in $mailcc) {
			$mailmessage.Cc.add($addr)
		}
		$mailmessage.Subject = "$vCenter clusters"
		$mailmessage.Body = $output
		#$mailmessage.Body = Get-Content $tmpfile
		$SMTPClient = New-Object Net.Mail.SmtpClient($mailhost,25)  
		$SMTPClient.Send($mailmessage)
} else {
	$output
}

remove-item $lockfile
#remove-item $tmpfile