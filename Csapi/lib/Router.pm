package Router;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Router/list.xml"));
}

sub set_stop_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Router/stop.xml"));
}

sub set_start_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Router/start.xml"));
}

sub set_reboot_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Router/reboot.xml"));
}

sub set_destroy_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Router/destroy.xml"));
}

sub action{
	my $self = shift;
	
	my $action = shift;
	
	#set xmltmp
	given($action){
		when ('list'){
			$self->set_list_xml();
		}
		when ('stop'){
			$self->set_stop_xml();
		}
		when ('start'){
			$self->set_start_xml();
		}
		when ('reboot'){
			$self->set_reboot_xml();
		}
		when ('destroy'){
			$self->set_destroy_xml();
		}
	}
	
	#set initial command and xmlresult attr
    $self->set_command();
   
    #set id if not set
    if(defined $self->uuid){        
        $self->command($self->command . "&id=" . $self->uuid) if $self->uuid;   
    }
   
    #print the output
    $self->get_output();
}

sub list_routers{
	my $self = shift;
    
    $self->action('list');
}

sub stop_router{
    my $self = shift;
    
    $self->action('stop');
}

sub start_router{
    my $self = shift;
    
    $self->action('start');
}

sub reboot_router{
    my $self = shift;
    
    $self->action('reboot');
}

sub destroy_router{
    my $self = shift;
    
    $self->action('destroy');
}

1;