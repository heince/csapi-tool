package LDAP;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;
use URI::Encode;

extends 'GenUrl';

has [qw /ldaphostname ldapsearchbase ldapqueryfilter/ ] => (is => 'ro', isa => "Str");

sub set_ldapConfig_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/LDAP/ldapConfig.xml"));
}

sub set_ldapRemove_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/LDAP/ldapRemove.xml"));
}

sub setldap{
    my $self = shift;
    
    my $uri = URI::Encode->new();
    
    $self->is_ldap(1);
    
    #set xmltmp
    $self->set_ldapConfig_xml();
    
    #set initial command and xmlresult attr
    $self->set_command();
    
    $self->command($self->command . "&hostname=" . $self->ldaphostname . "&queryfilter=" . $uri->encode($self->ldapqueryfilter,1) .
                "&searchbase=" . $uri->encode($self->ldapsearchbase,1));
    
    #print the output
    $self->get_output();
}

sub removeldap{
    my $self = shift;
    
}

1;