package Text::PDF::Array;

use strict;
use vars qw(@ISA);

use Text::PDF::Objind;
@ISA = qw(Text::PDF::Objind);

=head1 NAME

Text::PDF::Array - Corresponds to a PDF array. Inherits from L<PDF::Objind>

=head1 INSTANCE VARIABLES

This object is not an array but an associative array containing the array of
elements. Thus, there are special instance variables for an array object, beginning
with a space

=item var

Contains the actual array of elements

=head1 METHODS

=head2 PDF::Array->new($parent, @vals)

Creates an array with the given storage parent and an optional list of values to
initialise the array with.

=cut

sub new
{
    my ($class, @vals) = @_;
    my ($self);

    $self->{' val'} = [@vals];
    $self->{' realised'} = 1;
    bless $self, $class;
}


=head2 $a->outobjdeep($fh, $pdf)

Outputs an array as a PDF array to the given filehandle.

=cut

sub outobjdeep
{
    my ($self, $fh, $pdf) = @_;
    my ($obj);

    $fh->print("[ ");
    foreach $obj (@{$self->{' val'}})
    {
        $obj->outobj($fh, $pdf);
        $fh->print(" ");
    }
    $fh->print("]");
}


=head2 $a->removeobj($elem)

Removes all occurrences of an element from an array.

=cut

sub removeobj
{
    my ($self, $elem) = @_;

    $self->{' val'} = [grep($_ ne $elem, @{$self->{' val'}})];
}   


=head2 $a->elementsof

Returns a list of all the elements in the array. Notice that this is
not the array itself but the elements in the array.

=cut

sub elementsof
{ wantarray ? @{$_[0]->{' val'}} : $#{$_[0]->{' val'}} + 1; }


=head2 $a->add_elements

Appends the given elements to the array. An element is only added if it
is defined.

=cut

sub add_elements
{
    my ($self) = shift;
    my ($e);

    foreach $e (@_)
    { push (@{$self->{' val'}}, $e) if defined $e; }
    $self;
}


=head2 $a->val

Returns the value of the array, this is a reference to the actual array
containing the elements.

=cut

sub val
{ $_[0]->{' val'}; }


=head2 $a->copy($pdf)

Copies the array with deep-copy on elements which are not full PDF objects
with respect to a particular $pdf output context

=cut

sub copy
{
    my ($self, $pdf) = @_;
    my ($res) = $self->SUPER::copy($pdf);
    my ($e);

    $res->{' val'} = [];
    foreach $e (@{$self->{' val'}})
    {
        if (UNIVERSAL::can($e, "is_obj") && !$e->is_obj($pdf))
        { push(@{$res->{' val'}}, $e->copy($pdf)); }
        else
        { push(@{$res->{' val'}}, $e); }
    }
    $res;
}

1;


