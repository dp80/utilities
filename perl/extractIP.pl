#!/usr/bin/perl -w
#
#
#
#use WWW::Curl::Easy;

use strict;

 
open FILE, pop @ARGV or die "cannot open url list file";
my @serverlist = <FILE>;

open(my $FO, ">", "serverips.csv") or die "cannot open file to write: $!";
chomp @serverlist;
foreach (@serverlist){
	my $host = $_;
	my @summary = `ping -n 1 $host`;
	foreach (@summary){	
		if ( grep ( /^Reply from*/, $_)){
			my @tmp = split(/ /, $_);
			my $ip = substr( $tmp[2],0, -1);
            chomp $host;
			print $FO "$host,$ip\n";
		}
		if ( grep ( /^Request timed out*/, $_)){
			print $FO "$host,timed out\n";
			last;
		}
		if ( grep ( /^Ping request could not find*/, $_)){
			print $FO "$host,could not find host\n";
			last;
		}
	}
}
close $FO;
