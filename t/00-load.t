#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN { use_ok('PackageManager::Virtual') }

diag("Testing PackageManager::Virtual $PackageManager::Virtual::VERSION, Perl $], $^X");
