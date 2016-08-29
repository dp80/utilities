#!/usr/bin/perl
#http://search.cpan.org/~toddr/IPC-Run-0.92/lib/IPC/Run.pm
# 1)To Install perl module from shell: perl -MCPAN -eshell
# 2)install LWP:Protocol::https
#To Debug perl
#perl -d lwp.pl {arguments}
#
#  LWP high level operation
#In normal use the application creates an LWP::UserAgent object, and then configures it with values for timeouts, proxies, name, etc.
#It then creates an instance of HTTP::Request for the request that needs to be performed. This request is then passed to one of the request method the UserAgent,
#which dispatches it using the relevant protocol, and returns a HTTP::Response object. There are convenience methods for sending the most common request types: get(), head() and post().
#When using these methods then the creation of the request object is hidden as shown in the synopsis above.
#
#
#Author: Dhiren
#
use strict;
use warnings;
use LWP;
use LWP::Protocol::https;
use HTTP::Request::Common;
use HTTP::Cookies;
use HTML::Form;
use Data::Dumper;
use LWP::UserAgent;
use LWP::ConnCache;
use JSON;

#use HTML::TreeBuilder; #lwp.interglacial.com/ch09_02.htm
#****sub Procedures ******
sub csv_to_json($);           #csvfile into array, returns json Object
sub logit;                    #output to log file "lwp_logfile.txt
sub createrow($$);            #returns a row with cell and value assigned
sub get_date();
sub get_reporterTokens($);    #figure out the tokens based on env
sub ecloginurls($);

#****Global vars*****
my %reporterTokens = ();
my $user;
my $pwd;
my $outformat = "csv";
my $app;
my $env;
my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 },
							  agent    => "libwww-perl/5.10.1" );

#****File handles for input and output***
open LOGFILE_HANDLE, ">>lwp_logfile.txt" or die $!;
logit "*******Starting Main ***********\n\n";
if ( $#ARGV == 5 )
{
	logit "Checking the arguments";
	my $temp = pop @ARGV;
	$pwd  = pop @ARGV;
	$user = pop @ARGV;
	open FILE, pop @ARGV or die $!;
	if ( lc($temp) eq "csv" )
	{
		$outformat = "csv";
		open FILEOUT, ">>lwpoutput.csv" or die $!;
	}
	else
	{
		$outformat = "json";
		open JSONOBJECT, ">jsonFile.txt" or die $!;
	}
	$app = lc( pop @ARGV );
	$env = lc( pop @ARGV );
}
else
{
	print "Argument not correct\n usage: \n";
	print
"\t perl $0 {dev,itg,or pro} {useit,reporter,ec,or cda} urlfilename {username, or \"\"} {password, or \"\"} {csv or json} \n";
	print "\t\t\n";
	logit "Invalid arguments, program quits\n";
	exit;
}
logit "Creating userAgent";
my $header;
$ua->requests_redirectable;
push @{ $ua->requests_redirectable }, 'POST';
$ua->env_proxy;    #if accessing content that is external
$ua->max_redirect;
logit "Setting allowed protocols";
$ua->protocols_allowed( [ 'http', 'https' ] );
my $cache =
  $ua->conn_cache( LWP::ConnCache->new() );    #not being used right nowlwptut
$ua->conn_cache->total_capacity(10);
logit "creating cookie jar for cache";
$ua->cookie_jar(
				 HTTP::Cookies->new(
									 file           => "lwpcookies.txt",
									 autosave       => 1,
									 ignore_discard => 1
				 )
);
$ua->show_progress(1);    #show the resolution of urls and loadtime to stdout
my $csvobject;
my $response;
my $request;
my @output;
my $link;
my $i = 1;
my $buffer;
my $cmd;
my $url;
my $date          = `date -u +"%D %H:%M:%S UTC"`;
my @alphabetarray = ( "A" .. "Z" );
chomp $date;

if ( $app eq "ec" )
{
	logit "setting EC headers and login post";
	my $turi = &ecloginurls($env);
	if ( $turi eq "" )
	{
		logit "EC Login url not available so quitting.....";
		print "EC Login url not available so quitting.....";
		die;
	}
	logit "Creating post request to $turi\n";
	$request = HTTP::Request->new( GET => $turi );

	#$request->authorization_basic($user,$pwd);
	$request->header( 'Accept' => 'text/html' );
	$response = $ua->request($request);
	$response = $ua->post(
						   $response->request()->uri(),
						   [
							  'userName' => $user,
							  'password' => $pwd,
							  'formId'   => "login",
							  'action'   => "Login"
						   ]
	);
	if ( $response->is_success )
	{
		logit "login to $turi success\n";
	}
}
elsif ( $app eq "reporter" )
{
	logit "Setting reporter headers and tokens";
	%reporterTokens = &get_reporterTokens($env);
	$header         = HTTP::Headers->new();
	$header->header( 'Accept' => '*/*', );
	while ( my ( $key, $value ) = each(%reporterTokens) )
	{
		$header->header( $key => $value );
	}
	$header->www_authenticate();
	$ua->default_headers($header);
	logit "Reporter token headers set...";
}
else
{
	logit "Creating general request and header objects";
	$request = HTTP::Request->new();
	$request->header( 'Accept' => 'text/html' );
	$response = $ua->request($request);
}
logit "starting Main loop to get load times of urls\n";

#print "content is: \n\n". $response->request()->uri()." \n";
#Main loop over the urls in file
if ( $outformat eq "csv" )
{
	print FILEOUT $date . ",";
}
else
{
	$csvobject =
	    '{ "rows" : { "1" : { "columns" : { "'
	  . shift(@alphabetarray) . '" : "'
	  . $date . "\"";
}
logit "starting main loop";
foreach $url (<FILE>)
{

	my $start    = time();
	$response = $ua->get($url);
	my $end      = time();
	
	if ( $response->is_success )
	{
		chomp $url;
		my $time = $end - $start;
		if ( $outformat eq "csv" )
		{
			print FILEOUT $time . ",";
		}
		else
		{
			$csvobject =
			    $csvobject . ",\""
			  . shift(@alphabetarray)
			  . "\" : \""
			  . $time . "\"";
		}

		#print "\nRedirected to : ",$response->request->uri, "\n\n";
		#$response = $ua->get($url);
		print "Success!\n";
	}
	elsif ( $response->is_redirect )
	{
		logit "Response is redirected: " . $response->request->uri . "\n";
		print $response->is_redirect;
		exit;
	}
	else
	{
		logit "Response must have errored \n";
		exit;
	}
	$i = $i + 1;
}
if ( $outformat eq "csv" )
{
	print FILEOUT "\n";
	close FILEOUT;
}
else
{
	$csvobject = $csvobject . "}}}}";
	print JSONOBJECT $csvobject;
	close JSONOBJECT;
}
close FILE;
close LOGFILE_HANDLE;
#####################Subroutine Definitions ######################
#get_date - Get current date and time
#
sub get_date()
{
	my $dtg = `date -u +"%D %H:%M:%S UTC"`;
	return $dtg;
}

#logit - create a log file and logs
#Parameters logfile handle, message
sub logit
{
	my $my_date = get_date();
	chomp $my_date;
	print LOGFILE_HANDLE "$my_date : LOG:  @_ \n";
}

#createrow - creates a row
#returns a hash for row
sub createrow($$)
{
}

#csv_to_json - converts to json format for google doc;
#return - json object
sub csv_to_json($)
{
	my @alphabetarray = ( "A" .. "Z" );
	my %columnhash;
	my @list = split( ",", $_[0] );
	foreach (@list)
	{
		$columnhash{ shift(@alphabetarray) } = $_;
	}

	#	print Dumper(\%columnhash), "\n";
	return %columnhash;
}

#get_reporterTokens - figures out the reporter tokens based on ENV
#return - hash
sub get_reporterTokens($)    #figure out the tokens based on env
{
	my %tokenhash = ();
	if ( $_[0] eq "dev" )
	{
		$tokenhash{"auth-token-access-key"} = "y7FNu7Hs4ItX";
		$tokenhash{"auth-token-scope"}      = "DEV-ALL";
		$tokenhash{"auth-token-password"}   = "password";
		$tokenhash{"auth-timestamp"}        = "1351622734";
	}
	elsif ( $_[0] eq "itg" )
	{
		$tokenhash{"auth-token-access-key"} = "eqzebbAs8k6o";
		$tokenhash{"auth-timestamp"}        = "1354112814";
		$tokenhash{"auth-token-password"}   = "password";
		$tokenhash{"auth-token-scope"}      = "ITG-ALL";
	}
	elsif ( $_[0] eq "pro" )
	{
		$tokenhash{"auth-token-access-key"} = "ubN2bxobkleG";
		$tokenhash{"auth-token-scope"}      = "PRO-ALL";
		$tokenhash{"auth-token-password"}   = "20110726\$TDataMart";
		$tokenhash{"auth-timestamp"}        = "1340055977";
	}
	logit "Returning reporter hash: $tokenhash{'auth-token-scope'}\n";
	return %tokenhash;
}

#ecloginurls - figures out the ec login url based on env
#returns - string
sub ecloginurls($)
{
	logit "Getting eclogin urls";
	my $ecurl;
	if ( $_[0] eq "dev" )
	{
		$ecurl = "";
	}
	elsif ( $_[0] eq "itg" )
	{
		$ecurl = "https://ecitg1.atlanta.aws.com/commander/link/login";
	}
	elsif ( $_[0] eq "pro" )
	{
		$ecurl = "https://ec5.boi.aws.com/commander/link/login";
	}
	logit "EC login url for $env is $ecurl";
	return $ecurl;
}
