use strict;
use warnings;

# ABSTRACT: PackageManager::Virtual compositions with input validation.

=head1 SYNOPSIS

    if ( $obj->does('PackageManager::Base') ) {

        eval { $obj->install() };
        print "$@\n" if ($@);    # Required option 'name' is not provided...

        eval { $obj->list( verbose => 'abc' ) };
        print "$@\n" if ($@);    # Key 'verbose' (abc) is of invalid type...
    }

=head1 DESCRIPTION

A moose role that extends L<PackageManager::Virtual>. It wraps all
PackageManager::Virtual functions, validates the parameters and strips them of
their names.

=head2 FUNCTIONS

All function parameters lose their name and the base function is invoked using
a standard parameter array. The order of the parameters are the same as the
order they appear in the original method definition. Except for I<verbose> 
which has the default value B<0>, omitted optional parameters are undefined.

=cut

package PackageManager::Base;
use Carp qw/confess/;
use Params::Check qw/check/;
use Moose::Role;

around 'list' => sub {
    my ( $orig, $self, %args ) = @_;

    my $verbose;
    my $template = {
        verbose => {
            default => 0,
            store   => \$verbose,
            allow   => [ 0, 1 ],
        }
    };
    check( $template, \%args )
      or confess( Params::Check->last_error );

    return $self->$orig($verbose);
};

around 'install' => sub {
    my ( $orig, $self, %args ) = @_;

    my ( $verbose, $name, $version );
    my $template = {
        verbose => {
            default => 0,
            store   => \$verbose,
            allow   => [ 0, 1 ]
        },
        name => {
            required => 1,
            store    => \$name,
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
    check( $template, \%args )
      or confess( Params::Check->last_error );

    return $self->$orig( $name, $version, $verbose );
};

around 'remove' => sub {
    my ( $orig, $self, %args ) = @_;

    my ( $verbose, $name );
    my $template = {
        verbose => {
            default => 0,
            store   => \$verbose,
            allow   => [ 0, 1 ]
        },
        name => {
            required => 1,
            store    => \$name,
            allow    => sub {
                return length( $_[0] ) > 0;
            }
        }
    };
    check( $template, \%args )
      or confess( Params::Check->last_error );

    return $self->$orig( $name, $verbose );
};

with 'PackageManager::Virtual';

1;
