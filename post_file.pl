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
  my $query = CGIinit();
}

sub CGIinit{
  my $query = new CGI;
  print $query->header(-type=>'text/html; charset=utf-8');

  my $fname = basename($query->param('file'));
  my $path = "tmp";
  my $newfile = "$path/$fname";

  my $fh = $query->upload('file');
  copy ($fh, "$newfile");
  undef $query;

  #my $geo = address2GeoRSS->new('tmp/address.txt');
  my $geo = address2GeoRSS->new($newfile);

  my $mes = {status => $geo->{status}, path => $geo->{path}};
  print JSON::XS->new->utf8->encode ($mes);

  exit;
}

1;
