package LDAP;
use v5.10;
use Mouse;
use strict;
use warnings;
use GenUrl;
use URI::Encode;
use Net::LDAP;

extends 'GenUrl';

has [ qw /ldaphostname ldapsearchbase ldapqueryfilter ldapdomid dompath accmap/ ] => (is => 'ro', isa => "Str");
has [ qw /uri ldapbinddn ldapbindpass ldapssl ldaptruststore ldaptrustpass ldapbind iswin istest
     iachanged sitechanged/ ] => (is => 'rw');
has [ qw /ldapport/ ] => ( is => 'rw', default => 389 );
has [ qw /excludeuser/ ] => ( is => 'rw',);
                            #default => 'Administrator,krbtgt,SUPPORT_*,Guest');
has [ 'default_mail' ] => ( is => 'rw' );

sub set_ldapConfig_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/LDAP/ldapConfig.xml"));
}

sub set_ldapRemove_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/LDAP/ldapRemove.xml"));
}

sub bind_ldap{
    my $self = shift;
    
    my $port = $self->ldapport;
    
    my $ldap = Net::LDAP->new($self->ldaphostname,
                              port => $port)
                          or die "$@";
                          
    if($self->ldapbinddn){
        $self->ldapbind($ldap->bind($self->ldapbinddn, password => $self->ldapbindpass));
    }else{
        $self->ldapbind($ldap->bind());
    }
    
    $self->ldapbind->code && die $self->ldapbind->error;
    $self->ldapbind($ldap);
}

sub is_test{
    my $self = shift;
    
    my ($result, $accountlist) = @_;
    
    say "This is a test \n";

    my (@tmp, @ldaplist);
    
    #check LDAP entry, insert if not exist on cloudstack
    foreach my $entry ($$result->entries) {
        my $acc = $entry->get_value($self->accmap);
        push @ldaplist, $acc;
        @tmp = grep (/\b$acc\b/i, @$accountlist);
        
        unless(@tmp){
            if($entry->get_value('givenName')){
                if($entry->get_value('sn')){
                    if($entry->get_value('mail')){
                        say "inserting account $acc to CloudStack ...";
                    }else{
                        if($self->default_mail){
                            say "inserting account $acc to CloudStack, setting default mail to " . $self->default_mail;
                        }else{
                            say "skipping account $acc, email not found";
                        }
                    }
                }else{
                    say "skipping account $acc, Last Name not found";
                }
            }else{
                say "skipping account $acc, First Name not found";
            }
        }else{
            say "skipping account $acc, account exist";
        }
    }
    
    #check CloudStack entry, delete if not exist on LDAP
    foreach my $cs(@$accountlist){
        @tmp = grep (/\b$cs\b/i, @ldaplist);
        
        unless(@tmp){
            say "deleting account $cs ...";
        }
    }
}

sub delete_account{
    my $self = shift;
    
    my $acc = shift;
    
    use Account;
    
    say "deleting account $acc ...";
                
    my $obj = Account->new();
    
    $obj->default_site($self->sitechanged) if $self->sitechanged;
    $obj->ia($self->iachanged) if $self->iachanged;
    my $id = $obj->get_accid($self->ldapdomid, $acc);
    chomp @$id;
    
    $obj->accid("@$id");
    $obj->delete();
    
    say "Done\n";
}

sub create_account{
    my $self = shift;
    
    my ($acc, $fname, $lname, $password, $mail ) = @_;
    
    use Account;
    
    my $obj;
    
    if($self->default_mail){
        say "inserting account $acc to CloudStack, setting default mail to " . $self->default_mail;
        
        $obj = Account->new(acctype => 0,
                            accemail => $self->default_mail,
                            fname => $fname,
                            lname => $lname,
                            accpass => $password,
                            uname => $acc);
        
    }else{
        say "inserting account $acc to CloudStack ...";
        
        $obj = Account->new(acctype => 0,
                            accemail => $mail,
                            fname => $fname,
                            lname => $lname,
                            accpass => $password,
                            uname => $acc);
    }
    
    $obj->param("domainid=" . $self->ldapdomid);    
    $obj->default_site($self->sitechanged) if $self->sitechanged;
    $obj->ia($self->iachanged) if $self->iachanged;
    
    $obj->create();
    
    say "Done";
}

sub sync_ldap{
    my $self = shift;
    
    my ($domainpath, $accname) = @_;
    my (@accountlist, @ldaplist, @excludelist);
    
    my $result = $self->ldapsearch();
    
    #print domain path target
    print "Domain Target : ";
    print @$domainpath;
    
    #get current accounts
    if($self->excludeuser){
        @excludelist = split ',' => $self->excludeuser;
    }
    
    for my $tmp(@$accname){
        my $acc = unpack("A*" , $tmp);
        
        if(@excludelist){
            unless(grep (/\b$acc\b/i, @excludelist)){
                push @accountlist, $acc;
            }
        }else{
            push @accountlist, $acc;
        }
    }
    
    if($self->istest){
        $self->is_test($result,\@accountlist);  
    }else{
        my ($acc, $fname, $lname, $password, $mail );
        
        my (@tmp, @ldaplist);
        
        foreach my $entry ($$result->entries) {
            $acc = $entry->get_value($self->accmap);
            push @ldaplist, $acc;
            @tmp = grep (/\b$acc\b/i, @accountlist);
            
            $password = $self->gen_password;
            
            unless(@tmp){
                if($fname = $entry->get_value('givenName')){
                    if($lname = $entry->get_value('sn')){
                        if($mail = $entry->get_value('mail')){
                            $self->create_account($acc, $fname, $lname, $password, $mail);
                        }else{
                            if($self->default_mail){
                                $self->create_account($acc, $fname, $lname, $password, $mail);
                            }else{
                                say "skipping account $acc, email not found";
                            }
                        }
                    }else{
                        say "skipping account $acc, Last Name not found";
                    }
                }else{
                    say "skipping account $acc, First Name not found";
                }
            }else{
                say "skipping account $acc, account exist";
            }
        }
        
        #check CloudStack entry, delete if not exist on LDAP
        foreach my $cs(@accountlist){
            @tmp = grep (/\b$cs\b/i, @ldaplist);
            
            unless(@tmp){
                $self->delete_account($cs);
            }
        }
        
    }
}

sub get_exclude_user_list{
    my $self = shift;
    
    my @lists = split ',' => $self->excludeuser;
    
    my $excludelist = qq#(!(|#;
    for (@lists){
        #$excludelist .= qq#(!(# . $self->accmap . "=$_)) ";
        $excludelist .= "(" . $self->accmap . "=$_) ";
    }
    $excludelist .= "))";
    
    return $excludelist;
}

sub get_filter{
    my $self = shift;
    
    my ($filter, $excludelist);
    
    if($self->accmap =~ /sAMAccountName/i){
        if($self->excludeuser){
            $excludelist = $self->get_exclude_user_list;
            $filter = qq# (&(objectClass=user) # . $self->ldapqueryfilter . " $excludelist)";
        }else{
            $filter = qq# (&(objectClass=user) # . $self->ldapqueryfilter;
        }  
        $self->iswin(1);
    }else{
        if($self->excludeuser){
            $excludelist = $self->get_exclude_user_list;
            $filter = qq#(&# . $self->ldapqueryfilter . " $excludelist)";
        }else{
            $filter = qq#(&(# . $self->accmap . "=*)" . $self->ldapqueryfilter .")";
        }
    }
    say $filter;
    return $filter;
}

sub ldapsearch{
    my $self = shift;
    
    $self->bind_ldap();
    my $filter = $self->get_filter();
    
    my $attrs = [ 'givenName', 'sn', 'mail', $self->accmap ];
    my $result = $self->ldapbind->search( base => $self->ldapsearchbase,
                                          scope => "sub",
                                          filter => $filter,
                                          attrs => $attrs);
    die "no record found\n" unless $result->entries;
    
    return \$result;
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
    
    say "Done\n";
}

1;