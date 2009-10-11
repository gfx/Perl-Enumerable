#!perl -w
use strict;

{
    package IO::Enumerable;
    use Mouse;

    with 'Enumerable';

    has handle => (
        is  => 'rw',
        isa => 'FileHandle',
    );

    sub each{
        my($self, $block) = @_;

        my $handle = $self->handle;
        while(defined(my $line = <$handle>)){
            $block->($line);
        }
    }
}

my $io = IO::Enumerable->new(handle => \*DATA);
print $io->sort();

__DATA__
foo
bar
baz
