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
use Mouse;
use General;

extends 'General';

has [qw/site apikey secretkey flag command/] => (is => "rw", isa => "Str");

#call print_xml to get the output
sub get_output{
	my $self = shift;
	
	if($self->json){
		#print in json output
		$self->get_json();
	}else{
		#print in xml output
		$self->get_xml();
		$self->print_xml();
	}
}

#check config and set the API connection
sub check{
	my $self = shift;

	$self->init();
	
	#set site , apikey, secretkey
	$self->site($self->xmlconfig->findnodes(qq|/root/site/profile/name[text()="| . $self->default_site . qq|"]/../urlpath/text()|)->string_value());
	my $sslverifyhost = $self->trim($self->xmlconfig->findnodes(qq|/root/site/profile/name[text()="| . $self->default_site . qq|"]/../sslverifyhostname/text()|)->string_value());
	$self->apikey($self->xmlconfig->findnodes(qq|/root/site/profile/name[text()="| . $self->default_site . qq|"]/../key/apikey/text()|)->string_value());
	$self->secretkey($self->xmlconfig->findnodes(qq|/root/site/profile/name[text()="| . $self->default_site . qq|"]/../key/secretkey/text()|)->string_value());
	
	#check url
	die "Please configure the correct urlpath\n" unless $self->site =~ /^http.*api\?$/;
	
	#check ssl verify hostname
	die "please set sslverifyhostname 0|1 (0 - disable, 1 - enable)\n" unless $sslverifyhost =~ /^[0|1]/;
	
	#set perl lwp ssl env
	$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = $sslverifyhost;
	
	#check apikey
	die "please set apikey\n" unless $self->apikey ne '';
	
	#check secretkey
	die "please set secretkey\n" unless $self->secretkey ne '';
	
}

#return API result
sub get_result{
	my $self = shift;
	
	#my ($site, $command, $api_key, $secret_key, $flag) = @_;
	my ($field,$value);
	my $my_filename = basename($0, '');
	my $uri = URI::Encode->new();

	### Generate URL ###
	#step1
	
	my $query = $self->command . "&apiKey=". $self->apikey;
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
	my $digest = hmac_sha1($output, $self->secretkey);
	my $base64_encoded = encode_base64($digest);chomp($base64_encoded);
	my $url_encoded = $uri->encode($base64_encoded, 1); # encode_reserved option is set to 1
	my $url = $self->site."apikey=".$self->apikey."&".$self->command."&signature=".$url_encoded;
	
	if($self->flag == 1 || $self->flag ==3){
		return $url;
		if($self->flag == 1){
			exit;
		}
	}
	
	### get URL ###
	my $mech = WWW::Mechanize->new(autocheck => 1);
	my $temp;
	eval {  $temp = $mech->get($url); };
	
	if($@){
		my $resp = $mech->response();;
		for my $key($resp->header_field_names()){
			print $key, " : ", $resp->header( $key ), "\n" if $key =~ /Description/;
		}
		die "Error getting response from server, check the description above\n";
	}
	
	if($self->command =~ /response=json/){ #json
		my $obj = from_json($mech->content);
		my $json = JSON->new->pretty(1)->encode($obj);
		print $json;
		#return $json;
		
	}
	else
	{ #XML
		my $xml = encode('cp932',$mech->content); #cp932 for Win environment(ActivePerl)
		#my $twig = XML::Twig->new(pretty_print => 'indented', );
		#$twig->parse($xml);
		#$twig->print;
		#print $xml;
		$self->xmlresult($xml);
		
	}
}

#get xml result
sub get_xml{
	my $self = shift;
	
	$self->check;
	$self->flag(2);
	$self->get_result($self->site, $self->command, $self->apikey, $self->secretkey, $self->flag);
}

#get json result
sub get_json{
	my $self = shift;
	
	$self->check;
	$self->flag(2);
	$self->command($self->command . "&response=json");
	$self->get_result($self->site, $self->command, $self->apikey, $self->secretkey, $self->flag);
}

#get url result
sub get_url{
	my $self = shift;
	
	$self->check;
	$self->flag(1);
	$self->get_result($self->site, $self->command, $self->apikey, $self->secretkey, $self->flag);
}

#get json and xml result
sub get_both{
	my $self = shift;
	
	$self->check;
	$self->flag(3);
	$self->get_result($self->site, $self->command, $self->apikey, $self->secretkey, $self->flag);
}
1;

=head1 NAME

GenUrl		- Implements connection to API

=head1 METHOD

=over

=item check

check and set API connection attributes

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
