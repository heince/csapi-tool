package Csapi::Command::Delete;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;

my $supported_args = qq \account|domain|project|projectivt|accountfromproject|fwrule|pfrule\;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
cloudcmd delete [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                                => 'use integration api url (legacy port 8096)'
-p | --param     [comma separated api param]        => 'parameter field'
-r | --response  [comma separated api response]     => 'response field'
--nh | --noheader                                   => 'do not print header'
-s | --site      [site profile name]                => 'set site to be use'
--json                                              => 'print output in json'
-i | --id        [id / uuid]                        => 'set id / uuid to delete'
-a | --account   [account name]                     => 'set account name (supported on accountfromproject)'
--geturl                                            => 'get api url'
            
available cmd-arg:
$supported_args

example:
cloudcmd del -i xxx account
cloudcmd del -i xxx domain
cloudcmd del -i [project id] -a [account name] accountfromproject

EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    
    if(defined $cmd_opts->{'h'}){
        die $self->usage_text();
    }
    
    if(@args){
        given($args[0]){
            when (/\b($supported_args)\b/i){
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
    [ 'param|p=s'   => 'parameter field'  ],
    [ 'response|r=s'   => 'response field'  ],
    [ 'noheader|nh'    =>  'do not print header' ],
    [ 'h|help'    =>  'print help' ], 
    [ 'site|s=s' => 'set site' ],
    [ 'json' => 'print output in json' ],
    [ 'id|i=s'  =>  'set id to be deleted' ],
    [ 'account|a=s'  =>  'set account name' ],
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
    if($$opts->{'geturl'}){
        $$obj->geturl(1);
    }

}

#call delete
sub del{
    my ($opts, $obj, $args) = @_;
    
    check_site(\$opts, \$obj);
    check_opts(\$opts, \$obj);
    
    if($args eq 'projectivt'){
        $obj->delete_projectInvitation();
    }
    elsif($args eq 'accountfromproject'){
        $obj->delete_accountFromProject($opts->{'id'});
    }
    else{
        $obj->delete();
    } 
}

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
   
   given($args[0]){
        when (/\baccount\b/i){
            use Account;
            $obj = Account->new(accid => $opts->{'id'});
            
            del($opts, $obj, undef);
        }
        when (/\bdomain\b/i){
            use Domain;
            $obj = Domain->new(domid => $opts->{'id'});
            
            del($opts, $obj, undef);
        }
        when (/\bproject\b/i){
            use Project;
            $obj = Project->new(project_id => $opts->{'id'});
            
            del($opts, $obj, undef);
        }
        when (/\bprojectivt\b/i){
            use Project;
            $obj = Project->new(invitation_id => $opts->{'id'});
            
            del($opts, $obj, 'projectivt');
        }
        when (/\baccountfromproject\b/){
            if((defined $opts->{'id'}) and (defined $opts->{'account'})){
                use Account;
                
                $obj = Account->new(accname => $opts->{'account'});
                del($opts, $obj, 'accountfromproject');
            }
        }
        when (/\bfwrule\b/i){
        	use Firewall;
        	
        	$obj = Firewall->new(uuid => $opts->{'id'});
        	$obj->delete_firewallrule();
        }
        when (/\bpfrule\b/i){
        	use Firewall;
        	
        	$obj = Firewall->new(uuid => $opts->{'id'});
        	$obj->delete_pfrule();
        }
   }
   
   return;
}

1;