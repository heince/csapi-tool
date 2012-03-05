=head1 NAME

General			-	Implements general functions

=head1 METHOD

=over

=item init_check			

check environment ,configuration file and return @array ($xml, $urlpath, $api_key, $secret_key)

=item generate_xml

return xml from GenUrl get_xml

=back

=head1 AUTHOR

heince          	- heince@gmail.com

=cut

package Usage;
use strict;
use warnings;
use 5.010;
use XML::Simple;
use DBI;
use DBD::mysql;
use lib ("$ENV{'CSAPIROOT'}/lib");

sub new{
	my $class = shift;
   my $self = bless({}, $class);
   return $self;
}

sub connect_db{
	my $self = shift;
	
	my ($host, $port, $schema, $user, $password) = @_;
	
	my $dbh = DBI->connect("DBI:mysql:database=$schema;host=$host;port=$port",
								  $user, $password, {'RaiseError' => 1}
								  );
	return $dbh;
}

sub get_query{
	my $self = shift;
	
	my ($accountid, $stime, $etime, $type) = @_;
	my $query;
	
	given($type){
		when (/[1|2]/){
			$query = qq|(SELECT dc.name as "Datacenter", ac.account_name as "Account", u.domain_id
					as "Domain ID", u.raw_usage as "Raw Usage",
					s.cpu as "CPU count", s.speed as "CPU, MHz", s.ram_size as "RAM, MB",
					8589934592/1024/1024/1024 as "Storage, GB", u.start_date, u.end_date,
					"-", u.offering_id, u.usage_id, u.usage_type, u.description
					FROM cloud_usage.cloud_usage u, cloud.account ac,
					cloud.data_center dc, cloud.service_offering s
					WHERE u.account_id=$accountid
					AND ac.id=$accountid
					AND u.zone_id=dc.id
					AND u.offering_id=s.id
					AND u.usage_type=$type
					AND u.start_date >= "$stime"
					AND u.end_date <= "$etime")|;
		}
		when (/[6]/){
			$query = qq|(SELECT dc.name as "Datacenter", ac.account_name as "Account", u.domain_id as
					"Domain ID", u.raw_usage as "Raw Usage",
					NULL as "CPU count", NULL as "CPU, MHz", NULL as "RAM MB",
					u.size/1024/1024/1024 as "Storage, GB", u.start_date, u.end_date,
					"-", u.offering_id, u.usage_id, u.usage_type, u.description
					FROM cloud_usage.cloud_usage u, cloud.account ac,
					cloud.data_center dc, cloud.disk_offering dsk
					WHERE u.account_id=$accountid
					AND ac.id=$accountid
					AND u.zone_id=dc.id
					AND u.offering_id=dsk.id
					AND u.usage_type=$type
					AND u.start_date >= "$stime"
					AND u.end_date <= "$etime")|;
		}
	}
	
	return $query;
}

sub exec_query{
	my $self = shift;
	
	my ($statement) = @_;
	my (%hash, %description);
	
	$statement->execute();
	while(my $ref = $statement->fetchrow_hashref()){
		if($hash{$ref->{'offering_id'}}){
			$hash{$ref->{'offering_id'}} += $ref->{'Raw Usage'};
		}else{
			$hash{$ref->{'offering_id'}} = $ref->{'Raw Usage'};
		}
		
		if($description{$ref->{'description'}}){
			$description{$ref->{'description'}} += $ref->{'Raw Usage'};
		}else{
			$description{$ref->{'description'}} = $ref->{'Raw Usage'};
		}
	}
	
	$statement->finish();
	return (\%hash, \%description);
}

sub get_usage{
	my $self = shift;
	
	my ($general,$connection, $accountid, $stime, $etime, $type) = @_;
	my ($hash, $description);
	
	my $query = $self->get_query($accountid, $stime, $etime, $type);
					
	my $statement = $connection->prepare($query);
	($hash, $description) = $self->exec_query($statement);
	
	#print header
	my $details = $self->get_account($general, $accountid);
	say "Account: @$details[0]";
	say "Domain : @$details[1]";
	say "Period : $stime to $etime\n";
	say "Details:";
	
	while ( my ($k,$v) = each %$description ) {
		$v = sprintf("%.3f",$v);
      say pack("A70 A30", "$k", "Total Hours = $v");
	}
	
	say "\nSummary:";
	my ($totalhours, $totalcosts);
	while ( my ($k,$v) = each %$hash ) {
		my $offering_name = $self->get_offering($general, $k, $type);
		my $cost = $self->get_cost($general, $k);
		$cost = sprintf("%.3f",$cost);
		$v = sprintf("%.3f",$v);
		my $tcost = ($cost * $v);
		$tcost = sprintf("%.3f",$tcost);
		$totalhours += $v;
		$totalcosts += $tcost;
		
      say pack("A25 A30 A20 A30", "Offering id : $k", "Name: @$offering_name", "Hours : $v", "Cost: \$$cost per hour");
	}
	say "\nTotal Hours : $totalhours";
	say "Total Costs : \$$totalcosts";
}

sub get_cost{
	my $self = shift;
	
	my ($general, $id) = @_;
	
	my $config = "$ENV{'CSAPIROOT'}/config/usage.xml";
	my $xml = $general->load_xml($config);
	my $cost = $xml->findnodes("/root/offerings/offering/id[text()=\"$id\"]/../cost/text()")->string_value();
	$cost = 0 unless $cost;
	return $cost;
}

sub get_account{
	my $self = shift;
	
	my ($general, $id) = @_;
	my ($site, $apikey, $secretkey, $obj) = $general->init_check('account');
	my ($header, $result) = $obj->list_account($site, $apikey, $secretkey, $general, "id=$id", "name,domain", "$ENV{'CSAPIROOT'}/config/Account/list.xml");
	return $result;
}

sub get_offering{
	my $self = shift;
	
	my ($general, $id, $type) = @_;
	my ($site, $apikey, $secretkey, $obj, $header, $result);
	
	given($type){
		when (/[1|2]/){
			($site, $apikey, $secretkey, $obj) = $general->init_check('svc_offering');
			($header, $result) = $obj->list_service_offering($site, $apikey, $secretkey, $general, "id=$id", "name", "$ENV{'CSAPIROOT'}/config/ServiceOffering/list.xml");
		}
		when ([6]){
			($site, $apikey, $secretkey, $obj) = $general->init_check('disk_offering');
			($header, $result) = $obj->list_disk_offering($site, $apikey, $secretkey, $general, "id=$id", "displaytext", "$ENV{'CSAPIROOT'}/config/DiskOffering/list.xml");
		}
	}
	
	return $result;
}

sub init_check{
	my $self = shift;
	
	my $config = "$ENV{'CSAPIROOT'}/config/usage.xml";

	unless (-d $ENV{'CSAPIROOT'} && -f $config){
	  die "CSAPIROOT directory or config file is not exist\n";
	}
	
	my $xml = XMLin($config);
	my $host = $xml->{host};
	my $port = $xml->{port};
	my $schema = $xml->{schema};
	my $user = $xml->{user};
	my $password = $xml->{password};
	
	my $dbh = $self->connect_db($host, $port, $schema, $user, $password);
	
	die "can't connect to db\n" unless $dbh;
	return $dbh;
}

1;