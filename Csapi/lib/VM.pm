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

sub set_deploy_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/VM/deploy.xml"));
}

sub set_destroy_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/VM/destroy.xml"));
}

sub set_migrate_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/VM/migrate.xml"));
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

sub schedule_etime{
    my $self = shift;
    
    my $epoch = $self->get_epoch_time($self->etime);
    if($epoch){
        die "End time should be >= " . $self->etime_min_value . " minutes from current time\n" unless $self->check_etime($epoch);
        say "etime ok";
        say $self->cmd_line;
    }else{
        die "Failed to validate end time format: " . $self->etime . " ???\n";
    }
}

sub schedule_stime{
    my $self = shift;
    
    my $epoch = $self->get_epoch_time($self->stime);
    if($epoch){
        die "Start time should be >= " . $self->stime_min_value . " minutes from current time\n" unless $self->check_stime($epoch);
        say "stime ok";
        say $self->cmd_line;
    }else{
        die "Failed to validate start time format: " . $self->stime . " ???\n";
    }
}

sub schedule_both{
    my $self = shift;
    
    my ($epoch_stime,$epoch_etime);
    
    $epoch_stime = $self->get_epoch_time($self->stime) or die "Failed to validate start time format: " . $self->stime . " ???\n";
    $epoch_etime = $self->get_epoch_time($self->etime) or die "Failed to validate end time format: " . $self->etime . " ???\n";
    
    $self->check_vm_booking($epoch_stime,$epoch_etime);
    
    say "schedule both";
    say $self->cmd_line;
}

sub deploy_vm{
    my $self = shift;
    
    my ($soid, $tid, $zid, $name) = @_;
    
    #set xmltmp
    $self->set_deploy_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #check param to exclude soid, tid, zid
    if($self->command =~ /\b(serviceofferingid|templateid|zoneid|displayname)\b/){
        die "please set serviceofferingid|templateid|zoneid|displayname using available cmd-opts\n";
    }
    
    #set serviceofferingid|templateid|zoneid|displayname
    if(defined $name){
        $self->command($self->command . "&serviceofferingid=$soid" . "&templateid=$tid" . "&zoneid=$zid" . "&displayname=$name");
    }else{
        $self->command($self->command . "&serviceofferingid=$soid" . "&templateid=$tid" . "&zoneid=$zid");
    }
   
    #print the output
    $self->get_output();
}

sub destroy_vm{
    my $self = shift;
    
    my $displayname = shift;
    
    #set xmltmp
    $self->set_destroy_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    if(defined $self->uuid){
        say "\ndestroying " . $self->uuid . " a.k.a @$displayname";
        
        $self->command($self->command . "&id=" . $self->uuid) unless $self->param =~ /\bid=\b/;
    }
    
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

#do vm migration
sub migrate{
	my $self = shift;
	
	my ($hostid, $storageid) = @_;
	
	#set xmltmp
    $self->set_migrate_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    $self->command($self->command . "&virtualmachineid=" . $self->uuid);
    
    if($hostid){
    	$self->command($self->command . "&hostid=" . $hostid);
    }
    
    if($storageid){
    	$self->command($self->command . "&storageid=" . $storageid);
    }
    
    #print the output
    $self->get_output();
}

1;