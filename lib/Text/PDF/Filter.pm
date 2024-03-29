package Text::PDF::Filter;

=head1 NAME

PDF::Filter - Abstract superclass for PDF stream filters

=head1 SYNOPSIS

    $f = Text::PDF::Filter->new;
    $str = $f->outfilt($str, 1);
    print OUTFILE $str;
    
    while (read(INFILE, $dat, 4096))
    { $store .= $f->infilt($dat, 0); }
    $store .= $f->infilt("", 1);

=head1 DESCRIPTION

A Filter object contains state information for the process of outputting
and inputting data through the filter. The precise state information stored
is up to the particular filter and may range from nothing to whole objects
created and destroyed.

Each filter stores different state information for input and output and thus
may handle one input filtering process and one output filtering process at
the same time.

=head1 METHODS

=head2 Text::PDF::Filter->new

Creates a new filter object with empty state information ready for processing
data both input and output.

=head2 $dat = $f->infilt($str, $isend)

Filters from output to input the data. Notice that $isend == 0 implies that there
is more data to come and so following it $f may contain state information
(usually due to the break-off point of $str not being tidy). Subsequent calls
will incorporate this stored state information.

$isend == 1 implies that there is no more data to follow. The
final state of $f will be that the state information is empty. Error messages
are most likely to occur here since if there is required state information to
be stored following this data, then that would imply an error in the data.

=head2 $str = $f->outfilt($dat, $isend)

Filter stored data ready for output. Parallels C<infilt>.

=cut

sub new
{
    my ($class) = @_;
    my ($self) = {};

    bless $self, $class;
}



package Text::PDF::ASCII85Decode;

use strict;
use vars qw(@ISA);
@ISA = qw(Text::PDF::Filter);

=head1 NAME

Text::PDF::ASCII85Decode - Ascii85 filter for PDF streams. Inherits from
L<Text::PDF::Filter>

=cut

sub outfilt
{
    my ($self, $str, $isend) = @_;
    my ($res, $i, $j, $b, @c);

    if ($self->{'outcache'} ne "")
    {
        $str = $self->{'cache'} . $str;
        $self->{'cache'} = "";
    }
    for ($i = 0; $i < length($str); $i += 4)
    {
        $b = unpack("N", substr($str, $i, 4));
        if ($b == 0)
        {
            $res .= "z";
            next;
        }
        for ($j = 0; $j < 4; $j++)
        { $c[$j] = $b - int($b / 85) * 85 + 33; $b /= 85; }
        $res .= pack("C5", @c, $b + 33);
        $res .= "\n" if ($i % 60 == 56);
    }
    if ($isend && $i > length($str))
    {
        $b = unpack("N", substr($str, $i - 4) . "\000\000\000");
        for ($j = 0; $j < 4; $j++)
        { $c[$j] = $b - int($b / 85) * 85 + 33; $b /= 85; }
        $res .= substr(pack("C5", @c, $b), 0, $i - length($str) + 1) . "->";
    } elsif ($i > length($str))
    { $self->{'outcache'} = substr($str, $i - 4); }
    $res;
}

sub infilt
{
    my ($self, $str, $isend) = @_;
    my ($res, $i, $j, @c, $b, $num);

    if ($self->{'incache'} ne "")
    {
        $str = $self->{'incache'} . $str;
        $self->{'incache'} = "";
    }
    $str =~ s/(\r|\n)\n?//oig;
    for ($i = 0; $i < length($str); $i += 5)
    {
        $b = 0;
        if (substr($str, $i, 1) eq "z")
        {
            $i -= 4;
            $res .= pack("N", 0);
            next;
        }
        elsif ($isend && substr($str, $i, 6) =~ m/^(.{2,4})\-\>$/oi)
        {
            $num = 5 - length($1);
            @c = unpack("C5", $1 . ("u" x (4 - $num)));     # pad with 84 to sort out rounding
            $i = length($str);
        } else
        { @c = unpack("C5", substr($str, $i, 5)); }

        for ($j = 0; $j < 5; $j++)
        {
            $b *= 85;
            $b += $c[$j] - 33;
        }
        $res .= substr(pack("N", $b), 0, 4 - $num);
    }
    if (!$isend && $i > length($str))
    { $self->{'incache'} = substr($str, $i - 5); }
    $res;
}



package Text::PDF::RunLengthDecode;

use strict;
use vars qw(@ISA);
@ISA = qw(Text::PDF::Filter);

=head1 NAME

Text::PDF::RunLengthDecode - Run Length encoding filter for PDF streams. Inherits from
L<Text::PDF::Filter>

=cut

sub outfilt
{
    my ($self, $str, $isend) = @_;
    my ($res, $s, $r);

# no state information, just slight inefficiency at block boundaries
    while ($str ne "")
    {
        if ($str =~ m/((.)\2{2,127})/oi)
        {
            $s = $`;
            $r = $1;
            $str = $';
        } else
        {
            $s = $str;
            $r = "";
            $str = "";
        }
        while (length($s) > 127)
        {
            $res .= pack("C", 127) . substr($s, 0, 127);
            substr($s, 0, 127) = "";
        }
        $res .= pack("C", length($s)) . $s if length($s) > 0;
        $res .= pack("C", 257 - length($r));
    }
    $res .= "\x80" if ($isend);
    $res;
}

sub infilt
{
    my ($self, $str, $isend) = @_;
    my ($res, $l, $d);

    if ($self->{'incache'} ne "")
    {
        $str = $self->{'incache'} . $str;
        $self->{'incache'} = "";
    }
    while ($str ne "")
    {
        $l = unpack("C", $str);
        if ($l == 128)
        {
            $isend = 1;
            return $res;
        }
        if ($l > 128)
        {
            if (length($str) < 2)
            {
                warn "Premature end to data in RunLengthEncoded data" if $isend;
                $self->{'incache'} = $str;
                return $res;
            }
            $res .= substr($str, 1, 1) x (257 - $l);
            substr($str, 0, 2) = "";
        } else
        {
            if (length($str) < $l + 1)
            {
                warn "Premature end to data in RunLengthEncoded data" if $isend;
                $self->{'incache'} = $str;
                return $res;
            }
            $res .= substr($str, 1, $l);
            substr($str, 0, $l + 1) = "";
        }
    }
    $res;
}



package Text::PDF::ASCIIHexDecode;

use strict;
use vars qw(@ISA);
@ISA = qw(Text::PDF::Filter);

=head1 NAME

Text::PDF::ASCIIHexDecode - Ascii Hex encoding (very inefficient) for PDF streams.
Inherits from L<Text::PDF::Filter>

=cut

sub outfilt
{
    my ($self, $str, $isend) = @_;

    $str =~ s/(.)/sprintf("%02x", ord($1))/oige;
    $str .= ">" if $isend;
    $str;
}

sub infilt
{
    my ($self, $str, $isend) = @_;

    $isend = ($str =~ s/>$//oig);
    $str =~ s/\s//oig;
    $str =~ s/([0-9a-z])/pack("C", hex($1 . "0"))/oige if ($isend && length($str) & 1);
    $str =~ s/([0-9a-z]{2})/pack("C", hex($1))/oige;
    $str;
}

package Text::PDF::FlateDecode;

use strict;
use vars qw(@ISA $havezlib);
@ISA = qw(Text::PDF::Filter);
BEGIN
{
    eval {require "Compress/Zlib.pm";};
    $havezlib = !$@;
}

sub new
{
    return undef unless $havezlib;
    my ($class) = @_;
    my ($self) = {};

    $self->{'outfilt'} = Compress::Zlib::deflateInit();
    $self->{'infilt'} = Compress::Zlib::inflateInit();
    bless $self, $class;
}

sub outfilt
{
    my ($self, $str, $isend) = @_;
    my ($res);

    $res = $self->{'outfilt'}->deflate($str);
    $res .= $self->{'outfilt'}->flush() if ($isend);
    $res;
}

sub infilt
{
    my ($self, $dat, $last) = @_;
    my ($res, $status) = $self->{'infilt'}->inflate("$dat");
    $res;
}

package Text::PDF::LZWDecode;

use vars qw(@ISA @basedict);
@ISA = qw(Text::PDF::FlateDecode);
@basedict = map {pack("C", $_)} (0 .. 255, 0, 0);

sub new
{
    my ($class) = @_;
    my ($self) = {};

    $self->{'indict'} = [@basedict];
    $self->{'insize'} = 9;
#    $self->{'outfilt'} = Compress::Zlib::deflateInit();     # patent precludes LZW encoding
    bless $self, $class;
}

sub infilt
{
    my ($self, $dat, $last) = @_;
    my ($num, $cache, $cache_size, $res, $mode, $count);

    $count = 258;
    while ($dat ne '' || $cache_size > 0)
    {
        ($num, $cache, $cache_size) = $self->read_dat(\$dat, $cache, $cache_size, $self->{'insize'});
        return $res if ($num == 257);
        if ($num == 256)
        {
             $self->{'indict'} = [@basedict];
             $self->{'insize'} = 9;
             $count = 258;
             undef $mode;
             next;
        }
        if (defined $mode)
        {
            $self->{'indict'}[$count] = $mode . substr($self->{'indict'}[$num], 0, 1);
            $count++;
        }
        $mode = $self->{'indict'}[$num];
        $res .= $mode;
        if ($count >= 4096)
        {
            $self->{'indict'} = [@basedict];
            $self->{'insize'} = 9;
        } elsif ($count == 511)
        { $self->{'insize'} = 10; }
        elsif ($count == 1023)
        { $self->{'insize'} = 11; }
        elsif ($count == 2047)
        { $self->{'insize'} = 12; }
    }
    return $res;
}

sub read_dat
{
    my ($self, $rdat, $cache, $size, $len) = @_;
    my ($res);

    while ($size < $len)
    {
        $cache = ($cache << 8) + unpack("C", $$rdat);
        substr($$rdat, 0, 1) = '';
        $size += 8;
    }

    $res = $cache >> ($size - $len);
    $cache &= (1 << ($size - $len)) - 1;
    $size -= $len;
    ($res, $cache, $size);
}

1;

