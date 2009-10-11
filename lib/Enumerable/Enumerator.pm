package Enumerable::Enumerator;
use 5.008_001;
use Any::Moose;

with 'Enumerable';

has object => (
    is       => 'ro',
    does     => 'Enumerable',
    required => 1,
);

has args => (
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    required   => 1,
);

has method => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub _method_ref :method{
    my($self) = @_;

    return $self->object->can($self->method)
        || $self->meta->throw_error(sprintf 'Cannot locate %s in %s',
            $self->method, $self->object);
}


no Any::Moose;

1;
__END__

=head1 NAME

Enumerable::Enumerator - The abstract base class for enumerators

=head1 VERSION

This document describes Enumerable version 0.001.

=head1 SYNOPSIS

    my $list  = EnumerableSomething->new();
    print $list->enum_for('reverse_each')->join(' '), "\n";

=head1 DESCRIPTION

C<Enumerable::Enumerator> is an enumerable proxy class, which
B<does> C<Enumerable>.

See L<Enumerable>.

=head1 INTERFACE

=head2 Attributes

=head2 C<< object >>

=head2 C<< method >>

=head3 C<< args >>

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

No bugs have been reported.

Please report any bugs or feature requests to the author.

=head1 AUTHOR

Goro Fuji (gfx) E<lt>gfuji(at)cpan.orgE<gt>

=head1 SEE ALSO

L<Enumerable>

L<Enumerable::Enumerator::Each>

L<Enumerable::Enumerator::ToList>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009, Goro Fuji (gfx). Some rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
