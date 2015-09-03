# NAME

Mojo::UserAgent::Mock - A class to provide a mock Mojo user agent, allowing the caller to simulate an HTTP interaction.

# VERSION

version 0.001

# SYNOPSIS

# DESCRIPTION

Allows you to mock requests with a Mojo user agent.  Rewrites request URLs to an internal server instance.

# NAME 

Mojo::UserAgent::Mock

# ATTRIBUTES 

## app

The Mojolicious application that will service requests sent via this user agent.  This allows you 
to create a separate app that responds however you like and pass it in.

## mock\_blocking

If set, the user agent will mock processing non-blocking requests. Otherwise the standard 
application server URL will be used. It doesn't have much effect unless you pass in a full-fledged
application instance.

## routes

Routes to process. Syntax is the same as in ["any" in Mojolicious::Routes::Route](https://metacpan.org/pod/Mojolicious::Routes::Route#any)

# EVENTS

## mock\_request

An event that contains the original request. Useful for inspecting the original request URL, 
content-type, etc., and making sure they are acting as they ought to.

# ACKNOWLEDGEMENTS

Based heavily on https://metacpan.org/source/JBERGER/Webservice-Shipment-0.03/lib/Webservice/Shipment/MockUserAgent.pm 

# AUTHOR

Kit Peters &lt;kit.peters@broadbean.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Broadbean Technology.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
