# SYNOPSIS

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

    with 'PackageManager::Virtual';

Considering the package defined above, an example instantiation could be:

    my $obj = Example::Virtual->new(
        example_apps => [
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
        ]
    );

As an example, the valid method invocation:

    $obj->query(pattern => 'app');

Would return the value:

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

# DESCRIPTION

An interface that provides a minimumal functionality required to manage 
software package installations.

## SUBROUTINES

All functions use named parameters. For example, the function defintion:

    func( arg1:string arg2:number ): Hash

Would be invoked like so:

    my %result = $obj->func( arg1 => "hello", arg2 => 5);

A parameter named 'verbose' is always optional and has a value 0 or 1
(default=0). Commands run with verbose=1 are expected to output additional
information to STDOUT. It is implied in the definitions below.

### QUERY

Returns a filtered list of installed packages.

    query( pattern:string ): Array

Where 'pattern' is any valid Perl regular expression. The return value is an
Array of package-info whose names match 'pattern'.

### INSTALL

Installs a specified package.

    install( package:package-info ): error-code

Where package defines the package to be installed. The 'version' key of the
package may be omitted. In this case, the latest version will be installed.

### REMOVE

Uninstalls a specified package.

    remove( package_name:string ): error-code

Where package\_name is the name of the package to be uninstalled.

## DATA

### PACKAGE INFO

package-info := A hash value that defines a package. It has the following
structure:

    (
        name    => string,
        version => string
    )

Where 'name' is the name of the package and 'version' is a specific version
of the package.

### ERROR CODE

error-code := An integer number value. The value zero implies no error. Otherwise, the
return value indicates an error code.
