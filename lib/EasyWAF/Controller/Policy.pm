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

#---------- Save Policy ---------  
  if (defined $action && $action eq "savepolicy") {
   savepolicy($self);
  }

#---------- Delete Policy ---------  
  if (defined $action && $action eq "deletepolicy") {
   deletepolicy($self);
  }



#---------- Create Policy Menu ---------  
  if (defined $action && $action eq "createpolicymenu") {
	my %rules=get_rules();  
	$self->stash(rules => \%rules);  
	$self->render(template => 'easywaf/policycreate');
        return;
  }


#--------- settings menu ------------
   if (defined $action && $action eq "settingsmenu") {
     settings_menu($self);
     return;
   }


#------------------- Menu --------------
  %policy=get_policy();
  $self->stash(result => $result,
               msg => $msg,
	       policies => \%policy);

  $self->render(template => 'easywaf/policy');  
}

######### savepolicy #########
sub savepolicy($self) {
 my $update = $self->param("update");
 my %rules=get_rules();
 my $name=$self->param("name");
 my $ruleengine=$self->param("roleengine");
 my $enable_xml=1;
 my $enable_json=1;
 my $rule; 
 my $file="$POLICY_DIR/$name.conf";

 #------ Backup config if it's updated ----- 
 if ($update eq "true") {
   copy("$file","$file.backup");
 }

#------ Write file ------
 open(FH, '>', $file);
 print FH "#--------------- $name ---------------"; 
 print FH "SecRuleEngine $ruleengine";
 print FH "SecRequestBodyAccess On";
 if ($enable_xml) {
  print FH "SecRule REQUEST_HEADERS:Content-Type \"^(?:application(?:/soap\+|/)|text/)xml\" \"id:'200000',phase:1,t:none,t:lowercase,pass,noog,ctl:requestBodyProcessor=XML\"" ;
 }  
 if ($enable_json) {
  print FH "SecRule REQUEST_HEADERS:Content-Type \"^application/json\" \"id:'200001',phase:1,t:none,t:lowercase,pass,nolog,ctl:requestBodyProcessor=JSON\"";
 }
 print FH "SecRequestBodyLimit 13107200";
 print FH "SecRequestBodyNoFilesLimit 131072";
 print FH "SecRequestBodyLimitAction Reject";
 print FH "SecRequestBodyJsonDepthLimit 512";
 print FH "SecArgumentsLimit 1000";

 foreach $rule (keys %rules) {
   if (defined $self->param($rule)) {
    print FH "include $RULES_DIR/$rule.conf";
   }
 }
 close(FH);
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


######## settings_menu ######## 
sub settings_menu($self)
{
     my $policy=$self->param("policy");      
     my %policy=get_policy();
     my %rules=get_rules();

     $self->stash(policy => $policy,
	     	  rules => \%rules,
                  policies => \%policy,
	  	  rules => \%rules);
     $self->render(template => 'easywaf/policysettings');
     return;
}



1;




