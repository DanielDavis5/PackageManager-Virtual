use strict;
use warnings;

package PackageManager::Virtual;
use Moose::Role;

# ABSTRACT: An interface for package managers.

=head1 SYNOPSIS

    # Instantiate an object that composes this package.
    my $pkgMgr = My::PackageManager->new();

    # Get all installed packages.
    my @installed = $pkgMgr->list(); 

    # Get an installed package's info.
    my %app_1 = $pkgMgr->get( name => 'app1' );
    print $app_1{name};    # prints the app name
    print $app_1{version}; # prints the app version

    # Unless the package is not installed.
    my %app_2 = $pkgMgr->get( name => 'not_installed_app' );
    unless( %app_2 ){ print 'not installed'; } # prints 'not installed'

    # Install version '1.0' of an app named 'app3'.
    $pkgMgr->install( name => 'app3', version => '1.0' );

    # Remove an app named 'app4'.
    $pkgMgr->remove( name => 'app4' );

=head1 DESCRIPTION

A moose role interface that exposes functionalities for software package
management.

=head2 DATA MODELS

=head3 PACKAGE INFO

A hash value that defines a package. It has the following
key-value pairs:

=over 4

=item * B<name>    => string

I<The name of the package.>

=item * B<version> => string

I<A specific version of the package.>

=back

=head3 ERROR CODE

An integer number value. The value zero implies no error.
Otherwise, it indicates an error code.

=head2 SUBROUTINES

All functions use named parameters. Parameters who's types end in "B<?>" are
optional.

A parameter named I<verbose> is always optional and has a value "B<0>" or "B<1>"
I<(default=0)>. When I<verbose> is "B<1>" commands are expected to output additional
information to STDOUT. Although omitted, it is implied in the definitions
below.

=head3 LIST

Gets all installed packages.

    list(): Array

Every index of the return value is a L</PACKAGE INFO> reference.

=cut

requires 'list';

=head3 GET

Gets a specified installed package.

    get( name:string ): Hash

The returned value is a L</PACKAGE INFO> that defines an installed package who's
name equals I<name>. If the package is not installed, the returned value is
an empty list in list context or the undefined value in scalar context.

=cut

requires 'get';

=head3 INSTALL

Installs a specified package.

    install( name:string, version:string? ): Scalar

The returned value is an L</ERROR CODE>; it describes the result of an attempt to
install a package who's name equals I<name>. When I<version> is included it
is the version of the package to be installed. Otherwise, the latest package
version will be installed.

=cut

requires 'install';

=head3 REMOVE

Removes a specified package.

    remove( name:string ): Scalar

The returned value is an L</ERROR CODE>; it describes the result of an attempt to
remove a package who's name equals I<name>.

=cut

requires 'remove';

1;
