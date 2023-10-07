package EasyWAF::Controller::Login;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Digest::SHA qw/sha512_base64/;

my $msg;
my $result;

sub view ($self) {
   
    if ($self->session('is_auth')) {
        $self->redirect_to('/');
    }

    my $action = $self->param('action');
    $msg="";
    $result="";

#-------- Login ---------
    if (defined $action && $action eq "login") {
	login($self);
    }

#-------- Logout --------     
    if (defined $action && $action eq "logout") {
	logout($self);
    }

#-------- Menu ----------    
    $self->stash(result => $result,
                 msg => $msg,
		 username => '',
                 title => 'EasyWAF',
                 url => '/login');
    $self->render(template => 'easywaf/login');
    
}


sub login ($self) {
  my $user = $self->param('user') || '';
  my $pass = $self->param('pass') || '';
  my $shadow;
  my $pass1;
  my $pass2;
  my $salt;
  my $hash;
  $shadow = `/usr/bin/sudo /usr/bin/cat /etc/shadow | /usr/bin/grep $user`;
    (undef,$pass1,,,,,,,)=split(":",$shadow);
    (undef,undef,$salt,$pass2)=split(/\$/,$pass1); 
    $hash=crypt($pass, '$6$' . $salt);
    if( ($user ne "root") && ($pass1 eq $hash) ) {
     $result="success";
     $self->session(is_auth => 1);
     $self->session(user => $user);
     $self->redirect_to('/');
    }
    else {
     $result="failed";
     $msg="Bad Username or Password";
    }
     return;
}

sub logout ($self) {
  $self->session(expires => 1);
  $self->session(is_auth => 0);
  $self->redirect_to('login');
}

1;






