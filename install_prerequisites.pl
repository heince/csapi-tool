#!/usr/bin/env perl

my $requires = 'Mouse DBI DBD::mysql WWW::Mechanize URI::Encode XML::Simple XML::Twig XML::LibXML
                JSON LWP::Protocol::https  Digest::SHA CLI::Framework';
system("cpan $requires");
