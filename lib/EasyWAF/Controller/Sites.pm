package EasyWAF::Controller::Sites;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub view ($self) {

  $self->render(template => 'easywaf/sites',
	        username => 'admin',
  		title => 'Sites');

}

1;




