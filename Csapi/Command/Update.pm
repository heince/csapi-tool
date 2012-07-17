package Csapi::Command::Update;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
cloudcmd update [--cmd-opt] [cmd-arg]

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
-a | --account   [account]                          => 'set account'
--dt             [displaytext]                      => 'set displaytext'
--geturl                                            => 'get api url'
            
available cmd-arg:
account domain project projectIvt

example:
cloudcmd update -i xxx -a xxx --dt "aloha" project
cloudcmd update -i xxx -p newname=rambo account

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
                }       
                break;
            }
            when (/\bdomain\b/i){
                if($cmd_opts->{'showparams'} or $cmd_opts->{'showresponses'}){
                    break;
                }else{
                    die "domainname required\n" unless $cmd_opts->{'domainname'};
                }
            }
            when (/\b(project|projectIvt)\b/i){
                if($cmd_opts->{'showparams'} or $cmd_opts->{'showresponses'}){
                    break;
                }else{
                    die "Project ID required\n" unless $cmd_opts->{'id'};
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
    [ 'param|p=s'   => 'parameter field'  ],
    [ 'response|r=s'   => 'response field'  ],
    [ 'noheader|nh'    =>  'do not print header' ],
    [ 'showparams|sp'  =>  'print supported parameter' ],
    [ 'showresponses|sr' => 'print supported responses' ],
    [ 'h|help'    =>  'print help' ], 
    [ 'site|s=s' => 'set site' ],
    [ 'json' => 'print output in json' ],
    [ 'account|a=s'    =>  'account name' ],
    [ 'dt=s'      =>  'description / displaytext' ],
    [ 'id|i=s'      => 'set id/uuid' ],
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


sub update_project{
    my ($opts, $obj) = @_;
    
    if(defined $opts->{'showparams'}){
        $obj->set_updateProject_xml();
        $obj->print_param();
        exit;
    }
    if(defined $opts->{'showresponses'}){
        $obj->set_updateProject_xml();
        $obj->print_response();
        exit;
    }
    if(defined $opts->{'account'}){
        $obj->project_account($opts->{'account'});
    }
    if(defined $opts->{'dt'}){
        $obj->project_displaytext($opts->{'dt'});
    }
    
    check_site(\$opts, \$obj);
    check_opts(\$opts, \$obj);
    
    $obj->update_project();
}

sub update_projectInvitation{
    my ($opts, $obj) = @_;
    
    if(defined $opts->{'showparams'}){
        $obj->set_updateProjectInvitation_xml();
        $obj->print_param();
        exit;
    }
    if(defined $opts->{'showresponses'}){
        $obj->set_updateProjectInvitation_xml();
        $obj->print_response();
        exit;
    }
    if(defined $opts->{'account'}){
        $obj->project_account($opts->{'account'});
    }
    check_site(\$opts, \$obj);
    check_opts(\$opts, \$obj);
    
    $obj->update_projectInvitation;
}

sub update_account{
    my ($opts, $obj) = @_;
    
    if(defined $opts->{'showparams'}){
        $obj->set_update_xml();
        $obj->print_param();
        exit;
    }
    if(defined $opts->{'showresponses'}){
        $obj->set_update_xml();
        $obj->print_response();
        exit;
    }
    if(defined $opts->{'id'}){
        $obj->accid($opts->{'id'});
    }
    
    check_site(\$opts, \$obj);
    check_opts(\$opts, \$obj);
    
    $obj->update;
    
}

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   given($args[0]){
        when (/\baccount\b/i){
            use Account;
            $obj = Account->new();
            
            update_account($opts, $obj);
        }
        when (/\bdomain\b/i){
            use Domain;
            
            $obj = Domain->new(domname => $opts->{'domainname'});
            
            create($opts, $obj);
        }
        when (/\bproject\b/i){
            use Project;
            
            $obj = Project->new(project_id => $opts->{'id'});
            
            update_project($opts, $obj);
        }
        when (/\bprojectIvt\b/i){
            use Project;
            
            $obj = Project->new(project_id => $opts->{'id'});
            update_projectInvitation($opts, $obj);
        }
   }
   
   return;
}

1;