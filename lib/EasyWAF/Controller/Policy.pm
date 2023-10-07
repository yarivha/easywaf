package EasyWAF::Controller::Policy;
use lib '/apps/easy_waf/lib';
use Mojo::Base 'Mojolicious::Controller', -signatures;
use File::Basename 'basename';
use File::Path 'mkpath';
use Common;

my $msg;
my $result;
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
	my %rules;  
	my $dir;
 	my @files;
 	my $name;
 	opendir $dir, $RULES_DIR;
 	@files = readdir $dir;
 	closedir $dir;
 	foreach (@files) {
   	  if ($_ =~ /\.conf/) {
    	    ($name,undef)=split(/\.conf/, $_);
            $rules{$name}=[$name];
   	  }
  	  $name="";
 	}

	$self->stash(rules => \%rules);  
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
 my $name=$self->param("name");
 my $ruleengine=$self->param("roleengine");
 my @rules=$self->param("rules");
 my $rule; 
 my $file="$POLICY_DIR/$name.conf";

 `echo "#--------------- $name ---------------" | /usr/bin/sudo /usr/bin/tee $file`;
 `echo "SecRuleEngine $ruleengine" | /usr/bin/sudo /usr/bin/tee -a $file`;
 foreach $rule (@rules) {
   `echo "include $RULES_DIR/$rule.conf" | /usr/bin/sudo /usr/bin/tee -a $file`;
 }
 $result="success";
 $msg="Policy $name Created Succesfully ";  	 
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




