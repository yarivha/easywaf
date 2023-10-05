package EasyWAF::Controller::Policy;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;
use File::Basename 'basename';
use File::Path 'mkpath';

my $msg;
my $result;
my $POLICY_DIR="/etc/nginx/modsec";
my %policy;

sub view ($self) {
  if (!($self->session('is_auth'))) {
        $self->redirect_to('login');
  }
  my $username=$self->session('user');
  my $action=$self->param('action'); 
  $msg="";
  $result="";
  $self->stash(username => $username,
               title => 'Policy Manager',
               url => '/policy');

  # Create directory if not exists
  unless (-d $POLICY_DIR) {
    mkpath $POLICY_DIR;
  }

#---------- Create Policy ---------  
  if (defined $action && $action eq "createpolicy") {
   createpolicy($self);
  }

#---------- Delete Policy ---------  
  if (defined $action && $action eq "deletepolicy") {
   deletepolicy($self);
  }



#---------- Create Policy Menu ---------  
  if (defined $action && $action eq "createpolicymenu") {
	$self->render(template => 'easywaf/createpolicy');
        return;
  }


#------------------- Menu --------------
  %policy=get_policy();
  $self->stash(result => $result,
               msg => $msg,
	       policies => \%policy);

  $self->render(template => 'easywaf/policy');  
}

######### createpolicy #########
sub createpolicy($self) {
 return; 
}


########### deletepolicy #########
sub deletepolicy($self) 
{
 my $policy = $self->param("policy");
 unlink($POLICY_DIR."/".$policy.".conf");
 $result="success";
 $msg="Policy $policy Deleted Succesfully ";
 return;
}






######### get_policy ##########

sub get_policy
{

 my %policy;
 my $dir;
 my @files;
 my $name;
 opendir $dir, $POLICY_DIR;
 @files = readdir $dir;
 closedir $dir;
 foreach (@files) {
   if ($_ =~ ".conf") {
    ($name,undef)=split(/\./, $_);
    $policy{$name}=[$name];
   }
  $name="";
 }
 return (%policy);
}



1;




