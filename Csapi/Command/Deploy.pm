package Csapi::Command::Deploy;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
cloudcmd deploy [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                                => 'use integration api url (legacy port 8096)'
-p | --param     [comma separated api param]        => 'parameter field'
-r | --response  [comma separated api response]     => 'response field'
--nh | --noheader                                   => 'do not print header'
--sp | --showparams                                 => 'print supported parameter'
--sr | --showresponses                              => 'print supported responses'
--json                                              => 'print output in json'
-s | --site      [site profile name]                => 'set site to be use'
--soid           [serviceofferingid]                => 'set service offering id (required)'
--tid            [templateid]                       => 'set template id (required)'
--zid            [zoneid]                           => 'set zone id (required)'
-n | --name      [displayname]                      => 'set displayname'
--geturl                                            => 'get api url'

available cmd-arg:
vm

example:
#advanced network with dhcp
cloudcmd deploy --soid xxx --tid xxx --zid xxx -n testvm1 -p networkids=xxx  vm

#advanced network with ip address specified
cloudcmd deploy --soid xxx --tid xxx --zid xxx -n testvm1 -p iptonetworklist[0].ip=192.168.89.224,iptonetworklist[0].networkid=xxx vm

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
    [ 'ia'          => 'use integration api url (legacy port 8096)'],
    [ 'param|p=s'   => 'parameter field'  ],
    [ 'response|r=s'   => 'response field'  ],
    [ 'noheader|nh'    =>  'do not print header' ],
    [ 'showparams|sp'  =>  'print supported parameter' ],
    [ 'showresponses|sr' => 'print supported responses' ],
    [ 'h|help'    =>  'print help' ], 
    [ 'json' => 'print output in json' ],
    [ 'site|s=s' => 'set site'],
    [ 'soid=s'    => 'set service offering id'],
    [ 'tid=s'    => 'set template id'],
    [ 'zid=s'    => 'set zone id'],
    [ 'name|n=s'    => 'set displayname'],
    [ 'stime=s'   => 'set start time' ],
    [ 'etime=s'   => 'set end time'],
    [ 'geturl'    => 'get api url' ]
}

#check & set site
sub check_site{
    my ($opts, $obj) = @_;
    
    if(defined $$opts->{'site'}){
        $$obj->default_site($$opts->{'site'});
        return 1;
    }else{
        return 0;
    }
}

#check and set param / response attribute 
sub check_opts{
    my ($opts, $obj) = @_;

    if(defined $$opts->{'ia'}){
        $$obj->ia(1);
    }
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
    if($$opts->{'geturl'}){
        $$obj->geturl(1);
    }
}

sub set_cmd_line{
    my ($opts, $obj) = @_;

    #verify service offering id
    use Serviceoffering;
    my $tmp = Serviceoffering->new();
    $tmp->is_valid_id($$opts->{'soid'});
    
    #verify template id
    use Template;
    $tmp = Template->new();
    $tmp->is_valid_id($$opts->{'tid'});
    
    #verify zone id
    use Zone;
    $tmp = Zone->new();
    $tmp->is_valid_id($$opts->{'zid'});
    
    if(defined $$opts->{'param'}){
        if(check_site($opts, $obj)){
            $$obj->cmd_line("cloudcmd deploy --param " . $$opts->{'param'} .
                            " --soid " . $$opts->{'soid'} .
                            " --tid " . $$opts->{'tid'} .
                            " --zid " . $$opts->{'zid'} .
                            " --site " . $$opts->{'site'} .
                            " vm");
        }else{
            $$obj->cmd_line("cloudcmd deploy --param " . $$opts->{'param'} .
                            " --soid " .  $$opts->{'soid'} .
                            " --tid " . $$opts->{'tid'} .
                            " --zid " . $$opts->{'zid'} .
                            " vm");
        }
    }else{
        if(check_site($opts, $obj)){
            $$obj->cmd_line("cloudcmd deploy --soid " .  $$opts->{'soid'} .
                            " --tid " . $$opts->{'tid'} .
                            " --zid " . $$opts->{'zid'} .
                            " --site " . $$opts->{'site'} .
                            " vm");
        }else{
            $$obj->cmd_line("cloudcmd deploy --soid " .  $$opts->{'soid'} .
                            " --tid " . $$opts->{'tid'} .
                            " --zid " . $$opts->{'zid'} .
                            " vm");
        }
    }
}

sub check_time{
    my ($opts, $obj) = @_;
    
    set_cmd_line($opts, $obj);
    
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
            
            if(defined $opts->{'stime'} or defined $opts->{'etime'}){
                check_time(\$opts, \$obj);
            }else{
                check_site(\$opts, \$obj);
                check_opts(\$opts, \$obj);
                $obj->deploy_vm($opts->{'soid'}, $opts->{'tid'}, $opts->{'zid'}, $opts->{'name'});
            }
        }
   }
   
   return;
}

1;