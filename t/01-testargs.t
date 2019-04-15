#!perl -T
use 5.006;
use strict;
use warnings;

package Mock;
use Moose;

sub query { }

with 'PackageManager::Virtual';

package TestMain;
use Test::More;
plan tests => 3;

use Mock;
my $obj = new_ok('Mock');

subtest 'Test valid queries' => sub {
    my @list = split /\n/, <<'END';
foo
John Smith
(\d+):(\d+):(\d+)
(foo.*?)
(\d\s) {3}
a-z
^$
\G(\d+:\d+:\d+)
END
    plan tests => scalar @list;

    my $obj = Mock->new;
    foreach my $p (@list) {
        eval { $obj->query( pattern => $p ) };
        if ($@) {
            fail("Test valid pattern '$p'; exception occured. $@");
        }
        else {
            pass("Test valid pattern '$p'.");
        }
    }
};

subtest 'Test invalid queries' => sub {
    my @list = split /\n/, <<'END';
[
(?(??{bad})c|d)
(?(?p{bad})c|d)
(?(?>bad)c|d)
(?(?:bad)c|d)
(?(?i)c|d)
(?(?#bad)c|d)
(?(BAD)c|d)
(?(1BAD)c|d)
(?()c|d)
(?((?=bad))c|d)
(?(?=bad)c|d|e)
END
    plan tests => scalar @list;

    my $obj = Mock->new;
    foreach my $p (@list) {
        eval { $obj->query( pattern => $p ) };
        if ($@) {
            pass("Testing invalid pattern '$p'.");
        }
        else {
            fail("Testing invalid pattern '$p'; no exeption.");
        }
    }
};
