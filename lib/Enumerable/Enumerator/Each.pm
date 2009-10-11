package Enumerable::Enumerator::Each;
use 5.008_001;
use Any::Moose;

extends 'Enumerable::Enumerator';

sub to_list :method{
    my $self = shift;

    return $self->for_list(to_list => @_)
        if !wantarray;

    my $each = $self->_method_ref;

    my @values;
    $self->object->$each($self->args, sub{
        push @values, @_;
    });

    return @values;
}

sub each :method{
    my $self = shift;

    my $each = $self->_method_ref;

    $self->object->$each($self->args, @_);

    return $self;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable();

1;
__END__

=head1 NAME

Enumerable::Enumerator::Each - An enumerable proxy class for each() method

=head1 VERSION

This document describes Enumerable version 0.001.

=head1 SYNOPSIS

    # Do not use this class dhirectly.

=head1 DESCRIPTION

Do not use this class directly. See L<Enumerable>.

=head1 METHODS

=head2 C<< $enumerator->to_list() >>

=head2 C<< $enumerator->each(CodeRef $block) >>

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

No bugs have been reported.

Please report any bugs or feature requests to the author.

=head1 AUTHOR

Goro Fuji (gfx) E<lt>gfuji(at)cpan.orgE<gt>

=head1 SEE ALSO

L<Enumerable>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009, Goro Fuji (gfx). Some rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
