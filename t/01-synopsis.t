#!perl -T
use 5.006;
use strict;
use warnings;

package MockVirtual;
use Moose;

sub query   { }
sub install { }

with 'PackageManager::Virtual';

package MockBase;
use Moose;

sub query   { }
sub install { }

with 'PackageManager::Base';

package TestMain;
use Test::More;
plan tests => 2;

use MockVirtual;
new_ok('MockVirtual');

use MockBase;
new_ok('MockBase');