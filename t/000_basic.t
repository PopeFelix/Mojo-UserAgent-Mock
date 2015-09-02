use Test::Most;

my $class;
BEGIN {
    $class = 'Mojo::UserAgent::Mock';
    use_ok($class);
}

my $ua = new_ok($class);
done_testing;
