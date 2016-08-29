#!/usr/bin/perl -w
#
#
#

use strict;

use JSON;
use Data::Dumper;


my @alphabetarray = ("A".."z");

my $json = JSON::XS->new();

$json->pretty(1);
my $sheetname = "something";
#print "@alphabetarray\n";
my $jsonStructure;
my %column;
my %row;
my $cell;

my $i = 1;
foreach (@alphabetarray){
	if(

	if($_ eq "A"){
		$cell = "Date";
	}
	else
	{
		$cell = $i++; #this is where the load times will go;
	}
	$column{$_} = $cell;
	
}
print Dumper(\%column), "\n";
my $lines = 1;

while ($lines < 20){
	$row{$lines++} = %column;
	print "$lines\n";
}
print Dumper(\%row), "\n";
$jsonStructure->{$sheetname} = %row;
my $prettyJson = $json->encode($jsonStructure);
#print $prettyJson;

print JSON::to_json(\%column);
#print $json;
#
