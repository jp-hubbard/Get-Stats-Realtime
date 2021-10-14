function Get-Stats-Realtime {
    [CmdletBinding()]
	param(
		[string]$entity,
        [string]$path,
        [int]$duration,
        [ValidateRange(0,3600)]
        [int]$period
	)
    
    # Print notifications to screen
    function Status($item,$status) {
        write-host $item -NoNewLine -ForegroundColor cyan
        write-host " -> " -NoNewLine	
        write-host $status -ForegroundColor white
    } # End function status

    # Start the loop and end when elapsed time is greater than the duation
    $elasped=0
    while ($elapsed -lt ($duration + 1)) {

        # Subtract the period from the current time to identify start range of time to retrieve stats
        $start = (Get-Date) - [timespan]::fromseconds($period)
        
        # Get the statistics with the VMware Cmdlet
        Status "Getting Realtime Stats" "$start $entity"
        Status "Status" "$elapsed/$duration elapsed/duration in seconds"
        # Retrieve all statistics
        $stats = Get-Stat -Entity $entity -Memory -Cpu -Disk -Network -Realtime -Start $start | Select-Object Timestamp,Entity,MetricId,Instance,Value,Unit

	    # Create the name with a timestamp (Windows Pathing)
	    $time = (Get-Date $stats[0].Timestamp -format u).Replace(':','.').Replace(' ','_')
	    $name = "$path\realtime-" + $time + '.csv'

        # Export the statistics to a CSV file 
        Status "Exporting Realtime Stats" "$name"
	    $stats | Export-CSV -NoTypeInformation $name

        # Increment the elapsed time and sleep until next loop
        Status "Sleeping" "$period seconds"
        Start-Sleep $period
        $elapsed = $elapsed + $period      
    } # End duration loop
} 