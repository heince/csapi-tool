package Account;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

#set xmltmp to hold list account xml file
sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/list.xml"));
}

sub list_account{
    my $self = shift;
    
    #set xmltmp
    $self->set_list_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #print the output
    $self->get_output();
}

1;