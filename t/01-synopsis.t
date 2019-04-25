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
sub remove  { }

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
sub remove  { }

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
    my $class = shift;

    plan tests => 3;

    my $obj = new_ok($class);
    
    subtest 'query; no filter' => sub {
        validate_query( $class, [], Test::Data::example_apps_all() );
    };

    subtest 'query; filter' => sub {
        validate_query(
            $class,
            [ pattern => 'app' ],
            Test::Data::example_apps_filtered()
        );
    };

    1;
}

sub validate_query {
    return validate(
        @_,
        sub {
            my $obj = shift;
            return $obj->query(@_);
        }
    );
}

sub validate {
    my $class    = shift;
    my $args     = shift;
    my $expected = shift;
    my $func     = shift;

    plan tests => 1;

    my $obj    = $class->new( example_apps => Test::Data::example_apps_all() );
    my @result = eval { $func->( $obj, @$args ) };
    if ($@) {
        fail($@);
    }
    else {
        is_deeply( \@result, $expected );
    }

    1;
}

plan tests => 2;

subtest 'Test Virtual synopsis' => sub {
    use Example::Virtual;
    run('Example::Virtual');
};

subtest 'Test Base synopsis' => sub {
    use Example::Base;
    run('Example::Base');
};

1;
