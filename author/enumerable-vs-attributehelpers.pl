#!perl -w
use strict;
use Benchmark qw(:all);

package MyList;
use Any::Moose;
with 'Enumerable';

has _list => (
    is         => 'ro',
    isa        => 'ArrayRef',
    required   => 1,
    auto_deref => 1,
);

sub BUILDARGS{
    my $class = shift;

    return { _list => [@_] };
}

sub each{
    my($self, $block) = @_;

    foreach ($self->_list){
        $block->($_);
    }
    return $self;
}


__PACKAGE__->meta->make_immutable();

package A;
use Any::Moose;
use Any::Moose 'X::AttributeHelpers';

has array => (
    is     => 'rw',
    isa    => 'ArrayRef',
    traits => ['Array'],

    handles => {
        array_first => 'first',
        array_map   => 'map',
    },
);

has list => (
    is   => 'rw',
    does => 'Enumerable',
    default => sub{ MyList->new },
);

__PACKAGE__->meta->make_immutable;

package main;
use List::Util qw(first);

my $o = A->new(
    array => [1 .. 100],
    list  => MyList->new(1 .. 100),
);

$o->list->first(sub{ $_ == 10}) == 10 or die;
$o->array_first(sub{ $_ == 10}) == 10 or die;


print 'first { $_ == 10 }', "\n";
cmpthese -1 => {
    enum => sub{
        my $x = $o->list->first(sub{ $_ == 10 });
    },
    helpers => sub{
        my $x = $o->array_first(sub{ $_ == 10 });
    },
    listutil => sub{
        my $x = first{ $_ == 10 } @{$o->array};
    },
    
};

print 'map { -$_  }', "\n";
cmpthese -1 => {
    enum => sub{
        my @x = $o->list->map(sub{ -$_  });
    },
    helpers => sub{
        my @x = $o->array_map(sub{ -$_  });
    },
    listutil => sub{
        my @x = map{ -$_  } @{$o->array};
    },
};
