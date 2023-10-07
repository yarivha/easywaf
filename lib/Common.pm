#! /usr/bin/perl -w 
#
# Common.pm
# 
# EasyWAF is free software: You can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# This file is part of EasyWAF (c) created by Yariv Hakim 2023
#
# Homepage    : https://www.easywaf.org
# Source      : https://github.com/yarivha/easywaf
#
#########################################################################

package Common;

use strict;
use warnings;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw();
our @EXPORT    = qw( $SITE_DIR $CERT_DIR $POLICY_DIR $RULES_DIR   
		     get_certs);


############# Declarations #####################


############# Configuration dirs ###############
our $SITE_DIR="/etc/nginx/conf.d";
our $CERT_DIR="/etc/nginx/certs";
our $POLICY_DIR="/etc/nginx/modsec";
our $RULES_DIR="/usr/share/owasp-modsecurity-crs/rules";


################# Common Subs ##################

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

