package Site;
use strict;
use warnings;
use Mouse;
use v5.10;
use General;

has 'profile' => (is => "rw");

extends 'General';

sub get_name{
    my $self = shift;
    
    return "Name:\t\t" . $self->profile->findnodes("name")->string_value();
}

sub get_url{
    my $self = shift;
    
    return "URL:\t\t" . $self->profile->findnodes("urlpath")->string_value();   
}

sub get_user{
    my $self = shift;
    
    return "User:\t\t" . $self->profile->findnodes("user")->string_value();
}

sub get_domain{
    my $self = shift;
    
    return "Domain:\t\t" . $self->profile->findnodes("domain")->string_value();   
}

sub get_description{
    my $self = shift;
    
    return "Description:\t" . $self->profile->findnodes("description")->string_value();   
}

#get available site profile
sub get_all_site{
	my $self = shift;
	
   $self->init;
   say "Default Site:\t" . $self->default_site . "\n";
   my @profiles = $self->xmlconfig->findnodes(qq|/root/site/profile|);
   
   for my $profile(@profiles){
        $self->profile($profile);
        say $self->get_name();
        say $self->get_url();
        say $self->get_user();
        say $self->get_domain();
        say $self->get_description();
        say "";
   }
   
}

1;