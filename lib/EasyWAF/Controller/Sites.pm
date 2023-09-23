package EasyWAF::Controller::Sites;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

my $msg;
my $result;
my $action;
my $sites_dir="/etc/nginx/conf.d";

sub view ($self) {

  my %sites;
  $action=$self->param('action'); 
  $self->stash(username => 'admin',
 	       title => 'Site Managment',
               url => '/sites');

#---------- create site menu -----------
  if ($action eq "createsitemenu") {
    $self->render(template => 'easywaf/createsite');	  
    return;
  } 

#------------------- Menu --------------
  $self->stash(result => $result,
               msg => $msg,
	       sites => \%sites);

  $self->render(template => 'easywaf/sites');  
}

sub create_site($self)
{

}


sub get_sites
{

 my %sites;
 $sites{'test1'}=["sdf","sdfsdfsdf","sfdsdfsdf","sfdsdfsfd"];
 return (%sites);

}

1;




