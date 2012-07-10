package Zone;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Zone/list.xml"));
}

sub list_zones{
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

#return true if id is valid
sub is_valid_id{
    my $self = shift;
    
    my $id = shift;
    
    #set xmltmp
    $self->set_list_xml();
    
    #setparam
    $self->param("id=$id");
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    if($self->get_xml){
        return 1;
    }else{
        return 0;
    }
}

1;