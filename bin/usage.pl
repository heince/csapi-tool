#!/usr/bin/env perl


=head1 NAME

usage.pl         	- Interface to generate resources usage

=head1 USAGE

=over

=item help

usage.pl -h

=item list available type

usage.pl -type list

=item example

List the usage for running vm on accountid 6 with startdate 2012-02-01 and enddate 2012-03-01:

usage.pl -type 1 -a 6 -s 2012-02-01 -e 2012-03-01

=back

=head1 AUTHOR

heince          	- heince@gmail.com

=cut

use strict;
use warnings;
use Getopt::Long;
use 5.010;

#check CSAPIROOT environment variable, assign if not been defined
BEGIN{
	$ENV{'CSAPIROOT'} = "$ENV{'HOME'}/Project/csapi-tool" if not defined $ENV{'CSAPIROOT'};
}

#define lib include path
use lib ("$ENV{'CSAPIROOT'}/lib");

#new object usage
use Usage;
my $usage = new Usage::;

my ($connection, $accountid, $startdate, $enddate, $help, $type);

#check & define Getopt::Long options
usage() if ( @ARGV < 1 or
          ! GetOptions('help|h' => \$help, 'accountid|a=s' => \$accountid, 'startdate|s=s' => \$startdate,
							  'enddate|e=s' => \$enddate, 'type=s' => \$type) or defined $help );

#usage function
sub usage
{
	do {system "perldoc $0";exit;} if defined $help;
  	say "use -h for help";
  	say "Unknown option: @_" if ( @_ );
  	exit;
}

#new object general
use General;
my $general = new General::;

#get the DB connection
$connection = $usage->init_check();

if(defined $type){
	given($type){
		when(/list/){
			say "1 - Running VM\n" .
				 "2 - Allocated VM\n" .
				 "6 - Volume";
		}
		when($_ == 1){
			$usage->get_usage($general,$connection, $accountid, $startdate, $enddate, 1);
		}
		when($_ == 2){
			$usage->get_usage($general,$connection, $accountid, $startdate, $enddate, 2);
		}
		when($_ == 6){
			$usage->get_usage($general,$connection, $accountid, $startdate, $enddate, 6);
		}
		default{
			say "Type not supported yet";
		}
	}
}

$connection->disconnect();
