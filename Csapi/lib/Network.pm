package Network;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

sub set_listnetworks_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Network/listnetworks.xml"));
}

sub list_networks{
    my $self = shift;
    
    #set xmltmp
    $self->set_listnetworks_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
   
    #set id if not set
    if(defined $self->uuid){        
        $self->command($self->command . "&id=" . $self->uuid) unless $self->param =~ /\bid=\b/;   
    }
   
    #print the output
    $self->get_output();
}

1;