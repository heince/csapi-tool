=head1 NAME

General			-	Implements general functions

=head1 METHOD

=over

=item init_check			

Return DB connection

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
	
	my ($statement, $type) = @_;
	my (%hash, %description);
	
	$statement->execute();
	given($type){
		when (/[1|2]/){
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
		}
		when (/[6]/){
			while(my $ref = $statement->fetchrow_hashref()){
				if(defined $description{$ref->{'description'}}){
					if(defined $description{$ref->{'description'}}{'raw_usage'}){
						$description{$ref->{'description'}}{'raw_usage'} += $ref->{'Raw Usage'};
					}
				}else{
					%description = (%description, ($ref->{'description'} => {"raw_usage" => "$ref->{'Raw Usage'}", "size" => "$ref->{'Storage, GB'}", "offering_id" => "$ref->{'offering_id'}"}));
				}
			}
		}
	}
	
	$statement->finish();
	return (\%hash, \%description);
}

sub print_header{
	my $self = shift;
	
	my ($details, $stime, $etime, $type) = @_;
	my $header;
	
	given($type){
		when (/[1|2|6]/){
			$header .= "Account: @$details[0]\n";
			$header .= "Domain : @$details[1]\n";
			$header .= "Period : $stime to $etime\n\n";
			$header .= "Details:\n";
		}
	}
	return $header;
}

sub get_details{
	my $self = shift;
	
	my ($general, $description, $type) = @_;
	my @details;
	
	my %tmp = %$description;
	given($type){
		when (/[1|2]/){
			while ( my ($k,$v) = each %tmp) {
				$v = sprintf("%.3f",$v);
				push @details,pack("A70 A30", "$k", "Total Hours = $v");
			}
		}
		when (/[6]/){
			my ($totalhours, $totalcosts);
			for my $k( keys %tmp ) {
				my $cost = $self->get_cost($general, $tmp{$k}{"offering_id"});;
				if($self->is_custom_disk($general, $tmp{$k}{"offering_id"})){
					$cost *= $tmp{$k}{'size'};
				}
				$cost *= $tmp{$k}{'raw_usage'};
				$cost = sprintf("%.2f",$cost);
				
				$totalhours += $tmp{$k}{'raw_usage'};
				$totalcosts += $cost;
				$tmp{$k}{'size'} = sprintf("%.1f",$tmp{$k}{'size'});
				$tmp{$k}{'raw_usage'} = sprintf("%.2f",$tmp{$k}{'raw_usage'});
				push @details,pack("A50 A30 A30 A25", "$k", "Disk Size = $tmp{$k}{'size'} GB" , "Total Hours = $tmp{$k}{'raw_usage'}", "Costs = \$$cost");
			}
			$totalhours = sprintf("%.2f",$totalhours);
			push @details, "\nTotal Hours : $totalhours";
			push @details, "Total Costs : \$$totalcosts\n";
		}
	}
	
	return \@details;
}

sub get_summary{
	my $self = shift;
	
	my ($general, $summary, $type) = @_;
	my @summary;
	
	push @summary, ("\nSummary");
	
	my ($totalhours, $totalcosts);
	
	given($type){
		when (/[1|2]/){
			while ( my ($k,$v) = each %$summary ) {
				my $offering_name = $self->get_offering($general, $k, $type);
				my $cost = $self->get_cost($general, $k);
				$v = sprintf("%.2f",$v);
				my $tcost = ($cost * $v);
				$tcost = sprintf("%.3f",$tcost);
				$totalhours += $v;
				$totalcosts += $tcost;
				
				push @summary, pack("A25 A30 A20 A30", "Offering id : $k", "Name: @$offering_name", "Hours : $v", "Cost: \$$cost per hour");
			}
		}
	}
	
	return \@summary, $totalhours, $totalcosts;
}

sub is_custom_disk{
	my $self = shift;
	
	my ($general, $id) = @_;
	my ($site, $apikey, $secretkey, $obj) = $general->init_check('disk_offering');
	my ($header, $result) = $obj->list_disk_offering($site, $apikey, $secretkey, $general, "id=$id", "iscustomized", "$ENV{'CSAPIROOT'}/config/DiskOffering/list.xml");
	if(grep(/true/, @$result)){
		return 1;
	}else{
		return 0;
	}
}

sub get_usage{
	my $self = shift;
	
	my ($general,$connection, $accountid, $stime, $etime, $type) = @_;
	my ($hash, $description);
	
	my $query = $self->get_query($accountid, $stime, $etime, $type);
					
	my $statement = $connection->prepare($query);
	($hash, $description) = $self->exec_query($statement, $type);
	
	#print header
	my $details = $self->get_account($general, $accountid);
	print $self->print_header($details, $stime, $etime, $type);
	
	given($type){
		when (/[1|2]/){
			#print details
			for($self->get_details($general, $description, $type)){
				map {say} @$_;
			}
			
			#print summary
			my ($summary, $totalhours, $totalcosts) = $self->get_summary($general, $hash, $type);
			map {say} @$summary;
			say "\nTotal Hours : $totalhours";
			say "Total Costs : \$$totalcosts";
		}
		when (/[6]/){
			#print details
			for($self->get_details($general, $description, $type)){
				map {say} @$_;
			}
		}
	}
	
}

sub get_cost{
	my $self = shift;
	
	my ($general, $id) = @_;
	
	my $config = "$ENV{'CSAPIROOT'}/config/usage.xml";
	my $xml = $general->load_xml($config);
	my $cost = $xml->findnodes("/root/offerings/offering/id[text()=\"$id\"]/../cost/text()")->string_value();
	$cost = 0 unless $cost;
	$cost = sprintf("%.3f",$cost);
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