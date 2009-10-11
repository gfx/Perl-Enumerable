#!perl -w
# tests for any(), all(), none()

use strict;
use Test::More;

use lib 't/lib';
use MyList;

my $o = MyList->new(qw(foo bar baz));

ok $o->all(sub{ $_ }), 'all';
ok $o->all(sub{ 1  }), 'all with block';
ok!$o->all(sub{ 0  }), 'all with block';
ok $o->all(qr/[a-z]/), 'all with regexp';
ok!$o->all(qr/^b/),    'all with regexp';
ok!$o->all(qr/^z/),    'all with regexp';

ok $o->any(sub{ $_ }), 'any';
ok $o->any(sub{ 1  }), 'any with block';
ok!$o->any(sub{ 0  }), 'any with block';
ok $o->any(qr/[a-z]/), 'any with regexp';
ok $o->any(qr/^b/),    'any with regexp';
ok!$o->any(qr/^z/),    'any with regexp';

ok!$o->none(sub{ $_ }), 'none';
ok!$o->none(sub{ 1  }), 'none with block';
ok $o->none(sub{ 0  }), 'none with block';
ok!$o->none(qr/[a-z]/), 'none with regexp';
ok!$o->none(qr/^b/),    'none with regexp';
ok $o->none(qr/^z/),    'none with regexp';

is join(' ', $o->first(sub{ /^b/ })), 'bar', 'first with block';
is join(' ', $o->first(qr/^b/)),      'bar', 'first with regexp';
is_deeply [$o->first(sub{ 0 })], [undef], 'first returns a scalar';

is join(' ', $o->first_index(sub{ /^b/ })), 1, 'first_index with block';
is join(' ', $o->first_index(sub{ /^f/ })), 0, 'first_index with block';
is join(' ', $o->first_index(qr/^b/)),      1, 'first_index with regexp';
is join(' ', $o->first_index(qr/^f/)),      0, 'first_index with block';

is_deeply [$o->first(sub{ 0 })], [undef], 'first_index returns undef if item is not found';

is $o->join(' '), 'foo bar baz', 'join';
is $o->join(','), 'foo,bar,baz', 'join';

is $o->count,              3, 'count';
is $o->count(sub{ /^b/ }), 2, 'count with block';
is $o->count(qr/^b/),      2, 'count with regexp';

$o = MyList->new(3, 2, 1);

is $o->reduce(sub{ $_[0] + $_[1] }), 6, 'reduce';

ok $o->all(sub{ $_     });
ok $o->all(sub{ $_ > 0 });
ok!$o->all(sub{ $_ > 1 });

ok $o->any(sub{ $_     });
ok $o->any(sub{ $_ > 1 });
ok!$o->any(sub{ $_ > 3 });

ok!$o->none(sub{ $_     });
ok!$o->none(sub{ $_ > 1 });
ok $o->none(sub{ $_ > 3 });


done_testing;
