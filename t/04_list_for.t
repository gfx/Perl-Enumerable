#!perl -w
use strict;
use Test::More;
use lib 't/lib';

use MyList;

my $o = MyList->new(qw(foo bar baz));

is $o->to_list->join(' '),       'foo bar baz';
is $o->sort->join(' '),          'bar baz foo';
is $o->reverse->join(' '),       'baz bar foo';

is $o->sort->reverse->join(' '), 'foo baz bar';

is $o->to_list->to_list->to_list->to_list->join(' '),
                                 'foo bar baz';

is $o->map(sub{ -$_ })->reverse->join(' '),
    '-baz -bar -foo';

is $o->grep(qr/^b/)->reverse->join(' '),
    'baz bar';

$o = MyList->new(1 .. 100);

is $o->take(10)->grep(sub{ $_ % 2 })->reverse->join(' '),
    '9 7 5 3 1';

done_testing;
