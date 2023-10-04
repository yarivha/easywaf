package EasyWAF::Controller::Certs;
use lib '.';
use Mojo::Base 'Mojolicious::Controller', -signatures;
use File::Basename 'basename';
use File::Path 'mkpath';

my $msg;
my $result;
my $CERT_DIR="/etc/nginx/certs";
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



#---------- Create Cert Menu ---------  
  if (defined $action && $action eq "createcertmenu") {
	$self->render(template => 'easywaf/createcert');
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

######### get_certs ##########

sub get_certs
{

 my %certs;
 my $dir;
 my @files;
 my $name;
 my $subject;
 my $url;
 my $startdate;
 my $enddate;
 opendir $dir, $CERT_DIR;
 @files = readdir $dir;
 closedir $dir;
 foreach (@files) {
   if ($_ =~ ".cert") {
    ($name,undef)=split(/\./, $_);
    $subject=`/usr/bin/sudo /usr/bin/openssl x509 -noout -subject -in $CERT_DIR/$name.cert`;
    $startdate=`/usr/bin/sudo /usr/bin/openssl x509 -noout -startdate -in $CERT_DIR/$name.cert`;
    $enddate=`/usr/bin/sudo /usr/bin/openssl x509 -noout -enddate -in $CERT_DIR/$name.cert`;
    (undef,undef,undef,$url)=split(", ",$subject); 
    $url=substr($url,5);
    $startdate=substr($startdate, 10); 
    $enddate=substr($enddate,9);
    $certs{$name}=[$name,$url,$startdate,$enddate];
   }
  $name="";
  $url="";
  $startdate="";
  $enddate="";
 }
 return (%certs);
}



1;




