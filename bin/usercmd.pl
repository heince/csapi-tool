#!/usr/bin/env perl


=head1 NAME

usercmd.pl         	- Interface to user's API

=head1 USAGE

=over

=item help

usercmd.pl -h

=item list all account attributes

usercmd.pl -l account 

=item list usable templates

usercmd.pl -l template 

=item list vms

usercmd.pl -l vm

=item list vm parameters

usercmd.pl -l vm -p list

=item list vm responses

usercmd.pl -l vm -r list

=item list service offering

usercmd.pl -l svc_offering

=item start vm

usercmd.pl -start vm -id 1,3,4

=item stop vm

usercmd.pl -stop vm -id 1,3,4

=item reboot vm

usercmd.pl -reboot vm -id 1,3,4

=item destroy vm

usercmd.pl -destroy vm -id 1,3,4

=item deploy new vm

usercmd.pl -deploy -p serviceofferingid=[id], templateid=[id], zoneid=[id], name=[name], ipaddress=[ip]

=item list deploy vm parameters

usercmd.pl -deploy vm -p list

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

#new object general
use General;
my $general = new General::;

#get elements from config.xml
my ($site, $apikey, $secretkey, $obj) = $general->init_check(@ARGV);

my ($help, $list, $start, $stop, $reboot, $destroy, $deploy, $id, $param, $response);

#check & define Getopt::Long options
usage() if ( @ARGV < 1 or
          ! GetOptions('help|h' => \$help, 'list|l=s' => \$list, 'start=s' => \$start, 'stop=s' => \$stop,
          				'reboot=s' => \$reboot, 'destroy=s' => \$destroy, 'deploy=s' => \$deploy, 'id=s' => \$id,
							'param|p=s' => \$param, 'response|r=s' => \$response) or defined $help );
 
#usage function
sub usage
{
	do {system "perldoc $0";exit;} if defined $help;
  	say "use -h for help";
  	say "Unknown option: @_" if ( @_ );
  	exit;
}

use Options;
my $options = new Options::;
$options->check_options($general, $site, $apikey, $secretkey, $obj, $list, $start, $stop, $reboot, $destroy, $deploy, $id, $param, $response);
exit;

