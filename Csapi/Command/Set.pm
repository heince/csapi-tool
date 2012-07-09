package Csapi::Command::Set;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;
use lib ("$ENV{'CSAPI_ROOT'}/Csapi/lib");

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
cloudcmd set [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                                 => 'use integration api url (legacy port 8096)'
-p | --param     [comma separated api param]         => 'parameter field'
-r | --response  [comma separated api response]      => 'response field'
--nh | --noheader                                    => 'do not print header'
-s | --site      [site profile name]                 => 'set site to be use'
-H | --host          [hostname / IP]                 => 'set hostname'
-f | --queryfilter   [eg. (&(uid=%u))]               => 'set LDAP query filter'
-b | --searchbase    [eg. dc=cloud,dc=com]           => 'set LDAP search base'
-D | --binddn        [eg. cn=admin,dc=cloud,dc=com]  => 'set user with search permissions'
-w | --bindpass      [password]                      => 'set bind user password'
-P | --port          [LDAP port number]              => 'set ldap port number'
--ssl                                                => 'use ssl'
-T | --truststore    [eg. /key/ldapstore.jks]        => 'set path of the truststore'
-W | --storepass     [password]                      => 'password for truststore'

available cmd-arg:
ldap

example:
cloudcmd set -H ldap.example.com -f "(&(uid=%u))" -b "dc=cloud,dc=com" ldap
cloudcmd set -H ldap.example.com -D "cn=administrator,cn=users,dc=cloud,dc=com" \\
       -b "cn=users,dc=cloud,dc=com"  -w "mypass"  --ia -f "(&(sAMAccountName=%u))"  ldap
cloudcmd set -H ldap.example.com -f "(&(uid=%u))" \\
        -b "dc=cloud,dc=com" -D "cn=admin,dc=cloud,dc=com" \\
        -w "mypass" --ssl -T "/key/ldapstore.jks" -W "mystorepass" ldap

EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    
    if(defined $cmd_opts->{'h'}){
        die $self->usage_text();
    }
    
    if(@args){
        given($args[0]){
            when (/\bldap\b/i){
                die "host|queryfilter|basesearch is required\n" unless $cmd_opts->{'host'} and
                    $cmd_opts->{'queryfilter'} and $cmd_opts->{'searchbase'};
                
                if($cmd_opts->{'ssl'}){
                    unless($cmd_opts->{'truststore'} or $cmd_opts->{'storepass'}){
                        die "Please specify truststore and storepass\n";
                    }
                }
                
                if($cmd_opts->{'truststore'} or $cmd_opts->{'storepass'}){
                    unless($cmd_opts->{'ssl'}){
                        die "Please specify --ssl\n";
                    }
                }
                
                break;
            }
            default{
                die "$_ argument not supported\n";
            }
        }
    }else{
        die $self->usage_text();
    }
}

sub option_spec {
    # The option_spec() hook in the Command Class provides the option
    # specification for a particular command.
    [ 'ia'          => 'use integration api url (legacy port 8096)'],
    [ 'param|p=s'   => 'parameter field'  ],
    [ 'response|r=s'   => 'response field'  ],
    [ 'noheader|nh'    =>  'do not print header' ],
    [ 'h|help'    =>  'print help' ], 
    [ 'site|s=s' => 'set site'],
    [ 'host|H=s' => 'set hostname'],
    [ 'queryfilter|f=s'    => 'set LDAP query filter'],
    [ 'searchbase|b=s'    =>  'LDAP set base search'],
    [ 'port|P=i'      =>  'set port'],
    [ 'ssl'            =>  'use ssl'],
    [ 'binddn|D=s'    =>  'distinguished name of a user with the search permission'],
    [ 'bindpass|w=s'  =>  'dn password'],
    [ 'truststore|T=s'    =>  'path of cert store'],
    [ 'storepass|W=s'     =>  'password of the store'],
    
}

#check & set site
sub check_site{
    my ($opts, $obj) = @_;
    
    if(defined $$opts->{'site'}){
        $$obj->default_site($$opts->{'site'});
    }
}

#check and set param / response attribute 
sub check_opts{
    my ($opts, $obj) = @_;

    if(defined $$opts->{'ia'}){
        $$obj->ia(1);
    }
    if(defined $$opts->{'param'}){
        $$obj->param($$opts->{'param'});
    }
    if(defined $$opts->{'response'}){
        $$obj->response($$opts->{'response'});
    }
    if($$opts->{'noheader'}){
        $$obj->noheader('true');
    }
    if($$obj->is_ldap){
        $$obj->ldapport($$opts->{'port'}) if $$opts->{'port'};
        $$obj->ldapbinddn($$opts->{'binddn'}) if $$opts->{'binddn'};
        $$obj->ldapbindpass($$opts->{'bindpass'}) if $$opts->{'bindpass'};
        $$obj->ldapssl(1) if $$opts->{'ssl'};
        $$obj->ldaptruststore($$opts->{'truststore'}) if $$opts->{'truststore'};
        $$obj->ldaptrustpass($$opts->{'storepass'}) if $$opts->{'storepass'};
    }
}


sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   given($args[0]){
        when(/\bldap\b/){
            use LDAP;
            $obj = LDAP->new(ldaphostname => $opts->{'host'},
                             ldapqueryfilter => $opts->{'queryfilter'},
                             ldapsearchbase => $opts->{'searchbase'}
                             );
            $obj->is_ldap(1);
            
            check_site(\$opts, \$obj);
            check_opts(\$opts, \$obj);
            $obj->setldap();
        }
   }
   
   return;
}

1;