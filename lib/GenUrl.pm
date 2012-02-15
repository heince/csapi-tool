=head1 NAME

GenUrl		- Implements connection to API

=head1 METHOD

=over

=item get_xml 	

get xml output

=item get_json 	

get json output

=item get_url  	

get api url

=item get_both	

get url and xml output

=item get_result

process above method and return xml 

=back

=head1 AUTHOR

snumano			- modified his script for this module

heince          	- heince@gmail.com

=cut

package GenUrl;
use strict;
use warnings;
use 5.010;

use Digest::SHA qw(hmac_sha1);
use File::Basename qw(basename);
use MIME::Base64;
use WWW::Mechanize;
use Encode;
use XML::Twig;
use URI::Encode;
use JSON;

sub new{
	my $class = shift;
   my $self = bless({}, $class);
   return $self;
}

sub get_result{
	my ($site, $command, $api_key, $secret_key, $flag) = @_;
	my ($field,$value);
	my $my_filename = basename($0, '');
	my $uri = URI::Encode->new();

	### Generate URL ###
	#step1
	
	my $query = $command."&apiKey=".$api_key;
	my @list = split(/&/,$query);
	foreach (@list){
		if(/(.+)\=(.+)/){
			$field = $1;
			$value = $uri->encode($2, 1); # encode_reserved option is set to 1
			$_ = $field."=".$value;
		}
	}
	
	#step2
	foreach (@list){
	$_ = lc($_);
	}
	my $output = join("&",sort @list);
	
	#step3
	my $digest = hmac_sha1($output, $secret_key);
	my $base64_encoded = encode_base64($digest);chomp($base64_encoded);
	my $url_encoded = $uri->encode($base64_encoded, 1); # encode_reserved option is set to 1
	my $url = $site."apikey=".$api_key."&".$command."&signature=".$url_encoded;
	
	if($flag == 1 || $flag ==3){
		return $url;
		if($flag == 1){
			exit;
		}
	}
	
	### get URL ###
	my $mech = WWW::Mechanize->new();
	$mech->get($url);
	#eval {$mech->get($url);};

	die "Error getting response from server\n" unless $mech->success();	
	
	if($command =~ /response=json/){ #json
		my $obj = from_json($mech->content);
		my $json = JSON->new->pretty(1)->encode($obj);
		return $json;
	}
	else
	{ #XML
		my $xml = encode('cp932',$mech->content); #cp932 for Win environment(ActivePerl)
		#my $twig = XML::Twig->new(pretty_print => 'indented', );
		#$twig->parse($xml);
		#$twig->print;
		return $xml;
		
	}
}

	
sub get_xml{
	my $self = shift;
	my ($site, $command, $api_key, $secret_key) = @_;
	get_result($site, $command, $api_key, $secret_key, 2);
}

sub get_json{
	my $self = shift;
	my ($site, $command, $api_key, $secret_key) = @_;
	$command = $command . "&response=json";
	get_result($site, $command, $api_key, $secret_key, 2);
}

sub get_url{
	my $self = shift;
	my ($site, $command, $api_key, $secret_key) = @_;
	get_result($site, $command, $api_key, $secret_key, 1);
}

sub get_both{
	my $selft = shift;
	my ($site, $command, $api_key, $secret_key) = @_;
	get_result($site, $command, $api_key, $secret_key, 3);
}
1;
