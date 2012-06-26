package Account;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

has [ qw /accid acctype accemail fname lname uname accpass/ ] => ( is => 'ro' );

#set xmltmp to hold list account xml file
sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/list.xml"));
}

#set xmltmp to hold create acccount xml file
sub set_create_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/create.xml"));
}

#set xmltmp to hold delete acccount xml file
sub set_delete_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/delete.xml"));
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

#set account id
sub set_accid{
    my $self = shift;
    
    $self->command($self->command . "&id=" . $self->accid);
}

#set account type
sub set_acctype{
    my $self = shift;
    
    $self->command($self->command . "&accounttype=" . $self->acctype);
}

#set email
sub set_email{
    my $self = shift;
    
    $self->command($self->command . "&email=" . $self->accemail);
}

#set first name
sub set_fname{
    my $self = shift;
    
    $self->command($self->command . "&firstname=" . $self->fname);
}

#set last name
sub set_lname{
    my $self = shift;
    
    $self->command($self->command . "&lastname=" . $self->lname);
}

#set username
sub set_uname{
    my $self = shift;
    
    $self->command($self->command . "&username=" . $self->uname);
}

#set password
sub set_password{
    my $self = shift;
    
    use Digest::MD5 qw/md5_hex/ ;
    
    my $pass =  md5_hex($self->accpass);
    
    $self->command($self->command . "&password=" . $pass);
}

#set param that required for creating account
sub set_required_create{
    my $self = shift;
    
    $self->set_acctype;
    $self->set_email;
    $self->set_fname;
    $self->set_lname;
    $self->set_uname;
    $self->set_password;
}

#set param that required for deleting account
sub set_required_delete{
    my $self = shift;
    
    $self->set_accid;
}

sub create{
    my $self = shift;
    
    #set xmltmp
    $self->set_create_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_create();
    
    #print the output
    $self->get_output();
}

sub delete{
    my $self = shift;
    
    #set xmltmp
    $self->set_delete_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_delete();
    
    #print the output
    $self->get_output();
}

1;