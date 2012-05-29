package Field;
use v5.10;
use Mouse;
use strict;
use warnings;


has [qw /cpuused iplimit iptotal vmlimit vmtotal offerha isready status/] => ( is => 'rw', isa => 'Int', default => 9 );

has [qw /haenabled cpuspeed nic-type hosttags issystem memory tags bootable format ispublic
     size/] => ( is => 'rw', isa => 'Int', default => 10 );

has [qw /cpunumber jobstatus vmrunning vmstopped isdefault/] => ( is => 'rw', isa => 'Int', default => 11 );

has [qw /ipavailable hypervisor memory state user-state defaultuse disksize crossZones isfeatured type usage
     rawusage usagetype/] => ( is => 'rw', isa => 'Int', default => 12 );

has [qw /vmavailable volumelimit volumetotal user-domain limitcpuuse networkrate storagetype templatetag
     ostypename/] => ( is => 'rw', isa => 'Int', default => 13 );

has [qw /templatelimit templatetotal user-account systemvmtype iscustomized templatetype/] => ( is => 'rw', isa => 'Int', default => 14 );

has [qw /account domain group isoname password nic-ip nic-isdefault securitygroup-domain jobprocstatus jobresultcode jobresulttype
     securitygroup-name networkdomain receivedbytes sentbytes snapshottotal username isextractable
     /] => ( is => 'rw', isa => 'Int', default => 15 );

has [qw /rootdevicetype securitygroup-account accounttype user-firstname user-lastname
     firstname lastname/] => ( is => 'rw', isa => 'Int', default => 16 );

has [qw /ipaddress networkkbsread passwordenabled nic-traffictype volumeavailable
     passwordenabled/] => ( is => 'rw', isa => 'Int', default => 17 );

has [qw /networkkbswrite nic-broadcasturi nic-isolationuri nic-macaddress nic-netmask
     securitygroup-jobstatus user-accounttype/] => ( is => 'rw', isa => 'Int', default => 18 );

has [qw /forvirtualnetwork iscleanuprequired snapshotavailable snapshotlimit templateavailable jobinstancetype
     /] => ( is => 'rw', isa => 'Int', default => 19 );

has [qw /hostname isodisplaytext user-timezone displaytext description timezone/] => ( is => 'rw', isa => 'Int', default => 20 );

has [qw /serviceofferingname templatedisplaytext securitygroup-ingressrule-cidr/] => ( is => 'rw', isa => 'Int', default => 21 );

has [qw /securitygroup-ingressrule-account/] => ( is => 'rw', isa => 'Int', default => 23 );

has [qw /securitygroup-ingressrule-endport/] => ( is => 'rw', isa => 'Int', default => 24 );

has [qw /name displayname created securitygroup-description securitygroup-ingressrule-icmpcode securitygroup-ingressrule-icmptype
     securitygroup-ingressrule-protocols user-created user-email checksum removed zonename email
     /] => ( is => 'rw', isa => 'Int', default => 25 );

has [qw /enddate startdate/] => ( is => 'rw', isa => 'Int', default => 30 );

has [qw /securitygroup-ingressrule-securitygroupname/] => ( is => 'rw', isa => 'Int', default => 34 );

has [qw /securitygroup-ingressrule-startport templatename cmd/] => ( is => 'rw', isa => 'Int', default => 35 );

has [qw/id accountid domainid groupid guestosid hostid isoid templateid jobid rootdeviceid serviceofferingid sourcetemplateid
     diskofferingid zoneid nic-id nic-gateway nic-networkid securitygroup-id securitygroup-domainid securitygroup-jobid
     securitygroup-ingressrule-ruleid user-id user-domainid ostypeid networkid usageid virtualmachineid userid jobresult
     offeringid jobinstanceid/] => ( is => 'rw', isa => 'Int', default => 38 );

has [qw /user-apikey user-secretkey apikey secretkey/] => ( is => 'rw', isa => 'Int', default => 88 );

1;