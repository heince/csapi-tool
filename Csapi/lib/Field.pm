package Field;
use v5.10;
use Mouse;
use strict;
use warnings;

has [qw /cpuused iplimit iptotal vmlimit vmtotal offerha isready status level haschild port endport icmpcode icmptype
     /] => ( is => 'rw', isa => 'Int', default => 9 );

has [qw /haenabled cpuspeed nic-type hosttags issystem memory tags bootable format ispublic success
     size protocol/] => ( is => 'rw', isa => 'Int', default => 10 );

has [qw /cpunumber vmrunning vmstopped isdefault startport/] => ( is => 'rw', isa => 'Int', default => 11 );

has [qw /ipavailable hypervisor memory state user-state defaultuse disksize crossZones isfeatured  usage
     rawusage usagetype acltype publicport purpose memoryused/] => ( is => 'rw', isa => 'Int', default => 12 );

has [qw /vmavailable volumelimit volumetotal user-domain limitcpuuse networkrate storagetype templatetag privateport
     ostypename jobstatus networktype issourcenat isstaticnat averageload memorytotal percentused
     /] => ( is => 'rw', isa => 'Int', default => 13 );

has [qw /templatelimit templatetotal user-account systemvmtype iscustomized templatetype capabilities cpuallocated
     broadcasturi disconnected capacityused/] => ( is => 'rw', isa => 'Int', default => 14 );

has [qw /account domain group isoname password nic-ip nic-isdefault securitygroup-domain jobprocstatus jobresultcode jobresulttype
     securitygroup-name networkdomain receivedbytes sentbytes snapshottotal username isextractable domainname path parentdomainname
     scriptsversion publicendport disksizetotal events capacitytotal/] => ( is => 'rw', isa => 'Int', default => 15 );

has [qw /rootdevicetype securitygroup-account accounttype user-firstname user-lastname redundantstate
     firstname lastname privateendport podname/] => ( is => 'rw', isa => 'Int', default => 16 );

has [qw /ipaddress netmask gateway networkkbsread passwordenabled nic-traffictype volumeavailable allocationstate dhcpprovider
     passwordenabled dns1 dns2 internaldns1 internaldns2 restartrequired specifyipranges subdomainaccess traffictype
     guestipaddress guestnetmask linklocalip linklocalmacaddress linklocalnetmask publicip publicmacaddress publicnetmask
     memoryallocated/] => ( is => 'rw', isa => 'Int', default => 17 );

has [qw /networkkbswrite nic-broadcasturi nic-isolationuri nic-macaddress nic-netmask guestmacaddress
     securitygroup-jobstatus user-accounttype type/] => ( is => 'rw', isa => 'Int', default => 18 );

has [qw /forvirtualnetwork iscleanuprequired snapshotavailable snapshotlimit templateavailable jobinstancetype
     isredundantrouter disksizeallocated hasenoughcapacity hypervisorversion/] => ( is => 'rw', isa => 'Int', default => 19 );

has [qw /hostname isodisplaytext user-timezone displaytext description timezone guestcidraddress broadcastdomaintype
     cidr name cidrlist vlanname clustertype/] => ( is => 'rw', isa => 'Int', default => 20 );

has [qw /serviceofferingname templatedisplaytext securitygroup-ingressrule-cidr/] => ( is => 'rw', isa => 'Int', default => 21 );

has [qw /securitygroup-ingressrule-account securitygroupsenabled islocalstorageactive/] => ( is => 'rw', isa => 'Int', default => 23 );

has [qw /securitygroup-ingressrule-endport/] => ( is => 'rw', isa => 'Int', default => 24 );

has [qw /displayname created securitygroup-description securitygroup-ingressrule-icmpcode securitygroup-ingressrule-icmptype
     securitygroup-ingressrule-protocols user-created user-email checksum removed zonename email project service
     virtualmachinename allocated clustername lastpinged oscategoryname/] => ( is => 'rw', isa => 'Int', default => 25 );

has [qw /enddate startdate networkofferingavailability virtualmachinedisplayname
	cpuwithoverprovisioning/] => ( is => 'rw', isa => 'Int', default => 30 );

has [qw /securitygroup-ingressrule-securitygroupname vlan/] => ( is => 'rw', isa => 'Int', default => 34 );

has [qw /securitygroup-ingressrule-startport templatename/] => ( is => 'rw', isa => 'Int', default => 35 );

has [qw/id accountid domainid groupid guestosid hostid isoid templateid jobid rootdeviceid serviceofferingid sourcetemplateid
     diskofferingid zoneid nic-id nic-gateway nic-networkid securitygroup-id securitygroup-domainid securitygroup-jobid
     securitygroup-ingressrule-ruleid user-id user-domainid ostypeid networkid usageid virtualmachineid userid zonetoken
     offeringid jobinstanceid cmd networkofferingid networkofferingname physicalnetworkid projectid related parentdomainid
     queryfilter guestnetworkid linklocalnetworkid podid publicnetworkid ipaddressid associatednetworkid vlanid clusterid
     managementserverid oscategoryid/] => ( is => 'rw', isa => 'Int', default => 38 );

has [qw /searchbase/] => ( is => 'rw', isa => 'Int', default => 50 );

has [qw /user-apikey user-secretkey apikey secretkey networkofferingdisplaytext
     /] => ( is => 'rw', isa => 'Int', default => 88 );

has [qw /jobresult/] => ( is => 'rw', isa => 'Int', default => 100 );

1;