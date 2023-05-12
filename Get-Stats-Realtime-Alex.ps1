
# Print notifications to screen
function Status($item,$status) {
	write-host $item -NoNewLine -ForegroundColor cyan
	write-host " -> " -NoNewLine	
	write-host $status -ForegroundColor white
} # End function status

# For Alex

$duration=30
$period=30
$cluster = Get-Cluster DECC-Production
$vmhosts = $cluster | Get-VMHost | Sort-Object -Property Name
$entity = $vmhosts
$path=(pwd)

# Start the loop and end when elapsed time is greater than the duation
$elapsed=0

while ($elapsed -lt ($Duration + 1)) {

	# Subtract the Period from the current time to identify start range of time to retrieve stats
	$start = (Get-Date) - [timespan]::fromseconds($Period)
	
	# Get the statistics with the VMware Cmdlet
	Status "Getting Realtime Stats" "$start $Entity"
	Status "Status" "$elapsed/$Duration elapsed/Duration in seconds"
	# Retrieve all statistics
	$stats = Get-Stat -Entity $Entity -Stat mem.*,cpu.demand.average -Memory -Cpu -Disk -Network -Realtime -Start $start | Select-Object Timestamp,Entity,MetricId,Instance,Value,Unit

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

