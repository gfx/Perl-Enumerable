#!perl -w

die "This does not work. # TDOO\n";

package NaturalNumber;
use Any::Moose;
with 'Enumerable';

sub each{
    my($self, $block) = @_;
    local $_ = 0;
    while(1){
        $block->(++$_);
    }
}
package main;

my $n = NaturalNumber->new();

print $n->grep(sub{ $_ % 2 })->take(10);
