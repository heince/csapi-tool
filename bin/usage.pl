#!/usr/bin/env perl


=head1 NAME

usage.pl         	- Interface to generate resources usage

=head1 USAGE

=over

=item help

usage.pl -h

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
          ! GetOptions('help|h' => \$help, 'accountid|a=i' => \$accountid, 'startdate|s=s' => \$startdate,
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

$connection = $usage->init_check();

if(defined $type){
	given($type){
		when(/list/){
			say "1 - Running VM\n" .
				 "2 - Allocated VM\n" .
				 "6 - Volume";
		}
		when($_ == 1){
			$usage->get_running_vm($general,$connection, $accountid, $startdate, $enddate);
		}
		when($_ == 2){
			say "allocated vm";
		}
		default{
			say "default";
		}
	}
}

$connection->disconnect();
