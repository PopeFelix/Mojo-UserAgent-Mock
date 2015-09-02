use strict;
use warnings;
package Mojo::UserAgent::Mock;

# VERSION

# ABSTRACT: A class to provide a mock Mojo user agent, allowing the caller to simulate an HTTP interaction.

# Based on https://metacpan.org/source/JBERGER/Webservice-Shipment-0.03/lib/Webservice/Shipment/MockUserAgent.pm

=head1 NAME 

Mojo::UserAgent::Mock

=head1 SYNOPSIS

=head1 DESCRIPTION

Allows you to mock requests with a Mojo user agent.  Rewrites request URLs to an internal server instance.

=head1 ATTRIBUTES 

=head2 app

The Mojolicious application that will service requests sent via this user agent.  This allows you 
to create a separate app that responds however you like and pass it in.

=head2 mock_blocking

If set, the user agent will mock processing non-blocking requests. Otherwise the standard 
application server URL will be used. It doesn't have much effect unless you pass in a full-fledged
application instance.

=head2 routes

Routes to process. Syntax is the same as in L<Mojolicious::Routes::Route/any>

=head1 EVENTS

=head2 mock_request

An event that contains the original request. Useful for inspecting the original request URL, 
content-type, etc., and making sure they are acting as they ought to.

=head1 ACKNOWLEDGEMENTS

Based heavily on https://metacpan.org/source/JBERGER/Webservice-Shipment-0.03/lib/Webservice/Shipment/MockUserAgent.pm 

=cut

use Mojo::Base 'Mojo::UserAgent';
use Mojolicious;
use Mojo::URL;

has app => sub { Mojolicious->new; };
has mock_blocking => 1;
has routes => sub { {} };

sub new {
    my $self = shift->SUPER::new(@_);

    my $app = $self->app;
    my %routes;
    for my $key (keys %{$self->routes}) {
        if (grep { $key eq $_ } qw/GET POST PUT DELETE OPTIONS PATCH/) {
            my ($path, $code) = %{delete $self->routes->{$key}};
            my $method = lc $key;
            $app->routes->$method($path => $code);
        }
    }

    if (%{$self->routes}) {
        $app->routes->any(%{$self->routes});
    }
    $self->server->app($app);

    # Rewrite request to point at internal "mock" service
    $self->on(
        start => sub {
            my ( $self, $tx ) = @_;
            $self->emit( mock_request => $tx->req );
            my $port = $self->mock_blocking ? $self->server->url->port : $self->server->nb_url->port;
            $tx->req->url->host('')->scheme('')->port($port);
        }
    );

    return $self;
}

1;
