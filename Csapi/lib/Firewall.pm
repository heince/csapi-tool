package Firewall;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;

extends 'GenUrl';

sub set_listFirewallRules_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Firewall/listFirewallRules.xml"));
}

sub set_listPortForwardingRules_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Firewall/listPortForwardingRules.xml"));
}

sub set_createFirewallRule_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Firewall/createFirewallRule.xml"));
}

sub set_deleteFirewallRule_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Firewall/deleteFirewallRule.xml"));
}

sub set_createPortForwardingRule_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Firewall/createPortForwardingRule.xml"));
}

sub set_deletePortForwardingRule_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Firewall/deletePortForwardingRule.xml"));
}

sub action{
	my $self = shift;
	
	my $action = shift;
	
	#set xmltmp
	given($action){
		when ('listFirewallRules'){
			$self->set_listFirewallRules_xml();
		}
		when ('listPortForwardingRules'){
			$self->set_listPortForwardingRules_xml();
		}
		when ('deletefwrule'){
			$self->set_deleteFirewallRule_xml();
		}
		when ('deletepfrule'){
			$self->set_deletePortForwardingRule_xml();
		}
	}
	
	#set initial command and xmlresult attr
    $self->set_command();
   
    #set id if not set
    if(defined $self->uuid){        
        $self->command($self->command . "&id=" . $self->uuid) if $self->uuid;   
    }
   
    #print the output
    $self->get_output();
}

sub list_FirewallRules{
	my $self = shift;
    
    $self->action('listFirewallRules');
}

sub list_PortForwardingRules{
	my $self = shift;
    
    $self->action('listPortForwardingRules');
}

sub create_firewallrule{
	my $self = shift;
	
	my $protocol = shift;
	
	#set xmltmp
	$self->set_createFirewallRule_xml;
	
	#set initial command and xmlresult attr
    $self->set_command();
   
    #set protocol      
    $self->command($self->command . "&protocol=" . $protocol);
   
    #print the output
    $self->get_output();
}

sub delete_firewallrule{
	my $self = shift;
	
	$self->action('deletefwrule')
}

sub create_portforwardingrule{
	my $self = shift;
	
	#set xmltmp
	$self->set_createPortForwardingRule_xml;
	
	#set initial command and xmlresult attr
    $self->set_command();
    
    #print the output
    $self->get_output();
}

sub delete_pfrule{
	my $self = shift;
	
	$self->action('deletepfrule')
}

1;