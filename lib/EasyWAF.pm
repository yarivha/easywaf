package EasyWAF;
use lib '/apps/easy_waf/lib';
use Mojo::Base 'Mojolicious', -signatures;
#use Mojolicious::Plugin::Cron;
use Common;

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');
  
  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('dashboard#view');
  $r->any('/login')->to('login#view');
  $r->get('/logout')->to('login#logout');
  $r->get('/sites')->to('sites#view');
  $r->get('/certs')->to('certs#view');
  $r->get('/policy')->to('policy#view');
  $r->get('/geoip')->to('geoip#view');
  $r->get('/firmware')->to('firmware#view');
}

1;
