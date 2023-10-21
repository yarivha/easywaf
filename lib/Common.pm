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
our @EXPORT    = qw( $SITE_DIR $CERT_DIR $POLICY_DIR $RULES_DIR $LOG_DIR   
		     get_certs get_policy get_sites get_rules waf_stat );


############# Declarations #####################


############# Configuration dirs ###############
our $SITE_DIR="/etc/nginx/conf.d";
our $CERT_DIR="/etc/nginx/certs";
our $POLICY_DIR="/etc/nginx/modsec";
our $RULES_DIR="/usr/share/owasp-modsecurity-crs/rules";
our $LOG_DIR="/var/log/nginx";
our $MODSEC_LOG="/var/log/modsec_audit.log";
our $EVENTS_FILE="/apps/easy_waf/public/js/events.js";

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



######### get_policy ##########

sub get_policy
{

my %policy;
 my $dir;
 my @files;
 my $name;
 opendir $dir, $POLICY_DIR;
 @files = readdir $dir;
 closedir $dir;
 foreach (@files) {
   if ($_ =~ ".conf") {
    ($name,undef)=split(/\./, $_);
    $policy{$name}=[$name];
   }
  $name="";
 }
 return (%policy);
}


########## get_sites ##########
sub get_sites
{
 my %sites;
 my $dir;
 my $file;
 my $line;
 my @files;
 my @conf;
 my $name;
 my $server;
 my $port;
 my $url;
 my $policy;
 opendir $dir, $SITE_DIR;
 @files = readdir $dir;
 closedir $dir;
 foreach (@files) {
  if($_ =~ ".conf") {
    ($name,undef)=split(".conf",$_);
    $policy="Off";
    open $file, $SITE_DIR."/".$_;
    while ($line = <$file>) {
     if ($line =~ /server_name/i) {
        (undef,$server)=split(" ",$line);
        chop($server);
     }
     if ($line =~ /proxy_pass/i) {
        (undef,$url)=split(" ",$line);
        chop($url);
     }
     if ($line =~ /modsecurity on/i) {
	$policy="On";
     }
    }
    close $file;
    $sites{$name}=[$name,$server,$url,$policy];
  }
  $name="";
 }
 return (%sites);
}


######## get_rules #########
sub get_rules {

 my %rules;
 my $dir;
 my @files;
 my $name;
 opendir $dir, $RULES_DIR;
 @files = readdir $dir;
 closedir $dir;
 foreach (@files) {
   if (($_ =~ /\.conf/) and ($_ ne "REQUEST-901-INITIALIZATION.conf") and ($_ ne "RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf"))  {
     $name=substr $_,0,-5;
     $rules{$name}=[$name];
   }
  $name="";
 }
 return %rules;
}

######### waf_stat ##########
sub waf_stat {

 my %time_stat;
 my %attacks_stat;
 my %ip_stat;

 $attacks_stat{'Attack1'}=3;
 $attacks_stat{'Attack2'}=5;
 $ip_stat{'IP1'}=8;
 $time_stat{'00:00'}=10;
 $time_stat{'02:00'}=5;
 $time_stat{'04:00'}=1;
 $time_stat{'06:00'}=2;
 $time_stat{'08:00'}=1;
 $time_stat{'10:00'}=0;
 $time_stat{'12:00'}=0;
 $time_stat{'14:00'}=0;
 $time_stat{'16:00'}=10;


 
 open(FH, '>', $EVENTS_FILE);
 print FH "\$(function() {\n";
 print FH " Morris.Donut({\n";
 print FH "  element: 'morris-donut-chart',\n";
 print FH "data: [\n";
 foreach (keys %attacks_stat) {
   print FH "{\n" ;
   print FH "label: \"$_\",\n";
   print FH "value: $attacks_stat{$_}\n";
   print FH "},\n";
 } 
 print FH "{}],\n";
 print FH "resize: true\n";
 print FH "});\n";
 print FH "\n";
 print FH "Morris.Donut({\n";
 print FH " element: 'morris-donut2-chart',\n";
 print FH "data: [\n";
 foreach (keys %ip_stat) {
   print FH "{\n";
   print FH "label: \"$_\",\n";
   print FH "value: $ip_stat{$_}\n";
   print FH "},\n";
 }
 print FH "{}],\n";
 print FH "resize: true\n";
 print FH "});\n";
 
 print FH "\n";
 print FH "Morris.Bar({\n";
 print FH "element: 'morris-bar-chart',\n";
 print FH "data: [";
 foreach (keys %time_stat) {
   print FH "{\n";
   print FH "y: $_,\n";
   print FH "a: $time_stat{$_},\n";
   print FH "},";
 }
 print FH "{}],\n";
 print FH "xkey: 'y'\n";
 print FH "ykeys: ['a'],\n";
 print FH "labels: ['Events'],\n";
 print FH "hideHover: 'auto',\n";
 print FH "resize: true\n";
 print FH "});\n";
 print FH "});\n";
 close FH;

 return;
}


1;

