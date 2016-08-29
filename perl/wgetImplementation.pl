#!/usr/bin/perl
#http://search.cpan.org/~toddr/IPC-Run-0.92/lib/IPC/Run.pm
use IPC::Run qw(run);
use IPC::Cmd qw[can_run run run_forked];

use strict;
use warnings;


if ($#ARGV != 0){
	die "Argument not correct usage:\n\t $0 filename \n";
}
can_run('wget') or die "wget is not installed";
	
open FILE, pop @ARGV or die $!;

my @output;
my $link;
my $i = 1;
my $buffer;
my $cmd;
my $url;
#@buffer = system("wget --no-check-certificate http://hp.com -O /dev/null 2> @buffer");

foreach $url  (<FILE>){
	$cmd = "wget -O /dev/null --config=~/.wgetrc";
	$buffer = "";
	$cmd = "${cmd} $url";
	#print "Command is $cmd\n";
	scalar run (command => $cmd, verbose => 0, buffer => \$buffer ) or die "run command failed: $!";
	#scalar run (command => $cmd, verbose => 0, buffer => \$buffer ) or die "run command failed: $!";
	#my @args = ("wget", "-O", "/dev/null", "--no-check-certificate", $_);
	#print `wget --no-check-certificate $url -O /dev/null 2>&1`;
	#my @buffer  = `wget -O /dev/null  $_ --no-check-certificate`; #| awk '/^    /{print $0}'`;
	#my $statuscode = $buffer[9];
	#my $loadtime = $buffer[13];
	print "\nBuffer content: \n $buffer\n Buffer content Completed\n";
	
	#my @myarray = split(/\n/,$buffer);
	#print $statuscode;
	#print $loadtime
	my $statuscode = $buffer =~ m/(HTTP request sent, )(awaiting response\.\.\. 200 OK)(.*)/;
	#my $statuscode = grep(/Http request sent, awaiting response... 200 OK/, @myarray);
	print "\nStatuscode is: $statuscode\n";
	#print @myarray;
	#print @buffer;
	if ($statuscode ){
	
#		print $buffer;
		my @myarray = split(/\n/,$buffer);
		print "\nmyarray content: @myarray \n";
 	    # my $loadtime = $myarray[9];
		# my @loadtime1 = split(/=/,$loadtime);
		# chomp $_;
		# print "$i,$_,$loadtime1[1]";
#		push(@output, "$i,$_,$loadtime1[0]");
#		$temp = `awk 'BEGIN {}{print \$7}\' $temp`;
	
	  # }else{
		 # output("The $_ link did not resolve");
	   }
	   $i = $i++;
 }
# print "putting buffer";
#print $buffer;