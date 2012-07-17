package Account;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

has [ qw/acctype fname lname accpass uname/ ] => ( is => 'ro' );
has [ qw/accid acclock accemail accname/ ] => ( is => 'rw' );

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

sub set_update_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/update.xml"));
}

sub set_disable_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/disable.xml"));
}

sub set_enable_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/enable.xml"));
}

sub set_addAccountToProject_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/addAccountToProject.xml"));
}

sub set_listProjectAccounts_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/listProjectAccounts.xml"));
}

sub set_deleteAccountFromProject_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/deleteAccountFromProject.xml"));
}

sub get_accname_bydomid{
    my $self = shift;
    
    my $domid = shift;
    
    #set xmltmp
    $self->set_list_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    $self->command($self->command . "&listall=true&domainid=$domid");
    $self->response("name");
    
    $self->get_xml;
    
    return $self->get_api_result();
}

sub get_accid{
    my $self = shift;
    
    my ($domid, $name) = @_;
    
    #set xmltmp
    $self->set_list_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    $self->command($self->command . "&domainid=$domid&name=$name");
    $self->response("id");
    
    $self->get_xml;
    
    return $self->get_api_result();
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
    
    $self->command($self->command . "&id=" . $self->accid) if $self->accid;
}

#set account type
sub set_acctype{
    my $self = shift;
    
    $self->command($self->command . "&accounttype=" . $self->acctype);
}

#set email
sub set_email{
    my $self = shift;
    
    $self->command($self->command . "&email=" . $self->accemail) if $self->accemail;
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
    
    $self->command($self->command . "&username=" . $self->uname) if $self->uname;
}

sub set_accname{
    my $self = shift;
    
    $self->command($self->command . "&account=" . $self->accname) if $self->accname;
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

#set param that required for deleting account
sub set_required_delete{
    my $self = shift;
    
    $self->set_accid;
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

sub set_required_update{
    my $self = shift;
    
    $self->set_accid;
}

sub update{
    my $self = shift;
    
    #set xmltmp
    $self->set_update_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_update();
    
    #print the output
    $self->get_output();
}

sub set_required_disable{
    my $self = shift;
    
    $self->set_accid;
    
    if($self->acclock){
        $self->command($self->command . "&lock=true");
    }else{
        $self->command($self->command . "&lock=false");
    }
}

sub disable{
    my $self = shift;
    
    #set xmltmp
    $self->set_disable_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_disable();
    
    #print the output
    $self->get_output();
}

sub set_required_enable{
    my $self = shift;
    
    $self->set_accid;
    
}

sub enable{
    my $self = shift;
    
    #set xmltmp
    $self->set_enable_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_enable();
    
    #print the output
    $self->get_output();
}

sub set_required_deleteAccountFromProject{
    my $self = shift;
    
    $self->set_accname;
}

sub delete_accountFromProject{
    my $self = shift;
    
    my ($projectid) = shift;
    
    #set xmltmp
    $self->set_deleteAccountFromProject_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #add projectid command
    $self->command($self->command . "&projectid=$projectid");
    
    #set other required param if any
    $self->set_required_deleteAccountFromProject;
    
    #print the output
    $self->get_output();
}

sub set_required_addAccountToProject{
    my $self = shift;
    
    $self->set_email;
    $self->set_accname;
    
}

sub addAccountToProject{
    my $self = shift;
    
    my ($projectid) = shift;
    
    #set xmltmp
    $self->set_addAccountToProject_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #add projectid command
    $self->command($self->command . "&projectid=$projectid");
    
    #set other required param if any
    $self->set_required_addAccountToProject;
    
    #print the output
    $self->get_output();
}

sub list_projectAccounts{
    my $self = shift;
    
    my ($projectid) = shift;
    
    #set xmltmp
    $self->set_listProjectAccounts_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #add projectid command
    $self->command($self->command . "&projectid=$projectid");
    
    #print the output
    $self->get_output();
}

1;