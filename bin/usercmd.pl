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

usercmd.pl -deploy -p service_offering_id=[id],templateid=[id],zone_id=[id]

=back

=head1 AUTHOR

heince          	- heince@gmail.com

=cut

use strict;
use warnings;
use XML::Simple;
use XML::Twig;
use Getopt::Long;
use 5.010;

#check CSAPIROOT environment variable, assign if not been defined
BEGIN{
	$ENV{'CSAPIROOT'} = "$ENV{'HOME'}/Documents/sf.net/csapi-user" if not defined $ENV{'CSAPIROOT'};
}

#define lib include path
use lib ("$ENV{'CSAPIROOT'}/lib");

#new object general
use General;
my $general = new General;

#get elements from config.xml
my ($config, $site, $apikey, $secretkey, $obj) = $general->init_check(@ARGV);

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
	

if(defined $list){
	given($list){
		when (/account/){
			my ($header, $result) = $obj->list_account($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/Account/list.xml");
			#print header & result
			print @$header; print @$result;
			exit;
		}
		when (/template/){
			my ($header, $result) = $obj->list_template($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/Template/list.xml");
			#print header & result
			print @$header; print @$result;
			exit;
		}
		when (/\bvm\b/){
			my ($header, $result) = $obj->list_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/list.xml");
			#print header & result
			print @$header; print @$result;
			exit;
		}
		when (/svc_offering/){
			my ($header, $result) = $obj->list_service_offering($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/ServiceOffering/list.xml");
			#print header & result
			print @$header; print @$result;
			exit;
		}
		default{
			say "unknown object to list, use -h for help";
			exit;
		}
	}
}

if(defined $start){
	given($start){
		when (/\bvm\b/i){
			my $id = $general->check_id($id);
			for(@$id){
				$param="id=$_";
				$obj->modify_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/start.xml");
			}
			exit;
		}
		default{
			say "no available action (start $start)";
		}
	}
}

if(defined $stop){
		given($stop){
		when (/\bvm\b/i){
			my $id = $general->check_id($id);
			for(@$id){
				$param="id=$_";
				$obj->modify_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/stop.xml");
			}
			exit;
		}
		default{
			say "no available actions (stop $stop)";
		}
	}
}

if(defined $reboot){
	given($reboot){
		when (/\bvm\b/i){
			my $id = $general->check_id($id);
			for(@$id){
				$param="id=$_";
				$obj->modify_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/reboot.xml");
			}
			exit;
		}
		default{
			say "no available actions (reboot $reboot)";
		}
	}
}

if(defined $destroy){
	given($destroy){
		when (/\bvm\b/i){
			my $id = $general->check_id($id);
			for(@$id){
				$param="id=$_";
				$obj->modify_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/destroy.xml");
			}
			exit;
		}
		default{
			say "no available actions (destroy $destroy)";
		}
	}
}

if(defined $deploy){
	given($deploy){
		when(/\bvm\b/i){
			$obj->modify_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/deploy.xml");
			exit;
		}
	}
}
