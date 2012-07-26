package Csapi::Command::List;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;

my $supported_args = qq \vm|account|site|diskoffering|svcoffering|template|user|job|zone|network|domain\ .
                     qq \|project|projectIvt|projectAcc|router|fwrule|pfrule|publicip|host|capacity\;

#return usage output
sub usage_text{
    my $usage = <<EOF;
Usage:
cloudcmd ls [--cmd-opt] [cmd-arg]

available cmd-opt:
--ia                                                => 'use integration api url (legacy port 8096)'
-p | --param     [comma separated api param]        => 'parameter field'
-r | --response  [comma separated api response]     => 'response field'
--nh | --noheader                                   => 'do not print header'
--sp | --showparams                                 => 'print supported parameter'
--sr | --showresponses                              => 'print supported responses'
--json                                              => 'print output in json'
-s | --site      [site profile name]                => 'set site to be use'
-i | --id        [id|uuid]                          => 'set id or uuid for cmd-arg'
--geturl                                            => 'get api url'
--field          [comma separated field+value]      => 'custom field size'

available cmd-arg:
$supported_args

example:
cloudcmd ls -a vm                                   => list all vm
cloudcmd ls --nh vm                                 => list vm without header
cloudcmd ls -p account=heince,domainid=2 vm         => list vm with specified API parameter
cloudcmd ls -r displayname,account,domain vm        => list vm with specified responses field
cloudcmd ls --sp vm                                 => list parameter supported on listing vm
cloudcmd ls --sr vm                                 => list response supported on listing vm
cloudcmd ls -i xxx job                              => query async job by jobid
cloudcmd ls -s office-admin vm                      => list vm using 'office-admin' site profile

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
    [ 'id|i=s'    => 'set id'],
    [ 'all|a'     => 'turn on listall=true' ],
    [ 'geturl'    => 'get api url' ],
    [ 'field=s'     => 'custom field size' ]
}


#check and set param / response attribute 
sub check_opts{
    my ($opts, $obj, $args) = @_;

    if(defined $$opts->{'ia'}){
        $$obj->ia(1);
    }
    if(defined $$opts->{'site'}){
        $$obj->default_site($$opts->{'site'});
    }
    if(defined $$opts->{'all'}){
        $$obj->param("listall=true");
    }
    if(defined $$opts->{'showparams'}){
        if($args eq 'projectIvt'){
            $$obj->set_listProjectInvitations_xml;
        }
        elsif($args eq 'projectAcc'){
            $$obj->set_listProjectAccounts_xml;
        }
        else{
            $$obj->set_list_xml();
        }
        $$obj->print_param();
        exit;
    }
    if(defined $$opts->{'showresponses'}){
        if($args eq 'projectIvt'){
            $$obj->set_listProjectInvitations_xml;
        }
        elsif($args eq 'projectAcc'){
            $$obj->set_listProjectAccounts_xml;
        }
        else{
            $$obj->set_list_xml();
        }
        $$obj->print_response();
        exit;
    }
    if(defined $$opts->{'param'}){
        if($$obj->param){
            $$obj->param($$obj->param . "," . $$opts->{'param'});
        }else{
            $$obj->param($$opts->{'param'});   
        }
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
    if($$opts->{'field'}){
        my @field = split ',' => $$opts->{'field'};
        for(@field){
            my @tmp = split '=' => $_;
            my ($fieldname, $fieldsize) = @tmp;
            unless ($fieldsize =~ /\d+/){
                die "field size cannot empty and must be integer value\n";
            }
            $$obj->$fieldname($fieldsize);
        }
    }
}

sub run{
	my ($self, $opts, @args) = @_;
   
   my $obj;
    given($args[0]){
        when (/\bvm\b/i){
            use VM;
            $obj = VM->new();
            check_opts(\$opts, \$obj, undef);
            
            $obj->list_vm();
        }
        when (/\baccount\b/i){
            use Account;
            $obj = Account->new();
            check_opts(\$opts, \$obj, undef);
            
            $obj->list_account();
        }
        when (/\b(do|diskoffering)\b/i){
            use Diskoffering;
            $obj = Diskoffering->new();
            check_opts(\$opts, \$obj, undef);
            
            $obj->list_diskoffering();
            }
        when (/\b(so|svcoffering)\b/i){
            use Serviceoffering;
            $obj = Serviceoffering->new();
            check_opts(\$opts, \$obj, undef);
            
            $obj->list_serviceoffering();
            }
        when (/\btemplate\b/i){
            use Template;
            $obj = Template->new();
            check_opts(\$opts, \$obj, undef);
            
            $obj->list_template();
        }
        when (/\buser\b/i){
            use User;
            $obj = User->new();
            check_opts(\$opts, \$obj, undef);
            
            $obj->list_user();
        }
        when (/\busage\b/i){
            use Usage;
            $obj = Usage->new();
            check_opts(\$opts, \$obj, undef);
            
            $obj->list_usage();
        }
        when (/\bsite\b/i){
            use Site;
            $obj = Site->new();
            $obj->get_all_site();
        }
        when (/\bjob\b/i){
            use AsyncJob;
            $obj = AsyncJob->new();
            check_opts(\$opts, \$obj, undef);
            
            if(defined $opts->{'id'}){
                $obj->param("jobid=" . $opts->{'id'});
                $obj->query_asyncjob();
            }else{
                $obj->list_asyncjob();
            } 
        }
        when (/\bzone\b/i){
            use Zone;
            $obj = Zone->new();
            check_opts(\$opts, \$obj, undef);
            
            if(defined $opts->{'id'}){
                $obj->uuid($opts->{'id'});
            }
            $obj->list_zones();
        }
        when (/\bnetwork\b/i){
            use Network;
            
            $obj = Network->new();
            check_opts(\$opts, \$obj, undef);
            
            if(defined $opts->{'id'}){
                $obj->uuid($opts->{'id'});
            }
            $obj->list_networks();
        }
        when (/\bdomain\b/i){
            use Domain;
            
            $obj = Domain->new();
            check_opts(\$opts, \$obj, undef);
            
            if(defined $opts->{'id'}){
                $obj->uuid($opts->{'id'});
            }
            $obj->list_domains();
        }
        when (/\bproject\b/){
            use Project;
            
            $obj = Project->new();
            check_opts(\$opts, \$obj, undef);
            $obj->list_projects();
        }
        when(/\bprojectIvt\b/i){
            use Project;
            
            $obj = Project->new();
            check_opts(\$opts, \$obj, 'projectIvt');
            $obj->list_projectInvitations;
            
        }
        when (/\bprojectAcc\b/i){
            if(defined $opts->{'id'}){
                use Account;
            
                $obj = Account->new();
                check_opts(\$opts, \$obj, 'projectAcc');
                $obj->list_projectAccounts($opts->{'id'});
            }else{
                die "Project id is required, use -i [project id]\n";
            }      
        }
        when (/\brouter\b/i){
        	use Router;
        	
        	$obj = Router->new();
        	check_opts(\$opts, \$obj, undef);
        	if(defined $opts->{'id'}){
                $obj->uuid($opts->{'id'});
            }
            $obj->list_routers();
        }
        when (/\bfwrule\b/i){
        	use Firewall;
        	
        	$obj = Firewall->new();
        	check_opts(\$opts, \$obj, undef);
        	if(defined $opts->{'id'}){
                $obj->uuid($opts->{'id'});
            }
            $obj->list_FirewallRules();
        }
        when (/\bpfrule\b/i){
        	use Firewall;
        	
        	$obj = Firewall->new();
        	check_opts(\$opts, \$obj, undef);
        	if(defined $opts->{'id'}){
                $obj->uuid($opts->{'id'});
            }
            $obj->list_PortForwardingRules();
        }
        when (/\bpublicip\b/i){
        	use Address;
        	
        	$obj = Address->new();
        	check_opts(\$opts, \$obj, undef);
        	if(defined $opts->{'id'}){
                $obj->uuid($opts->{'id'});
            }
            $obj->list_publicip();	
        }
        when (/\bhost\b/i){
        	use Host;
        	
        	$obj = Host->new();
        	check_opts(\$opts, \$obj, undef);
        	if(defined $opts->{'id'}){
                $obj->uuid($opts->{'id'});
            }
            $obj->list_hosts();	
        }
        when (/\bcapacity\b/i){
        	use Capacity;
        	
        	$obj = Capacity->new();
        	check_opts(\$opts, \$obj, undef);
        	if(defined $opts->{'id'}){
                $obj->uuid($opts->{'id'});
            }
            $obj->list();
        }
    }

	return;
}

1;

