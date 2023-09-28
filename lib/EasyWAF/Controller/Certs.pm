package EasyWAF::Controller::Certs;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

my $msg;
my $result;
my $cert_dir="/etc/nginx/certs";
my %certs;

sub view ($self) {
  if (!($self->session('is_auth'))) {
        $self->redirect_to('login');
  }
  my $username=$self->session('user');
  my $action=$self->param('action'); 
  $msg="";
  $result="";
  $self->stash(username => $username,
               title => 'Certificate Managment',
               url => '/certs');

#---------- Create Cert Menu ---------  
  if ($action eq "createcertmenu") {
	$self->render(template => 'easywaf/createcert');
        return;
  }


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




