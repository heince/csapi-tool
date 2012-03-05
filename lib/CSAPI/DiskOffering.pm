=head1 NAME

CSAPI::DiskOffering	- Implements disk offerings actions

=head1 METHOD
	
=over

=item list_disk_offering

list Disk offering

=back

=head1 AUTHOR

heince          	- heince@gmail.com

=cut

package CSAPI::DiskOffering;
use strict;
use warnings;
use 5.010;
use XML::Simple;
use lib ("$ENV{'CSAPIROOT'}/lib");

sub new{
	my $class = shift;
   my $self = bless({}, $class);
   return $self;
}

sub list_disk_offering{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile) = @_;
	my ($xml,$doc,$result) = $general->process_request($site, $apikey, $secretkey, $general, $param, $response, $xmlfile);
	
	my @default_response = $general->get_default_response($response,$doc);
	my $header = $general->print_header(\@default_response,$doc);

	return ($header,$result);
}

1;
