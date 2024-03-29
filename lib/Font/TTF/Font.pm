package Font::TTF::Font;

=head1 NAME

Font::TTF::Font - Memory representation of a font

=head1 SYNOPSIS

Here is the regression test (you provide your own font). Run it once and then
again on the output of the first run. There should be no differences between
the outputs of the two runs.

    $f = Font::TTF::Font->open($ARGV[0]);

    # force a read of all the tables
    $f->tables_do(sub { $_[0]->read; });

    # force read of all glyphs (use read_dat to use lots of memory!)
    # $f->{'loca'}->glyphs_do(sub { $_[0]->read; });
    $f->{'loca'}->glyphs_do(sub { $_[0]->read_dat; });
    # NB. no need to $g->update since $f->{'glyf'}->out will do it for us

    $f->out($ARGV[1]);
    $f->release;                # IMPORTANT!

=head1 DESCRIPTION

A Truetype font consists of a header containing a directory of tables which
constitute the rest of the file. This class holds that header and directory and
also creates objects of the appropriate type for each table within the font.
Note that it does not read each table into memory, but creates a short reference
which can be read using the form:

    $f->{$tablename}->read;

Classes are included that support many of the different TrueType tables. For
those for which no special code exists, the table type C<table> is used, which
defaults to L<Font::TTF::Table>. The current tables which are supported are:

    table       Font::TTF::Table      - for unknown tables
    GDEF        Font::TTF::GDEF
    GPOS        Font::TTF::GPOS
    GSUB        Font::TTF::GSUB
    LTSH        Font::TTF::LTSH
    OS/2        Font::TTF::OS_2
    PCLT        Font::TTF::PCLT
    bsln        Font::TTF::Bsln
    cmap        Font::TTF::Cmap       - see also Font::TTF::OldCmap
    cvt         Font::TTF::Cvt_
    fdsc        Font::TTF::Fdsc
    feat        Font::TTF::Feat
    fmtx        Font::TTF::Fmtx
    fpgm        Font::TTF::Fpgm
    glyf        Font::TTF::Glyf       - see also Font::TTF::Glyph
    hdmx        Font::TTF::Hdmx
    head        Font::TTF::Head
    hhea        Font::TTF::Hhea
    hmtx        Font::TTF::Hmtx
    kern        Font::TTF::Kern       - see alternative Font::TTF::AATKern
    loca        Font::TTF::Loca
    maxp        Font::TTF::Maxp
    mort        Font::TTF::Mort       - see also Font::TTF::OldMort
    name        Font::TTF::Name
    post        Font::TTF::Post
    prep        Font::TTF::Prep
    prop        Font::TTF::Prop
    vhea        Font::TTF::Vhea
    vmtx        Font::TTF::Vmtx

=head1 INSTANCE VARIABLES

Instance variables begin with a space (and have lengths greater than the 4
characters which make up table names).

=over

=item nocsum

This is used during output to disable the creation of the file checksum in the
head table. For example, during DSIG table creation, this flag will be set to
ensure that the file checksum is left at zero.

=item fname (R)

Contains the filename of the font which this object was read from.

=item INFILE (P)

The file handle which reflects the source file for this font.

=item OFFSET (P)

Contains the offset from the beginning of the read file of this particular
font directory, thus providing support for TrueType Collections.

=back

=head1 METHODS

=cut

use IO::File;

use strict;
use vars qw(%tables $VERSION);
use Symbol();

require 5.004;

$VERSION = 0.22;    # MJPH      09-APR-2001     Ensure all of AAT stuff included
# $VERSION = 0.21;    # MJPH      23-MAR-2001     Improve Opentype support
# $VERSION = 0.20;    # MJPH      13-JAN-2001     Add XML output and some of XML input, AAT & OT tables
# $VERSION = 0.19;    # MJPH      29-SEP-2000     Add cmap::is_unicode, debug makefile.pl
# $VERSION = 0.18;    # MJPH      21-JUL-2000     Debug Utils::TTF_bininfo
# $VERSION = 0.17;    # MJPH      16-JUN-2000     Add utf8 support to names
# $VERSION = 0.16;    # MJPH      26-APR-2000     Mark read tables as read, tidy up POD
# $VERSION = 0.15;    # MJPH       5-FEB-2000     Ensure right versions released
# $VERSION = 0.14;    # MJPH      11-SEP-1999     Sort out Unixisms, agian!
# $VERSION = 0.13;    # MJPH       9-SEP-1999     Add empty, debug update_bbox
# $VERSION = 0.12;    # MJPH      22-JUL-1999     Add update_bbox
# $VERSION = 0.11;    # MJPH       7-JUL-1999     Don't store empties in cmaps
# $VERSION = 0.10;    # MJPH      21-JUN-1999     Use IO::File
# $VERSION = 0.09;    # MJPH       9-JUN-1999     Add 5.004 require, minor tweeks in cmap
# $VERSION = 0.08;    # MJPH      19-MAY-1999     Sort out line endings for Unix
# $VERSION = 0.07;    # MJPH      28-APR-1999     Get the regression tests to work
# $VERSION = 0.06;    # MJPH      26-APR-1999     Start to add to CVS, correct MANIFEST.SKIP
# $VERSION = 0.05;    # MJPH      13-APR-1999     See changes for 0.05
# $VERSION = 0.04;    # MJPH      13-MAR-1999     Tidy up Tarball
# $VERSION = 0.03;    # MJPH       9-MAR-1999     Move to Font::TTF for CPAN
# $VERSION = 0.02;    # MJPH      12-FEB-1999     Add support for ' nocsum' for DSIGS
# $VERSION = 0.0001;

%tables = (
        'table' => 'Font::TTF::Table',
        'GDEF' => 'Font::TTF::GDEF',
        'GPOS' => 'Font::TTF::GPOS',
        'GSUB' => 'Font::TTF::GSUB',
        'LTSH' => 'Font::TTF::LTSH',
        'OS/2' => 'Font::TTF::OS_2',
        'PCLT' => 'Font::TTF::PCLT',
        'bsln' => 'Font::TTF::Bsln',
        'cmap' => 'Font::TTF::Cmap',
        'cvt ' => 'Font::TTF::Cvt_',
        'fdsc' => 'Font::TTF::Fdsc',
        'feat' => 'Font::TTF::Feat',
        'fmtx' => 'Font::TTF::Fmtx',
        'fpgm' => 'Font::TTF::Fpgm',
        'glyf' => 'Font::TTF::Glyf',
        'hdmx' => 'Font::TTF::Hdmx',
        'head' => 'Font::TTF::Head',
        'hhea' => 'Font::TTF::Hhea',
        'hmtx' => 'Font::TTF::Hmtx',
        'kern' => 'Font::TTF::Kern',
        'loca' => 'Font::TTF::Loca',
        'maxp' => 'Font::TTF::Maxp',
        'mort' => 'Font::TTF::Mort',
        'name' => 'Font::TTF::Name',
        'post' => 'Font::TTF::Post',
        'prep' => 'Font::TTF::Prep',
        'prop' => 'Font::TTF::Prop',
        'vhea' => 'Font::TTF::Vhea',
        'vmtx' => 'Font::TTF::Vmtx',
        ##'CFF ' => 'Font::TTF::CFF_',
          );


=head2 Font::TTF::Font->AddTable($tablename, $class)

Adds the given class to be used when representing the given table name. It also
'requires' the class for you.

=cut

sub AddTable
{
    my ($class, $table, $useclass) = @_;

    $tables{$table} = $useclass;
#    $useclass =~ s|::|/|oig;
#    require "$useclass.pm";
}


=head2 Font::TTF::Font->Init

For those people who like making fonts without reading them. This subroutine
will require all the table code for the various table types for you. Not
needed if using Font::TTF::Font::read before using a table.

=cut

sub Init
{
    my ($class) = @_;
    my ($t);

    foreach $t (keys %tables)
    {
        $t =~ s|::|/|oig;
        require "$t.pm";
    }
}

=head2 Font::TTF::Font->new(%props)

Creates a new font object and initialises with the given properties. This is
primarily for use when a TTF is embedded somewhere. Notice that the properties
are automatically preceded by a space when inserted into the object. This is in
order that fields do not clash with tables.

=cut

sub new
{
    my ($class, %props) = @_;
    my ($self) = {};

    bless $self, $class;

    foreach (keys %props)
    { $self->{" $_"} = $props{$_}; }
    $self;
}


=head2 Font::TTF::Font->open($fname)

Reads the header and directory for the given font file and creates appropriate
objects for each table in the font.

=cut

sub open
{
    my ($class, $fname) = @_;
    my ($fh);
    my ($self) = {};
    
    unless (ref($fname))
    {
        $fh = IO::File->new($fname) or return undef;
        binmode $fh;
    } else
    { $fh = $fname; }

    $self->{' INFILE'} = $fh;
    $self->{' fname'} = $fname;
    $self->{' OFFSET'} = 0;
    bless $self, $class;
    
    $self->read;
}

=head2 $f->read

Reads a Truetype font directory starting from the current location in the file.
This has been separated from the C<open> function to allow support for embedded
TTFs for example in TTCs. Also reads the C<head> and C<maxp> tables immediately.

=cut

sub read
{
    my ($self) = @_;
    my ($fh) = $self->{' INFILE'};
    my ($dat, $i, $ver, $dir_num, $type, $name, $check, $off, $len, $t);

    $fh->seek($self->{' OFFSET'}, 0);
    $fh->read($dat, 12);
    ($ver, $dir_num) = unpack("Nn", $dat);
    $ver == 1 << 16 || $ver == 0x74727565 || $ver == 0x4f54544f or return undef;  # support Mac sfnts
    
    for ($i = 0; $i < $dir_num; $i++)
    {
        $fh->read($dat, 16) || die "Reading table entry";
        ($name, $check, $off, $len) = unpack("a4NNN", $dat);
        $self->{$name} = $self->{' PARENT'}->find($self, $name, $check, $off, $len) && next
                if (defined $self->{' PARENT'});
        $type = $tables{$name} || 'Font::TTF::Table';
        $t = $type;
        if ($^O eq "MacOS")
        { $t =~ s/^|::/:/oig; }
        else
        { $t =~ s|::|/|oig; }
        require "$t.pm";
        $self->{$name} = $type->new(PARENT  => $self,
                                    NAME    => $name,
                                    INFILE  => $fh,
                                    OFFSET  => $off,
                                    LENGTH  => $len,
                                    CSUM    => $check);
    }
    
    foreach $t ('head', 'maxp')
    { $self->{$t}->read if defined $self->{$t}; }

    $self;
}


=head2 $f->out($fname [, @tablelist])

Writes a TTF file consisting of the tables in tablelist. The list is checked to
ensure that only tables that exist are output. (This means that you can't have
non table information stored in the font object with key length of exactly 4)

In many cases the user simply wants to output all the tables in alphabetical order.
This can be done by not including a @tablelist, in which case the subroutine will
output all the defined tables in the font in alphabetical order.

Returns $f on success and undef on failure, including warnings.

All output files must include the C<head> table.

=cut

sub out
{
    my ($self, $fname, @tlist) = @_;
    my ($fh);
    my ($dat, $numTables, $sRange, $eSel);
    my (%dir, $k, $mloc, $count);
    my ($csum, $lsum, $msum, $loc, $oldloc, $len, $shift);

    unless (ref($fname))
    {
        $fh = IO::File->new("+>$fname") || return warn "Unable to open $fname";
        binmode $fh;
    } else
    { $fh = $fname; }
    
    $self->{' oname'} = $fname;
    $self->{' outfile'} = $fh;

    if ($self->{' wantsig'})
    {
        $self->{' nocsum'} = 1;
#        $self->{'head'}{'checkSumAdjustment'} = 0;
        $self->{' tempDSIG'} = $self->{'DSIG'};
        $self->{' tempcsum'} = $self->{'head'}{' CSUM'};
        delete $self->{'DSIG'};
        @tlist = sort {$self->{$a}{' OFFSET'} <=> $self->{$b}{' OFFSET'}}
            grep (length($_) == 4 && defined $self->{$_}, keys %$self) if ($#tlist < 0);
    }
    elsif ($#tlist < 0)
    { @tlist = sort keys %$self; }
    
    @tlist = grep(length($_) == 4 && defined $self->{$_}, @tlist);
    $numTables = $#tlist + 1;
    $numTables++ if ($self->{' wantsig'});
    
    ($numTables, $sRange, $eSel, $shift) = Font::TTF::Utils::TTF_bininfo($numTables, 16);
    $dat = pack("Nnnnn", 1 << 16, $numTables, $sRange, $eSel, $shift);
    $fh->print($dat);
    $msum = unpack("%32N*", $dat);

# reserve place holders for each directory entry
    foreach $k (@tlist)
    {
        $dir{$k} = pack("A4NNN", $k, 0, 0, 0);
        $fh->print($dir{$k});
    }

    $fh->print(pack('A4NNN', '', 0, 0, 0)) if ($self->{' wantsig'});

    $loc = $fh->tell();
    if ($loc & 3)
    {
        $fh->print(substr("\000" x 4, $loc & 3));
        $loc += 4 - ($loc & 3);
    }

    foreach $k (@tlist)
    {
        $oldloc = $loc;
        $self->{$k}->out($fh);
        $loc = $fh->tell();
        $len = $loc - $oldloc;
        if ($loc & 3)
        {
            $fh->print(substr("\000" x 4, $loc & 3));
            $loc += 4 - ($loc & 3);
        }
        $fh->seek($oldloc, 0);
        $csum = 0; $mloc = $loc;
        while ($mloc > $oldloc)
        {
            $count = ($mloc - $oldloc > 4096) ? 4096 : $mloc - $oldloc;
            $fh->read($dat, $count);
            $csum += unpack("%32N*", $dat);
# this line ensures $csum stays within 32 bit bounds, clipping as necessary
            if ($csum > 0xffffffff) { $csum -= 0xffffffff; $csum--; }
            $mloc -= $count;
        }
        $dir{$k} = pack("A4NNN", $k, $csum, $oldloc, $len);
        $msum += $csum + unpack("%32N*", $dir{$k});
        if ($msum > 0xffffffff) { $msum -= 0xffffffff; $msum--; }
        $fh->seek($loc, 0);
    }

    unless ($self->{' nocsum'})             # assuming we want a file checksum
    {
# Now we need to sort out the head table's checksum
        if (!defined $dir{'head'})
        {                                   # you have to have a head table
            $fh->close();
            return warn "No 'head' table to output in $fname";
        }
        ($csum, $loc, $len) = unpack("x4NNN", $dir{'head'});
        $fh->seek($loc + 8, 0);
        $fh->read($dat, 4);
        $lsum = unpack("N", $dat);
        if ($lsum != 0)
        {
            $csum -= $lsum;
            if ($csum < 0) { $csum += 0xffffffff; $csum++; }
            $msum -= $lsum * 2;                     # twice (in head and in csum)
            while ($msum < 0) { $msum += 0xffffffff; $msum++; }
        }
        $lsum = 0xB1B0AFBA - $msum;
        $fh->seek($loc + 8, 0);
        $fh->print(pack("N", $lsum));
        $dir{'head'} = pack("A4NNN", 'head', $csum, $loc, $len);
    } elsif ($self->{' wantsig'})
    {
        if (!defined $dir{'head'})
        {                                   # you have to have a head table
            $fh->close();
            return warn "No 'head' table to output in $fname";
        }
        ($csum, $loc, $len) = unpack("x4NNN", $dir{'head'});
        $fh->seek($loc + 8, 0);
        $fh->print(pack("N", 0));
#        $dir{'head'} = pack("A4NNN", 'head', $self->{' tempcsum'}, $loc, $len);
    }

# Now we can output the directory again
    if ($self->{' wantsig'})
    { @tlist = sort @tlist; }
    $fh->seek(12, 0);
    foreach $k (@tlist)
    { $fh->print($dir{$k}); }
    $fh->print(pack('A4NNN', '', 0, 0, 0)) if ($self->{' wantsig'});
    $fh->close();
    $self;
}


=head2 $f->out_xml($filename [, @tables])

Outputs the font in XML format

=cut

sub out_xml
{
    my ($self, $fname, @tlist) = @_;
    my ($fh, $context, $numTables, $k);

    $context->{'indent'} = ' ' x 4;

    unless (ref($fname))
    {
        $fh = IO::File->new("+>$fname") || return warn "Unable to open $fname";
        binmode $fh;
    } else
    { $fh = $fname; }

    unless (scalar @tlist > 0)
    {
        @tlist = sort keys %$self;
        @tlist = grep(length($_) == 4 && defined $self->{$_}, @tlist);
    }
    $numTables = $#tlist + 1;

    $context->{'fh'} = $fh;
    $fh->print("<?xml version='1.0' encoding='UTF-8'?>\n");
    $fh->print("<font tables='$numTables'>\n\n");
    
    foreach $k (@tlist)
    {
        $fh->print("<table name='$k'>\n");
        $self->{$k}->out_xml($context, $context->{'indent'});
        $fh->print("</table>\n");
    }

    $fh->print("</font>\n");
    $fh->close;
    $self;
}


=head2 $f->XML_start($context, $tag, %attrs)

Handles start messages from the XML parser. Of particular interest to us are <font> and
<table>.

=cut

sub XML_start
{
    my ($self, $context, $tag, %attrs) = @_;
    my ($name, $type, $t);

    if ($tag eq 'font')
    { $context->{'tree'}[-1] = $self; }
    elsif ($tag eq 'table')
    {
        $name = $attrs{'name'};
        unless (defined $self->{$name})
        {
            $type = $tables{$name} || 'Font::TTF::Table';
            $t = $type;
            if ($^O eq "MacOS")
            { $t =~ s/^|::/:/oig; }
            else
            { $t =~ s|::|/|oig; }
            require "$t.pm";
            $self->{$name} = $type->new('PARENT' => $self, 'NAME' => $name, 'read' => 1);
        }
        $context->{'receiver'} = ($context->{'tree'}[-1] = $self->{$name});
    }
    $context;
}


sub XML_end
{
    my ($self) = @_;
    my ($context, $tag, %attrs) = @_;
    my ($i);

    return undef unless ($tag eq 'table' && $attrs{'name'} eq 'loca');
    if (defined $context->{'glyphs'} && $context->{'glyphs'} ne $self->{'loca'}{'glyphs'})
    {
        for ($i = 0; $i <= $#{$context->{'glyphs'}}; $i++)
        { $self->{'loca'}{'glyphs'}[$i] = $context->{'glyphs'}[$i] if defined $context->{'glyphs'}[$i]; }
        $context->{'glyphs'} = $self->{'loca'}{'glyphs'};
    }
    return undef;
}

=head2 $f->update

Sends update to all the tables in the font and then resets all the isDirty
flags on each table. The data structure in now consistent as a font (we hope).

=cut

sub update
{
    my ($self) = @_;
    
    $self->tables_do(sub { $_[0]->update; });
    $self->tables_do(sub { $_[0]->{' isDirty'} = 0; });

    $self;
}


=head2 $f->tables_do(&func)

Calls &func for each table in the font. Calls the table in alphabetical sort
order as per the order in the directory:

    &func($table, $name);

=cut

sub tables_do
{
    my ($self, $func) = @_;
    my ($t);

    foreach $t (sort grep {length($_) == 4} keys %$self)
    { &$func($self->{$t}, $t); }
    $self;
}


=head2 $f->release

Releases ALL of the memory used by the TTF font and all of its component
objects.  After calling this method, do B<NOT> expect to have anything left in
the C<Font::TTF::Font> object.

B<NOTE>, that it is important that you call this method on any
C<Font::TTF::Font> object when you wish to destruct it and free up its memory.
Internally, we track things in a structure that can result in circular
references, and without calling 'C<release()>' these will not properly get
cleaned up by Perl.  Once you've called this method, though, don't expect to be
able to do anything else with the C<Font::TTF::Font> object; it'll have B<no>
internal state whatsoever.

B<Developer note:> As part of the brute-force cleanup done here, this method
will throw a warning message whenever unexpected key values are found within
the C<Font::TTF::Font> object.  This is done to help ensure that any unexpected
and unfreed values are brought to your attention so that you can bug us to keep
the module updated properly; otherwise the potential for memory leaks due to
dangling circular references will exist.

=cut

sub release
{
    my ($self) = @_;

    ###########################################################################
    # Go through our list of keys and clean things up as needed:
    # - All scalar values get deleted explicitly, to free up their memory.
    #   This is generally handled well by Perl, but our checks later on require
    #   that we free them up explicitly.
    # - All 'Font::TTF::*' elements get explicitly destructed, to free up all
    #   of their memory and break potential circular references.
    # - All 'IO::File' objects get silently destructed; we know there are a few
    #   and rather than name them all explicitly, we'll just clean them up here
    #   by type.
    ###########################################################################
    foreach my $key (keys %{$self})
    {
        my $ref = ref($self->{$key});
        if ($ref eq '')
        {
            # Remove scalar value.
            delete $self->{$key};
        }
        elsif ($ref =~ /^Font::TTF::/o)
        {
            # Sub-element, explicitly destruct.
            my $val = $self->{$key};
            delete $self->{$key};
            $val->release();
        }
        elsif ($ref eq 'IO::File')
        {
            # IO object, destruct silently.
            delete $self->{$key};
        }
    }

    ###########################################################################
    # Explicitly destruct anything that we _know_ about, and that wasn't caught
    # above.  We do this only so that when we do our checks below that we can
    # be sure that we've already freed up all of the memory.
    ###########################################################################

    ###########################################################################
    # Now that we think that we've gone back and freed up all of the memory
    # that we were using, check to make sure that we don't have any keys left
    # in our own hash (we shouldn't).  IF we do have keys left, throw a warning
    # message.
    ###########################################################################
    foreach my $key (keys %{$self})
    {
        warn ref($self) . " still has '$key' key left after release.\n";
    }

    ###########################################################################
    # All done cleaning up.
    ###########################################################################
}

1;

=head1 BUGS

Bugs abound aplenty I am sure. There is a lot of code here and plenty of scope.
The parts of the code which haven't been implemented yet are:

=over 4

=item Font::TTF::Post

Version 4 format types are not supported yet.

=item Font::TTF::Cmap

Format type 2 (MBCS) has not been implemented yet and therefore may cause
somewhat spurious results for this table type.

=item Font::TTF::Kern

Only type 0 & type 2 tables are supported (type 1 & type 3 yet to come).

=item Font::TTF::TTC

The current Font::TTF::Font::out method does not support the writing of TrueType
Collections.

=back

In addition there are weaknesses or features of this module library

=over 4

=item *

There is very little (or no) error reporting. This means that if you have
garbled data or garbled data structures, then you are liable to generate duff
fonts.

=item *

The exposing of the internal data structures everywhere means that doing
radical re-structuring is almost impossible. But it stop the code from becoming
ridiculously large.

=back

Apart from these, I try to keep the code in a state of "no known bugs", which
given the amount of testing this code has had, is not a guarantee of high
quality, yet.

For more details see the appropriate class files.

=head1 AUTHOR

Martin Hosken Martin_Hosken@sil.org

Copyright Martin Hosken 1998.

No warranty or expression of effectiveness, least of all regarding anyone's
safety, is implied in this software or documentation.

=head2 Licensing

The Perl TTF module is licensed under the Perl Artistic License.

