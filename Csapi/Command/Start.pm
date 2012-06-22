package Csapi::Command::Start;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;
use lib ("$ENV{'CSAPI_ROOT'}/Csapi/lib");

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
$0 start [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                            => 'use integration api url (legacy port 8096)'
--param     [comma separated api param]         => 'parameter field'
--response  [comma separated api response]      => 'response field'
--noheader                                      => 'do not print header'
--showparams                                    => 'print supported parameter'
--showresponses                                 => 'print supported responses'
--json                                          => 'print output in json'
--site      [site profile name]                 => 'set site to be use'
--id        [comma separated id|uuid]           => 'set id'

available cmd-arg:
vm

example:
$0 start --id 1,2,3 vm
$0 start --id 33b9d87a-93cd-4235-bb10-09ece1325487 --param forced=true --noheader vm
$0 start --showparams vm
$0 start --showreponses vm
EOF
}

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
    [ 'param=s'   => 'parameter field'  ],
    [ 'response=s'   => 'response field'  ],
    [ 'noheader'    =>  'do not print header' ],
    [ 'showparams'  =>  'print supported parameter' ],
    [ 'showresponses' => 'print supported responses' ],
    [ 'h|help'    =>  'print help' ], 
    [ 'json' => 'print output in json' ],
    [ 'site=s' => 'set site'],
    [ 'id=s'    => 'set id or uuid'],
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
    if(defined $$opts->{'showparams'}){
        $$obj->set_start_xml();
        $$obj->print_param();
        exit;
    }
    if(defined $$opts->{'showresponses'}){
        $$obj->set_start_xml();
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

sub get_vm_displayname{
    my ($obj) = @_;
    
    my $displayname = $$obj->get_displayname();
    if($displayname){
        return $displayname;
    }else{
        warn "vm not found\n";
    }
}

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   given($args[0]){
        when(/\bvm\b/){
            use VM;
            $obj = VM->new();
            
            if(defined $opts->{'id'}){
                my @ids = split ',' , $opts->{'id'};
                
                #loop through id
                for(@ids){
                    check_site(\$opts, \$obj);
                    $obj->uuid($_);
                    my $displayname = get_vm_displayname(\$obj);
                    check_opts(\$opts, \$obj);
                    $obj->start_vm($displayname);
                }
            }
        }
   }
   
   return;
}

1;