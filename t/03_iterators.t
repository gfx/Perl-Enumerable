#!perl -w
# tests for any(), all(), none()

use strict;
use Test::More;

use lib 't/lib';
use MyList;

my $o = MyList->new(qw(foo 1 bar 2 baz 3));


is join(' ', $o->each_with_index->to_list()),
   join(' ',
    0 => 'foo', 1 => '1',
    2 => 'bar', 3 => '2',
    4 => 'baz', 5 => '3'), 'each_with_index';

my %result;
$o->each_slice(2, sub{
    my($k, $v) = @_;
    $result{$k} = $v;
});

my %values = $o->to_list;
is join(' ', sort keys   %result), join(' ', sort keys   %values), 'each_slice';
is join(' ', sort values %result), join(' ', sort values %values), 'each_slice';

is_deeply [$o->each_slice(2)->map(sub{ [ @_ ] })->to_list],
    [
        [qw(foo 1)],
        [qw(bar 2)],
        [qw(baz 3)],
    ], 'enum_for each_slice';

done_testing;
