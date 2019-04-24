use strict;
use warnings;

# ABSTRACT: A base class for the PackageManager::Virtual role.

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Handles boiler plate parameter validation; as well as, some output
manipulation. 

=head2 SUBROUTINES

All subroutine parameters are validated before invocation.

=head3 QUERY

The pattern filter is automatically applied the results. Implementing
this subroutine now requires all installed packages to be returned.

Returns all installed packages.

    query(): Array

Every index of the returned array is a hash with the same structure as
the previous defintion.

=cut

package PackageManager::Base;
use 5.006;
use Carp;
use Params::Check qw(check);
use Moose::Role;

my $VERBOSE = 0;

around 'query' => sub {
    my $orig = shift;
    my $self = shift;
    my %args = @_;

    my ( $verbose, $pattern );
    my $tmpl = {
        verbose => {
            default => $VERBOSE,
            allow   => [ 0, 1 ]
        },
        pattern => {
            defined => 1,
            store   => \$pattern,
            allow   => sub {
                my $arg = $_[0];
                eval { qr/$arg/ };
                return $@ ? 0 : length($arg);
            }
        }
    };

    check( $tmpl, \%args, $verbose )
      or croak( "Could not validate input: %1", Params::Check->last_error );

    my @packages = $self->$orig($verbose);
    if ( defined $pattern ) {
        my $re = qr/$pattern/;
        return grep { $_->{name} =~ $re } @packages;
    }
    else {
        return @packages;
    }
};

around 'install' => sub {
    my $orig = shift;
    my $self = shift;
    my %args = @_;

    my ( $verbose, $package_name, $version );
    my $tmpl = {
        verbose => {
            default => $VERBOSE,
            store   => \$verbose,
            allow   => [ 0, 1 ]
        },
        package_name => {
            required => 1,
            store    => \$package_name,
            allow    => sub {
                return length( $_[0] ) > 0;
            }
        },
        version => {
            store => \$version,
            allow => sub {
                return length( $_[0] ) > 0;
            }
        }
    };

    check( $tmpl, \%args, $verbose )
      or croak( "Could not validate input: %1", Params::Check->last_error );

    return $self->$orig( $verbose, $package_name, $version );
};

with 'PackageManager::Virtual';

1;
