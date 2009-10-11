#!perl -w
use strict;
use 5.10.0;
{
    package MyEnumerable;
    use Mouse;
    with 'Enumerable';

    sub each{
        my($self, $block) = @_;

        foreach my $word(qw(moose mooose moooose mouse)){
            $block->($word);
        }
        return;
    }
    __PACKAGE__->meta->make_immutable;
}


my $o = MyEnumerable->new();
say join ' ', $o->sort_by(sub{ length });

