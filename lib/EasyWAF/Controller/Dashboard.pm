package EasyWAF::Controller::Dashboard;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub view ($self) {

  $self->render(template => 'easywaf/dashboard',
	        username => 'admin',
  		title => 'DashBoard');

}

1;




