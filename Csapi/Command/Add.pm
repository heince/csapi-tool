package Csapi::Command::Add;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
cloudcmd add [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                                => 'use integration api url (legacy port 8096)'
-p | --param     [comma separated api param]        => 'parameter field'
-r | --response  [comma separated api response]     => 'response field'
--nh | --noheader                                   => 'do not print header'
--sp | --showparams                                 => 'print supported parameter'
--sr | --showresponses                              => 'print supported responses'
-s | --site      [site profile name]                => 'set site to be use'
--json                                              => 'print output in json'
-i | --id        [id/uuid]                          => 'set id'
-a | --account                                      => 'set account name'
-e | --email                                        => 'set email'
--geturl                                            => 'get api url'
            
available cmd-arg:
account

example:
#add heince to project xxx 
cloudcmd add -i xxx -a heince account

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
                    die "project id is required, use -i [project id]\n" unless $cmd_opts->{'id'};
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
    [ 'ia'          => 'use integration api url (legacy port 8096)' ],
    [ 'param|p=s'   => 'parameter field'  ],
    [ 'response|r=s'   => 'response field'  ],
    [ 'noheader|nh'    =>  'do not print header' ],
    [ 'showparams|sp'  =>  'print supported parameter' ],
    [ 'showresponses|sr' => 'print supported responses' ],
    [ 'h|help'    =>  'print help' ], 
    [ 'site|s=s' => 'set site' ],
    [ 'json' => 'print output in json' ],
    [ 'id|i=s'      => 'set id/uuid' ],
    [ 'account|a=s' => 'set account name' ],
    [ 'email|e=s'   => 'set email' ],
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

sub add_account{
    my ($opts, $obj) = @_;
    
    if(defined $opts->{'showparams'}){
        $obj->set_enable_xml();
        $obj->print_param();
        exit;
    }
    if(defined $opts->{'showresponses'}){
        $obj->set_enable_xml();
        $obj->print_response();
        exit;
    }
    if(defined $opts->{'email'}){
        $obj->accemail($opts->{'email'});
    }
    if(defined $opts->{'account'}){
        $obj->accname($opts->{'account'});
    }
    
    check_site(\$opts, \$obj);
    check_opts(\$opts, \$obj);
    
    $obj->addAccountToProject($opts->{'id'});
    
}

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   given($args[0]){
        when (/\baccount\b/i){
            use Account;
            
            $obj = Account->new();
            
            add_account($opts, $obj);
        }
   }
   
   return;
}

1;