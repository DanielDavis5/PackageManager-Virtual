# SYNOPSIS

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

# DESCRIPTION

A moose role interface that exposes functionalities for software package
management.

## DATA MODELS

### PACKAGE INFO

A hash value that defines a package. It has the following
key-value pairs:

- **name**    => string

    _The name of the package._

- **version** => string

    _A specific version of the package._

### ERROR CODE

An integer number value. The value zero implies no error.
Otherwise, it indicates an error code.

## SUBROUTINES

All functions use named parameters. Parameters who's types end in "**?**" are
optional.

A parameter named _verbose_ is always optional and has a value "**0**" or "**1**"
_(default=0)_. When _verbose_ is "**1**" commands are expected to output additional
information to STDOUT. Although omitted, it is implied in the definitions
below.

### LIST

Gets all installed packages.

    list(): Array

Every index of the return value is a ["PACKAGE INFO"](#package-info) reference.

### GET

Gets a specified installed package.

    get( name:string ): Hash

The returned value is a ["PACKAGE INFO"](#package-info) that defines an installed package who's
name equals _name_. If the package is not installed, the returned value is
an empty list in list context or the undefined value in scalar context.

### INSTALL

Installs a specified package.

    install( name:string, version:string? ): Scalar

The returned value is an ["ERROR CODE"](#error-code); it describes the result of an attempt to
install a package who's name equals _name_. When _version_ is included it
is the version of the package to be installed. Otherwise, the latest package
version will be installed.

### REMOVE

Removes a specified package.

    remove( name:string ): Scalar

The returned value is an ["ERROR CODE"](#error-code); it describes the result of an attempt to
remove a package who's name equals _name_.
