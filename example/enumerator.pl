#!perl -w
use strict;
use 5.10.0;
{
    package MyEnumerable;
    use Mouse;
    with 'Enumerable';

    sub each{
        my($self, $block) = @_;

        foreach my $word(qw(foo bar baz)){
            $block->($word);
        }
        return;
    }

    sub reverse_each{
        my($self, $block) = @_;

        foreach my $word(reverse qw(foo bar baz)){
            $block->($word);
        }
        return;
    }

    __PACKAGE__->meta->make_immutable;
}


my $o = MyEnumerable->new();

say "each with index";
$o->enum_for('each')->each_with_index(sub{
    my($index, $value) = @_;
    say "$index: $value";
});
# => foo bar baz

say "reverse_each with index";
$o->enum_for('reverse_each')->each_with_index(sub{
    my($index, $value) = @_;
    say "$index: $value";
});
# => baz bar foo

say "done.";
