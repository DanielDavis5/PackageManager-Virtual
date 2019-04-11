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
    
    func( arg1:string arg2:number ): hash

Would be invoked like so:
    
    my %result = $obj->func( arg1 => "hello", arg2 => 5);

=head3 QUERY

Returns a filtered list of installed packages.

    query( pattern:string )

Where 'pattern' is any valid Perl regular expression. Only values that match
this parameter should be returned.

=cut

package PackageManager::Virtual;
use 5.006;
use Moose::Role;

requires 'query';

1;
