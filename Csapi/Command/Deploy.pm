package Csapi::Command::Deploy;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;
use lib ("$ENV{'CSAPI_ROOT'}/Csapi/lib");

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
$0 deploy [--cmd-opt] [cmd-arg]

available cmd-opt:
--param     [comma separated api param]         => 'parameter field'
--response  [comma separated api response]      => 'response field'
--noheader                                      => 'do not print header'
--showparams                                    => 'print supported parameter'
--showresponses                                 => 'print supported responses'
--json                                          => 'print output in json'
--site      [site profile name]                 => 'set site to be use'
--soid      [serviceofferingid]                 => 'set service offering id (required)'
--tid       [templateid]                        => 'set template id (required)'
--zid       [zoneid]                            => 'set zone id (required)'
--name      [displayname]                       => 'set displayname'

available cmd-arg:
vm

example:
#advanced network with dhcp
$0 deploy --soid xxx --tid xxx --zid xxx --name testvm1 --param networkids=xxx  vm
#advanced network with ip address specified
$0 deploy --soid xxx --tid xxx --zid xxx --name testvm1 --param iptonetworklist[0].ip=192.168.89.224,iptonetworklist[0].networkid=xxx vm
$0 deploy --showparams vm
$0 deploy --showreponses vm
EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    
    if(defined $cmd_opts->{'h'}){
        die $self->usage_text();
    }
    
    die "serviceofferingid|templateid|zoneid is required\n" unless $cmd_opts->{'soid'} and $cmd_opts->{'tid'} and $cmd_opts->{'zid'};
    
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
    [ 'param=s'   => 'parameter field'  ],
    [ 'response=s'   => 'response field'  ],
    [ 'noheader'    =>  'do not print header' ],
    [ 'showparams'  =>  'print supported parameter' ],
    [ 'showresponses' => 'print supported responses' ],
    [ 'h|help'    =>  'print help' ], 
    [ 'json' => 'print output in json' ],
    [ 'site=s' => 'set site'],
    [ 'soid=s'    => 'set service offering id'],
    [ 'tid=s'    => 'set template id'],
    [ 'zid=s'    => 'set zone id'],
    [ 'name=s'    => 'set displayname'],
    [ 'stime=s'   => 'set start time' ],
    [ 'etime=s'   => 'set end time']
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
        $$obj->set_deploy_xml();
        $$obj->print_param();
        exit;
    }
    if(defined $$opts->{'showresponses'}){
        $$obj->set_deploy_xml();
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

sub check_time{
    my ($opts, $obj) = @_;
    
    if(defined $$opts->{'stime'} and not defined $$opts->{'etime'}){
        $$obj->stime($$opts->{'stime'});
        $$obj->schedule_stime();
    }
    elsif(defined $$opts->{'etime'} and not defined $$opts->{'stime'}){
        $$obj->etime($$opts->{'etime'});
        $$obj->schedule_etime();
    }else{
        $$obj->stime($$opts->{'stime'});
        $$obj->etime($$opts->{'etime'});
        $$obj->schedule_both();
    }
}

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   given($args[0]){
        when(/\bvm\b/){
            use VM;
            $obj = VM->new();
            
            check_site(\$opts, \$obj);
            
            if(defined $opts->{'stime'} or defined $opts->{'etime'}){
                check_time(\$opts, \$obj);
            }else{
                check_opts(\$opts, \$obj);
                $obj->deploy_vm($opts->{'soid'}, $opts->{'tid'}, $opts->{'zid'}, $opts->{'name'});
            }
        }
   }
   
   return;
}

1;