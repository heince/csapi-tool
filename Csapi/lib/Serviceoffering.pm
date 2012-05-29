package Serviceoffering;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

#set xmltmp to hold list serviceoffering xml file
sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/ServiceOffering/list.xml"));
}

sub list_serviceoffering{
    my $self = shift;
    
    #set xmltmp
    $self->set_list_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #print the output
    $self->get_output();
}

1;