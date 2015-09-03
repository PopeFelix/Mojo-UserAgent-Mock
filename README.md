# NAME

Mojo::UserAgent::Mock - A class to provide a mock Mojo user agent

# VERSION

version 0.001

# ATTRIBUTES

## app

The [Mojolicious](https://metacpan.org/pod/Mojolicious) application that will service requests sent via this user agent.  This gives 
you the complete Mojolicious feature set, rather than the reduced set provided by ["routes"](#routes)

## routes

Routes to process. In general, path specification syntax is the same as in 
["any" in Mojo::Routes::Route](https://metacpan.org/pod/Mojo::Routes::Route#any). A quick way to specify a path / action is:

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
Placeholders (e.g. ":id") are handled as in [Mojolicious::Guides::Routing](https://metacpan.org/pod/Mojolicious::Guides::Routing)

The following special keys, corresponding to HTTP verbs, will allow you to specify routes that only
match requests with that verb.

- GET
- POST
- PUT
- PATCH
- OPTIONS
- DELETE

# SYNOPSIS
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

# EVENTS

## original\_request 

An event that contains the original request. Useful for inspecting the original request URL, 
content-type, etc., and making sure they are acting as they ought to.

# ACKNOWLEDGEMENTS

Based heavily on Joel Berger's MockUserAgent in [Webservice::Shipment](https://metacpan.org/pod/Webservice::Shipment)

Everyone in #mojo on irc.perl.org for helping me get my thinking straight on this.

# AUTHOR

Kit Peters &lt;kit.peters@broadbean.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Broadbean Technology.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
