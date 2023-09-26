package EasyWAF::Controller::Login;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;

my $msg;
my $result;

sub view ($self) {

  $self->render(template => 'easywaf/login',
                username => '',
		title => 'EasyNAS',
		url => '/login');  
}


1;




