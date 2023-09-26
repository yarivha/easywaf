package EasyWAF::Controller::Certs;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

my $msg;
my $result;
my $cert_dir="/etc/nginx/certs";
my %certs;

sub view ($self) {

  my $action=$self->param('action'); 
  $msg="";
  $result="";
  $self->stash(username => 'admin',
 	       title => 'Certificate Managment',
               url => '/certs');


#------------------- Menu --------------
  %certs=get_certs();
  $self->stash(result => $result,
               msg => $msg,
	       certs => \%certs);

  $self->render(template => 'easywaf/certs');  
}


########## get_certs ##########
sub get_certs
{
 my %certs;
 return (%certs);
}

1;




