package EasyWAF::Controller::Geoip;
use lib '/apps/easy_waf/lib';
use Mojo::Base 'Mojolicious::Controller', -signatures;
use File::Copy;
use Common;

my $msg;
my $result;

sub view ($self) {

  if (!($self->session('is_auth'))) {
        $self->redirect_to('login');
  }
  my $username=$self->session('user');
  my %sites;
  my $action=$self->param('action'); 
  $msg="";
  $result="";
  $self->stash(username => $username,
 	       title => 'GeoLocation Rules',
               url => '/geoip');

#------------------- Menu --------------
    $self->stash(result => $result,
                 msg => $msg);
    $self->render(template => 'easywaf/geoip');  
}


1;
