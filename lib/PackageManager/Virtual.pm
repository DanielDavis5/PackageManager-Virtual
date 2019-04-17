use strict;
use warnings;

# ABSTRACT: An interface for package managers.

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

    with 'PackageManager::Virtual';
    1;

=head1 DESCRIPTION

The interface provides a minimumalist set if functionality 
required to manage package installations.

=head2 SUBROUTINES

All functions should be invoked using the infix dereference operator "->"; 
the first parameter will always be the object instance. A parameter 'verbose'
is always optional and has a value 0 or 1 (default=0). Commands run with
verbose=1 are expected to output additional information to STDOUT. These
parameters are not included in the definitions below.

All functions use named parameters. For example, the function defintion:
    
    func( arg1:string arg2:number ): Hash

Would be invoked like so:
    
    my %result = $obj->func( arg1 => "hello", arg2 => 5);

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

Where package_name is the name of the package to be installed. The parameter
'version' specifies the version of the package to install; it is optional. When
omitted the latest version will be installed. The subroutine will return the
number zero on success. Otherwise, the return value indicates an error code.

=cut

package PackageManager::Virtual;
use Moose::Role;

requires 'query';
requires 'install';

1;
