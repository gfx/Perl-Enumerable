#!perl -w
use strict;
use 5.10.0;
{
    package MyEnumerable;
    use Mouse;
    with 'Enumerable';

    sub each{
        my($self, $block) = @_;

        foreach my $word(qw(foo bar hoge fuga)){
            $block->($word);
        }
        return;
    }
    __PACKAGE__->meta->make_immutable;
}


my $o = MyEnumerable->new();

say "each_slice(2)";

$o->each_slice(2, sub{
    my($key, $value) = @_;
    say "$key => $value";
});

say "done.";
