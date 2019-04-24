#!perl -T
use 5.006;
use strict;
use warnings;

package MockBase;
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
sub remove  { }

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
            fail("Test valid pattern '$p'; exception occurred. $@");
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
            fail("Testing invalid pattern '$p'; no exception.");
        }
    }
};
