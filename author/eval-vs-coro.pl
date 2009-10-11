#!perl -w
use strict;
use Benchmark qw(:all);
package A;
use Mouse;
with 'Enumerable';

has iteration => (is => 'rw');

sub each{
    my($self, $block) = @_;

    foreach my $value (1 .. $self->iteration){
        $block->($value);
    }
}

sub all{
    my($self, $block) = @_;

    my $enumerator = $self->enum_for('each');

    local $_;
    if(defined $block){
        while( ($_) = $enumerator->next ){
            if(!$block->($_)){
                return 0;
            }
        }
    }
    else{
        while( ($_) = $enumerator->next ){
            if(!$_){
                return 0;
            }
        }
    }
    return 1;
}

sub all2{
    my($self, $block) = @_;

    local $@;
    eval{
        if(defined $block){
            $self->each(sub{
                if(!$block->($_[0])){
                    die;
                }
            });
        }
        else{
            $self->each(sub{
                if(!$_[0]){
                    die;
                }
            });
        }
    };

    return !$@;
}

__PACKAGE__->meta->make_immutable;

package main;


my $o = A->new(iteration => 10);
print "iteration 10\n";
cmpthese -1 => {
    coro => sub{
        my $x = $o->all();
    },
    eval => sub{
        my $x = $o->all2();
    },
};

$o->iteration(100);
print "iteration 100\n";
cmpthese -1 => {
    coro => sub{
        my $x = $o->all();
    },
    eval => sub{
        my $x = $o->all2();
    },
};


