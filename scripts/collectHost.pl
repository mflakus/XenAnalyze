#!/usr/bin/perl
use Collect qw(findDisk doPre doPost getDelta);

$basePath = "/local/domain";
$xenDiskstat = $Collect::xenDiskstat;
$xenVmstat = $Collect::xenVmstat;
$hdrFormat  = "%-8s %2s %10s %10s %10s %10s %10s\n";
$hdrFormatCSV  = "%-8s, %2s, %10s, %10s, %10s, %10s, %10s\n";
$lineFormat = "%-8s %2d %10d %10d %10d %2.2f %10d\n";
$lineFormatCSV = "%-8s, %2d, %10d, %10d, %10d, %2.2f, %10d\n";

### Reporting:  Which VM data do we report ###
# my @vmKeys = ("pgpgin", "pgpgout", "pgfault" );
my @diskKeys = ("r_sectors", "r_ms", "r_total" );


### Try some other counters for 7.3 ###
# my @vmKeys = ("numa_hit", "pgmajfault", "pgfree" );

### Try some stuff from /proc/meminfo ###
my @vmKeys = ("Cached", "SwapCached", "Buffers" );
my %report;

sub doResults() {
	$| = 1;    # Flush print 
	print ("Finishing Collect Host Data.\n");
	doPost();
	%results = getDelta("VM");
	foreach $vmKey (@vmKeys) {
		print "Adding Host key $vmKey -> $results{$vmKey}\n";
		$report{"0"}{$vmKey} = $results{$vmKey};
	}
	%results = getDelta("DISK");
	foreach $diskKey (@diskKeys) {
		print "Adding Host key $diskKey -> $results{$diskKey}\n";
		$report{"0"}{$diskKey} = $results{$diskKey};
	}

	$results = `xenstore-list $basePath`;
	@domIDs = split (/\n/, $results);
	foreach $domID (@domIDs) {
		my @guestDisk=();
		$cmd = "xenstore-list $basePath/$domID/$xenDiskstat";
		$stats = `$cmd 2>/dev/null`;
		if ($? == 0) {
			foreach $key (@diskKeys) {
				$value = `xenstore-read $basePath/$domID/$xenDiskstat/$key`;
				$value =~ s/^\s+|\s+$//g;
				$report{"$domID"}{$key} = $value;
				$report{"U"}{$key} += $value;
				print "Found Dom-$domID Key $key -> $value\n";
			}
			foreach $key (@vmKeys) {
				$value = `xenstore-read $basePath/$domID/$xenVmstat/$key`;
				$value =~ s/^\s+|\s+$//g;
				$report{"$domID"}{$key} = $value;
				$report{"U"}{$key} += $value;
				print "Found Dom-$domID Key $key -> $value\n";
			}
		}
	}

	print ("--- Report ---\n");
	my $filename = '4Guest.csv';
	open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
	### Only do "disk", but need to add an extra ###
	# @allKeys = (@vmKeys, @diskKeys);
	@allKeys = (@diskKeys);
	printf $hdrFormat, "Domain", @allKeys, "TPS", "avgRdWait", "read/s";
	printf $fh $hdrFormatCSV, "Domain", @allKeys, "TPS", "avgRdWait", "read/s";
	# foreach $domID (@domIDs, "0", "U") {
	foreach $domID (@domIDs) {
		@domVals = ();
		foreach $key (@allKeys) {
			push(@domVals, $report{$domID}{$key});
		}
		$avgRdWait = 0;
		$TPS = `xenstore-read $basePath/$domID/data/analysis/tps 2>/dev/null`;
		if ($report{$domID}{'r_total'} > 0) {  #  ms/r Latency
			$avgRdWait = $report{$domID}{'r_ms'}/$report{$domID}{'r_total'};  #  ms/r Latency
		}
		$RPS = $report{$domID}{'r_total'}/30;    # Test runs for 30 seconds
		printf $lineFormat, "Dom-$domID", @domVals, $TPS, $avgRdWait, $RPS;	
		printf $fh $lineFormatCSV, "Dom-$domID", @domVals, $TPS, $avgRdWait, $RPS;	
	}

	close $fh;
	## Overhead ##

if (0) {
	print ("Overhd     ");
	foreach $key (@allKeys) {
		$hostVal  = $report{"0"}{$key};
		$guestVal = $report{"U"}{$key};
		# Orginal method ....
		# $overhead = 100 * ($guestVal - $hostVal) / $guestVal;
		
		# New method 
		if ($guestVal != 0) {
			$overhead = ($hostVal - $guestVal) / $guestVal;
			printf ("%1.3f     ", $overhead);
		}
		else {
			print ("xxxx    ");
		}

	}
	print ("\n");
}

	return 0;

}

############################## MAIN #################################
$SIG{'HUP'} = 'doResults';
`iostat -dxk /dev/sda /dev/tda /dev/tdb /dev/tdc /dev/tdd 5 > /tmp/iostat.txt &`;
doPre();
sleep;

`killall iostat`;
print "Complete!"
