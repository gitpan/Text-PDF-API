package Text::PDF::Page;

use strict;
use vars qw(@ISA);
@ISA = qw(Text::PDF::Pages);
use Text::PDF::Pages;

use Text::PDF::Utils;

=head1 NAME

Text::PDF::Page - Represents a PDF page, inherits from L<Text::PDF::Pages>

=head1 DESCRIPTION

Represents a page of output in PDF. It also keeps track of the content stream,
any resources (such as fonts) being switched, etc.

Page inherits from Pages due to a number of shared methods. They are really
structurally quite different.

=head1 INSTANCE VARIABLES

A page has various working variables:

=item curstrm

The currently open stream

=head1 METHODS

=head2 Text::PDF::Page->new($pdf, $parent, $index)

Creates a new page based on a pages object (perhaps the root object).

The page is also added to the parent at this point, so pages are ordered in
a PDF document in the order in which they are created rather than in the order
they are closed.

Only the essential elements in the page dictionary are created here, all others
are either optional or can be inherited.

The optional index value indicates the index in the parent list that this page
should be inserted (so that new pages need not be appended)

=cut

sub new
{
    my ($class, $pdf, $parent, $index) = @_;
    my ($self) = {};

    $class = ref $class if ref $class;
    $self = $class->SUPER::new($pdf, $parent);
    $self->{'Type'} = PDFName('Page');
    delete $self->{'Count'};
    delete $self->{'Kids'};
    $parent->add_page($self, $index);
    $self;
}


=head2 $p->add($str)

Adds the string to the currently active stream for this page. If no stream
exists, then one is created and added to the list of streams for this page.

The slightly cryptic name is an aim to keep it short given the number of times
people are likely to have to type it.

=cut

sub add
{
    my ($self, $str) = @_;
    my ($strm) = $self->{' curstrm'};

    if (!defined $strm)
    {
        $strm = Text::PDF::Dict->new;
        foreach (@{$self->{' outto'}})
        { $_->new_obj($strm); }
        $self->{'Contents'} = PDFArray() unless defined $self->{'Contents'};
        unless (ref $self->{'Contents'} eq "Text::PDF::Array")
        { $self->{'Contents'} = PDFArray($self->{'Contents'}); }
        $self->{'Contents'}->add_elements($strm);
        $self->{' curstrm'} = $strm;
    }

    $strm->{' stream'} .= $str;
    $self;
}


=head2 $p->ship_out($pdf)

Ships the page out to the given output file context

=cut

sub ship_out
{
    my ($self, $pdf) = @_;

    $pdf->ship_out($self);
    if (defined $self->{'Contents'})
    { $pdf->ship_out($self->{'Contents'}->elementsof); }
    $self;
}


