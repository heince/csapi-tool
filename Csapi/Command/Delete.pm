package Csapi::Command::Delete;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;
use lib ("$ENV{'CSAPI_ROOT'}/Csapi/lib");

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
$0 delete [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                            => 'use integration api url (legacy port 8096)'
--param     [comma separated api param]         => 'parameter field'
--response  [comma separated api response]      => 'response field'
--noheader                                      => 'do not print header'
--site      [site profile name]                 => 'set site to be use'
--json                                          => 'print output in json'
--id        [id / uuid]                         => 'set id / uuid to delete'                      
            
available cmd-arg:
account

example:
$0 delete --id xxx account
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
                    die "id is required\n" unless $cmd_opts->{'id'};
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
    [ 'param=s'   => 'parameter field'  ],
    [ 'response=s'   => 'response field'  ],
    [ 'noheader'    =>  'do not print header' ],
    [ 'showparams'  =>  'print supported parameter' ],
    [ 'showresponses' => 'print supported responses' ],
    [ 'h|help'    =>  'print help' ], 
    [ 'site=s' => 'set site' ],
    [ 'json' => 'print output in json' ],
    [ 'id=s'  =>  'set id to be deleted' ],
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
        $$obj->set_delete_xml();
        $$obj->print_param();
        exit;
    }
    if(defined $$opts->{'showresponses'}){
        $$obj->set_delete_xml();
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
        when(/\baccount\b/){
            use Account;
            $obj = Account->new(accid => $opts->{'id'});
            
            check_site(\$opts, \$obj);
            check_opts(\$opts, \$obj);
            
            $obj->delete();
        }
   }
   
   return;
}

1;