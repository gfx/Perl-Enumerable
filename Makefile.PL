use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/Enumerable.pm';

requires 'Any::Moose' => 0.09;

test_requires 'Test::More' => 0.88; # done_testing()

tests 't/*.t';
author_tests 'xt';

auto_set_repository() if -d '.git';

clean_files qw(
	Enumerable-* *.stackdump
	cover_db
	nytprof
	*.out
);

WriteAll check_nmake => 0;
