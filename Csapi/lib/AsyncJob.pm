package AsyncJob;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/AsyncJob/list.xml"));
}

sub set_query_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/AsyncJob/query.xml"));
}

sub list_asyncjob{
    my $self = shift;
    
    #set xmltmp
    $self->set_list_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
   
    #print the output
    $self->get_output();
}

sub query_asyncjob{
    my $self = shift;
    
    #set xmltmp
    $self->set_query_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
   
    #print the output
    $self->get_output();
}

1;