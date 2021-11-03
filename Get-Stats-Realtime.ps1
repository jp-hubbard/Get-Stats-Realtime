<#
 .Synopsis
  Collect and export vSphere realtime statistitcs over a user defined period of time.

 .Description
  Export vSphere realtime statistitcs over a user defined Period of time. This function 
  builds upon the functionality of the PowerCLI "Get-Stat" Cmdlet. By default, real-time 
  statistics are collected every 20 seconds for the last 60-minutes. This data is stored
  in a circular buffer and as new data is collected, the oldest data is overwritten. 
  This function exports timestamped realtime statistics to a comma seperated file (CSV) 
  every   period for a specified duration. Realtime statistics include memory, cpu, disk,
  and network.

 .Parameter Entity
  Fully qualified domain name (FQDN) or IP address of a vSphere host.

 .Parameter Path
  The file path where results are exported. The file path must exist and assumes a 
  Microsoft Windows operating system. 

 .Parameter Duration
  The length of time in seconds the function should run.

 .Parameter Period
  The interval in seconds that statistics are collected and exported. Periods must be
  between 0-3600 seconds to maintain contigiuous data sets.

 .Example
   # Load the function

   Import-Module .\Get-Stats-Realtime.ps1
   
   # Collect realtime statistics from the vSphere host "vmhost.example.com" every 45 minutes 
   for 2 hours and export to the "C:\stats" file path.

   Get-Stats-Realtime -Entity vmhost.example.com -Path C:\stats -Duration 7200 -Period 2700
#>
function Get-Stats-Realtime {
    [CmdletBinding()]
	param(
		[string]$Entity,
        [string]$Path,
        [int]$Duration,
        [ValidateRange(0,3600)]
        [int]$Period
	)
    
    # Print notifications to screen
    function Status($item,$status) {
        write-host $item -NoNewLine -ForegroundColor cyan
        write-host " -> " -NoNewLine	
        write-host $status -ForegroundColor white
    } # End function status

    # Start the loop and end when elapsed time is greater than the duation
    $elapsed=0
    while ($elapsed -lt ($Duration + 1)) {

        # Subtract the Period from the current time to identify start range of time to retrieve stats
        $start = (Get-Date) - [timespan]::fromseconds($Period)
        
        # Get the statistics with the VMware Cmdlet
        Status "Getting Realtime Stats" "$start $Entity"
        Status "Status" "$elapsed/$Duration elapsed/Duration in seconds"
        # Retrieve all statistics
        $stats = Get-Stat -Entity $Entity -Stat mem.consumed.average,mem.bandwidth*,mem.missrate.latest -Memory -Cpu -Disk -Network -Realtime -Start $start | Select-Object Timestamp,Entity,MetricId,Instance,Value,Unit

	    # Create the name with a timestamp (Windows Pathing)
	    $time = (Get-Date $stats[0].Timestamp -format u).Replace(':','.').Replace(' ','_')
	    $name = "$Path\realtime-" + $time + '.csv'

        # Export the statistics to a CSV file 
        Status "Exporting Realtime Stats" "$name"
	    $stats | Export-CSV -NoTypeInformation $name

        # Increment the elapsed time and sleep until next loop
        Status "Sleeping" "$Period seconds"
        Start-Sleep $Period
        $elapsed = $elapsed + $Period      
    } # End Duration loop
} 