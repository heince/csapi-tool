=head1 NAME

CSAPI::Template		- Implements Template actions

=head1 METHOD
	
=over

=item list_executable

list executable & usable templates

=back

=head1 AUTHOR

heince          	- heince@gmail.com

=cut

package CSAPI::Template;
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

sub list_template{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile) = @_;
	
	
		my $tmp = $general->load_xml($xmlfile);
		if(defined $param){
			unless($param =~ /templatefilter/){
				$param = "templatefilter=" . $tmp->findnodes("/root/defaultfilter")->string_value() . ",$param";
			}
		}else{
			$param = "templatefilter=" . $tmp->findnodes("/root/defaultfilter")->string_value();
		}
	
	my ($xml,$doc,$result) = $general->process_request($site, $apikey, $secretkey, $general, $param, $response, $xmlfile);
	
	my @default_response = $general->get_default_response($response,$doc);
	my $header = $general->print_header(\@default_response,$doc);

	return ($header,$result);
}

1;
