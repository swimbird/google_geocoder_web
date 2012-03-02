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


my $debug = 0;
#main
{
  my $query = CGIinit();
}

sub CGIinit{
  my $query = new CGI;
  my $path = $query->param('path');
  my $download_file = basename($path);
  print $query->header(-type=>'application/octet-stream',
                       -Content_Disposition =>  "attachment; filename=$download_file"
  );

  open( my $fh, "<", $path ) or die "Cannot open $path: $!";
  while (my $geoxml = <$fh>) {
    print $geoxml;
  }
  close $fh;
  #print STDERR $path;

  exit;
}

1;
