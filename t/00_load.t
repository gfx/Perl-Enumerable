#!perl -w

use strict;
use Test::More tests => 2;

BEGIN {
    use_ok 'Enumerable';
    use_ok 'Enumerable::Enumerator';
}


diag "Testing Enumerable/$Enumerable::VERSION";

diag "    ", "Any::Moose/$Any::Moose::VERSION";
diag "    ", Any::Moose::any_moose(), '/', Any::Moose::any_moose()->VERSION;
