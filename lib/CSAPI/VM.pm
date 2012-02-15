=head1 NAME

CSAPI::VM		- Implements VM actions

=head1 METHOD
	
=over

=item list_vm

list user's vm

=item start_vm

start vm by vmid

=item stop_vm

stop vm by vmid

=item reboot_vm

reboot vm by vmid

=item destroy_vm

destroy vm by vmid

=item deploy_vm

deploy new vm 

=back

=head1 AUTHOR

heince          	- heince@gmail.com

=cut

package CSAPI::VM;
use strict;
use warnings;
use 5.010;
use XML::LibXML;
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
	
	my ($xml,$doc,$result) = $general->process_request($site, $apikey, $secretkey, $general, $param, $response, $xmlfile);

	my @default_response = $general->get_default_response($response,$doc);
	my $header = $general->print_header(\@default_response,$doc);

	return ($header,$result);
}

sub modify_vm{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile) = @_;
	my ($xml,$doc,$result) = $general->process_request($site, $apikey, $secretkey, $general, $param, $response, $xmlfile);
}

1;
