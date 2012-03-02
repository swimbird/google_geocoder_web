#!/usr/bin/perl

use strict;
use warnings;

use URI::Escape qw/ uri_escape /;
use HTTP::Request;
use JSON::XS;
use Data::Dumper;
use CGI;
use File::Copy;
use File::Basename;
use address2GeoRSS;

my $debug = 0;
#main
{
  my $obj = address2GeoRSS->new('tmp/address.txt');

  print Dumper $obj;
}



1;
