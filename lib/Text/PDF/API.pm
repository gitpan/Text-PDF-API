package Text::PDF::API;

$VERSION = "0.01_12_snapshot";

use Text::PDF::File;
use Text::PDF::Page;
use Text::PDF::Utils;
use Text::PDF::SFont;
use Text::PDF::TTFont;
use Text::PDF::TTFont0;

sub _getcurrent {
	my ($this,$parameter)=@_;
	return ($this->{'current'.uc($parameter)});
}

sub _setcurrent {
	my ($this,$parameter,$value)=@_;
	$this->{'current'.uc($parameter)}=$value;
}

sub _error {	# internal function
	my ($this,$f,$e)=@_;
	print STDERR sprintf("[".localtime()."] Text::PDF::API::%s(%x) : '%s'\n",$f,$this,$e);
}


sub new {
	my $class=shift(@_);
	my %defaults=@_;
	my $this={};
	bless($this);
	$this->{'PDF'} = Text::PDF::File->new;
	$this->{'isROOT'}=0;
	$this->{'PAGES'}=();
	$this->setDefault('Compression',1);
	$this->_setcurrent('PageContext',undef);
	foreach $parameter (keys(%defaults)) {
		if(grep(/$parameter/i,@Text::PDF::API::parameterlist)) {
			$this->{'default'.uc($parameter)}=$defaults{$parameter};
		} else {
			$this->_error('new',"illegal parameter ($parameter='".$defaults{$parameter}."')");
		}
	}
	$this->{'PDF'}->{'Version'} = $this->getDefault('PdfVersion',3);
	return $this;
}

sub end {
	my $this=shift(@_);
	undef($this);
}

sub saveas {
	my ($this,$file)=@_;
	$this->{'PDF'}->out_file($file);
}

@Text::PDF::API::parameterlist=qw(
	pagesize
	pagewidth
	pageheight
	compression
	pdfversion
);

sub getDefault {
	my ($this,$parameter,$default)=@_;
	if(grep(/$parameter/i,@Text::PDF::API::parameterlist)) {
		if(defined($this->{'default'.uc($parameter)})) {
			return ($this->{'default'.uc($parameter)});
		} elsif(defined($default)) {
			return ($default);
		} else {
			return undef;
		}
	} else {
		$this->_error('getDefault',"illegal parameter ($parameter)");
		return undef;
	}
}

sub setDefault {
	my ($this,$parameter,$value)=@_;
	if(grep(/$parameter/i,@Text::PDF::API::parameterlist)) {
		$this->{'default'.uc($parameter)}=$value;
	} else {
		$this->_error('setDefault',"illegal parameter ($parameter)");
	}
}


%Text::PDF::API::pagesizes=(
	'a0'		=>	[ 2380	, 3368	],
	'a1'		=>	[ 1684	, 2380	],
	'a2'		=>	[ 1190	, 1684	],
	'a3'		=>	[ 842	, 1190	],
	'a4'		=>	[ 595	, 842	],
	'a5'		=>	[ 421	, 595	],
	'a6'		=>	[ 297	, 421	],
	'letter'	=>	[ 612	, 792	],
	'broadsheet'	=>	[ 1296	, 1584	],
	'ledger'	=>	[ 1224	, 792	],
	'tabloid'	=>	[ 792	, 1224	],
	'legal'		=>	[ 612	, 1008	],
	'executive'	=>	[ 522	, 756	],
	'36x36'		=>	[ 2592	, 2592	],
);

sub newpage {
	my ($this,$width,$height)=@_;
	if(!$this->{'isROOT'}) {
		$this->_newroot();
	}
	if(!defined($this->_getcurrent('PageContext'))) {
		$this->{'PAGE'} = Text::PDF::Page->new($this->{'PDF'},$this->{'ROOT'});
		push(@{$this->{'PAGES'}},$this->{'PAGE'});
		$this->_setcurrent('PageContext',$#{$pdf->{'PAGES'}});
		if(defined($width) && !defined($height)) {
			($width,$height)=@{$Text::PDF::API::pagesizes{$width}};
		} elsif(!defined($width) && !defined($height)) {
			($width,$height)=$this->_getDefaultpageWH();
		} 
		$this->_setMediaBox(0,0,$width,$height);
	} else {
		$this->_error('newpage','called before endpage');
	}
}

sub _getDefaultpageWH {
	my ($this,$size,$w,$h)=@_;
	if($size=$this->getDefault('PageSize')) {
		return(@{$Text::PDF::API::pagesizes{$size}});
	} elsif(($w=$this->getDefault('PageWidth'))&&($h=$this->getDefault('PageHeight'))) {
		return($w,$h);
	} else {
		return(@{$Text::PDF::API::pagesizes{'a4'}});
	}
	
}

sub _setMediaBox {
	my ($this,$x,$y,$width,$height)=@_;
	if(defined($this->_getcurrent('PageContext'))) {
		$this->{'PAGE'}{'MediaBox'}=PDFArray(PDFNum($x),PDFNum($y),PDFNum($width),PDFNum($height));
	} else {
		$this->_error('_setMediaBox','no PageContext defined, skipping');
	}
}

sub _newroot {
	my ($this)=@_;
	if(!$this->{'isROOT'}) {
		$this->{'ROOT'} = Text::PDF::Pages->new($this->{'PDF'});
		$this->{'ROOT'}->proc_set("PDF");
		$this->{'isROOT'}=1;
	} else {
		$this->_error('_newroot','root pages object already created');
	}
}

sub endpage {
	my ($this)=@_;
	if(defined($this->_getcurrent('PageContext'))) {
		if($this->getDefault('compression')) {
			$this->{'PAGE'}->{' curstrm'}{'Filter'} = PDFArray(PDFName('FlateDecode'));
		}
	#	$this->{'PAGE'}->ship_out($this->{'PDF'});
	#	$this->{'PAGE'}->empty;
		$this->{'PAGE'}=undef;
		$this->_setcurrent('PageContext',undef);
	} else {
		$this->_error('endpage','endpage called before newpage');
	}
}

sub _addtopage {	# internal function
	my ($this,$data)=@_;
	if(defined($this->_getcurrent('PageContext'))) {
		$this->{'PAGE'}->add($data);
	} else {
		$this->_error('_addtopage','no PageContext defined, skipping');
	}
}

sub setFontDir {
	my ($this,$dir)=@_;
	my $lastfd=$this->{'FONTDIR'};
	$this->{'FONTDIR'}=$dir;
	return $lastfd;
}
sub getFontDir {
	my ($this,$dir)=@_;
	return $this->{'FONTDIR'};
}

sub addFontPath {
	my ($this,$dir)=@_;
	if(!$this->{'FONTPATH'}){ $this->{'FONTPATH'}=[];}
	push(@{$this->{'FONTPATH'}},$dir);
}

sub newTTFont0 {
	use Digest::MD5 qw( md5_hex );
	my ($this,$name,$file)=@_;
	my $fontfile=undef;
	my $fontkey;
	if( -e $this->{'FONTDIR'}.'/'.$file ) {
		$fontfile=$this->{'FONTDIR'}.'/'.$file;
	} elsif ( -e $file ) {
		$fontfile=$file;
	} else {
		foreach my $dir (@{$this->{'FONTPATH'}}) {
			if( -e $dir.'/'.$file ) {
				$fontfile=$dir.'/'.$file;
			}
		}
	}
	if($fontfile) {
		$fontkey=md5_hex($this.$fontfile);
		if(!$this->{'FONTS'}) { $this->{'FONTS'}={}; }
		if(!$this->{'FONTS'}->{$fontkey} || !$this->{'FONTS'}->{$name}) {
			$this->{'FONTS'}->{$fontkey}={};
			$this->{'FONTS'}->{$fontkey}->{'name'}=$name;
			$this->{'FONTS'}->{$fontkey}->{'key'}=$fontkey;
			$this->{'FONTS'}->{$fontkey}->{'type'}="TT0";
			$this->{'FONTS'}->{$name}={};
			$this->{'FONTS'}->{$name}->{'name'}=$name;
			$this->{'FONTS'}->{$name}->{'key'}=$fontkey;
			$this->{'FONTS'}->{$name}->{'type'}="TT0";
			$this->{'FONTS'}->{$fontkey}->{'pdfname'}="FTT00x0$fontkey";
			$this->{'FONTS'}->{$name}->{'pdfname'}="FTT00x0$fontkey";
			$this->{'FONTS'}->{$fontkey}->{'pdfobj'}=Text::PDF::TTFont0->new($this->{'PDF'}, $fontfile, "FTT00x0$fontkey");
			$this->{'FONTS'}->{$name}->{'pdfobj'}=$this->{'FONTS'}->{$fontkey}->{'pdfobj'};
			if(!$this->{'isROOT'}) {
				$this->_newroot();
			}
			$this->{'ROOT'}->add_font($this->{'FONTS'}->{$fontkey}->{'pdfobj'});
		} 
		return $fontkey;
	} else {
		$this->_error('newFont',"could not find font '$file'");
		return undef;
	}
}

sub newTTFont {
	use Digest::MD5 qw( md5_hex );
	my ($this,$name,$file)=@_;
	my ($fontfile,$fontkey,$ttf,$font,$glyph,@map);
	if( -e $this->{'FONTDIR'}.'/'.$file ) {
		$fontfile=$this->{'FONTDIR'}.'/'.$file;
	} elsif ( -e $file ) {
		$fontfile=$file;
	} else {
		foreach my $dir (@{$this->{'FONTPATH'}}) {
			if( -e $dir.'/'.$file ) {
				$fontfile=$dir.'/'.$file;
			}
		}
	}
	if($fontfile) {
		$fontkey=md5_hex($this.$fontfile);
		if(!$this->{'FONTS'}) { $this->{'FONTS'}={}; }
		if(!$this->{'FONTS'}->{$fontkey} || !$this->{'FONTS'}->{$name}) {
			$this->{'FONTS'}->{$fontkey}={};
			$this->{'FONTS'}->{$fontkey}->{'name'}=$name;
			$this->{'FONTS'}->{$fontkey}->{'key'}=$fontkey;
			$this->{'FONTS'}->{$fontkey}->{'type'}="TT";
			$this->{'FONTS'}->{$name}={};
			$this->{'FONTS'}->{$name}->{'name'}=$name;
			$this->{'FONTS'}->{$name}->{'key'}=$fontkey;
			$this->{'FONTS'}->{$name}->{'type'}="TT";
			$this->{'FONTS'}->{$fontkey}->{'pdfname'}="FTT0x0$fontkey";
			$this->{'FONTS'}->{$name}->{'pdfname'}="FTT0x0$fontkey";
			$this->{'FONTS'}->{$fontkey}->{'pdfobj'}=Text::PDF::TTFont->new($this->{'PDF'}, $fontfile, "FTT0x0$fontkey");
			$this->{'FONTS'}->{$name}->{'pdfobj'}=$this->{'FONTS'}->{$fontkey}->{'pdfobj'};
			$font=$this->{'FONTS'}->{$fontkey}->{'pdfobj'};
			$ttf=$font->{' font'};
			$ttf->{'cmap'}->read;
			$ttf->{'post'}->read;
			foreach my $x (0..255) {
				$glyph=$ttf->{'cmap'}->ms_lookup($x) || $ttf->{'post'}{'STRINGS'}{'space'} || $ttf->{'cmap'}->ms_lookup(32) || 1;
				if($ttf->{'post'}{'VAL'}[$glyph] EQ '.notdef') {
					$glyph=$ttf->{'post'}{'STRINGS'}{'space'} || $ttf->{'cmap'}->ms_lookup(32) || 1;
				}
				push(@map,$glyph);
			}
			$font->add_glyphs(0, \@map);
		#	$this->{'FONTS'}->{$fontkey}->{'pdfobj'}->add_glyphs( 0, [0 .. 65] );
		#	
		#	$font->{'cmap'}->read;
		#	$glyphid=$font->{'cmap'}->ms_lookup($unicode);
		#	

			if(!$this->{'isROOT'}) {
				$this->_newroot();
			}
			$this->{'ROOT'}->add_font($this->{'FONTS'}->{$fontkey}->{'pdfobj'});
		} 
		return $fontkey;
	} else {
		$this->_error('newFont',"could not find font '$file'");
		return undef;
	}
}

sub getFont {
	my ($this,$name)=@_;
	if($this->{'FONTS'}->{$name}->{'name'} EQ $name) {
		return $this->{'FONTS'}->{$name}->{'key'};
	} elsif($this->{'FONTS'}->{$name}->{'key'} EQ $name) {
		return $name;
	} else {
		return undef;
	}
}

sub _getFontpdfname {
	my ($this,$name)=@_;
	if($this->{'FONTS'}->{$name}) {
		return $this->{'FONTS'}->{$name}->{'pdfname'};
	} else {
		return undef;
	}
}

sub addCoreFont {
	use Digest::MD5 qw( md5_hex );
	my ($this,$name)=@_;

	$fontkey=md5_hex($this.$name);
	if(!$this->{'FONTS'}) { $this->{'FONTS'}={}; }
	if(!$this->{'FONTS'}->{$fontkey}) {
		$this->{'FONTS'}->{$fontkey}={};
		$this->{'FONTS'}->{$fontkey}->{'name'}=$name;
		$this->{'FONTS'}->{$fontkey}->{'pdfname'}="FCORE0x0$fontkey";
		$this->{'FONTS'}->{$fontkey}->{'pdfobj'}=Text::PDF::SFont->new($this->{'PDF'}, $name, "FCORE0x0$fontkey");
		$this->{'FONTS'}->{$fontkey}->{'key'}=$fontkey;
		$this->{'FONTS'}->{$name}={};
		$this->{'FONTS'}->{$name}->{'name'}=$name;
		$this->{'FONTS'}->{$name}->{'pdfname'}="FCORE0x0$fontkey";
		$this->{'FONTS'}->{$name}->{'pdfobj'}=$this->{'FONTS'}->{$fontkey}->{'pdfobj'};
		$this->{'FONTS'}->{$name}->{'key'}=$fontkey;
		if(!$this->{'isROOT'}) {
			$this->_newroot();
		}
		$this->{'ROOT'}->add_font($this->{'FONTS'}->{$fontkey}->{'pdfobj'});
	}
	return $fontkey;
}

sub addCoreFonts {
	my ($this,%f)=@_;
	foreach my $name (qw(	Courier Courier-Bold Courier-Oblique Courier-BoldOblique
				Times-Roman Times-Bold Times-Italic Times-BoldItalic
				Helvetica Helvetica-Bold Helvetica-Oblique Helvetica-BoldOblique
				Symbol ZapfDingbats )) {
		$f{$name}=$this->addCoreFont($name);
	}
	return(%f);
}

sub setFont {
	my ($this,$font)=@_;

}


1;

__END__

=pod

=head1 NAME

Text::PDF::API - a wrapper api for the Text::PDF::* modules of Martin Hosken.

=head1 SYNOPSIS

	use Text::PDF::API;

	$pdf = Text::PDF::API->new( %defaults );

	$pdf->end;

=head1 DESCRIPTION

=head2 Methods

=over 4

=item $pdf = Text::PDF::API->new [%defaults]

This creates a new pdf-object initializes it with the given defaults and returns it.
See the functions B<getDefault> and B<setDefault> for a list of supported parameters.

=item $pdf->saveas $file 

This saves the pdf-object to a file indicated by B<$file>.

=item $pdf->end

This destroys the pdf-object and frees its memory.

=item $pdf->getDefault $parameter 

This returns the pdf-object default indicated by B<$parameter>.

The current supported defaults are: 

	PageSize, valid values:
	'a0'		=>	[ 2380	, 3368	]
	'a1'		=>	[ 1684	, 2380	]
	'a2'		=>	[ 1190	, 1684	]
	'a3'		=>	[ 842	, 1190	]
	'a4'		=>	[ 595	, 842	]
	'a5'		=>	[ 421	, 595	]
	'a6'		=>	[ 297	, 421	]
	'letter'	=>	[ 612	, 792	]
	'broadsheet'	=>	[ 1296	, 1584	]
	'ledger'	=>	[ 1224	, 792	]
	'tabloid'	=>	[ 792	, 1224	]
	'legal'		=>	[ 612	, 1008	]
	'executive'	=>	[ 522	, 756	]
	'36x36'		=>	[ 2592	, 2592	]

	PageWidth, valid values:
	0 .. 32535 points (remember default = 72dpi)
		
	PageHeight, valid values:
	0 .. 32535 points (remember default = 72dpi)

	Compression
	0, 1 (= off, on)

	PDFVersion
	0 .. 3 (corresponding to the abode acrobat versions 1 .. 4)

=item $pdf->setDefault $parameter , $value

This sets the pdf-object defaults (see $pdf->getDefault for details).

=item $pdf->newpage  [ $width , $height ]  OR $pdf->newpage [ $size ] 

This creates a new page in the pdf-object and assigns it to the default page context.
If $width and $height are not given the funtion falls back to any given defaults
(PageSize then PageWidth+PageHeight) and as a last resort to 'A4'.

=item $pdf->endpage

This removes the current page context.

=item $pdf->getPageContext

This returns the current PageContext.

=item $pdf->setPageContext [ $context ] 

=cut
