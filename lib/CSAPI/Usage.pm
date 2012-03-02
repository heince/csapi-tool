=head1 NAME

CSAPI::Usage		- Implements Usage actions

=head1 METHOD
	
=over

=item list_usage

list usage

=back

=head1 AUTHOR

heince          	- heince@gmail.com

=cut

package CSAPI::Usage;
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

sub list_usage{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile) = @_;
	my ($xml,$doc,$result) = $general->process_request($site, $apikey, $secretkey, $general, $param, $response, $xmlfile);
	
	my @default_response = $general->get_default_response($response,$doc);
	my $header = $general->print_header(\@default_response,$doc);

	return ($header,$result);
}

1;
