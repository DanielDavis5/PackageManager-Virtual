use strict;
use warnings;

# ABSTRACT: A base class for the PackageManager::Virtual role.

=head1 SYNOPSIS

    package My::PackageManager;
    use Moose;

    sub query {
        return (
            {
                name    => "app1",
                version => "1.0",
            },
            {
                name    => "devTool",
                version => "3.0.1-3",
            },
            {
                name    => "cool-thing",
                version => "alpha",
            },
        );
    }
    
    sub install { }

    with 'PackageManager::Base';
    1;

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
            default => '.*',
            defined => 1,
            store   => \$pattern,
            allow   => sub {
                my $arg = $_[0];
                eval { qr/$arg/ };
                return $@ ? 0 : length($arg);
            }
        }
    };

    check( $tmpl, \%args, $VERBOSE )
      or croak( "Could not validate input: %1", Params::Check->last_error );

    my @packages = $self->$orig();
    return grep /$pattern/, @packages;
};

before 'install' => sub {
    my $self = shift;
    my %hash = @_;

    my ( $verbose, $package_name, $version );
    my $tmpl = {
        verbose      => { default  => $VERBOSE, store => \$verbose },
        package_name => { required => 1,        store => \$package_name },
        version      => { required => 0,        store => \$version }
    };

    check( $tmpl, \%hash, $VERBOSE )
      or croak( "Could not validate input: %1", Params::Check->last_error );

    if ( length($package_name) == 0 ) {
        croak
          "Invalid parameter value; 'package_name' may not be empty string.";
    }

    if ( defined $version && length($version) == 0 ) {
        croak "Invalid parameter value; 'version' may not be empty string.";
    }
};

with 'PackageManager::Virtual';

1;
