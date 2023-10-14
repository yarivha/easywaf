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
	my %rules=get_rules();  
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
 my %rules=get_rules();
 my $name=$self->param("name");
 my $ruleengine=$self->param("roleengine");
 my $enable_xml=1;
 my $enable_json=1;
 my $rule; 
 my $file="$POLICY_DIR/$name.conf";

 `echo "#--------------- $name ---------------" | /usr/bin/sudo /usr/bin/tee $file`;
 `echo "SecRuleEngine $ruleengine" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `echo "SecRequestBodyAccess On" | /usr/bin/sudo /usr/bin/tee -a $file`;
 if ($enable_xml) {
 `echo 'SecRule REQUEST_HEADERS:Content-Type "^(?:application(?:/soap\+|/)|text/)xml" "id:'200000',phase:1,t:none,t:lowercase,pass,noog,ctl:requestBodyProcessor=XML"'  | /usr/bin/sudo /usr/bin/tee -a $file`;
 }  
 if ($enable_json) {
  `echo 'SecRule REQUEST_HEADERS:Content-Type "^application/json" "id:'200001',phase:1,t:none,t:lowercase,pass,nolog,ctl:requestBodyProcessor=JSON"' | /usr/bin/sudo /usr/bin/tee -a $file`;
 }
 `echo 'SecRequestBodyLimit 13107200' | /usr/bin/sudo /usr/bin/tee -a $file`;
 `echo 'SecRequestBodyNoFilesLimit 131072' | /usr/bin/sudo /usr/bin/tee -a $file`;
 `echo 'SecRequestBodyLimitAction Reject' | /usr/bin/sudo /usr/bin/tee -a $file`;
 `echo 'SecRequestBodyJsonDepthLimit 512' | /usr/bin/sudo /usr/bin/tee -a $file`;
 `echo 'SecArgumentsLimit 1000' | /usr/bin/sudo /usr/bin/tee -a $file`;

 foreach $rule (keys %rules) {
   if (defined $self->param($rule)) {
   `echo "include $RULES_DIR/$rule.conf" | /usr/bin/sudo /usr/bin/tee -a $file`;
   }
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


1;




