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

sub l_all{
    my($self, $block) = @_;

    if(defined $block){
        foreach ($self->to_list){
            if(!$block->($_)){
                return 0;
            }
        }
    }
    else{
        foreach ($self->to_list){
            if(!$_){
                return 0;
            }
        }
    }
    return 1;
}

sub e_all{
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
    to_list => sub{
        my $x = $o->l_all();
    },
    eval => sub{
        my $x = $o->e_all();
    },
};

$o->iteration(100);
print "iteration 100\n";
cmpthese -1 => {
    to_list => sub{
        my $x = $o->l_all();
    },
    eval => sub{
        my $x = $o->e_all();
    },
};


