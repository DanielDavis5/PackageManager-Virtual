#!perl -T
use strict;
use warnings;
use Test::More;

plan tests => 2;

BEGIN {
    use_ok('PackageManager::Virtual');
    use_ok('PackageManager::Base');
}
