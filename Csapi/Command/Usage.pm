package Csapi::Command::Usage;

use base qw( CLI::Framework::Command );
use v5.10;
use strict;
use warnings;
use Usage;

#return help output
sub usage_text{
    my $usage = <<EOF;
$0 usage -s 2012-05-01 -e 2012-06-01 -a 1 --type (1|2|6)
Type of usage:
1 - Running VM
2 - Allocated VM
6 - Volume
EOF
}

sub validate{
    my ($self, $cmd_opts, @args) = @_;
    if(defined $cmd_opts->{'h'} or ! %$cmd_opts){
        die $self->usage_text();
    }
    if(!$cmd_opts->{'s'}){
        die "start time required, use -s YYYY-MM-DD\n";
    }
    if(!$cmd_opts->{'e'}){
        die "end time required, use -e YYYY-MM-DD\n";
    }
    if(!$cmd_opts->{'a'}){
        die "account id required, use -a [id]\n";
    }
    if(!$cmd_opts->{'type'}){
        die "type required, use -h to see help section\n";
    }elsif($cmd_opts->{'type'} !~ /\b[1|2|6]\b/){
        die "type not supported, use -h to see help section\n"
    }
    
}

sub option_spec {
    # The option_spec() hook in the Command Class provides the option
    # specification for a particular command.
    [ 's|stime=s'   => 'start time'  ],
    [ 'e|etime=s'   => 'end time'  ],
    [ 'a|accountid=s'   => 'account id'  ],
    [ 'type=s' => 'type of usage' ],
    [ 'h|help'    =>  'print help' ]
}

#set required attributes
sub set_opts{
    my ($opts, $usage) = @_;
    
    $$usage->stime($$opts->{'s'});
    $$usage->etime($$opts->{'e'});
    $$usage->uuid($$opts->{'a'});
    $$usage->type($$opts->{'type'});
    
}

sub run{
    my ($self, $opts, @args) = @_;
    
    my $usage = Usage->new();
    $usage->init_check();
    
    set_opts(\$opts, \$usage);
    $usage->get_usage_result();
    
    return;
}

1;