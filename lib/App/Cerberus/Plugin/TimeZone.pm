package App::Cerberus::Plugin::TimeZone;

use strict;
use warnings;
use Time::OlsonTZ::Data qw(olson_tzfile);
use DateTime();
use DateTime::TimeZone::Tzfile();
use Carp;
use parent 'App::Cerberus::Plugin';

#===================================
sub request {
#===================================
    my ( $self, $req, $response ) = @_;

    my $tz_name = $response->{tz}{name} or return;

    my $now = DateTime->now( time_zone => 'UTC' );
    my $tz_file = eval { olson_tzfile($tz_name) };
    my $tz = DateTime::TimeZone::Tzfile->new($tz_file);

    $response->{tz}{gmt_offset} = $tz->offset_for_datetime($now);
    $response->{tz}{dst}        = $tz->is_dst_for_datetime($now);
    $response->{tz}{short_name} = $tz->short_name_for_datetime($now);

}

1;

# ABSTRACT: Add time-zone information to App::Cerberus

=head1 DESCRIPTION

This plugin uses L<Time::OlsonTZ::Data> to add time-zone information to
Cerberus. For instance:

    "tz": {
        "short_name": "EDT",
        "name": "America/New_York",
        "dst": "1",
        "gmt_offset": "-14400"
    }

The time-zone is deduced from the IP address, via L<Geo::IP>.

=head1 REQUEST PARAMS

Time zone information is returned when an IPv4 address is passed in:

    curl http://host:port/?ip=80.1.2.3

=head1 CONFIGURATION

The L<GeoIP plugin |App::Cerberus::Plugin::GeoIP> must be loaded before this
plugin. This plugin takes no configuration options:

    plugins:
      - GeoIP:    /opt/geoip/GeoLiteCity.dat
      - TimeZone

