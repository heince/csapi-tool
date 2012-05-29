package General;
use v5.10;
use Mouse;
use strict;
use warnings;
use XML::LibXML;
use Field;

extends 'Field';

has [qw/xmlconfig xmltmp xmlresult/] => (is => "rw");
has [qw/default_site param response noheader json uuid/] => (is => "rw");

#load and set xmlconfig and default site
sub init{
	my $self = shift;
	
	$self->get_xml_config();
	$self->default_site($self->xmlconfig->findnodes("/root/site/default")->string_value()) unless $self->default_site;
}

#print xml result
sub print_xml{
	my $self = shift;
	
	if(defined $self->noheader){
		#print content
		print @{$self->get_api_result()};
	}else{
		#print header
		my $default_responses = $self->get_default_response();
		print @{$self->set_header($default_responses, $self->xmltmp)};
		 
		#print content
		print @{$self->get_api_result()};
	}
}

#set listall in command
sub set_listall{
	my $self = shift;
	
	$self->command($self->command . "&listall=" . $self->xmltmp->findnodes('/root/listall')->string_value());
}

#return api result in formatted field
sub get_api_result{
	my $self = shift;
	
	my $xml = XML::LibXML->load_xml(string => $self->xmlresult);
	
	#array for storing default / user's custom responses
	my $default = $self->get_default_response();
	
	my @result;	
		
	my $top = $self->xmltmp->findnodes('/root/top')->string_value();
	
	my @vm = $xml->findnodes("$top");
	
	for my $vms(@vm){
		for my $attr(@$default){
			$attr = $self->trim($attr);
			#get attr's pack
			my $pack = "A" . $self->$attr;
			
			my @path =  $self->xmltmp->findnodes("/root/responses/response/name[text()=\"$attr\"]/../path/text()");
			if(@path){
				for my $string(@path){
					my $str = $string->data;
					my @array = split '::', $str;
					my $url;
					for(@array){
						$url .= "$_/";	
					}
					chop($url);
					push(@result,$self->pack_response($attr,$pack,$vms->findnodes("$url")->string_value));
				}	
			}else{
				push(@result,$self->pack_response($attr,$pack,$vms->findnodes("$attr")->string_value()));
			}
		}
			
		push(@result,$self->pack_response('','A1',"\n"));
	}
	$self->response(undef);
	return \@result;
}

#set command
sub set_command{
	my $self = shift;
	
	my ($string);
	
	if(defined $self->param){
		my @params = split ',', $self->param;
	
		for(@params){
		$string .= "&$_";
		}
		
		$self->command("command=" . $self->xmltmp->findnodes('/root/command')->string_value() . $string);
		
	}else{
		$self->command("command=" . $self->xmltmp->findnodes('/root/command')->string_value());
	}
	
}

#get default xml responses
sub get_default_response{
	my $self = shift;

	my @array;
	
	if(defined $self->response){
		@array = split ',', $self->response;
	}else{
		@array = (split ',' , $self->xmltmp->findnodes('/root/defaultresponses')->string_value());
	}
	
	return \@array;
}

#return header
sub set_header{
	my $self = shift;
	
	my ($attr,$doc) = @_;
	
	my @header;
	
	for(@$attr){
		my $tmp = $self->trim($_);
		my $pack = "A" . $self->$tmp;
		push(@header, uc pack($pack,$tmp));
	}
	push(@header,"\n\n");
	return \@header;
}

#return pack response result
sub pack_response{
	my $self = shift;
	
	my ($attr,$pack,$response) = @_;
	my $field = $response;	
	
	given($attr){
		when (/memory/){
			$field .= " MB";
		}
		when (/\bsize\b/){
			if($field){
				$field = ($field/1024/1024/1024);
				$field = sprintf("%.2f",$field) . " GB";
			}
		}
		when (/\bdisksize\b/){
			$field .= " GB";
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
		when (/\bjobstatus\b/){
			when ($field eq '0'){
				$field = "in progress";
			}
			when ($field eq '1'){
				$field = "completed";
			}
			when ($field eq '2'){
				$field = "failed";
			}
		}
		when (/\bjobresult\b/){
			if(length($field) > 200){
				$field = "Completed";
			}
		}
	}	
	#say "field:" . $field;
	return pack($pack,$field);
}

#get and print supported param
sub print_param{
	my $self = shift;
	
	my @params = $self->xmltmp->findnodes("/root/params/param");
	for my $value(@params){
		my $name = $value->findnodes("name")->string_value();
		my $description = $value->findnodes("description")->string_value();
		my $required = $value->findnodes("required")->string_value();
		
		say "name\t\t: $name";
		say "description\t: $description";
		say "required\t: $required";
		print "\n";
	}
}

#get and print supported response
sub print_response{
	my $self = shift;
	
	my @params = $self->xmltmp->findnodes("/root/responses/response");
	for my $value(@params){
		my $name = $value->findnodes("name")->string_value();
		my $description = $value->findnodes("description")->string_value();
		
		say "name\t\t: $name";
		say "description\t: $description";
		print "\n";
	}
}

#get xml configuration
sub get_xml_config{
	my $self = shift;
	
	my $config = "$ENV{'CSAPI_ROOT'}/config/config.xml";

	unless (-f $config){
	  die "config file is not exist\n";
	}
	
	$self->xmlconfig(XML::LibXML->load_xml(location => $config));
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