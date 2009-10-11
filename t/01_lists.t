#!perl -w
use strict;
use Test::More;

use lib 't/lib';
use MyList;

my $o = MyList->new(qw(foo bar baz));

is join(' ', $o->to_list), 'foo bar baz', 'to_list';


is join(' ', $o->sort),    'bar baz foo', 'sort';
is join(' ', $o->sort(sub{ $_[1] cmp $_[0] })), 'foo baz bar', 'sort with cmp';

is join(' ', $o->map(sub{ -$_ })), '-foo -bar -baz', 'map';

is join(' ', $o->grep(sub{ /^b/ })), 'bar baz', 'grep with block';
is join(' ', $o->grep(qr/^b/)),      'bar baz', 'grep with regexp';

is join(' ', $o->uniq),                'foo bar baz', 'uniq';
is join(' ', $o->uniq(sub{ length })), 'foo', 'uniq with block';
is join(' ', MyList->new(qw(foo bar foo bar foo bar baz))->uniq),
                                       'foo bar baz';

is join(' ', $o->take(1)), 'foo', 'take';
is join(' ', $o->take(2)), 'foo bar';
is join(' ', $o->take(4)), 'foo bar baz';

$o = MyList->new(qw(a aaa aa));

is join(' ', $o->sort_by(sub{ length })), 'a aa aaa',
    'sort_by';

is join(' ', $o->sort_by(sub{ length }, sub{ $_[1] cmp $_[0]})),
    'aaa aa a', 'sort_by with cmp';

done_testing;
