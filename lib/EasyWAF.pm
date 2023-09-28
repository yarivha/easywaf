package EasyWAF;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->any('/login')->to('login#view');
  $r->get('/logout')->to('login#logout');
  $r->get('/sites')->to('sites#view');
  $r->get('/certs')->to('certs#view');
}

1;
