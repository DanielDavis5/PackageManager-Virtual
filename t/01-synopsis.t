#!perl -T
use 5.006;
use strict;
use warnings;

package Example::Base;
use Moose;

use Data::Dumper;

has 'example_apps' => ( is => 'rw' );

sub query {
    my $self    = shift;
    my $verbose = shift;

    if ( defined $verbose && $verbose == 1 ) {
        print 'hi';
    }
    return @{ $self->example_apps };
}

sub install {
    my $self    = shift;
    my $verbose = shift;
    my $name    = shift;
    my $version = shift;

    if ( defined $verbose && $verbose == 1 ) {
        print 'hi';
    }
    push @{ $self->example_apps }, { name => $name, version => $version };

    return 1;
}

sub remove {
    my $self    = shift;
    my $verbose = shift;
    my $name    = shift;

    if ( defined $verbose && $verbose == 1 ) {
        print 'hi';
    }
    
    my @updated = grep { $_->{name} ne $name }
      @{ $self->example_apps };
    print Dumper @updated;

    $self->example_apps( \@updated );

    return 1;
}

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

sub example_app {
    (
        name    => "new_app",
        version => "0.001",
    )
}

sub example_apps_added {
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
        {
            name    => "new_app",
            version => "0.001",
        }
    ];
}

sub example_apps_removed {
    [
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

package Test::Main;
use Test::More;

sub run {
    my $class = shift;

    plan tests => 5;

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

    subtest 'install' => sub {
        my %app = Test::Data::example_app();
        validate_install(
            $class,
            [ name => $app{name}, version => $app{version} ],
            Test::Data::example_apps_added()
        );
    };

    subtest 'remove' => sub {
        my $start_list = Test::Data::example_apps_all();
        validate_remove(
            $class,
            [ name => $start_list->[0]->{name} ],
            Test::Data::example_apps_removed()
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

sub validate_install {
    return validate(
        @_,
        sub {
            my $obj = shift;
            $obj->install(@_);    # check value...
            return $obj->query();
        }
    );
}

sub validate_remove {
    return validate(
        @_,
        sub {
            my $obj = shift;
            $obj->remove(@_);
            return $obj->query();
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

plan tests => 1;

subtest 'Test Base synopsis' => sub {
    use Example::Base;
    run('Example::Base');
};

1;
