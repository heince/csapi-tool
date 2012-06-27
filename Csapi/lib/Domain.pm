package Domain;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

has [ qw /domname domid/ ] => ( is => 'ro' );

sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Domain/list.xml"));
}

sub set_create_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Domain/create.xml"));
}

sub set_delete_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Domain/delete.xml"));
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

#set domain id
sub set_domid{
    my $self = shift;
    
    $self->command($self->command . "&id=" . $self->domid);
}

#set domain name
sub set_domname{
    my $self = shift;
    
    $self->command($self->command . "&name=" . $self->domname);
}

#set required param to create domain
sub set_required_create{
    my $self = shift;
    
    $self->set_domname;
}

#set required param to delete domain
sub set_required_delete{
    my $self = shift;
    
    $self->set_domid;
}

#create domain
sub create{
    my $self = shift;
    
    #set xmltmp
    $self->set_create_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_create;
    
    #print the output
    $self->get_output();
}

#delete domain
sub delete{
    my $self = shift;
    
    #set xmltmp
    $self->set_delete_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_delete;
    
    #print the output
    $self->get_output();
}

1;