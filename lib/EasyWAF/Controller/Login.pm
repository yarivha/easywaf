package EasyWAF::Controller::Login;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

my $msg;
my $result;

sub view ($self) {
   
    my $action = $self->param('action');
    
    if ($self->session('user')) {
        $self->redirect_to('/');
    }

#-------- Login ---------
    if ($action eq "login") {
	login($self);
    }

#-------- Logout --------     
    if ($action eq "logout") {
	logout($self);
    }

    $self->render(template => 'easywaf/login',
	          username => '',
  		  title => 'EasyWAF',
		  url => '/login');
    
}


sub login ($self) {
  my $user = $self->param('user') || '';
  my $pass = $self->param('pass') || '';
  
  $self->session(is_auth => 1);
  $self->session(user => $user);
  $self->redirect_to('/');
  return; 
}

sub logout ($self) {
  $self->session(expires => 1);
  $self->session(is_auth => 0);
  $self->redirect_to('login');
}

1;






