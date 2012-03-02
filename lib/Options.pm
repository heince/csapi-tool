=head1 NAME

Options		- Implements options actions

=head1 METHOD
	
=over

=item check_options

check options

=back

=head1 AUTHOR

heince          	- heince@gmail.com

=cut

package Options;
use strict;
use warnings;
use 5.010;
use lib ("$ENV{'CSAPIROOT'}/lib");
#use Carp qw /croak cluck carp confess/;

sub new{
	my $class = shift;
   my $self = bless({}, $class);
   return $self;
}

sub default_given{
    my $self = shift;
    
    my ($option, $value, $items) = @_;
    say "Invalid value -$option $value (use -$option $items)";
}

sub check_options{
    my $self = shift;

    my ($general, $site, $apikey, $secretkey, $obj, $list, $start, $stop, $reboot, $destroy, $deploy, $id, $param, $response) = @_;
    my $items;   
   
    if(defined $list){
        $items = 'account|template|vm|svc_offering';
        given($list){
          when (/\baccount\b/){
             my ($header, $result) = $obj->list_account($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/Account/list.xml");
             #print header & result
             print @$header; print @$result;break;
          }
          when (/\btemplate\b/){
             my ($header, $result) = $obj->list_template($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/Template/list.xml");
             #print header & result
             print @$header; print @$result;break;
          }
          when (/\bvm\b/){
             my ($header, $result) = $obj->list_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/list.xml");
             #print header & result
             do{print @$header; print @$result} if defined @$result;break;
          }
          when (/\bsvc_offering\b/){
             my ($header, $result) = $obj->list_service_offering($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/ServiceOffering/list.xml");
             #print header & result
             print @$header; print @$result;break;
          }
			 when (/\busage\b/){
             my ($header, $result) = $obj->list_usage($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/Usage/listUsage.xml");
             #print header & result
             print @$header; print @$result;break;
          }
          default{
             $self->default_given('list', $list, $items);
          }
       }
    }
    
    if(defined $start){
        $items = 'vm';
        given($start){
          when (/\bvm\b/){
             my $id = $general->check_id($id);
             for(@$id){
                $param="id=$_";
                my $vmstatus = $obj->start_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/start.xml", $_);
                print $vmstatus if $vmstatus;
             }
             break;
          }
          default{
             $self->default_given('start', $start, $items);
          }
       }
    }
    
    if(defined $stop){
        $items = 'vm';
        given($stop){
          when (/\bvm\b/){
             my $id = $general->check_id($id);
             for(@$id){
                $param="id=$_";
                my $vmstatus = $obj->stop_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/stop.xml", $_);
                print $vmstatus if $vmstatus;
             }
             break;
          }
          default{
             $self->default_given('stop', $stop, $items);
          }
       }
    }
    
    if(defined $reboot){
        $items = 'vm';       
       given($reboot){
          when (/\bvm\b/){
             my $id = $general->check_id($id);
             for(@$id){
                $param="id=$_";
                my $vmstatus = $obj->reboot_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/reboot.xml", $_);
                print $vmstatus if $vmstatus;
             }
             break;
          }
          default{
             $self->default_given('reboot', $reboot, $items);
          }
       }
    }
    
    if(defined $destroy){
        $items = 'vm';    
        given($destroy){
          when (/\bvm\b/){
             my $id = $general->check_id($id);
             for(@$id){
                $param="id=$_";
                my $vmstatus = $obj->destroy_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/destroy.xml", $_);
                print $vmstatus if $vmstatus;
             }
             break;
          }
          default{
              $self->default_given('destroy',$destroy, $items);
          }
       }
    }
    
    if(defined $deploy){
        $items = 'vm';       
        given($deploy){
          when(/\bvm\b/){
             my $vmstatus = $obj->deploy_vm($site, $apikey, $secretkey, $general, $param, $response, "$ENV{'CSAPIROOT'}/config/VM/deploy.xml");
             print $vmstatus if $vmstatus;
          }
          default{
            $self->default_given('deploy',$deploy, $items);
          }
       }
    }
   
}


1;
