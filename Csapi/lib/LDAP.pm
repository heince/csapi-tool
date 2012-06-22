package LDAP;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;
use URI::Encode;

extends 'GenUrl';

has [ qw /ldaphostname ldapsearchbase ldapqueryfilter/ ] => (is => 'ro', isa => "Str");
has [ qw /uri ldapport ldapbinddn ldapbindpass ldapssl ldaptruststore ldaptrustpass/ ] => (is => 'rw');

sub set_ldapConfig_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/LDAP/ldapConfig.xml"));
}

sub set_ldapRemove_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/LDAP/ldapRemove.xml"));
}

sub set_port{
    my $self = shift;
    
    if($self->ldapport){
        $self->command($self->command . "&port=" . $self->ldapport);
    }
}

sub set_ssl{
    my $self = shift;
    
    if($self->ldapssl){
        $self->command($self->command . "&ssl=true");
    }
}

sub set_binddn{
    my $self = shift;
    
    if($self->ldapbinddn){
        $self->command($self->command . "&binddn=" . $self->uri->encode($self->ldapbinddn, 1));
    }
}

sub set_bindpass{
    my $self = shift;
    
    if($self->ldapbindpass){
        $self->command($self->command . "&bindpass=" . $self->uri->encode($self->ldapbindpass, 1));
    }
}

sub set_truststore{
    my $self = shift;
    
    if($self->ldaptruststore){
        $self->command($self->command . "&truststore=" . $self->uri->encode($self->ldaptruststore, 1));
    }
}

sub set_truststorepass{
    my $self = shift;
    
    if($self->ldaptrustpass){
        $self->command($self->command . "&truststorepass=" . $self->uri->encode($self->ldaptrustpass, 1));
    }
}

sub set_other_options{
    my $self = shift;
    
    $self->set_port();
    $self->set_binddn();
    $self->set_bindpass();
    $self->set_ssl();
    $self->set_truststore();
    $self->set_truststorepass();
}

sub setldap{
    my $self = shift;
    
    $self->uri(URI::Encode->new());
    
    #set xmltmp
    $self->set_ldapConfig_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    $self->command($self->command . "&hostname=" . $self->uri->encode($self->ldaphostname, 1) .
                   "&queryfilter=" . $self->uri->encode($self->ldapqueryfilter,1) .
                "&searchbase=" . $self->uri->encode($self->ldapsearchbase, 1));
    
    $self->set_other_options();
    
    #print the output
    $self->get_output();
}

sub removeldap{
    my $self = shift;
    
    #set xmltmp
    $self->set_ldapRemove_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    #print the output
    $self->get_output();
}

1;