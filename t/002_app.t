use strict;
use warnings;

use String::Random qw/random_string/;
use Test::Most;
use Test::Mojo;
use Test::XPath;
use Mojo::UserAgent::Mock;
use Mojolicious;
use XML::LibXML;

subtest 'route on HTTP verb' => sub {
    my $app = Mojolicious->new;
    $app->routes->get(
        '/thing/:id' => sub {
            my $c  = shift;
            my $id = $c->stash('id');
            my $whatsis = $c->param('whatsis');
            $c->render( json => { id => $id, whatsis => $whatsis, method => 'get' } );
        }
    );
    $app->routes->post(
        '/thing/:id' => sub {
            my $c       = shift;
            my $id      = $c->stash('id');
            my $whatsis = $c->param('whatsis');
            $c->render( json => { 'id' => $id, 'whatsis' => $whatsis, 'method' => 'post' } );
        },
    );
    $app->routes->put(
        '/thing/:id' => sub {
            my $c       = shift;
            my $id      = $c->stash('id');
            my $whatsis = $c->param('whatsis');
            $c->render( json => { 'id' => $id, 'whatsis' => $whatsis, 'method' => 'put' } );
        },
    );
    $app->routes->patch(
        '/thing/:id' => sub {
            my $c       = shift;
            my $id      = $c->stash('id');
            my $whatsis = $c->param('whatsis');
            $c->render( json => { 'id' => $id, 'whatsis' => $whatsis, 'method' => 'patch' } );
        },
    );
    $app->routes->options(
        '/thing/:id' => sub {
            my $c       = shift;
            my $id      = $c->stash('id');
            my $whatsis = $c->param('whatsis');
            $c->render( json => { 'id' => $id, 'whatsis' => $whatsis, 'method' => 'options' } );
        },
    );
    $app->routes->delete(
        '/thing/:id' => sub {
            my $c       = shift;
            my $id      = $c->stash('id');
            my $whatsis = $c->param('whatsis');
            $c->render( json => { 'id' => $id, 'whatsis' => $whatsis, 'method' => 'delete' } );
        },
    );

    my $ua = Mojo::UserAgent::Mock->new( app => $app );
    my $host = 'foo.bar.baz.bak';
    $ua->on(
        mock_request => sub {
            my ( $ua, $req ) = @_;
            my $url = $req->url;
            is( $url->host, $host, 'Hostname matches' );
        }
    );
    for my $verb (qw/get post put patch options delete/) {
        my $whatsis = random_string('...');
        my $tx      = $ua->$verb(qq{http://$host/thing/23} => form => { whatsis => $whatsis });
        is_deeply( $tx->res->json, { id => 23, method => $verb, whatsis => $whatsis }, 'JSON Matches' );
    }
};

subtest 'route on content type' => sub {
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
    my $ua = Mojo::UserAgent::Mock->new( app => $app );
    my $host = 'foo.bar.baz.bak';
    $ua->on(
        mock_request => sub {
            my ( $ua, $req ) = @_;
            my $url = $req->url;
            is( $url->host, $host, 'Hostname matches' );
        }
    );
    for my $verb (qw/get post put patch options delete/) {
        my $whatsis = random_string('...');
        for my $format (qw/xml json/) {
            my %txn = (
                'accept' => $ua->$verb(
                    qq{http://$host/thing/23} => { Accept => qq{application/$format} } => form =>
                        { whatsis => $whatsis }
                ),
                'format' => $ua->$verb( 
                    qq{http://$host/thing/23} => form => { whatsis => $whatsis, format => $format } 
                ),
                'extension' => $ua->$verb( 
                    qq{http://$host/thing/23.$format} => form => { whatsis => $whatsis } 
                ),
            );

            for my $method (keys %txn) {
                my $tx = $txn{$method};
                if ($format eq 'json') {
                    is_deeply( $tx->res->json, { id => 23, format => $format, whatsis => $whatsis }, qq{"$method": JSON correct} );
                }
                else {
                    my $t = Test::XPath->new( xml => $tx->res->body );
                    $t->ok(
                        '/root',
                        sub {
                            my $node = shift;
                            $node->is( './id',      23,       'ID OK' );
                            $node->is( './format',  $format,  'Format OK' );
                            $node->is( './whatsis', $whatsis, 'Arbitrary data OK' );
                        }
                    );
                }
            }
        }
    }
};
done_testing;
