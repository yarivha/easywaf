package EasyWAF::Controller::Certs;
use lib '/apps/easy_waf/lib';
use Mojo::Base 'Mojolicious::Controller', -signatures;
use File::Basename 'basename';
use File::Path 'mkpath';
use Common;

my $msg;
my $result;
my %certs;

sub view ($self) {
  if (!($self->session('is_auth'))) {
        $self->redirect_to('login');
  }
  my $username=$self->session('user');
  my $action=$self->param('action'); 
  $msg="";
  $result="";
  $self->stash(username => $username,
               title => 'Certificate Managment',
               url => '/certs');

  # Create directory if not exists
  unless (-d $CERT_DIR) {
    mkpath $CERT_DIR;
  }

#---------- Create Cert ---------  
  if (defined $action && $action eq "createcert") {
   createcert($self);
  }

#---------- Delete Cert ---------  
  if (defined $action && $action eq "deletecert") {
   deletecert($self);
  }





#---------- Create Cert Menu ---------  
  if (defined $action && $action eq "createcertmenu") {
	$self->render(template => 'easywaf/certcreate');
        return;
  }


#------------------- Menu --------------
  %certs=get_certs();
  $self->stash(result => $result,
               msg => $msg,
	       certs => \%certs);

  $self->render(template => 'easywaf/certs');  
}

######### createcert #########
sub createcert($self) {

 my $rc;
 my $name = $self->param("name");
 my @cert = $self->param("cert");
 my @key = $self->param("key");

 if ($name eq "") {
   $result="failed";
   $msg="Certificate name was not declared";
   return;
 }


 open (FILEHANDLE, ">$CERT_DIR/$name.cert");
 print FILEHANDLE @cert;
 close FILEHANDLE;

 open (FILEHANDLE, ">$CERT_DIR/$name.key");
 print FILEHANDLE @key;
 close FILEHANDLE;


 if ((-e "$CERT_DIR/$name.cert") && (-e "$CERT_DIR/$name.key")) {

   $result="success";
   $msg="Certificate $name was saved";
 }
 else {
   $result="failed";
   $msg="Certificate $name failed to save";
 }
 return; 

}


########### deletecert #########
sub deletecert($self) 
{
 my $rc;
 my $cert = $self->param("cert");
 unlink($CERT_DIR."/".$cert.".cert");
 unlink($CERT_DIR."/".$cert.".key");
 $result="success";
 $msg="Certificate $cert Deleted Succesfully ";
 return;
}

1;




