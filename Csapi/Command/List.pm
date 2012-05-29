package Csapi::Command::List;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;
use lib ("$ENV{'CSAPI_ROOT'}/Csapi/lib");

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
$0 list [--cmd-opt] [cmd-arg]

available cmd-opt:
--param     [comma separated api param]         => 'parameter field'
--response  [comma separated api response]      => 'response field'
--noheader                                      => 'do not print header'
--showparams                                    => 'print supported parameter'
--showresponses                                 => 'print supported responses'
--json                                          => 'print output in json'
--site      [site profile name]                 => 'set site to be use'
--id        [id|uuid]                           => 'set id or uuid for cmd-arg'

available cmd-arg:
vm|account|site|diskoffering|svcoffering|template|user|job

example:
$0 list vm
$0 list --noheader vm
$0 list --param account=heince,domainid=2 vm
$0 ls --response displayname,account,domain vm
$0 ls --showparams vm
$0 ls --showresponses vm
$0 ls job                                           #list async job
$0 ls --id 83d53862-f0f7-4840-81eb-d5a37b7b0749 job #query async job by jobid
$0 ls site                                          #show available site profile
$0 ls --site office-admin vm                        #list vm using 'office-admin' profile
EOF
}

#print usage if no options specified
sub validate{
    my ($self, $cmd_opts, @args) = @_;

    if(defined $cmd_opts->{'h'}){
        die $self->usage_text();
    }
    
    if(@args){
        given($args[0]){
            when (/\bvm\b/i){
                break;
            }
            when (/\baccount\b/i){
                break;
            }
            when (/\bsite\b/i){
                break;
            }
            when (/\b(do|diskoffering)\b/i){
                break;
            }
            when (/\b(so|svcoffering)\b/i){
                break;
            }
            when (/\btemplate\b/i){
                break;
            }
            when (/\buser\b/i){
                break;
            }
            when (/\busage\b/i){
                break;
            }
            when (/\bjob\b/i){
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
    [ 'param=s'   => 'parameter field'  ],
    [ 'response=s'   => 'response field'  ],
    [ 'noheader'    =>  'do not print header' ],
    [ 'showparams'  =>  'print supported parameter' ],
    [ 'showresponses' => 'print supported responses' ],
    [ 'h|help'    =>  'print help' ],
    [ 'json' => 'print output in json' ],
    [ 'site=s' => 'set site'],
    [ 'id=s'    => 'set id']
}

#check and set param / response attribute 
sub check_opts{
    my ($opts, $obj) = @_;

    if(defined $$opts->{'site'}){
        $$obj->default_site($$opts->{'site'});
    }
    if(defined $$opts->{'showparams'}){
        $$obj->set_list_xml();
        $$obj->print_param();
        exit;
    }
    if(defined $$opts->{'showresponses'}){
        $$obj->set_list_xml();
        $$obj->print_response();
        exit;
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
        when (/\bvm\b/i){
            use VM;
            $obj = VM->new();
            check_opts(\$opts, \$obj);
            
            $obj->list_vm();
        }
        when (/\baccount\b/i){
            use Account;
            $obj = Account->new();
            check_opts(\$opts, \$obj);
            
            $obj->list_account();
        }
        when (/\b(do|diskoffering)\b/i){
            use Diskoffering;
            $obj = Diskoffering->new();
            check_opts(\$opts, \$obj);
            
            $obj->list_diskoffering();
            }
        when (/\b(so|svcoffering)\b/i){
            use Serviceoffering;
            $obj = Serviceoffering->new();
            check_opts(\$opts, \$obj);
            
            $obj->list_serviceoffering();
            }
        when (/\btemplate\b/i){
            use Template;
            $obj = Template->new();
            check_opts(\$opts, \$obj);
            
            $obj->list_template();
        }
        when (/\buser\b/i){
            use User;
            $obj = User->new();
            check_opts(\$opts, \$obj);
            
            $obj->list_user();
        }
        when (/\busage\b/i){
            use Usage;
            $obj = Usage->new();
            check_opts(\$opts, \$obj);
            
            $obj->list_usage();
        }
        when (/\bsite\b/){
            use Site;
            $obj = Site->new();
            $obj->get_all_site();
        }
        when (/\bjob\b/){
            use AsyncJob;
            $obj = AsyncJob->new();
            check_opts(\$opts, \$obj);
            
            if(defined $opts->{'id'}){
                $obj->param("jobid=" . $opts->{'id'});
                $obj->query_asyncjob();
            }else{
                $obj->list_asyncjob();
            }
            
        }
    }

	return;
}

1;

