package Enumerable;

use 5.008_001;
use Any::Moose '::Role';

our $VERSION = '0.001';

use Scalar::Util;

#requires 'each';

my $break = "\n";

### Enumerator generators

sub enum_for :method{
    my($self, $each, @args) = @_;
    require Enumerable::Enumerator::Each;

    return Enumerable::Enumerator::Each->new(
        object => $self,
        method => $each,
        args   => \@args,
    );
}

sub list_for :method{
    my($self, $to_list, @args) = @_;

    require Enumerable::Enumerator::ToList;

    return Enumerable::Enumerator::ToList->new(
        object => $self,
        method => $to_list,
        args   => \@args,
    );
}

### List methods

sub to_list :method{
    my($self) = @_;

    return $self->list_for(to_list => @_)
        if !wantarray; # scalar context

    my @values;
    $self->each(sub{
        push @values, @_;
    });
    return @values;
}

sub take :method{
    my $self = shift;

    return $self->list_for(take => @_)
        if !wantarray; # scalar context

    my($n) = @_;

    my @values;
    local $@;
    eval{
       $self->each(sub{
            push @values, @_;
            if(--$n <= 0){
                die $break;
            }
       });
    };
    return @values;
}

sub grep :method{
    my $self = shift;

    return $self->list_for(grep => @_)
        if !wantarray; # scalar context

    my($block_or_regexp) = @_;

    my @values;

    if(ref($block_or_regexp) eq 'CODE'){ # block
        $self->each(sub{
            push @values, @_ if $block_or_regexp->(@_);
        });
    }
    else{ # regexp
        $self->each(sub{
            push @values, @_ if $_[0] =~ $block_or_regexp;
        });
    }

    return @values;
}

sub map :method{
    my $self = shift;

    return $self->list_for(map => @_)
        if !wantarray; # scalar context

    my($block) = @_;

    my @values;
    $self->each(sub{
        push @values, $block->(@_);
    });

    return @values;
}

sub reverse :method{
    my $self = shift;
    return $self->list_for(reverse => @_)
        if defined(wantarray) && !wantarray; # scalar context

    return reverse $self->to_list();
}


sub sort :method{
    my $self = shift;
    return $self->list_for(sort => @_)
        if !wantarray; # non-list context

    my $cmp = shift;
    if(defined $cmp){
        # if $cmp has the prototype '$$', sort passes $a and $b to $cmp as @_
        &Scalar::Util::set_prototype($cmp, '$$');
        return sort $cmp $self->to_list();
    }
    else{
        return sort $self->to_list();
    }
}

sub sort_by :method{
    my $self = shift;
    return $self->list_for(sort_by => @_)
        if defined(wantarray) && !wantarray; # scalar context

    my($block, $cmp) = @_;
    if(defined $cmp){
        return map  { $_->[0] }
               sort { $cmp->($a->[1], $b->[1]) }
               map  { [$_, scalar $block->($_)] } $self->to_list;
    }
    else{
        return map  { $_->[0] }
               sort { $a->[1] cmp $b->[1] }
               map  { [$_, scalar $block->($_)] } $self->to_list;
    }
}

### Scalar methods

sub join :method{
    my($self, $sep) = @_;

    return join $sep, $self->to_list;
}

sub first :method{
    my($self, $block_or_regexp) = @_;

    local $@;
    eval{
        if(ref($block_or_regexp) eq 'CODE'){ # block
            $self->each(sub{
                if($block_or_regexp->(@_)){
                    die \$_[0];
                }
            });
        }
        else{ # regexp
            $self->each(sub{
                if($_[0] =~ $block_or_regexp){
                    die \$_[0];
                }
            });
        }
    };
    return ref($@) ? ${$@} : undef;
}

sub first_index :method{
    my($self, $block_or_regexp) = @_;

    my $i = 0;
    local $@;
    eval{
        if(ref($block_or_regexp) eq 'CODE'){ # block
            $self->each(sub{
                if($block_or_regexp->(@_)){
                    die $break;
                }
                ++$i;
            });
        }
        else{ # regexp
            $self->each(sub{
                if($_[0] =~ $block_or_regexp){
                    die $break;
                }
                ++$i;
            });
        }
    };
    return $@ ? $i : undef;
}


sub reduce :method{
    my $self = shift;

    my($block) = @_;

    my $initialized;

    my $result;
    $self->each(sub{
        if(!$initialized){
            $result = shift;
            $initialized++;
        }
        else{
            $result = $block->($result, @_);
        }
    });

    return $result;
}

sub count :method{
    my $self = shift;

    my $count = 0;
    if(@_){
        my($block_or_regexp) = @_;
        if(ref($block_or_regexp) eq 'CODE'){ # block
            $self->each(sub{
                if($block_or_regexp->(@_)){
                    ++$count;
                }
            });
        }
        else{ # regexp
            $self->each(sub{
                if($_[0] =~ $block_or_regexp){
                    ++$count;
                }
            });
        }
    }
    else{
        $self->each(sub{ ++$count });
    }
    return $count;
}

sub all :method{
    my($self, $block_or_regexp) = @_;

    local $@;
    eval{
        if(ref($block_or_regexp) eq 'CODE'){ # block
            $self->each(sub{
                if(!$block_or_regexp->($_[0])){
                    die $break;
                }
            });
        }
        else{
            $self->each(sub{
                if($_[0] !~ $block_or_regexp){ # regexp
                    die $break;
                }
            });
        }
    };

    return !$@;
}

sub any :method{
    my($self, $block_or_regexp) = @_;

    local $@;
    eval{
        if(ref($block_or_regexp) eq 'CODE'){
            $self->each(sub{
                if($block_or_regexp->($_[0])){
                    die $break;
                }
            });
        }
        else{
            $self->each(sub{
                if($_[0] =~ $block_or_regexp){
                    die $break;
                }
            });
        }
    };

    return !!$@;
}

sub none :method{
    my($self, $block_or_regexp) = @_;

    local $@;
    eval{
        if(ref($block_or_regexp) eq 'CODE'){ # block
            $self->each(sub{
                if($block_or_regexp->($_[0])){
                    die $break;
                }
            });
        }
        else{ # regexp
            $self->each(sub{
                if($_[0] =~ $block_or_regexp){
                    die $break;
                }
            });
        }
    };

    return !$@;
}


sub uniq :method{
    my $self = shift;

    return $self->list_for(uniq => @_)
        if !wantarray; # non-list context

    my($block) = @_;

    my %seen;
    my @values;

    if(defined $block){ # uniq by $block
        $self->each(sub{
            if(++$seen{ $block->(@_) } == 1){
                push @values, @_;
            }
        });
    }
    else{
        $self->each(sub{
            # XXX: if scalar(@_) != 1, then ???
            if(++$seen{ $_[0] } == 1){
                push @values, $_[0];
            }
        });
    }
    return @values;
}

### Iteration methods

sub each_with_index :method{
    my $self = shift;

    return $self->enum_for(each_with_index => @_)
        if defined(wantarray) && !wantarray; # scalar context

    my($block) = @_;

    my $i = 0;
    $self->each(sub{
        $block->($i, @_);
        ++$i;
    });
    return $self;
}

sub each_slice :method{
    my $self = shift;

    return $self->enum_for(each_slice => @_)
        if defined(wantarray) && !wantarray; # scalar context

    my($n, $block) = @_;

    my @values;
    $self->each(sub{
        push @values, @_;

        if(@values >= $n){
            $block->(@values);
            @values = ();
        }
    });

    return $self;
}

no Any::Moose '::Role';
1;
__END__

=head1 NAME

Enumerable - A role that provides various list operators

=head1 VERSION

This document describes Enumerable version 0.001.

=head1 SYNOPSIS

    package IO::Enumerable;
    use Any::Moose;
    with 'Enumerable';

    sub each {
        my($self, $block) = @_;
        # ...
    }
    # ...
    package DBIx::Enumerable;
    use Any::Moose;
    with 'Enumerable';

    sub special_each {
        my($self, $block) = @_;
        # ...
    }
    # ...

    package MyClassUsingEnumerable;
    use Any::Moose;

    has list => (
        is   => 'rw',
        does => 'Enumerable',
    );
    # ...

    my $obj = MyClassUsingEnumerable->new;
    $obj->list(IO::Enumerable->new);
    print $obj->list->sort->reverse->join(' '), "\n";

    $obj->list(DBIx::Enumerable->new(dsn => 'dbi:MyDB', table => 'my_table'));
    print $obj->list->enum_for('special_each')
          ->grep(qr/^foo/)->join(' '), "\n";

=head1 DESCRIPTION

C<Enumerable> provides varous list operators for application classes.

=head1 REQUIRED METHODS

=head3 C<< $obj->each(CodeRef $block) >>

A class that does C<Enumerable> is required to provide the C<each> method,
which accepts a CODE reference I<$block> and calls it with each values:

    $obj->each(sub{
        print "Item: $_\n";
    });

For example, if you defines an IO-based enumerable class,
it will implement C<each> like this:

    sub each{
        my($self, $block) = @_;

        my $handle = $self->handle;
        local $_;
        while(<$handle>){
            $block->($_);
        }
        return $self;
    }

Note that C<< local $_ >> is not required by C<Enumerable>,
but it is useful for users.

=head1 PROVIDED METHODS

=head2 List methods

List methods return a list of values in list context,
or return an enumerator object in scalar context.

=head3 C<< $obj->to_list() >>

=head3 C<< $obj->take(Int $count) >>

=head3 C<< $obj->grep(Regexp $pattern | CodeRef $block) >>

=head3 C<< $obj->map(CodeRef $block) >>

=head3 C<< $obj->reverse() >>

=head3 C<< $obj->sort(?CodeRef $cmp) >>

=head3 C<< $obj->sort_by(CodeRef $block, ?CodeRef $cmp) >>

=head3 C<< $obj->uniq(?CodeRef $filter) >>

=head2 Scalar methods

Scalar methods return a scalar value.

=head3 C<< $obj->count() >>

=head3 C<< $obj->count(Regexp $pattern | CodeRef $block) >>

=head3 C<< $obj->reduce(CodeRef $block) >>

=head3 C<< $obj->first(Regexp $pattern | CodeRef $block) >>

=head3 C<< $obj->first_index(Regexp $pattern | CodeRef $block) >>

=head3 C<< $obj->all(Regexp $pattern | CodeRef $block) >>

=head3 C<< $obj->any(Regexp $pattern | CodeRef $block) >>

=head3 C<< $obj->none(Regexp $pattern | CodeRef $block) >>

=head3 C<< $obj->join(Str $separator) >>

=head2 Iteration methods

Iteration methods act as a kind of C<each> methods.
It returns I<$obj> itself.

=head3 C<< $obj->each_with_index(?CodeRef $block) >>

=head3 C<< $obj->each_slice(Int $count, ?CodeRef $block) >>

=head2 Enumerator generators

Enumerator generators return an enumerator object.

=head3 C<< $obj->enum_for(Str $each_method, Array @args) >>

=head3 C<< $obj->list_for(Str $lis_method, Array @args) >>

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

No bugs have been reported.

Please report any bugs or feature requests to the author.

=head1 AUTHOR

Goro Fuji (gfx) E<lt>gfuji(at)cpan.orgE<gt>

=head1 SEE ALSO

L<Moose::Role>

L<Mouse::Role>

L<List::Enumerator>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009, Goro Fuji (gfx). Some rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
