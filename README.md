# EasyWAF

EasyWAF is a web application firewall intended to protect web sites from malicious attacks.
It's based on NGINX, GUI is written in perl with Mojolicious framework.

Basic Requirments:
* perl
* perl-Mojolicious
* nginx
* nginx source


WAF:
for WAF detection, you must compile naxis module with nginx source from here:
https://github.com/wargio/naxsi


GeoIP Block:
for geo blocking, you must compile ngx_http_geoip2 module with nginx source from here:
https://github.com/leev/ngx_http_geoip2_module




Tested on OpenSUSE but will probably work on any distribution




