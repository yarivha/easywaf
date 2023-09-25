package EasyWAF::Controller::Sites;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

my $msg;
my $result;
my $sites_dir="/etc/nginx/conf.d";

sub view ($self) {

  my %sites;
  my $action=$self->param('action'); 
  $msg="";
  $result="";
  $self->stash(username => 'admin',
 	       title => 'Site Managment',
               url => '/sites');

#----------- Create Site --------------  
  if ($action eq "createsite") {
    create_site($self);
  }

#---------- Delete Site ---------------
  if ($action eq "deletesite") {
    delete_site($self);
  }


#---------- create site menu -----------
  if ($action eq "createsitemenu") {
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

sub create_site($self)
{
 
 my $rc;
 my $name = $self->param("name");
 my $server = $self->param("server");
 my $target = $self->param("target");
 my $port = $self->param("port");

 my $file=$sites_dir."/".$name.".conf";
 my $log="/var/log/nginx/".$name.".log";

 `/bin/echo "#### $name ####" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "server {" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   listen $port;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   server_name $server;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   access_log $log;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   location / {" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "     proxy_pass $target;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   }" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "}" | /usr/bin/sudo /usr/bin/tee -a $file`;

 $rc = system("/usr/bin/sudo /usr/bin/systemctl restart nginx > /dev/null"); 
 if ($rc) {
   $result="failed";
   $msg="Site $name Failed to Create";
 }
 else {
   $result="success";
   $msg="Site $name Created Succesfully ";
 }
 return;
}


sub delete_site($self) 
{
 my $rc;
 my $site = $self->param("site");
 unlink($sites_dir."/".$site);
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
 opendir $dir, $sites_dir;
 @files = readdir $dir;
 closedir $dir;
 foreach (@files) {
  if(($_ ne ".") && ($_ ne "..")) {
    $name=$_;
    open $file, $sites_dir."/".$_;
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




