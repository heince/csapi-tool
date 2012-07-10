package Project;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

has [ qw /project_name project_displaytext/ ] => ( is => 'rw' );
has [ qw /project_id project_account invitation_id/ ] => ( is => 'rw' );

#default to listProjects
sub set_list_xml{
    my $self = shift;
    
    $self->set_listProjects_xml();
}

sub set_listProjects_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Project/listProjects.xml"));
}

sub list_projects{
    my $self = shift;
    
    #set xmltmp
    $self->set_listProjects_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
   
    #print the output
    $self->get_output();
}

sub set_listProjectInvitations_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Project/listProjectInvitations.xml"));
}

sub list_projectInvitations{
    my $self = shift;
    
    #set xmltmp
    $self->set_listProjectInvitations_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
   
    #print the output
    $self->get_output();
}

sub set_suspend_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Project/suspend.xml"));
}

sub set_required_suspend{
    my $self = shift;
    
    $self->set_project_id;  
}

sub suspend{
    my $self = shift;
    
    #set xmltmp
    $self->set_suspend_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_suspend();
    
    #print the output
    $self->get_output();
}

sub set_activate_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Project/activate.xml"));
}

sub set_required_activate{
    my $self = shift;
    
    $self->set_project_id; 
}

sub activate{
    my $self = shift;
    
    #set xmltmp
    $self->set_activate_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_activate();
    
    #print the output
    $self->get_output();
}

sub set_updateProject_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Project/updateProject.xml"));
}

sub set_required_updateProject{
    my $self = shift;
    
    $self->set_project_id;
    $self->set_updateProject_account;
    $self->set_project_displaytext;
}

sub update_project{
    my $self = shift;
    
    #set xmltmp
    $self->set_updateProject_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_updateProject();
    
    #print the output
    $self->get_output();
}

sub set_updateProjectInvitation_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Project/updateProjectInvitation.xml"));
}

sub set_required_updateProjectInvitation{
    my $self = shift;
    
    $self->set_projectID;
    $self->set_updateProject_account;
}

sub update_projectInvitation{
    my $self = shift;
    
    #set xmltmp
    $self->set_updateProjectInvitation_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_updateProjectInvitation();
    
    #print the output
    $self->get_output();
}

sub set_deleteProjectInvitation_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Project/deleteProjectInvitation.xml"));
}

sub set_required_deleteProjectInvitation{
    my $self = shift;
    
    $self->set_invitation_id;
}

sub delete_projectInvitation{
    my $self = shift;
    
    #set xmltmp
    $self->set_deleteProjectInvitation_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #set required param
    $self->set_required_deleteProjectInvitation();
    
    #print the output
    $self->get_output();
}

#set xmltmp to hold create project xml file
sub set_create_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Project/create.xml"));
}

sub set_required_create{
    my $self = shift;
    
    $self->set_project_name;
    $self->set_project_displaytext;
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

#set xmltmp to hold delete project xml file
sub set_delete_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Project/delete.xml"));
}

#set param that required for deleting project
sub set_required_delete{
    my $self = shift;
    
    $self->set_project_id;
   
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

#set project id using id param
sub set_project_id{
    my $self = shift;
    
    $self->command($self->command . "&id=" . $self->project_id);
}

#set project id using projectid param
sub set_projectID{
    my $self = shift;
    
    $self->command($self->command . "&projectid=" . $self->project_id);
}

sub set_project_name{
    my $self = shift;
    
    $self->command($self->command . "&name=" . $self->project_name) if $self->project_name;
}

sub set_updateProject_account{
    my $self = shift;
    
    $self->command($self->command . "&account=" . $self->project_account) if $self->project_account;
}

sub set_project_displaytext{
    my $self = shift;
    
    $self->command($self->command . "&displaytext=" . $self->project_displaytext) if $self->project_displaytext;
}

sub set_invitation_id{
    my $self = shift;
    
    $self->command($self->command . "&id=" . $self->invitation_id)
}

1;