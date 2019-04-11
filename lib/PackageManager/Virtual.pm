use strict;
use warnings;

# ABSTRACT: An interface for package managers.

package PackageManager::Virtual;
use 5.006;
use Moose::Role;

requires 'query';

1;
