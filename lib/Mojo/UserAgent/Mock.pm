use strict;
use warnings;
package Mojo::UserAgent::Mock;

# VERSION

# ABSTRACT: A class to provide a mock Mojo user agent


=head1 SYNOPSIS
    use Mojo::UserAgent::Mock;

    # Specify different routes for different HTTP verbs
    my $ua = Mojo::UserAgent::Mock->new(
        routes => {
            GET => {
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Get thing $id} );
                },
            },
            POST => {
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Post thing $id} );
                },
            },
            PUT => {
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Put thing $id} );
                },
            },
            PATCH => {
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Patch thing $id} );
                },
            },
            OPTIONS => {
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Options thing $id} );
                },
            },
            DELETE => {
                '/thing/:id' => sub {
                    my $c  = shift;
                    my $id = $c->stash('id');
                    $c->render( text => qq{Delete thing $id} );
                },
            },
        }
    );

    # Specify routes for all HTTP verbs
    my $ua = Mojo::UserAgent::Mock->new(
        routes => {
            '/thing/:id' => sub {
                my $c  = shift;
                my $id = $c->stash('id');
                $c->render( text => qq{Thing $id} );
            }
        }
    );

    # You can also pass in a complete Mojolicious app
    my $app = Mojolicious->new();
    $app->routes->any(
        '/thing/:id' => sub { 
            my $c = shift;
            my $id = $c->stash('id');
            my $whatsis = $c->param('whatsis');
            $c->respond_to(
                json => { json => { id => $id, format => 'json', whatsis => $whatsis } },
                xml  => { text => qq{<root><id>$id</id><format>xml</format><whatsis>$whatsis</whatsis></root>} },
                any  => { data => '', status => 204 },
            );
        },
    );

=attr app

The L<Mojolicious> application that will service requests sent via this user agent.  This gives 
you the complete Mojolicious feature set, rather than the reduced set provided by L</routes>

=attr routes

Routes to process. In general, path specification syntax is the same as in 
L<Mojo::Routes::Route/any>. A quick way to specify a path / action is:

    Mojo::UserAgent::Mock->new(
        routes => [
            '/path/to/a/thing/:id' => sub {
                my $c  = shift;
                my $id = $c->stash('id');
                $c->render( text => qq{Thing $id} );
            },
        ],
    );

This creates a route such that any request to /path/to/a/thing/FOO returns "Thing FOO". 
Placeholders (e.g. ":id") are handled as in L<Mojolicious::Guides::Routing>

The following special keys, corresponding to HTTP verbs, will allow you to specify routes that only
match requests with that verb.

=for :list
* GET
* POST
* PUT
* PATCH
* OPTIONS
* DELETE

=head1 EVENTS

=head2 original_request 

An event that contains the original request. Useful for inspecting the original request URL, 
content-type, etc., and making sure they are acting as they ought to.

=head1 ACKNOWLEDGEMENTS

Based heavily on Joel Berger's MockUserAgent in L<Webservice::Shipment>

Everyone in #mojo on irc.perl.org for helping me get my thinking straight on this.

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
            $self->emit( original_request => $tx->req );
            my $port = $self->mock_blocking ? $self->server->url->port : $self->server->nb_url->port;
            $tx->req->url->host('')->scheme('')->port($port);
        }
    );

    return $self;
}

1;
