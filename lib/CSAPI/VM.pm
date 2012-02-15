=head1 NAME

CSAPI::VM		- Implements VM actions

=head1 METHOD
	
=over

=item list_vm

list user's vm

=item start_vm

start vm

=item stop_vm

stop vm

=item reboot_vm

reboot vm

=item destroy_vm

destroy vm

=item deploy_vm

deploy vm

=item default_action

common procedure for start/stop/reboot/destroy

=item get_state

return vm's state

=back

=head1 AUTHOR

heince          	- heince@gmail.com

=cut

package CSAPI::VM;
use strict;
use warnings;
use 5.010;
use lib ("$ENV{'CSAPIROOT'}/lib");
use Carp qw /croak cluck carp confess/;

sub new{
	my $class = shift;
   my $self = bless({}, $class);
   return $self;
}

sub list_vm{
	my $self = shift;

	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile) = @_;
	
	my ($header,$result) = $general->api_response($site, $apikey, $secretkey, $general, $param, $response, $xmlfile);
	if(defined @$result){	
		return ($header,$result);
	}else{
		warn "no result from server\n";
	}
}

sub start_vm{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid) = @_;
	
	my $state = $self->get_state($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid);
	if(defined @$state){
		given("@$state"){
			when (/Running/){
				say "VM with id $vmid is already Running\n";break;
			}
			when (/Starting/){
				warn "VM with id $vmid is Starting\n";break;
			}
			default{
				my $vmstatus = $self->default_action($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid);
				return $vmstatus;
			}
		}
	}else{
		warn "VM with id $vmid not found\n";
	}
}

sub stop_vm{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid) = @_;
	
	my $state = $self->get_state($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid);	
	if(defined @$state){
		given("@$state"){
			when (/Stopped/){
				warn "VM with id $vmid is already Stopped\n";
			}
			when (/Stopping/){
				warn "VM with id $vmid is Stopping\n";
			}
			default{
				my $vmstatus = $self->default_action($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid);
				return $vmstatus;
			}
		}
	}else{
		warn "VM with id $vmid not found\n";
	}
}

sub reboot_vm{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid) = @_;
	
	my $state = $self->get_state($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid);	
	if(defined @$state){
		my $vmstatus = $self->default_action($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid);
		return $vmstatus;
	}else{
		warn "VM with id $vmid not found\n";
	}
}

sub destroy_vm{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid) = @_;
	
	my $state = $self->get_state($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid);	
	if(defined @$state){
		my $vmstatus = $self->default_action($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid);
		return $vmstatus;
	}else{
		warn "VM with id $vmid not found\n";
	}
}

sub deploy_vm{
	my $self = shift;

	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile) = @_;
	
	my ($header,$result) = $general->api_response($site, $apikey, $secretkey, $general, $param, $response, $xmlfile);
	my $vmid;
	for(@$result){
		$vmid .= $_;
	}
	chomp $vmid;
	$vmid = $general->trim($vmid);
	say "deploying ...\nVM id = $vmid ...";
	my $state = $self->get_state($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid);
	if(defined @$state){
		my $vmstatus = "VM state : @$state";
		return $vmstatus;
	}else{
		warn "can't get VM id $vmid state from server\n";
	}
}

sub default_action{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid) = @_;
	
	my ($header,$result) = $general->api_response($site, $apikey, $secretkey, $general, $param, $response, $xmlfile);
	my $vmstatus = $self->get_state($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid);
	$vmstatus = "VM id $vmid state : @$vmstatus";
	
	return $vmstatus;
}

sub get_state{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile, $vmid) = @_;
	$param = "id=$vmid";
	$response = "state";
	$xmlfile = "$ENV{'CSAPIROOT'}/config/VM/list.xml";
	
	my ($header,$result) = $self->list_vm($site, $apikey, $secretkey, $general, $param, $response, $xmlfile);
	return $result;
}

1;
