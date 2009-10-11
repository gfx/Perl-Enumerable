#!perl -w
use strict;
use Test::More;

use lib 't/lib';
use MyList;

my $o = MyList->new(qw(foo bar baz));

is join(' ', $o->enum_for('each')->to_list),         'foo bar baz';
is join(' ', $o->enum_for('reverse_each')->to_list), 'baz bar foo';

done_testing;
