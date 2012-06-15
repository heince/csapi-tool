package Domain;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Domain/list.xml"));
}

sub list_domains{
    my $self = shift;
    
    #set xmltmp
    $self->set_list_xml();
    
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