use strict;
use warnings;

# ABSTRACT: An interface for package managers.

=head1 SYNOPSIS

    package My::PackageManager;
    use Moose;

    sub query {
        # return installed packages
    }

    with 'PackageManager::Virtual';
    1;

=head1 DESCRIPTION

The interface provides a minimumalist set if functionality 
required to manage package installations.

=head2 SUBROUTINES

All functions should be invoked using the infix dereference operator "->"; 
the first parameter will always be the object instance. The parameter 'verbose'
is a value 0 or 1, and is always optional (default: 0). Commands run with
verbose=1 are expected to output additional information to STDOUT. These
parameters are not included in the definitions below.

All functions use named parameters. For example, the function defintion:
    
    func( arg1:string arg2:number ): Hash

Would be invoked like so:
    
    my %result = $obj->func( arg1 => "hello", arg2 => 5);

All input parameters are prevalidated; there is no need to revalidate
inputs in implementation.

=head3 QUERY

Returns a filtered list of installed packages.

    query( pattern:string ): Array

Where 'pattern' is any valid Perl regular expression. Only packages whose names
match this parameter will be returned. Every index of the returned array is a
hash with the following keys-values:

Name of the package.

    name => string

Version of the package.

    version => string

=head3 INSTALL

Installs a specified package.

    install( package_name:string version:string ): Integer

Where package_name is the name of the package to be installed. Version specifies the
version of the package; it is optional and defaults to the latest version. Zero
is returned when successful. Otherwise, the value indicates an error code.

=cut

package PackageManager::Virtual;

use 5.006;
use Carp;
use Params::Check qw(check);

my $VERBOSE = 0;

use Moose::Role;

requires 'query';

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

requires 'install';

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

1;
