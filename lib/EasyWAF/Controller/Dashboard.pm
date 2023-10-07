package EasyWAF::Controller::Dashboard;
use lib '/apps/easy_waf/lib';
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Common;

sub view ($self) {
  if (!($self->session('is_auth'))) {
        $self->redirect_to('login');
  }
  my $username=$self->session('user');
  $self->render(template => 'easywaf/dashboard',
	        username => $username,
  		title => 'DashBoard',
		url => '/');

}

1;




