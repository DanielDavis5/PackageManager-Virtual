#!perl -T
use 5.006;
use strict;
use warnings;

package MockBase;
use Moose;

my @packages = ("app1", "app2", "app3");

sub query   { return @packages; }
sub install { }

with 'PackageManager::Base';

package TestMain;
use Test::More;
plan tests => 2;

use MockBase;

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

    my $obj = MockBase->new;
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

    my $obj = MockBase->new;
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
