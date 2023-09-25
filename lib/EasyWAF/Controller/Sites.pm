package EasyWAF::Controller::Sites;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

my $msg;
my $result;
my $sites_dir="/etc/nginx/conf.d";

sub view ($self) {

  my %sites;
  my $action=$self->param('action'); 
  $self->stash(username => 'admin',
 	       title => 'Site Managment',
               url => '/sites');

#---------- create site menu -----------
  if ($action eq "createsitemenu") {
    $self->render(template => 'easywaf/createsite');	  
    return;
  } 

#----------- Create Site --------------  
  if ($action eq "createsite") {
    create_site($self);
  }
#------------------- Menu --------------
  $self->stash(result => $result,
               msg => $msg,
	       sites => \%sites);

  $self->render(template => 'easywaf/sites');  
}

sub create_site($self)
{
 
 my $rc;
 my $name = $self->param("name");
 my $port = $self->param("port");
 my $url = $self->param("url");

 my $file=$sites_dir."/".$name;
 my $log="/var/log/nginx/".$name.".log";

 `/bin/echo "#### $name ####" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "server {" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   listen $port;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   server_name $url;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   access_log $log;" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "   location / {" | /usr/bin/sudo /usr/bin/tee -a $file`;
 `/bin/echo "     proxy_pass $url" | /usr/bin/sudo /usr/bin/tee -a $file`;
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


sub get_sites
{

 my %sites;
 $sites{'test1'}=["sdf","sdfsdfsdf","sfdsdfsdf","sfdsdfsfd"];
 return (%sites);

}

1;




