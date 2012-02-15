#!/usr/bin/env perl

my $requires = 'WWW::Mechanize URI::Encode XML::Simple XML::Twig XML::LibXML JSON LWP::Protocol::https  Digest::SHA';
system("cpan $requires");
