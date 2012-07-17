package Csapi::Command::Remove;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
cloudcmd remove [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                                => 'use integration api url (legacy port 8096)'
-p | --param     [comma separated api param]        => 'parameter field'
-r | --response  [comma separated api response]     => 'response field'
--nh | --noheader                                   => 'do not print header'
-s | --site      [site profile name]                => 'set site to be use'
--json                                              => 'print output in json'
--geturl                                            => 'get api url'

available cmd-arg:
ldap

example to remove ldap configuration:
cloudcmd remove ldap  
cloudcmd remove -s branch-office ldap

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
    [ 'json'     => 'print json output'],
    [ 'geturl'    => 'get api url' ]
    
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
    if($$opts->{'json'}){
        $$obj->json('true');
    }
    if($$opts->{'geturl'}){
        $$obj->geturl(1);
    }
}


sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   given($args[0]){
        when(/\bldap\b/){
            use LDAP;
            
            $obj = LDAP->new();
            $obj->is_ldap(1);
            
            check_site(\$opts, \$obj);
            check_opts(\$opts, \$obj);
            $obj->removeldap();
        }
   }
   
   return;
}

1;