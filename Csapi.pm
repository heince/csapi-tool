package Csapi;

use base qw( CLI::Framework);

use v5.10;
use strict;
use warnings;

sub usage_text {
    # The usage_text() hook in the Application Class is meant to return a
    # usage string describing the whole application.
    my $usage = <<EOF;
cloudcmd <cmd> [--cmd-opt] [cmd-arg]

Display help on each command:
cloudcmd <cmd> -h
cloudcmd list -h
cloudcmd deploy -h

(commands):
console             run interactively
cmd-list            list available commands
list                list    [--cmd-opt] (vm|account|site|diskoffering|svcoffering|
                                        template|user|job|zone|network|domain|project|
                                        projectIvt|projectAcc|router|fwrule|pfrule|publicip|
                                        host)
migrate             migrate [--cmd-opt] (vm)
deploy              deploy  [--cmd-opt] (vm)
destroy             destroy [--cmd-opt] (vm|router)
stop                stop    [--cmd-opt] (vm|router)
start               start   [--cmd-opt] (vm|router)
reboot              reboot  [--cmd-opt] (vm|router)
sync                sync    [--cmd-opt] (ldap)
set                 set     [--cmd-opt] (ldap)
remove              remove  [--cmd-opt] (ldap)
usage               usage -s 2012-05-01 -e 2012-06-01 -a 1 -type (1|2|6)
create              create  [--cmd-opt] (account|domain|project|fwrule|pfrule)
delete              delete  [--cmd-opt] (account|domain|project|projectIvt|accountfromproject|fwrule|pfrule)
update              update  [--cmd-opt] (account|domain|project|projectIvt)
suspend             suspend [--cmd-opt] project
activate            activate [--cmd-opt] project
disable             disable [--cmd-opt] account
enable              enable  [--cmd-opt] account
add                 add     [--cmd-opt] account
    
EOF
}

sub option_spec {
    # The option_spec() hook in the Application class provides the option
    # specification for the whole application.
    [ 'help|h'         => 'display help' ],
}

sub validate_options {
    # The validate_options() hook can be used to ensure that the application
    # options are valid.
    my ($self, $opts) = @_;
    die $self->usage_text unless defined $opts or $opts->{'help'};
    
    # ...nothing to check for this application
}

sub command_map {
    
    # In this *list*, the command names given as keys will be bound to the
    # command classes given as values.  This will be used by CLIF as a hash
    # initializer and the command_map_hashref() method will be provided to
    # return a hash created from this list for convenience.
    
    console     => 'CLI::Framework::Command::Console',
    alias       => 'CLI::Framework::Command::Alias',
    'cmd-list'  => 'CLI::Framework::Command::List',
    list		=> 'Csapi::Command::List',
    deploy	=> 'Csapi::Command::Deploy',
    destroy	=> 'Csapi::Command::Destroy',
    usage   => 'Csapi::Command::Usage',
    stop    => 'Csapi::Command::Stop',
    start    => 'Csapi::Command::Start',
    reboot    => 'Csapi::Command::Reboot',
    sync    => 'Csapi::Command::Sync',
    set     => 'Csapi::Command::Set',
    remove     => 'Csapi::Command::Remove',
    create     => 'Csapi::Command::Create',
    delete     => 'Csapi::Command::Delete',
    update     => 'Csapi::Command::Update',
    suspend    => 'Csapi::Command::Suspend',
    activate    => 'Csapi::Command::Activate',
    disable    => 'Csapi::Command::Disable',
    enable     => 'Csapi::Command::Enable',
    add         => 'Csapi::Command::Add',
    migrate     => 'Csapi::Command::Migrate',
}

sub command_alias {
    # In this list, the keys are aliases to the command names given as values
    # (the values should be found as "keys" in command_map()).
    sh  => 'console',
    ls  => 'list',
    cr  => 'create',
    del => 'delete',
    rm  => 'remove'
}

sub init {
    # This initialization is performed once for the application (default
    # behavior).
    my ($self, $opts) = @_;

}
1;
