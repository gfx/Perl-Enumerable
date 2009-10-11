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

sub reverse_each{
    my($self, $block) = @_;

    foreach (reverse $self->_list){
        $block->($_);
    }
    return $self;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable();


