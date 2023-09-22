package EasyWAF::Controller::Sites;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub view ($self) {

  my $result="";
  my $msg=""; 
  my %sites;
  my $sites_dir="/etc/nginx/conf.d";
  
  $self->render(template => 'easywaf/sites',
	        username => 'admin',
  		title => 'Site Managment',
		result => $result,
		msg => $msg,
		sites => \%sites);

}

sub get_sites
{

 my %sites;
 $sites{'test1'}=["sdf","sdfsdfsdf","sfdsdfsdf","sfdsdfsfd"];
 return (%sites);

}

1;




