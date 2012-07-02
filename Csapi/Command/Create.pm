package Csapi::Command::Create;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;
use lib ("$ENV{'CSAPI_ROOT'}/Csapi/lib");

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
$0 create [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                            => 'use integration api url (legacy port 8096)'
--param     [comma separated api param]         => 'parameter field'
--response  [comma separated api response]      => 'response field'
--noheader                                      => 'do not print header'
--showparams                                    => 'print supported parameter'
--showresponses                                 => 'print supported responses'
--site      [site profile name]                 => 'set site to be use'
--json                                          => 'print output in json'
--acctype   [0 for user, 1 for root admin,      => 'account type'
            and 2 for domain admin]             
--email     [email address]                     => 'set email address'
--fname     [first name]                        => 'set first name'
--lname     [last name]                         => 'set last name'
--password  [password]                          => 'set password'
--uname     [user name]                        => 'set username'
--domainid  [domain id]                         => 'set domain id'
--domainname  [domain name]                         => 'set domain name'
            
available cmd-arg:
account domain

example:
$0 create --acctype 0 --email dummy\@example.com --fname dummy \\
          --lname cloud --password 'mypass' --uname dummy account

$0 create --domainname "sales" domain
EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    
    if(defined $cmd_opts->{'h'}){
        die $self->usage_text();
    }
    
    if(@args){
        given($args[0]){
            when (/\baccount\b/i){
                if($cmd_opts->{'showparams'} or $cmd_opts->{'showresponses'}){
                    break;
                }else{
                    die "acctype|email|fname|lname|password|username is required\n" unless $cmd_opts->{'acctype'} >= 0 and
                    $cmd_opts->{'acctype'} <= 2 and$cmd_opts->{'email'} and $cmd_opts->{'fname'} and $cmd_opts->{'lname'} and
                    $cmd_opts->{'password'} and $cmd_opts->{'uname'};
                }       
                break;
            }
            when (/\bdomain\b/){
                if($cmd_opts->{'showparams'} or $cmd_opts->{'showresponses'}){
                    break;
                }else{
                    die "domainname required\n" unless $cmd_opts->{'domainname'};
                }
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
    [ 'param=s'   => 'parameter field'  ],
    [ 'response=s'   => 'response field'  ],
    [ 'noheader'    =>  'do not print header' ],
    [ 'showparams'  =>  'print supported parameter' ],
    [ 'showresponses' => 'print supported responses' ],
    [ 'h|help'    =>  'print help' ], 
    [ 'site=s' => 'set site' ],
    [ 'json' => 'print output in json' ],
    [ 'acctype=s' => 'Specify 0 for user, 1 for root admin, and 2 for domain admin' ],
    [ 'email=s' => 'set email' ],
    [ 'fname=s' => 'First name' ],
    [ 'lname=s' => 'Last name' ],
    [ 'password=s' => 'password' ],
    [ 'uname=s' => 'username' ],
    [ 'domainid=s' => 'domain id'],
    [ 'domainname=s' => 'domain name' ]
    
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

    if(defined $$opts->{'showparams'}){
        $$obj->set_create_xml();
        $$obj->print_param();
        exit;
    }
    if(defined $$opts->{'showresponses'}){
        $$obj->set_create_xml();
        $$obj->print_response();
        exit;
    }
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

}


sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   given($args[0]){
        when (/\baccount\b/){
            use Account;
            $obj = Account->new(acctype => $opts->{'acctype'},
                                accemail => $opts->{'email'},
                                fname => $opts->{'fname'},
                                lname => $opts->{'lname'},
                                accpass => $opts->{'password'},
                                uname => $opts->{'uname'});
            
            check_site(\$opts, \$obj);
            check_opts(\$opts, \$obj);
            
            $obj->create();
        }
        when (/\bdomain\b/){
            use Domain;
            
            $obj = Domain->new(domname => $opts->{'domainname'});
            
            check_site(\$opts, \$obj);
            check_opts(\$opts, \$obj);
            
            $obj->create();
        }
   }
   
   return;
}

1;