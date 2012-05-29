package Template;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

has 'templatefilter' => ( is => "rw", default => "executable");

#set xmltmp to hold list template xml file
sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Template/list.xml"));
}

sub list_template{
    my $self = shift;
    
    #set xmltmp
    $self->set_list_xml();
    
    #set default filter
    if($self->param){
        $self->param($self->param . "&templatefilter=" . $self->templatefilter) unless $self->param =~ /\btemplatefilter=\b/;
    }else{
        $self->param("templatefilter=" . $self->templatefilter);
    }
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #print the output
    $self->get_output();
}

1;