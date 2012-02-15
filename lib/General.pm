=head1 NAME

General			-	Implements general functions

=head1 METHOD

=over

=item init_check			

check environment ,configuration file and return @array ($xml, $urlpath, $api_key, $secret_key)

=item generate_xml

return xml from GenUrl get_xml

=item pack_response

pack response from get_response

=item submit_request

submit request to server

=item print_header

print the header

=item get_response

get response from REST

=item get_param

return param list / value

= item load_xml

load xml from file

=item trim

to trim a string

=back

=head1 AUTHOR

heince          	- heince@gmail.com

=cut

package General;
use strict;
use warnings;
use 5.010;
use XML::Simple;
use lib ("$ENV{'CSAPIROOT'}/lib");
use GenUrl;

sub new{
	my $class = shift;
   my $self = bless({}, $class);
   return $self;
}

sub load_xml{
	my $self = shift;
	
	my $xmlfile = shift;
	my $parser = XML::LibXML->new;
	my $doc = $parser->parse_file($xmlfile);
	return $doc;
}

sub generate_xml{
	my $self = shift;
	
	my $url = new GenUrl;
	my $xml = $url->get_xml(@_);
	return $xml;
}

sub check_id{
	my $self = shift;
	
	my $id = shift;
	my @list;
	
	if(defined $id){
		@list = split ',' , $id;
		map {die "id must be integer value\n" unless /\d+$/} @list;
	}else{
		warn "id must be defined\n";
	}
	return \@list;
}

sub get_param{
	my $self = shift;
	
	my ($param,$doc) = @_;
	
	given($param){
		when (/\blist\b/i){
			my @params = $doc->findnodes("/root/params/param");
			for my $value(@params){
				my $name = $value->findnodes("name")->string_value();
				my $description = $value->findnodes("description")->string_value();
				my $required = $value->findnodes("required")->string_value();
				
				say "name\t\t: $name";
				say "description\t: $description";
				say "required\t: $required";
				print "\n";
			}
			exit;
		}
		default{
			return $param;
		}
	}
}

sub set_response{
	my $self = shift;
	
	my ($response,$doc) = @_;

	given($response){
		when (/\blist\b/i){
			my @responses = $doc->findnodes("/root/responses/response");
			for my $value(@responses){
				my $name = $value->findnodes("name")->string_value();
				my $description = $value->findnodes("description")->string_value();
				
				say "name\t\t: $name";
				say "description\t: $description";
				print "\n";
			}
			exit;
		}
		default{
			return $response;
		}
	}	
}

sub process_request{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile) = @_;
	my $doc = $self->load_xml($xmlfile);
	$param = $self->get_param($param,$doc) if defined $param;
	$response = $self->set_response($response,$doc) if defined $response;
	
	my $xml = $self->submit_request($site, $apikey, $secretkey, $doc, $param);
	my @result = $self->get_response($doc,$xml,$response);
	return ($xml,$doc,\@result);
}

sub submit_request{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $doc, $param) = @_;
	
	my ($cmd, $string);
	
	if(defined $param){
		my @params = split ',', $param;
	
		for(@params){
		$string .= "&$_";
		}
		
		$cmd = "command=" . $doc->findnodes('/root/command')->string_value() . $string;
		
	}else{
		$cmd = "command=" . $doc->findnodes('/root/command')->string_value();
	}
	
	my $response = $self->generate_xml($site, $cmd, $apikey, $secretkey);
	return $response;
}

sub get_default_response{
	my $self = shift;
	
	my ($response, $doc) = @_;
	my @array;
	
	if(defined $response){
		@array = split ',', $response;
	}else{
		@array = split ',' , $doc->findnodes('/root/defaultresponses')->string_value();
	}
	
	return @array;
}

sub get_response{
	my $self = shift;
	my($doc,$responses,$response) = @_;
	
	my $xml = XML::LibXML->load_xml(string => $responses);
	
	#array for storing default / user's custom responses
	my @default = $self->get_default_response($response,$doc);
	
	my @result;	
		
	my $top = $doc->findnodes('/root/top')->string_value();
	
	my @vm = $xml->findnodes("$top");
	
	for my $vms(@vm){
		for my $attr(@default){
			$attr = $self->trim($attr);
			#get attr's pack
			my $pack = "A" . $doc->findnodes("/root/responses/response/name[text()=\"$attr\"]/../pack/text()");
			
			my @path =  $doc->findnodes("/root/responses/response/name[text()=\"$attr\"]/../path/text()");
			if(@path){
				for my $string(@path){
					my $str = $string->data;
					my @array = split '::', $str;
					my $url;
					for(@array){
						$url .= "$_/";	
					}
					chop($url);
					
					push(@result,pack_response($attr,$pack,$vms->findnodes("$url")->string_value));
				}	
			}else{
				push(@result,pack_response($attr,$pack,$vms->findnodes("$attr")->string_value));
			}
		}
			
		push(@result,pack_response('','A1',"\n"));
	}
	return @result;
}

sub api_response{
	my $self = shift;
	
	my ($site, $apikey, $secretkey, $general, $param, $response, $xmlfile) = @_;
	
	my ($xml,$doc,$result) = $general->process_request($site, $apikey, $secretkey, $general, $param, $response, $xmlfile);

	my @default_response = $general->get_default_response($response,$doc);
	my $header = $general->print_header(\@default_response,$doc);

	return ($header,$result);
}

sub print_header{
	my $self = shift;
	
	my ($attr,$doc) = @_;
	
	my @header;
	
	for(@$attr){
		my $tmp = $self->trim($_);
		my $pack = "A" . $doc->findnodes("/root/responses/response/name[text()=\"$tmp\"]/../pack/text()");
		push(@header, uc pack($pack,$tmp));
	}
	push(@header,"\n\n");
	return \@header;
}

sub pack_response{
	
	my ($attr,$pack,$response) = @_;
		my $field = $response;	
	
		given($attr){
			when (/memory/){
				$field .= " MB";
			}
			when (/size/){
				$field = ($field/1024/1024/1024);
				$field = sprintf("%.2f",$field) . " GB";
			}
			when (/cpuspeed/){
				$field .= " MHz";
			}
			when (/accounttype/){
				when ($field eq '0'){
					$field = "0(user)";
				}
				when ($field eq '1'){
					$field = "1(admin)";
				}
				when ($field eq '2'){
					$field = "2(domain-admin)";
				}
			}
		}	
	
		return pack($pack,$field);
}

sub init_check{
	my $self = shift;
	
	my @param = @_;
	my $obj;
	
	my $config = "$ENV{'CSAPIROOT'}/config/config.xml";

	unless (-d $ENV{'CSAPIROOT'} && -f $config){
	  die "CSAPIROOT directory or config file is not exist\n";
	}
	
	my $xml = XMLin($config);
	my $urlpath = $self->trim($xml->{urlpath});
	my $sslverifyhost = $self->trim($xml->{sslverifyhostname});
	my $api_key = $self->trim($xml->{key}->{apikey});
	my $secret_key = $self->trim($xml->{key}->{secretkey});
	
	#check url
	die "Please configure the correct urlpath\n" unless $urlpath =~ /^http.*api\?$/;
	
	#check ssl verify hostname
	die "please set sslverifyhostname 0|1 (0 - disable, 1 - enable)\n" unless $sslverifyhost =~ /^[0|1]/;
	
	#set perl lwp ssl env
	$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = $xml->{sslverifyhostname};
	
	#check apikey
	die "please set apikey\n" unless $api_key ne '';
	
	for(@param){
	when (/\b^vm\b/){
		use CSAPI::VM;
		$obj = new CSAPI::VM;
	}
	when (/\b^account\b/){
		use CSAPI::Account;
		$obj = new CSAPI::Account;
	}
	when (/\btemplate\b/){
		use CSAPI::Template;
		$obj = new CSAPI::Template;
	}
	when (/\bsvc_offering\b/){
		use CSAPI::ServiceOffering;
		$obj = new CSAPI::ServiceOffering;
	}
}
	
	my @array = ($urlpath, $api_key, $secret_key, $obj);
	return @array;
}

sub trim
{
	my $self = shift;	
	
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
1;
