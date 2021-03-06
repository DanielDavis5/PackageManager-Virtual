use strict;
use warnings;

package PackageManager::Virtual;
use Moose::Role;

# ABSTRACT: A moose role interface for package managers.

=head1 SYNOPSIS

    if ( $obj->does('PackageManager::Virtual') ) {

        # Installs a package named 'cool_app'
        $obj->install( name => 'cool_app' );

        # Removes a package named 'app1'. Output is verbose.
        $obj->remove( verbose => 1, name => 'app1' );

        # Prints all installed packages
        print "\'$_->{name}\' has version \'$_->{version}\'\n"
            foreach ( $obj->list() );
    }

=head1 DESCRIPTION

A moose role that exposes functionalities for software package management.

=head2 METHODS

=head3 list( [verbose => BOOLEAN] )

Gets all installed packages.

The returned value is an array; every index is a hashref with the following
key-value pairs:

=over 4

=item * B<name>    => STRING

I<The name of the package.>

=item * B<version> => STRING

I<A specific version of the package.>

=back

=head4 verbose

When this parameters value is "B<1>" this command may output additional
information to STDOUT.

=cut

requires 'list';

=head3 install( name => STRING, [version => STRING, verbose => BOOLEAN] )

Installs a specified package.

The returned value is an integer. The value "B<0>" implies a successful
installation. Otherwise, it indicates there was an error and the package was
not installed.

=head4 name

The name of the package to be installed.

=head4 version

The version of the package to be installed. If omitted, the package version
is automatically selected.

=head4 verbose

When this parameters value is "B<1>" this command may output additional
information to STDOUT.

=cut

requires 'install';

=head3 remove( name => STRING, [verbose => BOOLEAN] )

Removes a specified package.

The returned value is an integer. The value "B<0>" implies a successful
removal. Otherwise, it indicates there was an error in the removal process and
the package was not removed.

=head4 name

The name of the package to be removed.

=head4 verbose

When this parameters value is "B<1>" this command may output additional
information to STDOUT.

=cut

requires 'remove';

1;
