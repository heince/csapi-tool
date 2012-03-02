#!/usr/bin/env perl

#this script generate url for ldapConfig API
#set your parameter below

use URI::Escape;
 
my ($apiurl, $command, $ldapsvr, $searchbase, $queryfilter, $binddn, $bindpass, $encode); 

$apiurl = q|http://192.168.1.109:8096/client/api?|;
$command = q|command=ldapConfig|;
$ldapsvr = q|ldap.example.com|;
$searchbase = q|cn=users,dc=example,dc=com|;
$queryfilter = q|(&(uid=%u))|;
$binddn = q|cn=Admin,cn=users,dc=example,dc=com|;
$bindpass = q|secret|;

$encode = "$apiurl$command&hostname=$ldapsvr&searchbase=" . uri_escape($searchbase) . "&queryfilter=" . uri_escape($queryfilter) .
            "&binddn=" . uri_escape($binddn) . "&bindpass=$bindpass&response=json";

print "$encode\n";
