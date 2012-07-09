package Csapi::Command::Sync;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;
use lib ("$ENV{'CSAPI_ROOT'}/Csapi/lib");

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
cloudcmd sync [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                                    => 'use integration api url (legacy port 8096)'
-s | --site          [site profile name]                => 'set site to be use'
-d | --domainid      [domain id]                        => 'set domain id'
-H | --ldaphost      [ldap server address]              => 'set LDAP server'
-f | --queryfilter   [eg. "(uid=user*)" ]               => 'set LDAP query filter for account name'
-b | --searchbase    [eg. dc=cloud,dc=com]              => 'set LDAP search base'
-P | --port          [LDAP port number]                 => 'set ldap port number'
-D | --binddn        [eg. cn=admin,dc=cloud,dc=com]     => 'set user with search permissions'
-w | --bindpass      [password]                         => 'set bind user password'
-x | --excludeuser   [comma separated user]             => 'exclude user list'
-t | --test          [test sync]                        => 'summary of what need to be sync if success'
-e | --defaultmail   [default mail]                     => 'set default mail if not found'
-a | --accmap        [eg. uid or sAMAccountName on AD]  => 'set account name attribute to map'
            
available cmd-arg:
ldap

example:
#open source LDAP example (This will get all uid user, excluding batman,robin & mrbean)
cloudcmd sync -d xxx -H ldap.example.com -b "dc=example,dc=com"
        -D "uid=admin,dc=example,dc=com" -w "mypass"
        -f "(uid=*)" -a "uid" -x "batman,robin,mrbean" --ia ldap
        
#Microsoft AD example (This will get all user with 'user' and 'guest' prefix )
cloudcmd sync -d xxx -H ldap.example.com -b "cn=users,dc=example,dc=com"
        -f "(|(sAMAccountName=guest*) (sAMAccountName=user*))"
        -D "cn=administrator,cn=users,dc=example,dc=com" -w "mypass"
        -a "sAMAccountName" --ia ldap
        
EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    
    if(defined $cmd_opts->{'h'}){
        die $self->usage_text();
    }
    
    if(@args){
        given($args[0]){
            when (/\bldap\b/){
                die "domainid|ldaphost|accmap|searchbase|queryfilter is required\n" unless
                $cmd_opts->{'domainid'} and
                $cmd_opts->{'accmap'} and
                $cmd_opts->{'queryfilter'} and
                $cmd_opts->{'searchbase'} and
                $cmd_opts->{'ldaphost'};
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
    [ 'ia'          => 'use integration api url (legacy port 8096)' ],
    [ 'h|help'    =>  'print help' ], 
    [ 'site|s=s' => 'set site' ],
    [ 'domainid|d=s' => 'domain id'],
    [ 'queryfilter|f=s'    => 'set LDAP query filter'],
    [ 'searchbase|b=s'    =>  'LDAP set base search'],
    [ 'port|P=i'      =>  'set port'],
    [ 'ldaphost|H=s'  =>  'set ldap hostname / ip' ],
    [ 'binddn|D=s'    =>  'distinguished name of a user with the search permission'],
    [ 'bindpass|w=s'  =>  'dn password'],
    [ 'excludeuser|x=s' => 'exclude user list' ],
    [ 'test|t'        =>  'test sync' ],
    [ 'defaultmail|e=s' => 'set default mail' ],
    [ 'accmap|a=s'          => 'set account name attribute to map' ]
}

#check & set site
sub check_site{
    my ($opts, $obj) = @_;
    
    if(defined $$opts->{'site'}){
        $$obj->default_site($$opts->{'site'});
        $$obj->sitechanged($$opts->{'site'});
    }
}

#check and set param / response attribute 
sub check_opts{
    my ($opts, $obj) = @_;

    if(defined $$opts->{'ia'}){
        $$obj->ia(1);
        $$obj->iachanged(1);
    }
    if(defined $$opts->{'test'}){
        $$obj->istest(1);
    }
}

sub check_ldap_opts{
    my ($opts, $obj) = @_;
    
    if(defined $$opts->{'port'}){
        $$obj->ldapport($$opts->{'port'});
    }
    if(defined $$opts->{'binddn'}){
        $$obj->ldapbinddn($$opts->{'binddn'});
    }
    if(defined $$opts->{'bindpass'}){
        $$obj->ldapbindpass($$opts->{'bindpass'});
    }
    if(defined $$opts->{'excludeuser'}){
        $$obj->excludeuser($$opts->{'excludeuser'});
    }
    if(defined $$opts->{'defaultmail'}){
        $$obj->default_mail($$opts->{'defaultmail'});
    }
}

sub get_domain_path{
    my ($domid, $opts) = @_;
    
    use Domain;
    
    my $domain = Domain->new(domid => $domid);
    $domain->default_site($$opts->{'site'}) if $$opts->{'site'};
    $domain->ia(1) if $$opts->{'ia'};

    my $path = $domain->get_dompath;
    return $path;
}

sub get_account_name{
    my ($domid, $opts) = @_;
    
    use Account;
    
    my $acc = Account->new();
    $acc->default_site($$opts->{'site'}) if $$opts->{'site'};
    $acc->ia(1) if $$opts->{'ia'};
    
    return $acc->get_accname_bydomid($domid);
}

sub run{
	my ($self, $opts, @args) = @_;

   my $obj;
   
   given($args[0]){
        when (/\bldap\b/){
            use LDAP;
            
            $obj = LDAP->new(ldaphostname => $opts->{'ldaphost'},
                             ldapqueryfilter => $opts->{'queryfilter'},
                             ldapsearchbase => $opts->{'searchbase'},
                             ldapdomid => $opts->{'domainid'},
                             accmap => $opts->{'accmap'},
                             );
            check_site(\$opts, \$obj);
            check_opts(\$opts, \$obj);
            check_ldap_opts(\$opts, \$obj);
            
            my $domainpath = get_domain_path($opts->{'domainid'},\$opts);
            my $accountname = get_account_name($opts->{'domainid'},\$opts);
            
            $obj->sync_ldap($domainpath,$accountname);  
        }
   }
   return;
}

1;