#!perl -T
use 5.006;
use strict;
use warnings;

package Example::Virtual;
use Moose;

has 'example_apps' => ( is => 'rw' );

sub query {
    my $self    = shift;
    my %args    = @_;
    my $verbose = $args{verbose};
    my $pattern = $args{pattern};

    if ( defined $verbose && $verbose == 1 ) {
        print 'hi';
    }
    if ( defined $pattern ) {
        my $re = qr/$pattern/;
        return grep { $_->{name} =~ $re } @{ $self->example_apps };
    }
    return @{ $self->example_apps };
}

sub install { }

with 'PackageManager::Virtual';

package Example::Base;
use Moose;

has 'example_apps' => ( is => 'rw' );

sub query {
    my $self    = shift;
    my $verbose = shift;

    if ( defined $verbose && $verbose == 1 ) {
        print 'hi';
    }
    return @{ $self->example_apps };
}

sub install { }

with 'PackageManager::Base';

package Test::Data;

sub example_apps_all {
    [
        {
            name    => "devTool",
            version => "3.0.1-3",
        },
        {
            name    => "app1",
            version => "1.0",
        },
        {
            name    => "app2",
            version => "2.1",
        },
        {
            name    => "cool-thing",
            version => "alpha",
        },
    ];
}

sub example_apps_filtered {
    [
        {
            name    => "app1",
            version => "1.0",
        },
        {
            name    => "app2",
            version => "2.1",
        },
    ];
}

package Test::Main;
use Test::More;

sub run {
    my $packageName = shift;
    my $factory     = shift;

    unless ( $factory->()->isa($packageName) ) {
        die 'invalid test; bad factory';
    }

    plan tests => 3;

    my $obj = new_ok($packageName);

    subtest 'query; no filter' => sub {
        test_valid_query( $factory, [], Test::Data::example_apps_all() );
    };

    subtest 'query; filter' => sub {
        test_valid_query(
            $factory,
            [ pattern => 'app' ],
            Test::Data::example_apps_filtered()
        );
    };
}

sub test_valid_query {
    my $factory  = shift;
    my $args     = shift;
    my $expected = shift;
    my $obj      = $factory->();

    plan tests => 1;

    my @result = eval { $obj->query(@$args) };
    if ($@) {
        fail( 'error on valid input: ' . $@ );
    }
    else {
        is_deeply( \@result, $expected );
    }
}

plan tests => 2;

subtest 'Test Virtual synopsis' => sub {
    use Example::Virtual;
    run(
        'Example::Virtual',
        sub {
            Example::Virtual->new(
                example_apps => Test::Data::example_apps_all() );
        }
    );
};

subtest 'Test Base synopsis' => sub {
    use Example::Base;
    run(
        'Example::Base',
        sub {
            Example::Base->new(
                example_apps => Test::Data::example_apps_all() );
        }
    );
};

1;
