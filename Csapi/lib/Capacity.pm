package Capacity;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Capacity/list.xml"));
}

sub action{
	my $self = shift;
	
	my $action = shift;
	
	#set xmltmp
	given($action){
		when ('listCapacity'){
			$self->set_list_xml();
		}
	}
	
	#set initial command and xmlresult attr
    $self->set_command();
   
    #set id if not set
    if(defined $self->uuid){        
        $self->command($self->command . "&clusterid=" . $self->uuid) if $self->uuid;   
    }
   
    #print the output
    $self->get_output();
}

sub list{
	my $self = shift;
    
    $self->action('listCapacity');
}


1;