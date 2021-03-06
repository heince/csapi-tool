package Csapi::Command::Destroy;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;

my $supported_args = qq \vm|router\;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
cloudcmd destroy [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                                => 'use integration api url (legacy port 8096)'
-p | --param     [comma separated api param]        => 'parameter field'
-r | --response  [comma separated api response]     => 'response field'
--nh | --noheader                                   => 'do not print header'
--sp | --showparams                                 => 'print supported parameter'
--sr | --showresponses                              => 'print supported responses'
--json                                              => 'print output in json'
-s | --site      [site profile name]                => 'set site to be use'
-i | --id        [comma separated vmid]             => 'set vm id (required)'
--geturl                                            => 'get api url'

available cmd-arg:
$supported_args

example:
cloudcmd destroy -i x $supported_args
cloudcmd destroy -i x,y,z $supported_args

EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    
    if(defined $cmd_opts->{'h'}){
        die $self->usage_text();
    }
    
    die "VM id required\n" unless $cmd_opts->{'id'};
    
    if(@args){
        given($args[0]){
            when (/\b($supported_args)\b/i){
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
    [ 'id|i=s'    => 'set vm id'],
    [ 'geturl'    => 'get api url' ]
}

#check & set site
sub check_site{
    my ($opts, $obj) = @_;
    
    if(defined $$opts->{'site'}){
        $$obj->default_site($$opts->{'site'});
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

#check and set param / response attribute 
sub check_opts{
    my ($opts, $obj) = @_;

    if(defined $$opts->{'ia'}){
        $$obj->ia(1);
    }
    if(defined $$opts->{'showparams'}){
        $$obj->set_destroy_xml();
        $$obj->print_param();
        exit;
    }
    if(defined $$opts->{'showresponses'}){
        $$obj->set_destroy_xml();
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

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   given($args[0]){
        when(/\bvm\b/i){
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
                    $obj->destroy_vm($displayname);
                }
            }
        }
        when (/\brouter\b/i){
        	if(defined $opts->{'id'}){
        		use Router;
        	
        		$obj = Router->new();
        		my @ids = split ',' , $opts->{'id'};
        		
        		#loop through id
                for(@ids){
                    check_site(\$opts, \$obj);
                    $obj->uuid($_);
                    check_opts(\$opts, \$obj);
                    $obj->destroy_router();
                }
        	}else{
        		die "router id required\n";
        	}
        }
   }
   
   return;
}

1;