package Usage;
use strict;
use warnings;
use 5.010;
use XML::Simple;
use DBI;
use DBD::mysql;
use lib ("$ENV{'CSAPI_ROOT'}/lib");
use Mouse;
use GenUrl;

extends 'GenUrl';

has [qw/host user password stime etime query accountid/] => ( is => 'rw', isa => 'Str' );
has [qw/port type/] => ( is => 'rw', isa => 'Int' );
has 'dbh' => ( is => 'rw' );
has 'detail_field' => ( is => 'rw', isa => 'Str', default => "A90 A30" );
has 'summary_field' => ( is => 'rw', isa => 'Str', default => "A25 A30 A20 A30" );
has 'type6_field' => ( is => 'rw', isa => 'Str', default =>"A50 A25 A25 A25" );

#set xmltmp to hold list usage xml file
sub set_list_xml{
    my $self = shift;
    
    $self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Usage/listUsage.xml"));
}

sub list_usage{
    my $self = shift;
    
    #set xmltmp
    $self->set_list_xml();
    
	 #set initial command and xmlresult attr
    $self->set_command();
	 
    #print the output
    $self->get_output();
}

sub connect_db{
	my $self = shift;
	
	my $schema = shift;
	
	$self->dbh(DBI->connect("DBI:mysql:database=" . $schema . ";host=" . $self->host . ";port=" . $self->port,
								  $self->user, $self->password, {'RaiseError' => 1}
								  ));
}

#set query to get account uuid
sub set_account_id_query{
	my $self = shift;
	
	$self->query(qq|SELECT id FROM cloud.account where uuid="| . $self->uuid . qq|"|);
}

#get account id , not uuid
sub get_account_id{
	my $self = shift;
	
	my $id;
	
	$self->set_account_id_query();
	my $statement = $self->dbh->prepare($self->query);
	$statement->execute();
	
	while(my $ref = $statement->fetchrow_hashref()){
		$id = $ref->{'id'};
	}
	
	$self->dbh->disconnect();
	
	die "Account id not found, please use 'list account' to get the correct id\n" unless $id;
	$self->accountid($id);
}

sub get_usage_result{
	my $self = shift;
	
	$self->init_check();
	$self->connect_db("cloud");
	$self->get_account_id();
	
	given($self->type){
		when (/\b[1|2]\b/){
			$self->set_vm_query();
			$self->print_usage;
			
		}
		when (/\b[6]\b/){
			$self->set_volume_query();
			$self->print_usage;
		}
	}
}

#set running vm or allocated vm query
sub set_vm_query{
	my $self = shift;
	
	$self->query(qq|(SELECT dc.name as "Datacenter", ac.account_name as "Account", u.domain_id
					as "Domain ID", u.raw_usage as "Raw Usage",
					s.cpu as "CPU count", s.speed as "CPU, MHz", s.ram_size as "RAM, MB",
					8589934592/1024/1024/1024 as "Storage, GB", u.start_date, u.end_date,
					"-", u.offering_id, u.usage_id, u.usage_type, u.description
					FROM cloud_usage.cloud_usage u, cloud.account ac,
					cloud.data_center dc, cloud.service_offering s
					WHERE u.account_id=| . $self->accountid .
					" AND ac.id=" . $self->accountid .
					" AND u.zone_id=dc.id
					AND u.offering_id=s.id
					AND u.usage_type=" . $self->type .
					qq| AND u.start_date >= "| . $self->stime . qq|"
					 AND u.end_date <= "| . $self->etime . qq |")|);
}

#execute query and return the hash result
sub exec_usage_query{
	my $self = shift;
	
	my ($id, %hash, %description);
	
	$self->connect_db("cloud_usage");
	my $statement = $self->dbh->prepare($self->query);
	$statement->execute();
	
	given($self->type){
		when(/\b[1|2]\b/){
			while(my $ref = $statement->fetchrow_hashref()){
				#for Summary
				if($hash{$ref->{'offering_id'}}){
					$hash{$ref->{'offering_id'}} += $ref->{'Raw Usage'};
				}else{
					$hash{$ref->{'offering_id'}} = $ref->{'Raw Usage'};
				}
				
				#for details
				if($description{$ref->{'description'}}){
					$description{$ref->{'description'}} += $ref->{'Raw Usage'};
				}else{
					$description{$ref->{'description'}} = $ref->{'Raw Usage'};
				}
			}
		}
		when(/\b[6]\b/){
			#for details, no summary on type 6
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
	
	$self->dbh->disconnect();
	return (\%hash, \%description);
}

sub print_usage{
	my $self = shift;
	
	my ($hash, $description);
	
	($hash, $description) = $self->exec_usage_query();
	
	#print header
	my $details = $self->get_account();
	print $self->print_header($details);
	
	#print details
	for($self->get_details($description)){
		map {say} @$_;
	}
	
	given($self->type){
		when(/\b[1|2]\b/){
			#print summary
			my ($summary, $totalhours, $totalcosts) = $self->get_summary($hash);
			die "can't get summary\n" unless $totalhours;
			map {say} @$summary;
			say "\nTotal Hours : $totalhours";
			say "Total Costs : \$$totalcosts";
		}
	}
}

#set volume query
sub set_volume_query{
	my $self = shift;
	
	$self->query(qq|(SELECT dc.name as "Datacenter", ac.account_name as "Account", u.domain_id as
					"Domain ID", u.raw_usage as "Raw Usage",
					NULL as "CPU count", NULL as "CPU, MHz", NULL as "RAM MB",
					u.size/1024/1024/1024 as "Storage, GB", u.start_date, u.end_date,
					"-", u.offering_id, u.usage_id, u.usage_type, u.description
					FROM cloud_usage.cloud_usage u, cloud.account ac,
					cloud.data_center dc, cloud.disk_offering dsk
					WHERE u.account_id=| . $self->accountid .
					" AND ac.id=" . $self->accountid . 
					" AND u.zone_id=dc.id
					AND u.offering_id=dsk.id
					AND u.usage_type=" . $self->type .
					qq| AND u.start_date >= "| . $self->stime . qq|"
					 AND u.end_date <= "| . $self->etime . qq|")|);
}

sub print_header{
	my $self = shift;
	
	my ($details) = @_;
	my $header;
	
	given($self->type){
		when (/[1|2|6]/){
			$header .= "Account: @$details[0]\n";
			$header .= "Domain : @$details[1]\n";
			$header .= "Period : " . $self->stime . " to " . $self->etime . "\n\n";
			$header .= "Details:\n";
		}
	}
	return $header;
}

sub get_details{
	my $self = shift;
	
	my ($description) = @_;
	my @details;
	
	my %tmp = %$description;
	given($self->type){
		when (/[1|2]/){
			while ( my ($k,$v) = each %tmp) {
				$v = sprintf("%.3f",$v);
				push @details,pack($self->detail_field, "$k", "Total Hours = $v");
			}
		}
		when (/[6]/){
			my ($totalhours, $totalcosts);
			for my $k( keys %tmp ) {
				my $cost = $self->get_cost($tmp{$k}{"offering_id"});
				
				#check if its a custom disk & multiply it with the size
				if($self->is_custom_disk($tmp{$k}{"offering_id"})){
					$cost *= $tmp{$k}{'size'};
				}
				#multiply the cost with the usage hours
				$cost *= $tmp{$k}{'raw_usage'};
				
				#format with 2 decimal
				$cost = sprintf("%.2f",$cost);
				
				#get the total hours by adding the raw usage hours
				$totalhours += $tmp{$k}{'raw_usage'};
				
				#get the total cost by adding each cost
				$totalcosts += $cost;
				
				#format the disk size with 1 decimal
				$tmp{$k}{'size'} = sprintf("%.1f",$tmp{$k}{'size'});
				
				#format the raw usage with 2 decimal
				$tmp{$k}{'raw_usage'} = sprintf("%.2f",$tmp{$k}{'raw_usage'});
				
				#store details array with description, disk size, totalhours, costs
				push @details,pack($self->type6_field, "$k", "Disk Size = $tmp{$k}{'size'} GB" , "Total Hours = $tmp{$k}{'raw_usage'}", "Costs = \$$cost");
			}
			die "can't get summary\n" unless $totalhours;
			$totalhours = sprintf("%.2f",$totalhours);
			push @details, "\nTotal Hours : $totalhours";
			push @details, "Total Costs : \$$totalcosts\n";
		}
	}
	
	return \@details;
}

sub get_summary{
	my $self = shift;
	
	my ($summary) = @_;
	my @summary;
	
	push @summary, ("\nSummary");
	
	my ($totalhours, $totalcosts);
	
	given($self->type){
		when (/\b[1|2]\b/){
			while ( my ($k,$v) = each %$summary ) {
				my $offering_name = $self->get_offering($k);
				my $cost = $self->get_cost($k);
				$v = sprintf("%.2f",$v);
				my $tcost = ($cost * $v);
				$tcost = sprintf("%.3f",$tcost);
				$totalhours += $v;
				$totalcosts += $tcost;
				
				push @summary, pack($self->summary_field, "Offering id : $k", "Name: @$offering_name", "Hours : $v", "Cost: \$$cost per hour");
			}
		}
	}
	
	return \@summary, $totalhours, $totalcosts;
}

sub is_custom_disk{
	my $self = shift;
	
	my ($id) = @_;
	
	$self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/DiskOffering/list.xml"));
	$self->param("id=" . $id);
	$self->response("iscustomized");
	$self->set_command();
	$self->get_xml();
	
	if(grep(/true/, @{$self->get_api_result()})){
		return 1;
	}else{
		return 0;
	}
}

sub get_cost{
	my $self = shift;
	
	my ($id) = @_;
	
	$self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/usage.xml"));
	my $cost = $self->xmltmp->findnodes("/root/offerings/offering/id[text()=\"$id\"]/../cost/text()")->string_value();
	$cost = 0 unless $cost;
	$cost = sprintf("%.3f",$cost);
	return $cost;
}

sub get_account{
	my $self = shift;

	$self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/Account/list.xml"));
	$self->param("id=" . $self->uuid);
	$self->response("name,domain");
	$self->set_command();
	$self->get_xml();
	return $self->get_api_result();
}

sub get_offering{
	my $self = shift;
	
	my ($id) = @_;
	
	given($self->type){
		when (/\b[1|2]\b/){
			$self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/ServiceOffering/list.xml"));
			$self->param("id=" . $id);
			$self->response("name");
		}
		when (/\b[6]\b/){
			$self->xmltmp(XML::LibXML->load_xml(location => "$ENV{'CSAPI_ROOT'}/config/DiskOffering/list.xml"));
			$self->param("id=" . $id);
			$self->response("displaytext");
		}
	}
	
	$self->set_command();
	$self->get_xml();
	return $self->get_api_result();
}

sub init_check{
	my $self = shift;
	
	my $config = "$ENV{'CSAPI_ROOT'}/config/usage.xml";

	unless (-f $config){
	  die "Usage config file is not exist\n";
	}
	
	$self->xmltmp(XMLin($config));
	$self->host($self->xmltmp->{host});
	$self->port($self->xmltmp->{port});
	$self->user($self->xmltmp->{user});
	$self->password($self->xmltmp->{password});
}

1;