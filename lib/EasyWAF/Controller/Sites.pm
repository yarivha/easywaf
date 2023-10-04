package EasyWAF::Controller::Sites;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

my $msg;
my $result;
my $SITE_DIR="/etc/nginx/conf.d";

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
    if (defined $action && $action eq "createsite") {
     create_site($self);
    } 

#---------- Delete Site ---------------
    if (defined $action && $action eq "deletesite") {
     delete_site($self);
    }


#---------- create site menu -----------
    if (defined $action && $action eq "createsitemenu") {
     $self->render(template => 'easywaf/createsite');	  
     return;
    } 

#------------------- Menu --------------
    %sites=get_sites();
    $self->stash(result => $result,
               msg => $msg,
	       sites => \%sites);

    $self->render(template => 'easywaf/sites');  
}


######## create_site #########
sub create_site($self)
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

 my $file=$SITE_DIR."/".$name.".conf";
 my $log="/var/log/nginx/".$name.".log";
 print $protection1;
 `/bin/echo "#### $name ####" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "server {" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   listen $port;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   server_name $server;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   access_log $log;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 if ($protection1) {
  `/bin/echo "   add_header Strict-Transport-Security \"max-age=63072000; includeSubDomains; preload\";" | /usr/bin/sudo /usr/bin/tee -a $file`;
 }
 if ($protection2) {
  `/bin/echo "   add_header X-Frame-Options DENY;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 }
 if ($protection3) {
  `/bin/echo "   add_header X-Content-Type-Options nosniff;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 }
 if ($protection4) {
  `/bin/echo "   add_header X-XSS-Protection \"1; mode=block\";" | /usr/bin/sudo /usr/bin/tee -a $file`;
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
 unlink($SITE_DIR."/".$site);
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

########## get_sites ##########
sub get_sites
{
 my %sites;
 my $dir;
 my $file;
 my $line;
 my @files;
 my @conf;
 my $name;
 my $server;
 my $port;
 my $url;
 opendir $dir, $SITE_DIR;
 @files = readdir $dir;
 closedir $dir;
 foreach (@files) {
  if(($_ ne ".") && ($_ ne "..")) {
    $name=$_;
    open $file, $SITE_DIR."/".$_;
    while ($line = <$file>) {
     if ($line =~ /server_name/i) {
	(undef,$server)=split(" ",$line);
	chop($server);
     }
     if ($line =~ /proxy_pass/i) {
	(undef,$url)=split(" ",$line);
	chop($url);
     }
    }   
    close $file;
    $sites{$_}=[$_,$server,$url,"sfdsdfsdf"];
  }
  $name="";
 }
 return (%sites);
}

1;




