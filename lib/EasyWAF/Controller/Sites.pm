package EasyWAF::Controller::Sites;
use lib '/apps/easy_waf/lib';
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Common;

my $msg;
my $result;

sub view ($self) {

  if (!($self->session('is_auth'))) {
        $self->redirect_to('login');
  }
  my $username=$self->session('user');
  my %sites;
  my $action=$self->param('action'); 
  $msg="";
  $result="";
  $self->stash(username => $username,
 	       title => 'Site Managment',
               url => '/sites');

#----------- Create Site --------------  
    if (defined $action && $action eq "savesite") {
     save_site($self);
    } 

#---------- Delete Site ---------------
    if (defined $action && $action eq "deletesite") {
     delete_site($self);
    }


#---------- create site menu -----------
    if (defined $action && $action eq "createsitemenu") {
     my %policy=get_policy();
     $self->stash(policies => \%policy);
     $self->render(template => 'easywaf/createsite');	  
     return;
    } 

#--------- settings menu ------------
   if (defined $action && $action eq "settingsmenu") {
     settings_menu($self);
     return;
   }


#------------------- Menu --------------
    %sites=get_sites();
    $self->stash(result => $result,
               msg => $msg,
	       sites => \%sites);

    $self->render(template => 'easywaf/sites');  
}


######## save_site #########
sub save_site($self)
{
 
 my $rc;
 my $name = $self->param("name");
 my $server = $self->param("server");
 my $target = $self->param("target");
 my $port = $self->param("port");
 my $protection1 = $self->param("protection1");
 my $protection2 = $self->param("protection2");
 my $protection3 = $self->param("protection3");
 my $protection4 = $self->param("protection4");
 my $policy = $self->param("policy");

 my $file=$SITE_DIR."/".$name.".conf";
 my $log=$LOG_DIR."/".$name.".log";
 
 if (-e $file) {
  $result="failed";
  $msg="Site name already exist";	 
  return;
 }

 `/bin/echo "#### $name ####" | /usr/bin/sudo /usr/bin/tee $file`;
 `/bin/echo "server {" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   listen $port;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   server_name $server;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   access_log $log;" | /usr/bin/sudo /usr/bin/tee -a $file`;

 if ($policy ne "None") {
 `/bin/echo "   modsecurity on;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   modsecurity_rules_file $POLICY_DIR/$policy.conf;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 }

 if ($protection1) {
  `/bin/echo '   add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;' | /usr/bin/sudo /usr/bin/tee -a $file`;
 }
 if ($protection2) {
  `/bin/echo '   add_header X-Frame-Options DENY;' | /usr/bin/sudo /usr/bin/tee -a $file`;
 }
 if ($protection3) {
  `/bin/echo '   add_header X-Content-Type-Options nosniff;' | /usr/bin/sudo /usr/bin/tee -a $file`;
 }
 if ($protection4) {
  `/bin/echo '   add_header X-XSS-Protection "1; mode=block";' | /usr/bin/sudo /usr/bin/tee -a $file`;
 }
 `/bin/echo "   location / {" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "     proxy_pass $target;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   }" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "}" | /usr/bin/sudo /usr/bin/tee -a $file`;

 $rc = system("/usr/bin/sudo /usr/bin/systemctl restart nginx > /dev/null"); 
 if ($rc) {
   $result="failed";
   $msg="Site $name Failed to Create";
   unlink($SITE_DIR."/".$name.".conf");
 }
 else {
   $result="success";
   $msg="Site $name Created Succesfully $protection1 $protection2 $protection3 $protection4 ";
 }
 return;
}

########### delete_site #########
sub delete_site($self) 
{
 my $rc;
 my $site = $self->param("site");
 unlink($SITE_DIR."/".$site.".conf");
 unlink($LOG_DIR."/".$site.".log");
 $rc = system("/usr/bin/sudo /usr/bin/systemctl restart nginx > /dev/null");
 if ($rc) {
   $result="failed";
   $msg="Site $site Failed to Delete";
 }
 else {
   $result="success";
   $msg="Site $site Deleted Succesfully ";
 }
 return;
}


######## settings_menu ######## 
sub settings_menu($self)
{
     my $line;
     my $port;
     my $url;
     my $server;
     my $target;
     my $protection1="";
     my $protection2="";
     my $protection3="";
     my $protection4="";	
     my $site=$self->param("site");      
     my %policy=get_policy();
     open my $fh, '<', "$SITE_DIR/$site.conf";
     while(<$fh>) {
      $line=$_;
      if ($line =~ /listen/i) {
     	(undef,$port)=split(" ",$line);
        chop($port);
      }
      if ($line =~ /server_name/i) {
	(undef,$server)=split(" ",$line);
	chop($server);
      }
      if ($line =~ /proxy_pass/i) {
        (undef,$target)=split(" ",$line);
        chop($target);
      }
      if ($line =~ /add_header Strict-Transport-Security/i) {
	$protection1="checked";
      }
      if ($line =~ /add_header X-Frame-Options/i) {
        $protection2="checked";
      }
      if ($line =~ /add_header X-Content-Type-Options/i) {
        $protection3="checked";
      }
      if ($line =~ /add_header X-XSS-Protection/i) {
        $protection4="checked";
      }
     }
     $self->stash(site => $site,
                  policies => \%policy,
		  server => $server,
		  target => $target,
	  	  port => $port,
	  	  protection1 => $protection1,
	          protection2 => $protection2,
	  	  protection3 => $protection3,
	          protection4 => $protection4);
     $self->render(template => 'easywaf/settingssite');
     return;
}

1;




