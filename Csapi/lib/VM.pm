package VM;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/VM/list.xml"));
}

sub set_stop_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/VM/stop.xml"));
}

sub set_start_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/VM/start.xml"));
}

sub set_reboot_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/VM/reboot.xml"));
}

sub get_displayname{
    my $self = shift;
    
    $self->set_list_xml();
    $self->param("id=" . $self->uuid);
    $self->response("displayname");
    $self->set_command();
    $self->get_xml();
    return $self->get_api_result;
}

sub list_vm{
    my $self = shift;
    
    #set xmltmp
    $self->set_list_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
   
    #print the output
    $self->get_output();
}

sub stop_vm{
    my $self = shift;
    
    my $displayname = shift;
    
    #set xmltmp
    $self->set_stop_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    if(defined $self->uuid){
        say "\nstopping " . $self->uuid . " a.k.a @$displayname";
        
        $self->command($self->command . "&id=" . $self->uuid) unless $self->param =~ /\bid=\b/;
    }
    
    #print the output
    $self->get_output();
}

sub start_vm{
    my $self = shift;
    
    my $displayname = shift;
    
    #set xmltmp
    $self->set_start_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    if(defined $self->uuid){
        say "\nstarting " . $self->uuid . " a.k.a @$displayname";
        
        $self->command($self->command . "&id=" . $self->uuid) unless $self->param =~ /\bid=\b/;
    }
    
    #print the output
    $self->get_output();
}

sub reboot_vm{
    my $self = shift;
    
    my $displayname = shift;
    
    #set xmltmp
    $self->set_reboot_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    if(defined $self->uuid){
        say "\nrebooting " . $self->uuid . " a.k.a @$displayname";
        
        $self->command($self->command . "&id=" . $self->uuid) unless $self->param =~ /\bid=\b/;
    }
    
    #print the output
    $self->get_output();
}

1;