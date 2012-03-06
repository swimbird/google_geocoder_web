package address2GeoRSS;

use strict;
use warnings;
use URI::Escape qw/ uri_escape /;
use HTTP::Request;
use LWP::UserAgent;
use JSON::XS;
use Data::Dumper;
use Getopt::Long;
use Encode 'encode_utf8';
use File::Basename;

use constant {
  GOOGLE_GEOCODING_API => 'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&language=ja&address='
};

my $debug = 0;

my $GeoXMLHeader = <<'EOS';
<?xml version="1.0" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
    <channel>
EOS

my $GeoXMLFooter = <<'EOS';
    </channel>
</rss>
EOS

sub request {
    my ($method, $url, $data_arr) = @_;
    my $req = HTTP::Request->new(
        $method => $url
    );

    if ($method eq 'POST') {
        my $data_str = join '&', map { uri_escape($_) . '=' . uri_escape($data_arr->{$_}) } keys %$data_arr;
        $req->content_type('application/x-www-form-urlencoded');
        $req->content($data_str);
    }

    my $ua = LWP::UserAgent->new();
    my $res = $ua->request($req);

    return $res;
}

sub GeoCall {
  my $address = shift;
  my $url = GOOGLE_GEOCODING_API . uri_escape($address);
  my $res = request('GET', $url);

  return decode_json(encode_utf8($res->content));
}

sub new{
  my $pkg = shift;
  my $file = shift;
  my $geo = {
    status => undef,
    path => undef
  };

  open( my $fh, "<", $file ) or die "Cannot open $file: $!";

  my $GeoXMLItems;
  while (my $address = <$fh>) {
    chomp $address;
    $address =~ s///;
    my @addressList = split /,/, $address;
    my $json_res = GeoCall($addressList[1]);

    if($debug){
      print STDERR $addressList[0], "\n";
      print STDERR $addressList[1], "\n";
      print STDERR $addressList[2], "\n";
      print STDERR $json_res->{status}, "\n";
      print STDERR $json_res->{results}[0]->{formatted_address}, "\n";
      print STDERR $json_res->{results}[0]->{geometry}->{location}->{lat}, "\n";
      print STDERR $json_res->{results}[0]->{geometry}->{location}->{lng}, "\n";
      print STDERR "\n";
    }

    my $GeoXMLItem;
    if($json_res->{status} eq "OK"){
      $GeoXMLItem = << "EOS";
        <item>
            <title>
              $addressList[0]
            </title>
            <description>
              <![CDATA[$addressList[2]]]>
            </description>
            <geo:lat>
                $json_res->{results}[0]->{geometry}->{location}->{lat}
            </geo:lat>
            <geo:long>
                $json_res->{results}[0]->{geometry}->{location}->{lng}
            </geo:long>
        </item>
EOS
    }
    $GeoXMLItems .= $GeoXMLItem;

    select undef, undef, undef, 0.5;
  }

  close $fh;

  if($debug){
    print STDERR $GeoXMLHeader . $GeoXMLItems . $GeoXMLFooter;
  }

  my $GeoXML = $GeoXMLHeader . $GeoXMLItems . $GeoXMLFooter;
  my @extlist = ('.txt', '.csv');
  my $out_file = basename($file, @extlist)."_GeoRSS.xml";
  $out_file = './tmp/'.$out_file;
  open( my $out_fh, ">", $out_file ) or die "Cannot open $out_file for write: $!";
  print $out_fh $GeoXML;
  close $out_fh;

  $geo->{status} = 'OK';
  $geo->{path} = $out_file;

  bless $geo, $pkg;

  return $geo;
}
1;
