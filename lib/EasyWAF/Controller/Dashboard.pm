package EasyWAF::Controller::Dashboard;
use lib '/apps/easy_waf/lib';
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Common;

sub view ($self) {
  if (!($self->session('is_auth'))) {
        $self->redirect_to('login');
  }
  my $username=$self->session('user');
  my %certs=get_certs();
  my %policy=get_policy();
  my %sites=get_sites();
  #  waf_stat;
  $self->render(template => 'easywaf/dashboard',
	        username => $username,
  		title => 'DashBoard',
		url => '/',
		sites_number => scalar(keys %sites),
		policy_number => scalar(keys %policy),
		certs_number => scalar(keys %certs));

}

1;




