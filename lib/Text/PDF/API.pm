package Text::PDF::API;

$VERSION = "0.699_2";

use Text::PDF::File;
use Text::PDF::AFont;
use Text::PDF::Page;
use Text::PDF::Utils;
use Text::PDF::SFont;
use Text::PDF::TTFont;
use Text::PDF::TTFont0;
use Text::PDF::TTFont0;
use Text::PDF::API::UniMap;
@Text::PDF::API::parameterlist=qw(
	pagesize
	pagewidth
	pageheight
	pageorientation
	compression
	pdfversion
);

@Text::PDF::API::CORETYPEFONTS=qw(
	Courier		Courier-Bold	Courier-Oblique		Courier-BoldOblique
	Times-Roman	Times-Bold	Times-Italic		Times-BoldItalic
	Helvetica	Helvetica-Bold	Helvetica-Oblique	Helvetica-BoldOblique
);
@Text::PDF::API::CORESYMBOLFONTS=qw(
	Symbol
	ZapfDingbats
);
@Text::PDF::API::COREFONTS=(
	@Text::PDF::API::CORETYPEFONTS,
	@Text::PDF::API::CORESYMBOLFONTS
);


sub genKEY {
        my $key=join(',',@_);
	use Digest::REHLHA qw( rehlha0_16 );
	$key=rehlha0_16($key);
        return($key);
}

sub getDefault {
	my ($this,$parameter,$default)=@_;
	if(grep(/$parameter/i,@Text::PDF::API::parameterlist)) {
		if(defined($this->{'DEFAULT'}{lc($parameter)})) {
			return ($this->{'DEFAULT'}{lc($parameter)});
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
		$this->{'DEFAULT'}{lc($parameter)}=$value;
	} else {
		$this->_error('setDefault',"illegal parameter ($parameter)");
	}
}
sub _getCurrent {
	my ($this,$parameter)=@_;
	return ($this->{'CURRENT'}{lc($parameter)});
}

sub _setCurrent {
	my ($this,$parameter,$value)=@_;
	$this->{'CURRENT'}{lc($parameter)}=$value;
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
	$this->{'PAGES'}=();
	$this->{'DEFAULT'}=();
	$this->{'CURRENT'}=();
	$this->{'IMAGES'}=();
	$this->{'STACK'}=();
	$this->{'UNIMAPS'}={};
	$this->setDefault('Compression',1);
	$this->_setCurrent('PageContext',undef);
	$this->_setCurrent('Root',0);
	foreach $parameter (keys(%defaults)) {
		if(grep(/$parameter/i,@Text::PDF::API::parameterlist)) {
			$this->setDefault($parameter,$defaults{$parameter});
		} else {
			$this->_error('new',"illegal parameter ($parameter='".$defaults{$parameter}."')");
		}
	}
	$this->{'PDF'}->{' version'} = $this->getDefault('PdfVersion',3);
	return $this;
}

sub info {
	my $this=shift(@_);
	my $t=shift(@_);
	my $s=shift(@_);
	my $c=shift(@_);
	my $a=shift(@_);
	my $k=shift(@_);

	if(!defined($this->{'PDF'}->{'Info'})) {
        	$this->{'PDF'}->{'Info'}=PDFDict();
        	$this->{'PDF'}->new_obj($pdf->{'PDF'}->{'Info'});
	}
        $this->{'PDF'}->{'Info'}->{'Producer'}=PDFStr('perl with Text::PDF::API on '.localtime());
        $this->{'PDF'}->{'Info'}->{'Author'}  =PDFStr($a);
        $this->{'PDF'}->{'Info'}->{'Creator'} =PDFStr($c);
        $this->{'PDF'}->{'Info'}->{'Title'}   =PDFStr($t);
        $this->{'PDF'}->{'Info'}->{'Subject'} =PDFStr($s);
        $this->{'PDF'}->{'Info'}->{'Keywords'}=PDFStr($k);
}

sub end {
	my $this=shift(@_);
	undef($this);
}

sub saveas {
	my ($this,$file)=@_;
	$this->{'PDF'}->out_file($file);
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
	if(!$this->_getCurrent('Root',0)) {
		$this->_newroot();
	}
	if(!defined($this->_getCurrent('PageContext'))) {
		$this->{'PAGE'} = Text::PDF::Page->new($this->{'PDF'},$this->{'ROOT'});
		push(@{$this->{'PAGES'}},$this->{'PAGE'});
		$this->_setCurrent('PageContext',$#{$pdf->{'PAGES'}});
		if(defined($width) && !defined($height)) {
			if($this->getDefault('pageorientation')=~/^L/i) {
				($height,$width)=@{$Text::PDF::API::pagesizes{$width}};
			} else {
				($width,$height)=@{$Text::PDF::API::pagesizes{$width}};
			}
		} elsif(!defined($width) && !defined($height)) {
			if($this->getDefault('pageorientation')=~/^L/i) {
				($height,$width)=$this->_getDefaultpageWH();
			} else {
				($width,$height)=$this->_getDefaultpageWH();
			}
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
	if(defined($this->_getCurrent('PageContext'))) {
		$this->{'PAGE'}{'MediaBox'}=PDFArray(PDFNum($x),PDFNum($y),PDFNum($width),PDFNum($height));
	} else {
		$this->_error('_setMediaBox','no PageContext defined, skipping');
	}
}

sub _newroot {
	my ($this)=@_;
	if(!$this->_getCurrent('Root')) {
		$this->{'ROOT'} = Text::PDF::Pages->new($this->{'PDF'});
		$this->{'ROOT'}->proc_set(qw( PDF Text ImageB ImageC ImageI ));
		$this->_setCurrent('Root',1);
	} else {
		$this->_error('_newroot','root pages object already created');
	}
}

sub endpage {
	my ($this)=@_;
	if(defined($this->_getCurrent('PageContext'))) {
		if($this->getDefault('compression')==1) {
			$this->{'PAGE'}->{' curstrm'}{'Filter'} = PDFArray(PDFName('FlateDecode'));
		}
		$this->{'PAGE'}=undef;
		$this->_setCurrent('PageContext',undef);
	} else {
		$this->_error('endpage','endpage called before newpage');
	}
}

sub _addtopage {	# internal function
	my ($this,$data)=@_;
	if(defined($this->_getCurrent('PageContext'))) {
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

sub lookUPc2u {
	my ($this,$enc,$char)=@_;
	$enc=lc($enc);
	$enc=~s/[^a-z0-9\-]+//cgi;
	if(!$this->{'UNIMAPS'}->{$enc}){
		$this->{'UNIMAPS'}->{$enc}=Text::PDF::API::UniMap->new($enc);
	}
	return($this->{'UNIMAPS'}->{$enc}->c2u($char));
}

sub lookUPu2c {
	my ($this,$enc,$char)=@_;
	$enc=lc($enc);
	$enc=~s/[^a-z0-9\-]+//cgi;
	if(!$this->{'UNIMAPS'}->{$enc}){
		$this->{'UNIMAPS'}->{$enc}=Text::PDF::API::UniMap->new($enc);
	}
	return($this->{'UNIMAPS'}->{$enc}->u2c($char));
	
}

sub lookUPu2n {
	my ($this,$ucode)=@_;
	if(wantarray) {
		return ($u2n{$ucode}||'.notdef');
	} else {
		return $u2n{$ucode}||'.notdef';
	}
}

sub lookUPn2c {
	my ($this,$name)=@_;
}

sub lookUPc2n {
	my ($this,$enc,$char)=@_;
	$enc=lc($enc);
	$enc=~s/[^a-z0-9\-]+//cgi;
	if(!$this->{'UNIMAPS'}->{$enc}){
		$this->{'UNIMAPS'}->{$enc}=Text::PDF::API::UniMap->new($enc);
	}
	return($this->{'UNIMAPS'}->{$enc}->c2n($char));
}

sub resolveFontFile {
	my $this=shift @_;
	my $file=shift @_;
	my $fontfile=undef;
	if ( -e $file ) {
		$fontfile=$file;
		return $fontfile;
	} else {
		map {
			$fontfile="$_/$file";
			if(-e $fontfile) { return $fontfile; }
		} (
			'.',$this->{'FONTDIR'},@{$this->{'FONTPATH'}},
			map {
				glob("$_/Text/PDF/API/fonts"),
				glob("$_/Text/PDF/fonts"),
				glob("$_/Text/PDF/API/fonts/ttf"),
				glob("$_/Text/PDF/fonts/ttf"),
				glob("$_/Text/PDF/API/fonts/t1"),
				glob("$_/Text/PDF/fonts/t1"),
			} (@INC),
		# last resort looking for files in standard unix/windos locations
			qw( 
				c:/windows/fonts 
				c:/winnt/fonts 
			),
			map {
				glob($_)
			} qw(
				/usr/openwin/lib/locale/*/X11/fonts/TrueType
				/usr/openwin/lib/locale/*/X11/fonts/Type1
				/usr/openwin/lib/locale/*/X11/fonts/Type1/afm
				/usr/openwin/lib/X11/fonts/*/*
				/usr/openwin/lib/X11/fonts/*/*/afm
				/usr/openwin/lib/X11/fonts/*/afm
				/usr/openwin/lib/X11/fonts/*/outline
				/usr/openwin/lib/X11/fonts/*
				/usr/openwin/lib/X11/fonts/*/afm
				/usr/lpp/X11/lib/X11/fonts
				/usr/lpp/X11/lib/X11/fonts/*
				/usr/lib/ps
				/usr/local/share/*/afm
				/usr/local/share/*/fonts
				/usr/local/share/*/fonts/afm
				/usr/share/texmf/fonts/*/*/*
				/usr/share/*/fonts
				/usr/share/fonts/*
				/usr/share/fonts/default/*
				/usr/X11R6/lib/fonts/*
			)
		);
	}
	return undef;
}

sub newFontCore {
	my ($this,$name,$encoding,@glyphs)=@_;
	my ($fontkey,$font,$ug,$fontype,$fontname);

	$fontkey=genKEY($name);

	if(!$this->{'FONTS'}) {
		$this->{'FONTS'}={};
	}
	$encoding=$encoding||'';
	if(!$this->{'FONTS'}->{$fontkey}) {
		$this->{'FONTS'}->{$fontkey}={};
		$fontype='AC';
		$fontname=$fontype.'x'.$fontkey;
		if($encoding=~/encoding$/i) {
		} elsif($encoding eq 'latin1') {
		} elsif($encoding eq 'asis') {
		} elsif($encoding eq 'custom') {
		} elsif($encoding && Text::PDF::API::UniMap::isMap($encoding)) {
			$encoding=lc($encoding);
			$encoding=~s/[^a-z0-9\-]+//cgi;
			if(!$this->{'UNIMAPS'}->{$encoding}) {
				$this->{'UNIMAPS'}->{$encoding}=Text::PDF::API::UniMap->new($encoding);
			}
			@glyphs=$this->{'UNIMAPS'}->{$encoding}->glyphs();
			$encoding='WinAnsiEncoding';
		}

		$font=Text::PDF::AFont->newCore(
			$this->{'PDF'}, 
			$name, 
			$fontname,
			$encoding,
			@glyphs
		);
		$this->{'FONTS'}->{$fontkey}={
			'type'	=> $fontype,
			'pdfobj'=> $font,
			'PDFN'	=> $fontname,
		};
		if(!$this->_getCurrent('Root')) {
			$this->_newroot();
		}
		$this->{'ROOT'}->add_font($font);
	} else {
		$fontype=$this->{'FONTS'}->{$fontkey}->{'type'};
		$font=$this->{'FONTS'}->{$fontkey}->{'pdfobj'};
	} 

	return($fontname);
}

sub newFontTTF {
	my ($this,$name,$file,$encoding)=@_;
	my ($fontfile,$fontfile2,$fontkey,$ttf,$font,$glyph,$fontype,$fontname,@map);

	$fontkey=genKEY($name);

	if(!$this->{'FONTS'}) {
		$this->{'FONTS'}={};
	}
	if(Text::PDF::API::UniMap::isMap($encoding)) {
		$encoding=lc($encoding);
		$encoding=~s/[^a-z0-9\-]+//cgi;
		if(!$this->{'UNIMAPS'}->{$encoding}) {
			$this->{'UNIMAPS'}->{$encoding}=Text::PDF::API::UniMap->new($encoding);
		}
	}

	if(!$this->{'FONTS'}->{$fontkey}) {
		$this->{'FONTS'}->{$fontkey}={};
		$fontype='TT';
		$fontname=$fontype.'x'.$fontkey;
		$fontfile=$this->resolveFontFile($file);
		die "can not find requested font '$file'" unless($fontfile);
		if($^O eq "MacOS") {
			$this->{'FONTS'}->{$fontkey}->{'defaultencoding'}=$encoding||'MacRoman';
		} elsif($^O eq "MSWin32") {
			$this->{'FONTS'}->{$fontkey}->{'defaultencoding'}=$encoding||'WinLatin1';
		} else {
			$this->{'FONTS'}->{$fontkey}->{'defaultencoding'}=$encoding||'latin1';
		}
		$font=Text::PDF::TTFont0->new($this->{'PDF'}, $fontfile, $fontname);

		$this->{'FONTS'}->{$fontkey}={};
		$this->{'FONTS'}->{$fontkey}={
			'type'	=> $fontype,
			'pdfobj'=> $font,
			'PDFN'	=> $fontname,
		};
		if(!$this->_getCurrent('Root')) {
			$this->_newroot();
		}
		$this->{'ROOT'}->add_font($font);

		$ttf=$font->{' font'};
		$ttf->{'cmap'}->read;
		$ttf->{'hmtx'}->read;
		$ttf->{'post'}->read;
		my $upem = $ttf->{'head'}->read->{'unitsPerEm'};
		if(!$this->{'FONTS'}->{$fontkey}->{'u2g'}) {
			$this->{'FONTS'}->{$fontkey}->{'u2g'}=();
			$this->{'FONTS'}->{$fontkey}->{'u2w'}=();
			@map=$ttf->{'cmap'}->reverse;
			foreach my $x (0..scalar(@map)) {
				$this->{'FONTS'}->{$fontkey}->{'u2g'}{$map[$x]||0}=$x;
				$this->{'FONTS'}->{$fontkey}->{'u2w'}{$map[$x]||0}=$ttf->{'hmtx'}{'advance'}[$x]/$upem;
			}
		}
	}
	return($fontname); 
}

sub newFontT1reencode {
	my ($this,$fontkey,$fontype,$encoding,@glyphs)=@_;
	my ($newkey,$font,$fontname,$ug);

	$newkey=$encoding;
	$newkey=~s/[^a-z0-9\-]+//cgi;
	$newkey="$fontkey-$newkey";
	$this->{'FONTS'}->{$newkey}={};
	$fontname=$fontype.'x'.$newkey;

	if($encoding=~/encoding$/i) {
	} elsif($encoding eq 'latin1') {
	} elsif($encoding eq 'asis') {
	} elsif($encoding eq 'custom') {
	} elsif($encoding && Text::PDF::API::UniMap::isMap($encoding)) {
		$encoding=lc($encoding);
		$encoding=~s/[^a-z0-9\-]+//cgi;
		if(!$this->{'UNIMAPS'}->{$encoding}) {
			$this->{'UNIMAPS'}->{$encoding}=Text::PDF::API::UniMap->new($encoding);
		}
		@glyphs=$this->{'UNIMAPS'}->{$encoding}->glyphs();
		$encoding='WinAnsiEncoding';
	}

	$font=$this->{'FONTS'}->{$fontkey}->{'pdfobj'}->reencode(
		$this->{'PDF'},
		$fontname,
		$encoding,
		@glyphs
	);

	$this->{'FONTS'}->{$newkey}={
		'type'	=> $fontype,
		'pdfobj'=> $font,
		'PDFN'	=> $fontname,
	};

	if(!$this->_getCurrent('Root')) {
		$this->_newroot();
	}
	$this->{'ROOT'}->add_font($font);
	return($fontname); 
}

sub newFontPSreencode {
	my ($this,$fontkey,$encoding,@glyphs)=@_;

	return($this->newFontT1reencode($fontkey,'PS',$encoding,@glyphs));
}

sub newFontPS {
	my ($this,$name,$file,$file2,$encoding,@glyphs)=@_;
	my ($fontfile,$fontfile2,$fontkey,$ttf,$font,$ug,$fontype,$fontname,@map);

	$fontkey=genKEY($name);

	if(!$this->{'FONTS'}) {
		$this->{'FONTS'}={};
	}

	if(!$this->{'FONTS'}->{$fontkey}) {
		$this->{'FONTS'}->{$fontkey}={};
		$fontype='PS';
		$fontname=$fontype.'x'.$fontkey;
		$fontfile=$this->resolveFontFile($file) || die "can not find requested font '$file'";
		$fontfile2=$this->resolveFontFile($file2) || die "can not find requested font '$file2'";

		if($encoding=~/encoding$/i) {
		} elsif($encoding eq 'latin1') {
		} elsif($encoding eq 'asis') {
		} elsif($encoding eq 'custom') {
		} elsif($encoding && Text::PDF::API::UniMap::isMap($encoding)) {
			$encoding=lc($encoding);
			$encoding=~s/[^a-z0-9\-]+//cgi;
			if(!$this->{'UNIMAPS'}->{$encoding}) {
				$this->{'UNIMAPS'}->{$encoding}=Text::PDF::API::UniMap->new($encoding);
			}
			@glyphs=$this->{'UNIMAPS'}->{$encoding}->glyphs();
			$encoding='WinAnsiEncoding';
		}

		$font=Text::PDF::AFont->new(
			$this->{'PDF'}, 
			$fontfile, 
			$fontfile2, 
			$fontname,
			$encoding,
			@glyphs
		);

		$this->{'FONTS'}->{$fontkey}={
			'type'	=> $fontype,
			'pdfobj'=> $font,
			'PDFN'	=> $fontname,
		};

		if(!$this->_getCurrent('Root')) {
			$this->_newroot();
		}
		$this->{'ROOT'}->add_font($font);
	}
	return($fontname); 
}

sub newFont {
	my ($this,$name,$file,$file2,$encoding);
	my ($fontfile,$fontfile2,$fontkey,$ttf,$font,$glyph,$fontype,$fontname,@map);

	$this=shift @_;
	$name=shift @_;
	$fontkey=genKEY($name);

	if(!$this->{'FONTS'}) {
		$this->{'FONTS'}={};
	}

	if(!$this->{'FONTS'}->{$fontkey}) {
		if(grep(/$name/,@Text::PDF::API::COREFONTS)) {
			$encoding=shift @_;
			return $this->newFontCore($name,$encoding);
		} elsif($name=~/\,/) {
			$file=shift @_;
			$encoding=shift @_;
			return $this->newFontTTF($name,$file,$encoding);
		} else {
			$file=shift @_;
			$file2=shift @_;
			$encoding=shift @_;
			return $this->newFontPS($name,$file,$file2,$encoding);
		}
	} 

}

sub getFont {
	my ($this,$name)=@_;
	my $fontkey=genKEY($name);
	if($this->{'FONTS'}->{$fontkey}) {
		return $fontkey;
	} else {
		return undef;
	}
}

sub _getFontpdfname {
	my ($this,$name)=@_;
	my $fontkey=genKEY($name);
	if($this->{'FONTS'}->{$fontkey}) {
		return $this->{'FONTS'}->{$fontkey}->{'type'}.'x'.$fontkey;
	} else {
		return undef;
	}
}

sub addCoreFonts {
	my ($this,%f)=@_;
	foreach my $name (@Text::PDF::API::COREFONTS) {
		$f{$name}=$this->newFont($name);
	}
	return(%f);
}


sub initFontCurrent {
	my ($this)=@_;
	if(!defined($this->{'CURRENT'}{lc('Font')})) {
		$this->{'CURRENT'}{'font'}={
			'Matrix' => [1,0,0,1,0,0],
			'Size' => 1,
		};
	}
}

sub useFont {
	my ($this,$name,$size,$enc)=@_;
	my $fontkey=genKEY($name);
	my $cenc;
	if($enc) {
		$cenc=$enc;
		$cenc=~s/[^a-z0-9\-]+//cgi;
		$cenc="$fontkey-$cenc";
	} else {
		$cenc=$fontkey;
	}
	
	if(
		($fontkey ne $cenc) &&
		(($this->{'FONTS'}->{$fontkey}{'type'} eq 'PS') || ($this->{'FONTS'}->{$fontkey}{'type'} eq 'AC'))
	) {
		if( !$this->{'FONTS'}->{$cenc} ) {
			$this->newFontT1reencode($fontkey,$this->{'FONTS'}->{$fontkey}{'type'},$enc);
		}
		$fontkey=$cenc;
	}
	$this->initFontCurrent;
	$this->{'CURRENT'}{'font'}{'Name'}=$name;
	$this->{'CURRENT'}{'font'}{'Key'}=$fontkey;
	$this->{'CURRENT'}{'font'}{'PDFN'}=$this->{'FONTS'}->{$fontkey}{'PDFN'};
	$this->{'CURRENT'}{'font'}{'Size'}=$size;
	$this->{'CURRENT'}{'font'}{'Type'}=$this->{'FONTS'}->{$fontkey}{'type'};
	$this->{'CURRENT'}{'font'}{'Encoding'}=$enc || 'latin1';
	return($this->{'CURRENT'}{'font'}{'PDFN'});
}

sub setFontTranslate {
	use Text::PDF::API::Matrix;
	my ($this,$x,$y)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixTranslate'}) {
		$this->{'CURRENT'}{'font'}{'MatrixTranslate'}=Text::PDF::API::Matrix->new(
			[ 1, 0, 0],
			[ 0, 1, 0],
			[$x,$y, 1]
		);
	} else {
		$this->{'CURRENT'}{'font'}{'MatrixTranslate'}->[2][0]=$x;
		$this->{'CURRENT'}{'font'}{'MatrixTranslate'}->[2][1]=$y;
	}
}

sub setFontScale {
	use Text::PDF::API::Matrix;
	my ($this,$x,$y)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixScale'}) {
		$this->{'CURRENT'}{'font'}{'MatrixScale'}=Text::PDF::API::Matrix->new(
			[$x, 0, 0],
			[ 0,$y, 0],
			[ 0, 0, 1]
		);
	} else {
		$this->{'CURRENT'}{'font'}{'MatrixScale'}->[0][0]=$x;
		$this->{'CURRENT'}{'font'}{'MatrixScale'}->[1][1]=$y;
	}
}

sub setFontSkew {
	use Text::PDF::API::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixSkew'}) {
		$this->{'CURRENT'}{'font'}{'MatrixSkew'}=Text::PDF::API::Matrix->new(
			[                1, tan(deg2rad($a)), 0],
			[ tan(deg2rad($b)),                1, 0],
			[                0,                0, 1]
		);
	} else {
		$this->{'CURRENT'}{'font'}{'MatrixSkew'}->[0][0]=tan(deg2rad($a));
		$this->{'CURRENT'}{'font'}{'MatrixSkew'}->[1][1]=tan(deg2rad($b));
	}
}

sub setFontRotation {
	use Text::PDF::API::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixRotation'}) {
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}=Text::PDF::API::Matrix->new(
			[ cos(deg2rad($a)), sin(deg2rad($a)), 0],
			[-sin(deg2rad($a)), cos(deg2rad($a)), 0],
			[                0,                0, 1]
		);
	} else {
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}->[0][0]=cos(deg2rad($a));
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}->[0][1]=-sin(deg2rad($a));
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}->[1][0]=sin(deg2rad($a));
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}->[1][1]=cos(deg2rad($a));
	}
}

sub clearFontMatrix {
	my ($this)=@_;
	$this->initFontCurrent;
	foreach my $mx (qw( MatrixTranslate MatrixRotation MatrixScale MatrixSkew 
				CharSpacing WordSpacing TextLeading TextRise TextRendering )) {
		delete($this->{'CURRENT'}{'font'}{$mx});
	}
}

sub calcFontMatrix {
	use Text::PDF::API::Matrix;
	my ($this)=@_;
	my $tm=Text::PDF::API::Matrix->new([1,0,0],[0,1,0],[0,0,1]);
	$this->initFontCurrent;
	foreach my $mx (qw( MatrixSkew MatrixScale MatrixRotation MatrixTranslate )) {
		if(defined($this->{'CURRENT'}{'font'}{$mx})) {
			$tm=$tm->multiply($this->{'CURRENT'}{'font'}{$mx});
		}
	}
	$this->{'CURRENT'}{'font'}{'Matrix'}->[0]=$tm->[0][0];
	$this->{'CURRENT'}{'font'}{'Matrix'}->[1]=$tm->[0][1];
	$this->{'CURRENT'}{'font'}{'Matrix'}->[2]=$tm->[1][0];
	$this->{'CURRENT'}{'font'}{'Matrix'}->[3]=$tm->[1][1];
	$this->{'CURRENT'}{'font'}{'Matrix'}->[4]=$tm->[2][0];
	$this->{'CURRENT'}{'font'}{'Matrix'}->[5]=$tm->[2][1];
}

sub setFontMatrix {
	my ($this,$tm0,$tm1,$tm2,$tm3,$tm4,$tm5)=@_;
	$this->initFontCurrent;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[0]=$tm0;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[1]=$tm1;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[2]=$tm2;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[3]=$tm3;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[4]=$tm4;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[5]=$tm5;
}

sub getFontMatrix {
	my ($this)=@_;
	$this->initFontCurrent;
	return (
		$this->{'CURRENT'}{'font'}{'Matrix'}->[0],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[1],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[2],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[3],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[4],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[5]
	);
}

sub calcTextWidthFSET {
        my ($this,$name,$size,$enc,$text)=@_;
        my $fontkey=genKEY($name);
        my $cenc;
        if($enc) {
                $cenc=$enc;
                $cenc=~s/[^a-z0-9\-]+//cgi;
                $cenc="$fontkey-$cenc";
        } else {
                $cenc=$fontkey;
        }

        if(
                ($fontkey ne $cenc) &&
                (($this->{'FONTS'}->{$fontkey}{'type'} eq 'PS') || ($this->{'FONTS'}->{$fontkey}{'type'} eq 'AC'))
        ) {
                if( !$this->{'FONTS'}->{$cenc} ) {
                        $this->newFontT1reencode($fontkey,$this->{'FONTS'}->{$fontkey}{'type'},$enc);
                }
                $fontkey=$cenc;
        }
	my $font=$this->{'FONTS'}{$fontkey}{'pdfobj'};
	my $type=$this->{'FONTS'}{$fontkey}{'type'};
        my $wm=0;


        if($type eq 'AC') {
                foreach my $c (split(//,$text)) {
                        $wm+=$font->{' AFM'}{'wx'}{$font->{' AFM'}{'char'}[ord($c)]}*$size/1000;
                }
        } elsif($type eq 'PS') {
                foreach my $c (split(//,$text)) {
                        $wm+=$font->{' AFM'}{'wx'}{$font->{' AFM'}{'char'}[ord($c)]}*$size/1000;
                }
        } elsif($type eq 'TT') {
                foreach my $c (split(//,$text)) {
                        $wm+=$this->{'FONTS'}{$k}{"u2w"}{$this->lookUPc2u($enc,ord($c))}*$size;
                }
        }
        return $wm;
}

sub calcTextWidth {
	my ($this,$text)=@_;

	my $k=$this->{'CURRENT'}{'font'}{'Key'};
	my $size=$this->{'CURRENT'}{'font'}{'Size'};
	my $enc=$this->{'CURRENT'}{'font'}{'Encoding'};
	my $font=$this->{'FONTS'}{$k}{'pdfobj'};
	my $type=$this->{'FONTS'}{$k}{'type'};
	my $wm=0;

	$this->calcFontMatrix;

	if($type eq 'AC') {
		#$wm=$font->width($text)*$size;
		foreach my $c (split(//,$text)) {
			$wm+=$font->{' AFM'}{'wx'}{$font->{' AFM'}{'char'}[ord($c)]}*$size/1000;
		}
	} elsif($type eq 'PS') {
		foreach my $c (split(//,$text)) {
			$wm+=$font->{' AFM'}{'wx'}{$font->{' AFM'}{'char'}[ord($c)]}*$size/1000;
		}
	} elsif($type eq 'TT') {
		foreach my $c (split(//,$text)) {
			$wm+=$this->{'FONTS'}{$k}{"u2w"}{$this->lookUPc2u($enc,ord($c))}*$size;
		}
	}
	return $wm;
}
sub setCharSpacing  {
	my $this = shift @_;
	$this->{'CURRENT'}{'font'}{'CharSpacing'} = shift @_;
}
sub setWordSpacing  {
	my $this = shift @_;
	$this->{'CURRENT'}{'font'}{'WordSpacing'} = shift @_;
}
sub setTextLeading  {
	my $this = shift @_;
	$this->{'CURRENT'}{'font'}{'TextLeading'} = shift @_;
}
sub setTextRise  {
	my $this = shift @_;
	$this->{'CURRENT'}{'font'}{'TextRise'} = shift @_;
}
sub setTextRendering  {
	my $this = shift @_;
	$this->{'CURRENT'}{'font'}{'TextRendering'} = shift @_;
}

sub beginText {
	my ($this)=@_;
	$this->_addtopage(" BT \n");
}
sub charSpacing  {
	my $this = shift @_;
	my $cs=(shift @_)||$this->{'CURRENT'}{'font'}{'CharSpacing'}||0;
	$this->_addtopage(sprintf(" %.9f Tc \n",$cs));
}
sub wordSpacing  {
	my $this = shift @_;
	my $ws=(shift @_) || $this->{'CURRENT'}{'font'}{'WordSpacing'} || 0;
	$this->_addtopage(sprintf(" %.9f Tw \n",$ws));
}
sub textLeading  {
	my $this = shift @_;
	my $tl=(shift @_) || $this->{'CURRENT'}{'font'}{'TextLeading'} || 0;
	$this->_addtopage(sprintf(" %.9f TL \n",$tl));
	return $tl;
}
sub textRise  {
	my $this = shift @_;
	my $tr=(shift @_) || $this->{'CURRENT'}{'font'}{'TextRise'} || 0;
	$this->_addtopage(sprintf(" %.9f Ts \n",$tr));
}
sub textRendering {
	my $this = shift @_;
	my $tr=(shift @_) || $this->{'CURRENT'}{'font'}{'TextRendering'} || 0;
	$this->_addtopage(sprintf(" %i Tr \n",$tr));
}
sub textMatrix {
	my $this = shift @_;
	my @tm=@_;
	if(!@tm) {
		@tm=@{$this->{'CURRENT'}{'font'}{'Matrix'}};
	}
	$this->_addtopage(sprintf(" %.9f %.9f %.9f %.9f %.9f %.9f Tm \n",@tm));
}
sub textPos {
	my $this = shift @_;
	my ($x,$y)=@_;
	my @tm=@{$this->{'CURRENT'}{'font'}{'Matrix'}};
	$tm[4]=$x;
	$tm[5]=$y;
	$this->textMatrix(@tm);
}
sub textFont {
	my $this = shift @_;
	my $font;
	my($name,$size,$enc)=@_;
	if(scalar @_ != 0) {
       		my $fontkey=genKEY($name);
		my $cenc;
		if($enc) {
			$cenc=$enc;
			$cenc=~s/[^a-z0-9\-]+//cgi;
			$cenc="$fontkey-$cenc";
		} else {
			$cenc=$fontkey;
		}
		if($this->{'FONTS'}->{$cenc}) {
			$fontkey=$cenc;
		}
                $font=$this->{'FONTS'}->{$fontkey}->{'PDFN'};
	}
	$this->initFontCurrent;
	$font||=$this->{'CURRENT'}{'font'}{'PDFN'};
	$size||=$this->{'CURRENT'}{'font'}{'Size'};
	$this->_addtopage(sprintf(" /%s %.9f Tf \n",$font,$size));
}
sub textNewLine {
	my $this = shift @_;
	my $l;
	if($l=shift @_) {
		$this->_addtopage(sprintf(" 0 %.9f Td \n",$l));
	} else {
		$this->_addtopage(" T* \n");
	}
}
sub textAdd {
	my ($this,$text)=@_;
	$this->initFontCurrent;
	my $k=$this->{'CURRENT'}{'font'}{'Key'};
	my $enc=$this->{'CURRENT'}{'font'}{'Encoding'};
	$this->_addtopage(" <");
	foreach my $c (split(//,$text)) {
		if($this->{'CURRENT'}{'font'}{'Type'} eq 'AC') {
			$this->_addtopage(sprintf('%02x',unpack('C',$c)));
		} elsif($this->{'CURRENT'}{'font'}{'Type'} eq 'PS') {
			$this->_addtopage(sprintf('%02x',unpack('C',$c)));
		} else {
			$this->_addtopage(sprintf('%04x',$this->{'FONTS'}{$k}{"u2g"}{$this->lookUPc2u($enc,ord($c))}));
		}
	}
	$this->_addtopage("> Tj \n");
}
sub endText {
	my ($this)=@_;
	$this->_addtopage(" ET \n");
}

sub paragraphFit {
        use POSIX qw( floor );
        my ($this)=shift @_;
        my ($font)=shift @_;
        my ($encoding)=shift @_;
        my ($leadingfactor)=shift @_;
        my ($width)=shift @_;
        my ($height)=shift @_;
        my ($text)=shift @_;
        my ($fudge)=shift @_ || 0.95;
	my @paras=split(/\n/,$text);
	my $paragraphs=scalar(@paras);
        my $text_width=$this->calcTextWidthFSET($font,10,$encoding,$text)/10;
        my $size=((($width*$height)-($leadingfactor*$paragraphs))/($leadingfactor*$text_width))**0.5;
        if(($width/$size)<20) {
                $fudge*=$fudge;
        }
        if(($width/$size)<10) {
                $fudge*=$fudge;
        }
        #       if(($width/$size)<5) {
        #               $fudge*=$fudge;
        #       }
        $size*=$fudge;
        $size=floor($size*$width)/$width;
        return($size,$fudge);
}

sub paragraphFit2 {
	my ($this)=shift @_;
        my ($font)=shift @_;
        my ($encoding)=shift @_;
        my ($leadingfactor)=shift @_;
        my ($width)=shift @_;
        my ($height)=shift @_;
        my ($text)=shift @_;
	my ($mindelta)=shift @_ || 0.01 ;
	my ($maxiterations)=shift @_ || 10;
	my $fontsize=shift @_;
	($fontsize)=$this->paragraphFit($font,$encoding,$leadingfactor,$width,$height,$text,1-$mindelta) if(!defined($fontsize));
	my $fontsizelast;
	do {
		$fontsizelast=$fontsize;
		$maxiterations--;
		my @paras=split(/\n/,$text);
		my ($para, $line, @words, $word, $lastwidth);
		$line=$fontsize*$leadingfactor*(scalar @paras - 1);
		while(defined($para=shift @paras)) {
			$lastwidth=0;
			@words=split(/\s+/,$para);
			my @wline;
			while(0 < scalar @words){
				if($this->calcTextWidthFSET($font,$fontsize,$encoding,join(' ',@wline,$words[0]) < $width)){
					push(@wline,shift @words);
					$lastwidth=$this->calcTextWidthFSET($font,$fontsize,$encoding,join(' ',@wline));
				} elsif($this->calcTextWidthFSET($font,$fontsize,$encoding,$words[0]) > $width){
					@wline=();
					$line+=$fontsize*$leadingfactor;
					$lastwidth=0;
				} else {
					@wline=();
					$line+=$fontsize*$leadingfactor;
					$lastwidth=0;
				}
			}
		}
		my $area=($line*$width)+($lastwidth*$fontsize*$leadingfactor);
		$fontsize=$fontsizelast*($width*$height/($area*$leadingfactor))**0.5;
		## $fontsize=$fontsizelast*($width*$height/($area))**0.5;
		## print STDERR "this=$fontsize, last=$fontsizelast\n";
	} while ( (abs(1-($fontsize/$fontsizelast))>$mindelta) && ($maxiterations>0) );
	return($fontsize,abs(1-($fontsize/$fontsizelast)),$maxiterations);
}

sub textParagraph {
	my ($this,$x,$y,$w,$h,$text,$block)=@_;
	if(!$text) {return($x,$y);}
	$this->beginText;
	my $tl=$this->textLeading;
	$h-=($tl/2);
	$this->textFont;
	$this->textPos($x,$y);
	my @paras=split(/\n/,$text);
	my $para;
	my $line=0;
	my $word;
	my $hor=0;
	while(defined($para=shift @paras)) {
		@words=split(/\s+/,$para);
		$hor=0;
		my @wline;
		while(( 0 < scalar @words ) && ( $h > $line )){
			if($this->calcTextWidth(join(' ',@wline,$words[0])) < $w) {
				push(@wline,shift @words);
			} elsif($this->calcTextWidth($words[0]) > $w) {
				push(@wline,shift @words);
				$this->textAdd(join(' ',@wline));
				@wline=();
				$this->textNewLine;	$line+=$this->{'CURRENT'}{'font'}{'TextLeading'};
				$hor=0;
			} else {
				if($block) {
					$this->wordSpacing(($w-$this->calcTextWidth(join(' ',@wline)))/((scalar @wline - 1)?(scalar @wline - 1):1));
				}	
				$this->textAdd(join(' ',@wline));
				@wline=();
				$this->textNewLine;	$line+=$this->{'CURRENT'}{'font'}{'TextLeading'};
				$hor=0;
			}
			if(( 0 == scalar @words ) && ( $h > $line ) && ( scalar @wline )){
				if($block) {
					$this->wordSpacing(0);
				}	
				$this->textAdd(join(' ',@wline));
				$hor=$this->calcTextWidth(join(' ',@wline));
			} elsif (( $h < $line ) && ( scalar @wline )) {
				unshift(@words,@wline);
			}
		}
		if($line>$h){last;}
		$this->textNewLine;	$line+=$this->{'CURRENT'}{'font'}{'TextLeading'};
	}
	$this->endText;
	return($x+$hor,$y-$line,join("\n",join(' ',@words),@paras));
}

sub showText {
	my ($this,$text)=@_;
	$this->initFontCurrent;
	my $k=$this->{'CURRENT'}{'font'}{'Key'};
	my $enc=$this->{'CURRENT'}{'font'}{'Encoding'};
	
	$this->beginText();
	$this->textFont();
	$this->charSpacing();
	$this->wordSpacing();
	$this->textLeading();
	$this->textRise;
	$this->textRendering;
	$this->textMatrix;
	$this->textAdd($text);
	$this->endText();
}

sub showTextXY {
	my ($this,$x,$y,$text)=@_;
	my ($nx,$ny);
	$this->initFontCurrent;
	$this->calcFontMatrix;
	($nx,$ny)=(
		$this->{'CURRENT'}{'font'}{'Matrix'}->[4],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[5]
	);
	$this->setFontMatrix(
		$this->{'CURRENT'}{'font'}{'Matrix'}->[0],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[1],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[2],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[3],
		$x,$y
	);

	$this->showText($text);

	$this->setFontMatrix(
		$this->{'CURRENT'}{'font'}{'Matrix'}->[0],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[1],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[2],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[3],
		$nx,$ny
	);
}

sub showTextXY_R {
	my ($this,$x,$y,$text)=@_;
	$x-=$this->calcTextWidth($text);
	$this->showTextXY($x,$y,$text);
}

sub showTextXY_C {
	my ($this,$x,$y,$text)=@_;
	$x-=($this->calcTextWidth($text)/2);
	$this->showTextXY($x,$y,$text);
}

sub printText {
	my ($this,$x,$y,$font,$size,$encoding,$text)=@_;
	$this->useFont($font,$size,$encoding);
	$this->showTextXY($x,$y,$text);
}

sub initGfxCurrent {
	my ($this)=@_;
	if(!defined($this->{'CURRENT'}{'gfx'})) {
		$this->{'CURRENT'}{'gfx'}={
			'Matrix' => [1,0,0,1,0,0],
		};
	}
}

sub setGfxTranslate {
	use Text::PDF::API::Matrix;
	my ($this,$x,$y)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixTranslate'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixTranslate'}=Text::PDF::API::Matrix->new(
			[ 1, 0, 0],
			[ 0, 1, 0],
			[$x,$y, 1]
		);
	} else {
		$this->{'CURRENT'}{'gfx'}{'MatrixTranslate'}->[2][0]=$x;
		$this->{'CURRENT'}{'gfx'}{'MatrixTranslate'}->[2][1]=$y;
	}
}

sub setGfxScale {
	use Text::PDF::API::Matrix;
	my ($this,$x,$y)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixScale'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixScale'}=Text::PDF::API::Matrix->new(
			[$x, 0, 0],
			[ 0,$y, 0],
			[ 0, 0, 1]
		);
	} else {
		$this->{'CURRENT'}{'gfx'}{'MatrixScale'}->[0][0]=$x;
		$this->{'CURRENT'}{'gfx'}{'MatrixScale'}->[1][1]=$y;
	}
}

sub setGfxSkew {
	use Text::PDF::API::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixSkew'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixSkew'}=Text::PDF::API::Matrix->new(
			[                1, tan(deg2rad($a)), 0],
			[ tan(deg2rad($b)),                1, 0],
			[                0,                0, 1]
		);
	} else {
		$this->{'CURRENT'}{'gfx'}{'MatrixSkew'}->[0][0]=tan(deg2rad($a));
		$this->{'CURRENT'}{'gfx'}{'MatrixSkew'}->[1][1]=tan(deg2rad($b));
	}
}

sub setGfxRotation {
	use Text::PDF::API::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixRotation'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixRotation'}=Text::PDF::API::Matrix->new(
			[ cos(deg2rad($a)), sin(deg2rad($a)), 0],
			[-sin(deg2rad($a)), cos(deg2rad($a)), 0],
			[                0,                0, 1]
		);
	} else {
		@{$this->{'CURRENT'}{'gfx'}{'MatrixRotation'}->[0]}=(cos(deg2rad($a)),-sin(deg2rad($a)),0);
		@{$this->{'CURRENT'}{'gfx'}{'MatrixRotation'}->[1]}=(sin(deg2rad($a)),cos(deg2rad($a)),0);
	}
}

sub clearGfxMatrix {
	my ($this)=@_;
	$this->initGfxCurrent;
	foreach my $mx (qw( MatrixTranslate MatrixRotation MatrixScale MatrixSkew )) {
		delete($this->{'CURRENT'}{'gfx'}{$mx});
	}
}

sub calcGfxMatrix {
	use Text::PDF::API::Matrix;
	my ($this)=@_;
	my $tm=Text::PDF::API::Matrix->new(
		[1,0,0],
		[0,1,0],
		[0,0,1]
	);
	$this->initGfxCurrent;
	foreach my $mx (qw( MatrixSkew MatrixScale MatrixRotation MatrixTranslate )) {
		if(defined($this->{'CURRENT'}{'gfx'}{$mx})) {
			$tm=$tm->multiply($this->{'CURRENT'}{'gfx'}{$mx});
		}
	}
	@{$this->{'CURRENT'}{'gfx'}{'Matrix'}}=(
		$tm->[0][0],$tm->[0][1],
		$tm->[1][0],$tm->[1][1],
		$tm->[2][0],$tm->[2][1]
	);
	return(@{$this->{'CURRENT'}{'gfx'}{'Matrix'}});
}

sub setGfxMatrix {
	my ($this,@tm)=@_;
	$this->initGfxCurrent;
	@{$this->{'CURRENT'}{'gfx'}{'Matrix'}}=@tm;
	return(@{$this->{'CURRENT'}{'gfx'}{'Matrix'}});
}

sub getGfxMatrix {
	my ($this)=@_;
	$this->initGfxCurrent;
	return(@{$this->{'CURRENT'}{'gfx'}{'Matrix'}});
}


sub useGfxState {
	my ($this)=@_;

	$this->initGfxCurrent;
	my @tm=@{$this->{'CURRENT'}{'gfx'}{'Matrix'}};

	$this->_addtopage(sprintf("%0.6f %0.6f %0.6f %0.6f %0.6f %0.6f cm\n",@tm));
}

sub savePdfState {
	my ($this)=@_;
	$this->_addtopage("q\n");
}

sub restorePdfState {
	my ($this)=@_;
	$this->_addtopage("Q\n");
}

sub saveState {
	my ($this)=@_;
	use Data::Dumper;
	push(@{$this->{'STACK'}},Dumper($this->{'CURRENT'}));
	$this->savePdfState;
}

sub restoreState {
	my ($this)=@_;
	my $cr=pop(@{$this->{'STACK'}});
	$this->{'CURRENT'}=eval($cr);
	$this->restorePdfState;
}

sub useGfxFlatness {
	my ($this,$flatness)=@_;
	$this->_addtopage("$flatness i\n");
}

sub useGfxLineCap {
	my ($this,$linecap)=@_;
	$this->_addtopage("$linecap J\n");
}

sub useGfxLineDash {
	my ($this,@a)=@_;
	$this->_addtopage("[ ".join(' ',@a)." ] 0 d\n");
}

sub useGfxLineJoin {
	my ($this,$linejoin)=@_;
	$this->_addtopage("$linejoin j\n");
}

sub useGfxLineWidth {
	my ($this,$linewidth)=@_;
	$this->_addtopage("$linewidth w\n");
}

sub useGfxMeterlimit {
	my ($this, $limit)=@_;
	$this->_addtopage("$limit M\n");
}

sub setColorFill {
	my ($this,$c,$m,$y,$k)=@_;
	if (!defined($k)) {
		if (!defined($m)) {
			$this->_addtopage("$c g\n");
		} else {
			$this->_addtopage("$c $m $y rg\n");
		}
	} else {
		$this->_addtopage("$c $m $y $k k\n");
	} 
}

sub setColorStroke {
	my ($this,$c,$m,$y,$k)=@_;
	if (!defined($k)) {
		if (!defined($m)) {
			$this->_addtopage("$c G\n");
		} else {
			$this->_addtopage("$c $m $y RG\n");
		}
	} else {
		$this->_addtopage("$c $m $y $k K\n");
	} 
}

sub moveTo {
	my ($this,$x,$y)=@_;
	$this->_addtopage(sprintf("%.9f %.9f m\n",$x,$y));
} 

sub lineTo {
	my $this=shift @_;
	my($x,$y);
	while($x=shift @_) {
		$y=shift @_;
		$this->_addtopage(sprintf("%.9f %.9f l\n",$x,$y));
	}
}

sub curveTo {
	my ($this,$x1,$y1,$x2,$y2,$x3,$y3)=@_;
	$this->_addtopage(sprintf("%.9f %.9f %.9f %.9f %.9f %.9f c\n",$x1,$y1,$x2,$y2,$x3,$y3));
}

sub rect  {
	my ($this,$x,$y,$w,$h)=@_;
	$this->_addtopage(sprintf("%.9f %.9f %.9f %.9f re\n",$x,$y,$w,$h));
}

sub closePath {
	my ($this)=@_;
	$this->_addtopage("h\n");
}

sub endPath{
	my ($this)=@_;
	$this->_addtopage("n\n");
}

sub rectXY {
	my ($this,$x,$y,$x2,$y2)=@_;
	$this->rect($x,$y,($x2-$x),($y2-$y));
}

sub lineXY {
	my ($this,$x1,$y1,$x2,$y2)=@_;
	$this->moveTo($x1,$y1);
	$this->lineTo($x2,$y2);
}

sub arcXYabDG {
        my $self = shift @_;
        my $x = shift @_;
        my $y = shift @_;
        my $a = shift @_;
        my $b = shift @_;
        my $alpha = shift @_;
        my $beta = shift @_;
        my $move = shift @_;
        my $test = shift @_;
        if(abs($beta-$alpha) > 180) {
                my ($p0_x,$p0_y) =
                        $self->arcXYabDG($x,$y,$a,$b,$alpha,($beta+$alpha)/2,$move,$test);
                my ($p2_x,$p2_y,$p3_x,$p3_y) =
                        $self->arcXYabDG($x,$y,$a,$b,($beta+$alpha)/2,$beta,$move,$test);
                return($p0_x,$p0_y,$p3_x,$p3_y);
        } else {
                $alpha = ($alpha * 3.1415 / 180);
                $beta  = ($beta * 3.1415 / 180);

                my $bcp = (4.0/3 * (1 - cos(($beta - $alpha)/2)) / sin(($beta - $alpha)/2));

                my $sin_alpha = sin($alpha);
                my $sin_beta =  sin($beta);
                my $cos_alpha = cos($alpha);
                my $cos_beta =  cos($beta);

                my $p0_x = $x + $a * $cos_alpha;
                my $p0_y = $y + $b * $sin_alpha;
                my $p1_x = $x + $a * ($cos_alpha - $bcp * $sin_alpha);
                my $p1_y = $y + $b * ($sin_alpha + $bcp * $cos_alpha);
                my $p2_x = $x + $a * ($cos_beta + $bcp * $sin_beta);
                my $p2_y = $y + $b * ($sin_beta - $bcp * $cos_beta);
                my $p3_x = $x + $a * $cos_beta;
                my $p3_y = $y + $b * $sin_beta;

                if(!$test) {
                        $self->moveTo($p0_x,$p0_y) if($move);
                        $self->curveTo($p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);
                }
                return($p0_x,$p0_y,$p3_x,$p3_y);
        }

}

sub arcXYrDG {
        my $self = shift @_;
        my $x = shift @_;
        my $y = shift @_;
        my $r = shift @_;
        my $alpha = shift @_;
        my $beta = shift @_;
        my $move = shift @_;
        my $test = shift @_;

        return($self->arcXYabDG($x,$y,$r,$r,$alpha,$beta,$move,$test));
}

sub ellipsisXYAB {
	my ($this,$x,$y,$a,$b)=@_;
	$this->moveTo($x-$a,$y);
	$this->curveTo($x-$a,$y+($b*4/3),$x+$a,$y+($b*4/3),$x+$a,$y);
	$this->curveTo($x+$a,$y-($b*4/3),$x-$a,$y-($b*4/3),$x-$a,$y);
	$this->closePath;
}

sub circleXYR {
	my ($this,$x,$y,$r)=@_;
	$this->arcXYrDG($x,$y,$r,0,360,1);
	$this->closePath;
}

sub stroke {
	my ($this)=@_;
	$this->_addtopage("S\n");
}
sub closestroke {
	my ($this)=@_;
	$this->_addtopage("h S\n");
}
sub fill {
	my ($this)=@_;
	$this->_addtopage("f\n");
}
sub closefill {
	my ($this)=@_;
	$this->_addtopage("h f\n");
}
sub fillNZ {
	my ($this)=@_;
	$this->_addtopage("f*\n");
}
sub fillstroke {
	my ($this)=@_;
	$this->_addtopage("B\n");
}
sub closefillstroke {
	my ($this)=@_;
	$this->_addtopage("b\n");
}
sub fillstrokeNZ {
	my ($this)=@_;
	$this->_addtopage("B*\n");
}
sub closefillstrokeNZ {
	my ($this)=@_;
	$this->_addtopage("b*\n");
}

sub rawImage {
	my($this, $name, $w, $h, $type, @imagearray)=@_;
	
	my ($xo,$img,$bpc,$cs);
	my $key='IMGxRAW'.genKEY(sprintf('%s%s-%d-%d',$name,$w,$h,$type));

	if(!defined($this->{'IMAGES'}{$key})) {
		if($type eq '-rgb'){
			$img=join('',
				map {
					pack('C',$_);
				} @imagearray
			);
			$cs='DeviceRGB';
			$bpc=8;
		} elsif($type eq '-RGB') {
			$img=join('',
				map {
					pack('H*',$_);
				} @imagearray
			);
			$cs='DeviceRGB';
			$bpc=8;
		} elsif ($type==1) {
			($img)=@imagearray;
			$cs='DeviceGray';
			$bpc=8;
		} elsif ($type==3) {
			($img)=@imagearray;
			$cs='DeviceRGB';
			$bpc=8;
		} elsif ($type==4) {
			($img)=@imagearray;
			$cs='DeviceCMYK';
			$bpc=8;
		} elsif ($type=~/device.*/i) {
			$cs=$type; 
			$bpc=8;
			$img=join('',@imagearray);
		}
		$xo=PDFDict();
		$this->{'PDF'}->new_obj($xo);
		$xo->{'Type'}=PDFName('XObject');
		$xo->{'Subtype'}=PDFName('Image');
		$xo->{'Name'}=PDFName($key);
		$xo->{'Width'}=PDFNum($w);
		$xo->{'Height'}=PDFNum($h);
		$xo->{'Filter'}=PDFArray(PDFName('FlateDecode'));
		$xo->{'BitsPerComponent'}=PDFNum($bpc);
		$xo->{'ColorSpace'}=PDFName($cs);
		$xo->{' stream'}=$img;
		$this->{'IMAGES'}{$key}=$xo;
		if(!defined($this->{'ROOT'}->{'Resources'}->{'XObject'})) {
			$this->{'ROOT'}->{'Resources'}->{'XObject'}=PDFDict();
		}
		$this->{'ROOT'}->{'Resources'}->{'XObject'}->{$key}=$xo;
	}
	return ($key,$w,$h);
}

sub newImage {
	my ($this,$file,$type)=@_;
	my $xo;
	my $key;

	use Text::PDF::API::Image;
	my ($w,$h,$bpc,$cs,$img)=Text::PDF::API::Image::parseImage($file,$type);
	($key,$w,$h)=$this->rawImage($file,$w,$h,$cs,$img);
	return ($key,$w,$h);
}

sub placeImage {
	my ($this,$key,$x,$y,$sx,$sy)=@_;
	$this->saveState;
	$this->setGfxMatrix($sx,0,0,$sy,$x,$y);
	$this->useGfxState;
	$this->_addtopage("/$key Do\n");
	$this->restoreState;
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

=head2 Base Methods

=over 4

=item $pdf = Text::PDF::API->new [%defaults]

This creates a new pdf-object initializes it with the given defaults and returns it.
See the functions B<getDefault> and B<setDefault> for a list of supported parameters.

=item $pdf->info $title, $subject, $creator, $author, $keywords

This creates the pdf-info-object and initializes it with the given values.

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

PageOrientation, valid values:
	
	Landscape, Portrait

Compression

	0, 1 (= off, on)

PDFVersion

	0 .. 3 (corresponding to the adobe acrobat versions up to 4.0)

=item $pdf->setDefault $parameter , $value

This sets the pdf-object defaults (see $pdf->getDefault for details).

=item $pdf->newpage [ $width, $height ] 

=item $pdf->newpage [ $pagesize ] 

This creates a new page in the pdf-object and assigns it to the default page context.
If $width and $height are not given the funtion falls back to any given defaults
(PageSize then PageWidth+PageHeight) and as a last resort to 'A4'.
You can use also specify oonly the Pagesize as given under the defaults.

=item $pdf->endpage

This closes the current page.

=back

=head2 Generic Methods

=over 4

=item $pdf->savePdfState

=item $pdf->restorePdfState

Saves and restores the state of the pdf-document
BUT NOT of the pdf-object.

B<BEWARE:> Don't cross page boundaries with save/restore,
if you really don't know the pdf-specification well enough.

=item $pdf->saveState {currently broken}

=item $pdf->restoreState {currently broken}

Saves and restores the state of the pdf-object
and the underlying document.

B<NOTE:> All states are automagically restored if
you issue a $pdf->endpage.

=back

=head2 Font State Methods

=over 4

=item $pdf->setFontDir $directory

Sets the default font search directory.

=item $directory = $pdf->getFontDir 

Gets the default font search directory.

=item $pdf->addFontPath $directory

Adds a directory to the font search path.

=item $pdf->newFont $fontname, $ttfile

=item $pdf->newFont $fontname, $psffile, $afmfile

=item $pdf->newFont $fontname 

Adds a new font to the pdf-object. Based on the fonts name
either a core, truetype or postscript font is assumed:
TrueType have a ',' between the family and style names whereas
the postscript and core fonts use a '-'.

B<BEWARE:> Postscript fonts other than the core fonts are supported,
BUT the implementation is still somewhere in alpha/beta stage and
may not result in valid pdf-files under certain conditions. 

B<NOTE:> this function is for BACKWARD COMPATIBLITY ONLY (as of version 0.5)
and will be removed sometime before version 1.0.

B<RECOMMENDATION:> Start using the following three functions below.

=item $pdf->newFontCore $fontname [, $encoding [, @glyphs ]]

=item $pdf->newFontTTF $fontname, $ttffile [, $encoding ]

=item $pdf->newFontPS $fontname, $psffile, $afmfile [, $encoding [, @glyphs ]]

Although you can add a font thru the $pdf->newFont function, these three new 
functions are much more stable (newFontPS is alpha-quality) and reliable.

The $encoding is the name of one of the encoding schemes supported , 'asis' 
or 'custom'. If you use 'custom' as encoding, you have to supply the @glyphs 
array which should specify 256 glyph-names as defined by the 
"PostScript(R) Language Reference 3rd. Ed. -- Appendix E"

If you do not give $encoding or 'asis', than the afms internal encoding is used.

If you give an unknown $encoding, the encoding defaults to WinAnsiEncoding.

=item $pdf->addCoreFonts 

This is a shortcut to add all pdf-core-fonts to the pdf-object.

=item $pdf->useFont $name, $size [, $encoding ]

This selects the font at the specified size and encoding.
The font must have been loaded with the same $name 
parameter with $pdf->newFont

If you do not give $encoding, than the encoding from $pdf->newFont??? is used.

B<NOTE:> As of version API 0.699 you can specify the following encodings:
adobe-standard adobe-symbol adobe-zapf-dingbats cp1250 cp1251 cp1252 cp1253 cp1254 cp1255 cp1256 cp1257 cp1258 cp437 cp850 ebcdic-at-de ebcdic-at-de-a ebcdic-ca-fr ebcdic-dk-no ebcdic-dk-no-a ebcdic-es ebcdic-es-a ebcdic-es-s ebcdic-fi-se ebcdic-fi-se-a ebcdic-fr ebcdic-it ebcdic-pt ebcdic-uk ebcdic-us latin1 latin13 latin15 latin2 latin3 latin4 latin5 latin6 latin7 latin8 microsoft-dingbats

B<NOTE:> The fonts are automagically reencoded to use the new encoding if it differs
from that encoding specified at $pdf->newFont???.

=item $pdf->setFontTranslate $tx, $ty

Sets the translation (aka. x,y-offset) in the Font-Transformation-Matrices.

=item $pdf->setFontScale $scalex, $scaley

Sets the scale in the Font-Transformation-Matrices.

=item $pdf->setFontSkew $alfa, $beta

Sets the skew in the Font-Transformation-Matrices specified
in degrees (0..360).

=item $pdf->setFontRotation $alfa

Sets the rotation in the Font-Transformation-Matrices specified
in degrees (0..360) counter-clock-wise from the right horizontal.

=item $pdf->clearFontMatrix

Resets all Font-Transformation-Matrices.

=item $pdf->calcFontMatrix

Calculates the final Transformation-Matrix for use with the *Text* functions.

=item $pdf->setFontMatrix $a, $b, $c, $d, $e, $f

Sets the final Transformation-Matrix directly.

=item ($a, $b, $c, $d, $e, $f)=$pdf->getFontMatrix

Returns the final Transformation-Matrix. Use $pdf->calcFontMatrix 
and then $pdf->getFontMatrix to retrive the combined effects
of Translate, Skew, Scale & Rotate.

=item $pdf->setCharSpacing $spacing

=item $pdf->setWordSpacing $spacing

=item $pdf->setTextLeading $leading

=item $pdf->setTextRise $rise

=item $pdf->setTextRendering $rendering

=back

=head2 Text Block Methods

=over 4

=item $pdf->beginText

Starts a text block.

=item $pdf->endText

Ends a text block

=item $pdf->charSpacing [ $spacing ]

=item $pdf->wordSpacing [ $spacing ]

=item $pdf->textLeading [ $leading ]

=item $pdf->textRise [ $rise ]

=item $pdf->textRendering [ $rendering ]

=item $pdf->textMatrix [ @matrix ]

Sets the parameter for the text-block only. If parameter is not given the default
as defined by $pdf->set* is used.

=item $pdf->textPos $mx, $my 

Sets a new text position, but honoring the current FontMatrix.

=item $pdf->textFont [ $font, $size [, $encoding ] ] 

Switches the font within the text-block or resets to the last $pdf->useFont.
B<BEWARE:> you can only change to a new font before a matrix or pos command since
changing it after such command gives pdf-errors !!!

=item $pdf->textAdd $text

Adds text to the text-block.

=item $pdf->textNewLine [ $leading ]

Moves the text-pointer to a new line using TextLeading as default. 

=back

=head2 Text Utility Methods

=over 4

=item $pdf->calcTextWidth $text

Calculates the width of the text based on the parameters set by useFont.

B<BEWARE:> Does not consider parameters specified by setFont* and *Matrix functions.

=item $pdf->calcTextWidthFSET $fontname $size $encoding $text

Calculates the width of the text without needing useFont.

B<BEWARE:> Does not consider parameters specified by setFont* and *Matrix functions.

=item ($fontsize, $fudgefactor) = $pdf->paragraphFit $font, $encoding, $leadingfactor, $width, $height, $text [, $fudge] 

Calculates the the required $fontsize to fit $text into the paragraph $width x $height using $font, $encoding and 
$leadingfactor. $fudge is a factor used to correct increasing fontsizes in relation to the given $width and
common text-patterns (wordlength, ...) found in both english and german languages which defaults to 0.95.
The returned $fudgefactor is the actual factor used to calculate $fontsize since the algurithm can only
mathematically estimate a fitting contition, but a perfect fit may ll somewhere between $fudgefactor and 1.

B<BEWARE:> this function does a one-shot mathematical estimation which may not be correct under some circumstances !

B<BEWARE:> same limitations as $pdf->calcTextWidthFSET !

=item ($fontsize, $lastdelta) = $pdf->paragraphFit2 $font, $encoding, $leadingfactor, $width, $height, $text [, $maxdelta [, $maxiterations [, $startingfontsize ]]] 

As $pdf->paragraphFit above but uses a iterative deterministic algorithm (like $pdf->textParagraph) to estimate the fontsize. 

B<NOTE:> this function works best for texts with more that 200 words to put you on the save side with no overflowing text.

B<BEWARE:> this function fails hopelessly for ridiculous parameters and small texts !

=item ($xend, $yend, $overflowtext) = $pdf->textParagraph $x, $y, $width, $height, $text [, $block ] 

Positions $text into the paragraph specified by $x, $y, $width and $height. If $block is
true the text is block aligned else it is left aligned. The function returns the end position
of the text and if the text can not entirely positioned into the paragraph the actual overflow. 

=item $pdf->showText $text

Displays the $text based on the parameters given by the *Font* functions.

=item $pdf->showTextXY $x, $y, $text

=item $pdf->showTextXY_R $x, $y, $text

=item $pdf->showTextXY_C $x, $y, $text

Like $pdf->showText but overrides the x,y-offsets of the Matrices.
The *_R and *_C variants perform right and center alignment !

=item $pdf->printText $x, $y, $font, $size, $encoding, $text

Like a $pdf->useFont followed by a $pdf->showTextXY.

=back

=head2 Graphic State Methods

=over 4

=item $pdf->setGfxTranslate $tx, $ty

=item $pdf->setGfxScale $scalex, $scaley

=item $pdf->setGfxSkew $alfa, $beta

=item $pdf->setGfxRotation $alfa

=item $pdf->clearGfxMatrix

=item $pdf->calcGfxMatrix

=item $pdf->setGfxMatrix $a, $b, $c, $d, $e, $f

=item ($a, $b, $c, $d, $e, $f)=$pdf->getGfxMatrix

These functions behave like the the font functions BUT affect
the whole global graphics state.

B<BEWARE:> If you use both the Gfx and Font versions of these functions
the final result for Text would be the combined effects
of both the Gfx and Font parameters.

=item $pdf->useGfxState

Adds the parameters of the functions above to the current graphics state.
To revert to the former parameters use $pdf->savePdfState and $pdf->restorePdfState.

=item $pdf->useGfxFlatness $flatness

=item $pdf->useGfxLineCap $linecap

=item $pdf->useGfxLineDash @dasharray

=item $pdf->useGfxLineJoin $linejoin

=item $pdf->useGfxLineWidth $linewidth

=item $pdf->useGfxMeterlimit $limit

=back

=head2 Color Methods

=over 4

=item $pdf->setColorFill $red, $green, $blue

=item $pdf->setColorFill $cyan, $magenta, $yellow, $black

=item $pdf->setColorFill $gray

=item $pdf->setColorStroke $red, $green, $blue

=item $pdf->setColorStroke $cyan, $magenta, $yellow, $black

=item $pdf->setColorStroke $gray

=back

=head2 Drawing Methods

=over 4

=item $pdf->moveTo $x, $y

=item $pdf->lineTo $x, $y

=item $pdf->curveTo $x1, $y1, $x2, $y2, $x3, $y3

=item $pdf->rect $x, $y, $w, $h

=item $pdf->closePath

=item $pdf->endPath

=item $pdf->rectXY $x1, $y1, $x2, $y2

=item $pdf->lineXY $x1, $y1, $x2, $y2

=item ($xs,$ys,$xe,$ye)=$pdf->arcXYabDG $x, $y, $a, $b, $delta, $gamma, $move

=item ($xs,$ys,$xe,$ye)=$pdf->arcXYrDG $x, $y, $r, $delta, $gamma, $move

=item $pdf->ellipsisXYAB $x, $y, $a, $b

=item $pdf->circleXYR $x, $y, $r

=item $pdf->stroke

=item $pdf->closestroke

=item $pdf->fill

=item $pdf->closefill

=item $pdf->fillNZ

=item $pdf->fillstroke

=item $pdf->closefillstroke

=item $pdf->fillstrokeNZ

=item $pdf->closefillstrokeNZ

quot errat demonstrandum

=back

=head2 Bitmap Methods

=over 4

=item ( $key , $width , $height ) = $pdf->newImage $file

Current loading support includes NetPBM images of the
RAW_BITS variation and non-interlaced/non-filtered PNG.
Transperancy/Opacity information is currently ignored
as well as Alpha-Channel information.

B<Note:> As of version 0.604 the API supports additional
image-formats via XS drop-in modules namely JPEG, GIF, PPM,
BMP (little-endian only). 

=item ( $key , $width , $height ) = $pdf->rawImage $name, $width $height $type @imagearray

This function supports loading of point-arrays for embedding
image information into the pdf. $type must be one of the following:

	'-rgb' ... each element of the array is a color component
			in the range of 0..255
	'-RGB' ... each element of the array is a hex-encoded color pixel
			with two hex-digits per color component  

$name must be a unique name for this image (at least 8 characters long).

=item $pdf->placeImage $key, $x, $y, $scalex, $scaley

=back

=head1 HISTORY

=over 4

=item Version 0.00

GENESIS

=item Version 0.01

inital implementation without documentation

=item Version 0.01_01

you can create pages, still no docs

=item Version 0.01_02 - 0.01_11

various conceptual design stages

=item Version 0.01_12

first public snapshot with some docs
and first implementation of font caching
(released as 0.01_12_snapshot)

=item Version 0.01_14

reimplementaion of font-handling with
unification of core and truetype fonts
under the function "newFont"

=item Version 0.01_15

implementaion of font-encoding for truetypes

=item Version 0.01_16

reimplementaion of font-encoding thru CID
because Acrobat seems to ignore encoding tables 
for TTs when using normal embedding

=item Version 0.01_17

implementaion of printText, useFont, showText & showTextXY

=item Version 0.01_18

implementaion of *FontMatrix functions, 
changes in showText & showTextXY

=item Version 0.01_19

addition of setFontTranslate, Skew, Rotate & Scale
with cleanup in *FontMatrix

=item Version 0.01_20

end of text/font implementation, let it stabilize :)

=item Version 0.02

genesis of the graphical interface
(CTM handling copied from fonts)

=item Version 0.02_01

added text and graphic state functions

=item Version 0.02_02

cleanup/extension of dokumentation, but still not finished

=item Version 0.02_03

proposed implementation of drawing functions (NOT FINISHED)

=item Version 0.02_04

finished implemetation of needed drawing functions

=item Version 0.03

bugfixes in drawing and font functions
first implementation of state functions

=item Version 0.03_01

first implementation of bitmap functions

=item Version 0.03_02

bugfixes in text/font functions

=item Version 0.03_03

added support for loading of PNM(netpbm) and PNG bitmaps

=item Version 0.03_04

added circle and ellipsis drawing functions

=item Version 0.03_05

fixed calcTextWidth to allow the type1 core fonts to be measured too.
added showTextXY_R and _C functions for alignment procedures :)

=item Version 0.04-0.43

rewrite of type1 core-font handling to ease development support for 
other type1 fonts in future releases of Text::PDF and Text::PDF::API.

small bugfixes in calcTextWidth and showTextXY_[RC].

small documentation update

=item Version 0.05 (Oct. 2000)

major rewrite to use Unicode::Map8 instead of the homegrown functions :)
, add another dependency but at least a fast one

=item Versions 0.5_pre??? (Dec. 2000)

major rewrite of font-handling routines stalls the tutorial/exaples collection.
now adobe-type1 fonts (pfb/pfa + afm) and the core-fonts can be used the same way
as truetype with the Unicode::Map8 encodings.

=item Version 0.5 (07-01-2001)

documemtation update and release of the much hacked 0.5_pre??? code :)

=item Version 0.5001 to 0.5003 

minor bugfixes:

under certain conditions the 'image' functions stopped working,
hope that my newly invented "nigma-hash" keygenerator fixes this.  

the symbol and zapfdingbat corefonts did not work ... since they missed 
attributes and had wrong font-flags set ... doesn't anybody use them ?

=item Version 0.6

removed: "nigma-hash" keygenerator had some disadvantages.

added: Digest::REHLHA module for key-generation (this comes with the API).

added: $p->arcXYrDG() and $p->arcXYabDG() to relief users of the (in my opinion)
'mind boggling' bezier-curve function for arcs.  

added: $p->info() to include copyright/generator information in the pdf.

added: new text-block functions to ease the use of text.

changed: unicode<->name mapping was broken under perl-5.004xx.  

=item Version 0.6?? to 0.699

major rewrite to remove dependency on Unicode::Map8 which seams to be chronically 
unavailable under win32 (eg. activestate perl). the internal unicode tables
have the same file-format as the '.bin' by Unicode::Map8 so you can copy them over
for use with the api as long as the new filename conforms to the following
regular expression: /^[a-z0-9\-]+\.map$/

testing scripts remain broken and currently depend on the availibility of Data::DumpXML
since Data::Dumper just core-dumps into my face everytime i run them.

=back

=head1 CONTRIBUTORS / BUGHUNTERS / THANKS

Martin Hosken [mhosken@sil.org] 
-- for writing Text::PDF in the first place

Lester Hightower [hightowe@TheAIMSGroup.com] 
-- fixes/reports: perl-5.004xx, key-generation, Makefile.PL

=head1 PLUG-INS

As of Version 0.604 bitmapped image loading functions can be extended
via XS modules.  Currently available: Text-PDF-API-JPEG, Text-PDF-API-GIF, 
Text-PDF-API-PPM and Text-PDF-API-BMP (little-endian only).

=head1 BUGS

MANY! If you find some report them to perl-text-pdf-modules@yahoogroups.com.

=head1 TODO ( in no particular order )

documentation ?

drawing functions ?

more bitmap import functions (jpeg,tiff,xbm,xpm,...?)

function to populate a Text::PDF::API object from an existing pdf-file ?

=cut

BEGIN {

%u2n=(
  '32'=>'space',
  '33'=>'exclam',
  '34'=>'quotedbl',
  '35'=>'numbersign',
  '36'=>'dollar',
  '37'=>'percent',
  '38'=>'ampersand',
  '39'=>'quotesingle',
  '40'=>'parenleft',
  '41'=>'parenright',
  '42'=>'asterisk',
  '43'=>'plus',
  '44'=>'comma',
  '45'=>'hyphen',
  '46'=>'period',
  '47'=>'slash',
  '48'=>'zero',
  '49'=>'one',
  '50'=>'two',
  '51'=>'three',
  '52'=>'four',
  '53'=>'five',
  '54'=>'six',
  '55'=>'seven',
  '56'=>'eight',
  '57'=>'nine',
  '58'=>'colon',
  '59'=>'semicolon',
  '60'=>'less',
  '61'=>'equal',
  '62'=>'greater',
  '63'=>'question',
  '64'=>'at',
  '65'=>'A',
  '66'=>'B',
  '67'=>'C',
  '68'=>'D',
  '69'=>'E',
  '70'=>'F',
  '71'=>'G',
  '72'=>'H',
  '73'=>'I',
  '74'=>'J',
  '75'=>'K',
  '76'=>'L',
  '77'=>'M',
  '78'=>'N',
  '79'=>'O',
  '80'=>'P',
  '81'=>'Q',
  '82'=>'R',
  '83'=>'S',
  '84'=>'T',
  '85'=>'U',
  '86'=>'V',
  '87'=>'W',
  '88'=>'X',
  '89'=>'Y',
  '90'=>'Z',
  '91'=>'bracketleft',
  '92'=>'backslash',
  '93'=>'bracketright',
  '94'=>'asciicircum',
  '95'=>'underscore',
  '96'=>'grave',
  '97'=>'a',
  '98'=>'b',
  '99'=>'c',
  '100'=>'d',
  '101'=>'e',
  '102'=>'f',
  '103'=>'g',
  '104'=>'h',
  '105'=>'i',
  '106'=>'j',
  '107'=>'k',
  '108'=>'l',
  '109'=>'m',
  '110'=>'n',
  '111'=>'o',
  '112'=>'p',
  '113'=>'q',
  '114'=>'r',
  '115'=>'s',
  '116'=>'t',
  '117'=>'u',
  '118'=>'v',
  '119'=>'w',
  '120'=>'x',
  '121'=>'y',
  '122'=>'z',
  '123'=>'braceleft',
  '124'=>'bar',
  '125'=>'braceright',
  '126'=>'asciitilde',
  '160'=>'space',
  '161'=>'exclamdown',
  '162'=>'cent',
  '163'=>'sterling',
  '164'=>'currency',
  '165'=>'yen',
  '166'=>'brokenbar',
  '167'=>'section',
  '168'=>'dieresis',
  '169'=>'copyright',
  '170'=>'ordfeminine',
  '171'=>'guillemotleft',
  '172'=>'logicalnot',
  '173'=>'hyphen',
  '174'=>'registered',
  '175'=>'macron',
  '176'=>'degree',
  '177'=>'plusminus',
  '178'=>'twosuperior',
  '179'=>'threesuperior',
  '180'=>'acute',
  '181'=>'mu',
  '182'=>'paragraph',
  '183'=>'periodcentered',
  '184'=>'cedilla',
  '185'=>'onesuperior',
  '186'=>'ordmasculine',
  '187'=>'guillemotright',
  '188'=>'onequarter',
  '189'=>'onehalf',
  '190'=>'threequarters',
  '191'=>'questiondown',
  '192'=>'Agrave',
  '193'=>'Aacute',
  '194'=>'Acircumflex',
  '195'=>'Atilde',
  '196'=>'Adieresis',
  '197'=>'Aring',
  '198'=>'AE',
  '199'=>'Ccedilla',
  '200'=>'Egrave',
  '201'=>'Eacute',
  '202'=>'Ecircumflex',
  '203'=>'Edieresis',
  '204'=>'Igrave',
  '205'=>'Iacute',
  '206'=>'Icircumflex',
  '207'=>'Idieresis',
  '208'=>'Eth',
  '209'=>'Ntilde',
  '210'=>'Ograve',
  '211'=>'Oacute',
  '212'=>'Ocircumflex',
  '213'=>'Otilde',
  '214'=>'Odieresis',
  '215'=>'multiply',
  '216'=>'Oslash',
  '217'=>'Ugrave',
  '218'=>'Uacute',
  '219'=>'Ucircumflex',
  '220'=>'Udieresis',
  '221'=>'Yacute',
  '222'=>'Thorn',
  '223'=>'germandbls',
  '224'=>'agrave',
  '225'=>'aacute',
  '226'=>'acircumflex',
  '227'=>'atilde',
  '228'=>'adieresis',
  '229'=>'aring',
  '230'=>'ae',
  '231'=>'ccedilla',
  '232'=>'egrave',
  '233'=>'eacute',
  '234'=>'ecircumflex',
  '235'=>'edieresis',
  '236'=>'igrave',
  '237'=>'iacute',
  '238'=>'icircumflex',
  '239'=>'idieresis',
  '240'=>'eth',
  '241'=>'ntilde',
  '242'=>'ograve',
  '243'=>'oacute',
  '244'=>'ocircumflex',
  '245'=>'otilde',
  '246'=>'odieresis',
  '247'=>'divide',
  '248'=>'oslash',
  '249'=>'ugrave',
  '250'=>'uacute',
  '251'=>'ucircumflex',
  '252'=>'udieresis',
  '253'=>'yacute',
  '254'=>'thorn',
  '255'=>'ydieresis',
  '256'=>'Amacron',
  '257'=>'amacron',
  '258'=>'Abreve',
  '259'=>'abreve',
  '260'=>'Aogonek',
  '261'=>'aogonek',
  '262'=>'Cacute',
  '263'=>'cacute',
  '264'=>'Ccircumflex',
  '265'=>'ccircumflex',
  '266'=>'Cdotaccent',
  '267'=>'cdotaccent',
  '268'=>'Ccaron',
  '269'=>'ccaron',
  '270'=>'Dcaron',
  '271'=>'dcaron',
  '272'=>'Dcroat',
  '273'=>'dcroat',
  '274'=>'Emacron',
  '275'=>'emacron',
  '276'=>'Ebreve',
  '277'=>'ebreve',
  '278'=>'Edotaccent',
  '279'=>'edotaccent',
  '280'=>'Eogonek',
  '281'=>'eogonek',
  '282'=>'Ecaron',
  '283'=>'ecaron',
  '284'=>'Gcircumflex',
  '285'=>'gcircumflex',
  '286'=>'Gbreve',
  '287'=>'gbreve',
  '288'=>'Gdotaccent',
  '289'=>'gdotaccent',
  '290'=>'Gcommaaccent',
  '291'=>'gcommaaccent',
  '292'=>'Hcircumflex',
  '293'=>'hcircumflex',
  '294'=>'Hbar',
  '295'=>'hbar',
  '296'=>'Itilde',
  '297'=>'itilde',
  '298'=>'Imacron',
  '299'=>'imacron',
  '300'=>'Ibreve',
  '301'=>'ibreve',
  '302'=>'Iogonek',
  '303'=>'iogonek',
  '304'=>'Idotaccent',
  '305'=>'dotlessi',
  '306'=>'IJ',
  '307'=>'ij',
  '308'=>'Jcircumflex',
  '309'=>'jcircumflex',
  '310'=>'Kcommaaccent',
  '311'=>'kcommaaccent',
  '312'=>'kgreenlandic',
  '313'=>'Lacute',
  '314'=>'lacute',
  '315'=>'Lcommaaccent',
  '316'=>'lcommaaccent',
  '317'=>'Lcaron',
  '318'=>'lcaron',
  '319'=>'Ldot',
  '320'=>'ldot',
  '321'=>'Lslash',
  '322'=>'lslash',
  '323'=>'Nacute',
  '324'=>'nacute',
  '325'=>'Ncommaaccent',
  '326'=>'ncommaaccent',
  '327'=>'Ncaron',
  '328'=>'ncaron',
  '329'=>'napostrophe',
  '330'=>'Eng',
  '331'=>'eng',
  '332'=>'Omacron',
  '333'=>'omacron',
  '334'=>'Obreve',
  '335'=>'obreve',
  '336'=>'Ohungarumlaut',
  '337'=>'ohungarumlaut',
  '338'=>'OE',
  '339'=>'oe',
  '340'=>'Racute',
  '341'=>'racute',
  '342'=>'Rcommaaccent',
  '343'=>'rcommaaccent',
  '344'=>'Rcaron',
  '345'=>'rcaron',
  '346'=>'Sacute',
  '347'=>'sacute',
  '348'=>'Scircumflex',
  '349'=>'scircumflex',
  '350'=>'Scedilla',
  '351'=>'scedilla',
  '352'=>'Scaron',
  '353'=>'scaron',
  '354'=>'Tcommaaccent',
  '355'=>'tcommaaccent',
  '356'=>'Tcaron',
  '357'=>'tcaron',
  '358'=>'Tbar',
  '359'=>'tbar',
  '360'=>'Utilde',
  '361'=>'utilde',
  '362'=>'Umacron',
  '363'=>'umacron',
  '364'=>'Ubreve',
  '365'=>'ubreve',
  '366'=>'Uring',
  '367'=>'uring',
  '368'=>'Uhungarumlaut',
  '369'=>'uhungarumlaut',
  '370'=>'Uogonek',
  '371'=>'uogonek',
  '372'=>'Wcircumflex',
  '373'=>'wcircumflex',
  '374'=>'Ycircumflex',
  '375'=>'ycircumflex',
  '376'=>'Ydieresis',
  '377'=>'Zacute',
  '378'=>'zacute',
  '379'=>'Zdotaccent',
  '380'=>'zdotaccent',
  '381'=>'Zcaron',
  '382'=>'zcaron',
  '383'=>'longs',
  '402'=>'florin',
  '416'=>'Ohorn',
  '417'=>'ohorn',
  '431'=>'Uhorn',
  '432'=>'uhorn',
  '486'=>'Gcaron',
  '487'=>'gcaron',
  '506'=>'Aringacute',
  '507'=>'aringacute',
  '508'=>'AEacute',
  '509'=>'aeacute',
  '510'=>'Oslashacute',
  '511'=>'oslashacute',
  '536'=>'Scommaaccent',
  '537'=>'scommaaccent',
  '538'=>'Tcommaaccent',
  '539'=>'tcommaaccent',
  '700'=>'afii57929',
  '701'=>'afii64937',
  '710'=>'circumflex',
  '711'=>'caron',
  '713'=>'macron',
  '728'=>'breve',
  '729'=>'dotaccent',
  '730'=>'ring',
  '731'=>'ogonek',
  '732'=>'tilde',
  '733'=>'hungarumlaut',
  '768'=>'gravecomb',
  '769'=>'acutecomb',
  '771'=>'tildecomb',
  '777'=>'hookabovecomb',
  '803'=>'dotbelowcomb',
  '900'=>'tonos',
  '901'=>'dieresistonos',
  '902'=>'Alphatonos',
  '903'=>'anoteleia',
  '904'=>'Epsilontonos',
  '905'=>'Etatonos',
  '906'=>'Iotatonos',
  '908'=>'Omicrontonos',
  '910'=>'Upsilontonos',
  '911'=>'Omegatonos',
  '912'=>'iotadieresistonos',
  '913'=>'Alpha',
  '914'=>'Beta',
  '915'=>'Gamma',
  '916'=>'Delta',
  '917'=>'Epsilon',
  '918'=>'Zeta',
  '919'=>'Eta',
  '920'=>'Theta',
  '921'=>'Iota',
  '922'=>'Kappa',
  '923'=>'Lambda',
  '924'=>'Mu',
  '925'=>'Nu',
  '926'=>'Xi',
  '927'=>'Omicron',
  '928'=>'Pi',
  '929'=>'Rho',
  '931'=>'Sigma',
  '932'=>'Tau',
  '933'=>'Upsilon',
  '934'=>'Phi',
  '935'=>'Chi',
  '936'=>'Psi',
  '937'=>'Omega',
  '938'=>'Iotadieresis',
  '939'=>'Upsilondieresis',
  '940'=>'alphatonos',
  '941'=>'epsilontonos',
  '942'=>'etatonos',
  '943'=>'iotatonos',
  '944'=>'upsilondieresistonos',
  '945'=>'alpha',
  '946'=>'beta',
  '947'=>'gamma',
  '948'=>'delta',
  '949'=>'epsilon',
  '950'=>'zeta',
  '951'=>'eta',
  '952'=>'theta',
  '953'=>'iota',
  '954'=>'kappa',
  '955'=>'lambda',
  '956'=>'mu',
  '957'=>'nu',
  '958'=>'xi',
  '959'=>'omicron',
  '960'=>'pi',
  '961'=>'rho',
  '962'=>'sigma1',
  '963'=>'sigma',
  '964'=>'tau',
  '965'=>'upsilon',
  '966'=>'phi',
  '967'=>'chi',
  '968'=>'psi',
  '969'=>'omega',
  '970'=>'iotadieresis',
  '971'=>'upsilondieresis',
  '972'=>'omicrontonos',
  '973'=>'upsilontonos',
  '974'=>'omegatonos',
  '977'=>'theta1',
  '978'=>'Upsilon1',
  '981'=>'phi1',
  '982'=>'omega1',
  '1025'=>'afii10023',
  '1026'=>'afii10051',
  '1027'=>'afii10052',
  '1028'=>'afii10053',
  '1029'=>'afii10054',
  '1030'=>'afii10055',
  '1031'=>'afii10056',
  '1032'=>'afii10057',
  '1033'=>'afii10058',
  '1034'=>'afii10059',
  '1035'=>'afii10060',
  '1036'=>'afii10061',
  '1038'=>'afii10062',
  '1039'=>'afii10145',
  '1040'=>'afii10017',
  '1041'=>'afii10018',
  '1042'=>'afii10019',
  '1043'=>'afii10020',
  '1044'=>'afii10021',
  '1045'=>'afii10022',
  '1046'=>'afii10024',
  '1047'=>'afii10025',
  '1048'=>'afii10026',
  '1049'=>'afii10027',
  '1050'=>'afii10028',
  '1051'=>'afii10029',
  '1052'=>'afii10030',
  '1053'=>'afii10031',
  '1054'=>'afii10032',
  '1055'=>'afii10033',
  '1056'=>'afii10034',
  '1057'=>'afii10035',
  '1058'=>'afii10036',
  '1059'=>'afii10037',
  '1060'=>'afii10038',
  '1061'=>'afii10039',
  '1062'=>'afii10040',
  '1063'=>'afii10041',
  '1064'=>'afii10042',
  '1065'=>'afii10043',
  '1066'=>'afii10044',
  '1067'=>'afii10045',
  '1068'=>'afii10046',
  '1069'=>'afii10047',
  '1070'=>'afii10048',
  '1071'=>'afii10049',
  '1072'=>'afii10065',
  '1073'=>'afii10066',
  '1074'=>'afii10067',
  '1075'=>'afii10068',
  '1076'=>'afii10069',
  '1077'=>'afii10070',
  '1078'=>'afii10072',
  '1079'=>'afii10073',
  '1080'=>'afii10074',
  '1081'=>'afii10075',
  '1082'=>'afii10076',
  '1083'=>'afii10077',
  '1084'=>'afii10078',
  '1085'=>'afii10079',
  '1086'=>'afii10080',
  '1087'=>'afii10081',
  '1088'=>'afii10082',
  '1089'=>'afii10083',
  '1090'=>'afii10084',
  '1091'=>'afii10085',
  '1092'=>'afii10086',
  '1093'=>'afii10087',
  '1094'=>'afii10088',
  '1095'=>'afii10089',
  '1096'=>'afii10090',
  '1097'=>'afii10091',
  '1098'=>'afii10092',
  '1099'=>'afii10093',
  '1100'=>'afii10094',
  '1101'=>'afii10095',
  '1102'=>'afii10096',
  '1103'=>'afii10097',
  '1105'=>'afii10071',
  '1106'=>'afii10099',
  '1107'=>'afii10100',
  '1108'=>'afii10101',
  '1109'=>'afii10102',
  '1110'=>'afii10103',
  '1111'=>'afii10104',
  '1112'=>'afii10105',
  '1113'=>'afii10106',
  '1114'=>'afii10107',
  '1115'=>'afii10108',
  '1116'=>'afii10109',
  '1118'=>'afii10110',
  '1119'=>'afii10193',
  '1122'=>'afii10146',
  '1123'=>'afii10194',
  '1138'=>'afii10147',
  '1139'=>'afii10195',
  '1140'=>'afii10148',
  '1141'=>'afii10196',
  '1168'=>'afii10050',
  '1169'=>'afii10098',
  '1241'=>'afii10846',
  '1456'=>'afii57799',
  '1457'=>'afii57801',
  '1458'=>'afii57800',
  '1459'=>'afii57802',
  '1460'=>'afii57793',
  '1461'=>'afii57794',
  '1462'=>'afii57795',
  '1463'=>'afii57798',
  '1464'=>'afii57797',
  '1465'=>'afii57806',
  '1467'=>'afii57796',
  '1468'=>'afii57807',
  '1469'=>'afii57839',
  '1470'=>'afii57645',
  '1471'=>'afii57841',
  '1472'=>'afii57842',
  '1473'=>'afii57804',
  '1474'=>'afii57803',
  '1475'=>'afii57658',
  '1488'=>'afii57664',
  '1489'=>'afii57665',
  '1490'=>'afii57666',
  '1491'=>'afii57667',
  '1492'=>'afii57668',
  '1493'=>'afii57669',
  '1494'=>'afii57670',
  '1495'=>'afii57671',
  '1496'=>'afii57672',
  '1497'=>'afii57673',
  '1498'=>'afii57674',
  '1499'=>'afii57675',
  '1500'=>'afii57676',
  '1501'=>'afii57677',
  '1502'=>'afii57678',
  '1503'=>'afii57679',
  '1504'=>'afii57680',
  '1505'=>'afii57681',
  '1506'=>'afii57682',
  '1507'=>'afii57683',
  '1508'=>'afii57684',
  '1509'=>'afii57685',
  '1510'=>'afii57686',
  '1511'=>'afii57687',
  '1512'=>'afii57688',
  '1513'=>'afii57689',
  '1514'=>'afii57690',
  '1520'=>'afii57716',
  '1521'=>'afii57717',
  '1522'=>'afii57718',
  '1548'=>'afii57388',
  '1563'=>'afii57403',
  '1567'=>'afii57407',
  '1569'=>'afii57409',
  '1570'=>'afii57410',
  '1571'=>'afii57411',
  '1572'=>'afii57412',
  '1573'=>'afii57413',
  '1574'=>'afii57414',
  '1575'=>'afii57415',
  '1576'=>'afii57416',
  '1577'=>'afii57417',
  '1578'=>'afii57418',
  '1579'=>'afii57419',
  '1580'=>'afii57420',
  '1581'=>'afii57421',
  '1582'=>'afii57422',
  '1583'=>'afii57423',
  '1584'=>'afii57424',
  '1585'=>'afii57425',
  '1586'=>'afii57426',
  '1587'=>'afii57427',
  '1588'=>'afii57428',
  '1589'=>'afii57429',
  '1590'=>'afii57430',
  '1591'=>'afii57431',
  '1592'=>'afii57432',
  '1593'=>'afii57433',
  '1594'=>'afii57434',
  '1600'=>'afii57440',
  '1601'=>'afii57441',
  '1602'=>'afii57442',
  '1603'=>'afii57443',
  '1604'=>'afii57444',
  '1605'=>'afii57445',
  '1606'=>'afii57446',
  '1607'=>'afii57470',
  '1608'=>'afii57448',
  '1609'=>'afii57449',
  '1610'=>'afii57450',
  '1611'=>'afii57451',
  '1612'=>'afii57452',
  '1613'=>'afii57453',
  '1614'=>'afii57454',
  '1615'=>'afii57455',
  '1616'=>'afii57456',
  '1617'=>'afii57457',
  '1618'=>'afii57458',
  '1632'=>'afii57392',
  '1633'=>'afii57393',
  '1634'=>'afii57394',
  '1635'=>'afii57395',
  '1636'=>'afii57396',
  '1637'=>'afii57397',
  '1638'=>'afii57398',
  '1639'=>'afii57399',
  '1640'=>'afii57400',
  '1641'=>'afii57401',
  '1642'=>'afii57381',
  '1645'=>'afii63167',
  '1657'=>'afii57511',
  '1662'=>'afii57506',
  '1670'=>'afii57507',
  '1672'=>'afii57512',
  '1681'=>'afii57513',
  '1688'=>'afii57508',
  '1700'=>'afii57505',
  '1711'=>'afii57509',
  '1722'=>'afii57514',
  '1746'=>'afii57519',
  '1749'=>'afii57534',
  '7808'=>'Wgrave',
  '7809'=>'wgrave',
  '7810'=>'Wacute',
  '7811'=>'wacute',
  '7812'=>'Wdieresis',
  '7813'=>'wdieresis',
  '7922'=>'Ygrave',
  '7923'=>'ygrave',
  '8204'=>'afii61664',
  '8205'=>'afii301',
  '8206'=>'afii299',
  '8207'=>'afii300',
  '8210'=>'figuredash',
  '8211'=>'endash',
  '8212'=>'emdash',
  '8213'=>'afii00208',
  '8215'=>'underscoredbl',
  '8216'=>'quoteleft',
  '8217'=>'quoteright',
  '8218'=>'quotesinglbase',
  '8219'=>'quotereversed',
  '8220'=>'quotedblleft',
  '8221'=>'quotedblright',
  '8222'=>'quotedblbase',
  '8224'=>'dagger',
  '8225'=>'daggerdbl',
  '8226'=>'bullet',
  '8228'=>'onedotenleader',
  '8229'=>'twodotenleader',
  '8230'=>'ellipsis',
  '8236'=>'afii61573',
  '8237'=>'afii61574',
  '8238'=>'afii61575',
  '8240'=>'perthousand',
  '8242'=>'minute',
  '8243'=>'second',
  '8249'=>'guilsinglleft',
  '8250'=>'guilsinglright',
  '8252'=>'exclamdbl',
  '8260'=>'fraction',
  '8304'=>'zerosuperior',
  '8308'=>'foursuperior',
  '8309'=>'fivesuperior',
  '8310'=>'sixsuperior',
  '8311'=>'sevensuperior',
  '8312'=>'eightsuperior',
  '8313'=>'ninesuperior',
  '8317'=>'parenleftsuperior',
  '8318'=>'parenrightsuperior',
  '8319'=>'nsuperior',
  '8320'=>'zeroinferior',
  '8321'=>'oneinferior',
  '8322'=>'twoinferior',
  '8323'=>'threeinferior',
  '8324'=>'fourinferior',
  '8325'=>'fiveinferior',
  '8326'=>'sixinferior',
  '8327'=>'seveninferior',
  '8328'=>'eightinferior',
  '8329'=>'nineinferior',
  '8333'=>'parenleftinferior',
  '8334'=>'parenrightinferior',
  '8353'=>'colonmonetary',
  '8355'=>'franc',
  '8356'=>'lira',
  '8359'=>'peseta',
  '8362'=>'afii57636',
  '8363'=>'dong',
  '8364'=>'Euro',
  '8453'=>'afii61248',
  '8465'=>'Ifraktur',
  '8467'=>'afii61289',
  '8470'=>'afii61352',
  '8472'=>'weierstrass',
  '8476'=>'Rfraktur',
  '8478'=>'prescription',
  '8482'=>'trademark',
  '8486'=>'Omega',
  '8494'=>'estimated',
  '8501'=>'aleph',
  '8531'=>'onethird',
  '8532'=>'twothirds',
  '8539'=>'oneeighth',
  '8540'=>'threeeighths',
  '8541'=>'fiveeighths',
  '8542'=>'seveneighths',
  '8592'=>'arrowleft',
  '8593'=>'arrowup',
  '8594'=>'arrowright',
  '8595'=>'arrowdown',
  '8596'=>'arrowboth',
  '8597'=>'arrowupdn',
  '8616'=>'arrowupdnbse',
  '8629'=>'carriagereturn',
  '8656'=>'arrowdblleft',
  '8657'=>'arrowdblup',
  '8658'=>'arrowdblright',
  '8659'=>'arrowdbldown',
  '8660'=>'arrowdblboth',
  '8704'=>'universal',
  '8706'=>'partialdiff',
  '8707'=>'existential',
  '8709'=>'emptyset',
  '8710'=>'Delta',
  '8711'=>'gradient',
  '8712'=>'element',
  '8713'=>'notelement',
  '8715'=>'suchthat',
  '8719'=>'product',
  '8721'=>'summation',
  '8722'=>'minus',
  '8725'=>'fraction',
  '8727'=>'asteriskmath',
  '8729'=>'periodcentered',
  '8730'=>'radical',
  '8733'=>'proportional',
  '8734'=>'infinity',
  '8735'=>'orthogonal',
  '8736'=>'angle',
  '8743'=>'logicaland',
  '8744'=>'logicalor',
  '8745'=>'intersection',
  '8746'=>'union',
  '8747'=>'integral',
  '8756'=>'therefore',
  '8764'=>'similar',
  '8773'=>'congruent',
  '8776'=>'approxequal',
  '8800'=>'notequal',
  '8801'=>'equivalence',
  '8804'=>'lessequal',
  '8805'=>'greaterequal',
  '8834'=>'propersubset',
  '8835'=>'propersuperset',
  '8836'=>'notsubset',
  '8838'=>'reflexsubset',
  '8839'=>'reflexsuperset',
  '8853'=>'circleplus',
  '8855'=>'circlemultiply',
  '8869'=>'perpendicular',
  '8901'=>'dotmath',
  '8962'=>'house',
  '8976'=>'revlogicalnot',
  '8992'=>'integraltp',
  '8993'=>'integralbt',
  '9001'=>'angleleft',
  '9002'=>'angleright',
  '9312'=>'a120',
  '9313'=>'a121',
  '9314'=>'a122',
  '9315'=>'a123',
  '9316'=>'a124',
  '9317'=>'a125',
  '9318'=>'a126',
  '9319'=>'a127',
  '9320'=>'a128',
  '9321'=>'a129',
  '9472'=>'SF100000',
  '9474'=>'SF110000',
  '9484'=>'SF010000',
  '9488'=>'SF030000',
  '9492'=>'SF020000',
  '9496'=>'SF040000',
  '9500'=>'SF080000',
  '9508'=>'SF090000',
  '9516'=>'SF060000',
  '9524'=>'SF070000',
  '9532'=>'SF050000',
  '9552'=>'SF430000',
  '9553'=>'SF240000',
  '9554'=>'SF510000',
  '9555'=>'SF520000',
  '9556'=>'SF390000',
  '9557'=>'SF220000',
  '9558'=>'SF210000',
  '9559'=>'SF250000',
  '9560'=>'SF500000',
  '9561'=>'SF490000',
  '9562'=>'SF380000',
  '9563'=>'SF280000',
  '9564'=>'SF270000',
  '9565'=>'SF260000',
  '9566'=>'SF360000',
  '9567'=>'SF370000',
  '9568'=>'SF420000',
  '9569'=>'SF190000',
  '9570'=>'SF200000',
  '9571'=>'SF230000',
  '9572'=>'SF470000',
  '9573'=>'SF480000',
  '9574'=>'SF410000',
  '9575'=>'SF450000',
  '9576'=>'SF460000',
  '9577'=>'SF400000',
  '9578'=>'SF540000',
  '9579'=>'SF530000',
  '9580'=>'SF440000',
  '9600'=>'upblock',
  '9604'=>'dnblock',
  '9608'=>'block',
  '9612'=>'lfblock',
  '9616'=>'rtblock',
  '9617'=>'ltshade',
  '9618'=>'shade',
  '9619'=>'dkshade',
  '9632'=>'filledbox',
  '9633'=>'H22073',
  '9642'=>'H18543',
  '9643'=>'H18551',
  '9644'=>'filledrect',
  '9650'=>'triagup',
  '9658'=>'triagrt',
  '9660'=>'triagdn',
  '9668'=>'triaglf',
  '9670'=>'a78',
  '9674'=>'lozenge',
  '9675'=>'circle',
  '9679'=>'a71',
  '9687'=>'a81',
  '9688'=>'invbullet',
  '9689'=>'invcircle',
  '9702'=>'openbullet',
  '9733'=>'a35',
  '9742'=>'a4',
  '9755'=>'a11',
  '9758'=>'a12',
  '9786'=>'smileface',
  '9787'=>'invsmileface',
  '9788'=>'sun',
  '9792'=>'female',
  '9794'=>'male',
  '9824'=>'spade',
  '9827'=>'club',
  '9829'=>'heart',
  '9830'=>'diamond',
  '9834'=>'musicalnote',
  '9835'=>'musicalnotedbl',
  '9985'=>'a1',
  '9986'=>'a2',
  '9987'=>'a202',
  '9988'=>'a3',
  '9990'=>'a5',
  '9991'=>'a119',
  '9992'=>'a118',
  '9993'=>'a117',
  '9996'=>'a13',
  '9997'=>'a14',
  '9998'=>'a15',
  '9999'=>'a16',
  '10000'=>'a105',
  '10001'=>'a17',
  '10002'=>'a18',
  '10003'=>'a19',
  '10004'=>'a20',
  '10005'=>'a21',
  '10006'=>'a22',
  '10007'=>'a23',
  '10008'=>'a24',
  '10009'=>'a25',
  '10010'=>'a26',
  '10011'=>'a27',
  '10012'=>'a28',
  '10013'=>'a6',
  '10014'=>'a7',
  '10015'=>'a8',
  '10016'=>'a9',
  '10017'=>'a10',
  '10018'=>'a29',
  '10019'=>'a30',
  '10020'=>'a31',
  '10021'=>'a32',
  '10022'=>'a33',
  '10023'=>'a34',
  '10025'=>'a36',
  '10026'=>'a37',
  '10027'=>'a38',
  '10028'=>'a39',
  '10029'=>'a40',
  '10030'=>'a41',
  '10031'=>'a42',
  '10032'=>'a43',
  '10033'=>'a44',
  '10034'=>'a45',
  '10035'=>'a46',
  '10036'=>'a47',
  '10037'=>'a48',
  '10038'=>'a49',
  '10039'=>'a50',
  '10040'=>'a51',
  '10041'=>'a52',
  '10042'=>'a53',
  '10043'=>'a54',
  '10044'=>'a55',
  '10045'=>'a56',
  '10046'=>'a57',
  '10047'=>'a58',
  '10048'=>'a59',
  '10049'=>'a60',
  '10050'=>'a61',
  '10051'=>'a62',
  '10052'=>'a63',
  '10053'=>'a64',
  '10054'=>'a65',
  '10055'=>'a66',
  '10056'=>'a67',
  '10057'=>'a68',
  '10058'=>'a69',
  '10059'=>'a70',
  '10061'=>'a72',
  '10063'=>'a74',
  '10064'=>'a203',
  '10065'=>'a75',
  '10066'=>'a204',
  '10070'=>'a79',
  '10072'=>'a82',
  '10073'=>'a83',
  '10074'=>'a84',
  '10075'=>'a97',
  '10076'=>'a98',
  '10077'=>'a99',
  '10078'=>'a100',
  '10081'=>'a101',
  '10082'=>'a102',
  '10083'=>'a103',
  '10084'=>'a104',
  '10085'=>'a106',
  '10086'=>'a107',
  '10087'=>'a108',
  '10102'=>'a130',
  '10103'=>'a131',
  '10104'=>'a132',
  '10105'=>'a133',
  '10106'=>'a134',
  '10107'=>'a135',
  '10108'=>'a136',
  '10109'=>'a137',
  '10110'=>'a138',
  '10111'=>'a139',
  '10112'=>'a140',
  '10113'=>'a141',
  '10114'=>'a142',
  '10115'=>'a143',
  '10116'=>'a144',
  '10117'=>'a145',
  '10118'=>'a146',
  '10119'=>'a147',
  '10120'=>'a148',
  '10121'=>'a149',
  '10122'=>'a150',
  '10123'=>'a151',
  '10124'=>'a152',
  '10125'=>'a153',
  '10126'=>'a154',
  '10127'=>'a155',
  '10128'=>'a156',
  '10129'=>'a157',
  '10130'=>'a158',
  '10131'=>'a159',
  '10132'=>'a160',
  '10136'=>'a196',
  '10137'=>'a165',
  '10138'=>'a192',
  '10139'=>'a166',
  '10140'=>'a167',
  '10141'=>'a168',
  '10142'=>'a169',
  '10143'=>'a170',
  '10144'=>'a171',
  '10145'=>'a172',
  '10146'=>'a173',
  '10147'=>'a162',
  '10148'=>'a174',
  '10149'=>'a175',
  '10150'=>'a176',
  '10151'=>'a177',
  '10152'=>'a178',
  '10153'=>'a179',
  '10154'=>'a193',
  '10155'=>'a180',
  '10156'=>'a199',
  '10157'=>'a181',
  '10158'=>'a200',
  '10159'=>'a182',
  '10161'=>'a201',
  '10162'=>'a183',
  '10163'=>'a184',
  '10164'=>'a197',
  '10165'=>'a185',
  '10166'=>'a194',
  '10167'=>'a198',
  '10168'=>'a186',
  '10169'=>'a195',
  '10170'=>'a187',
  '10171'=>'a188',
  '10172'=>'a189',
  '10173'=>'a190',
  '10174'=>'a191',
  '63166'=>'dotlessj',
  '63167'=>'LL',
  '63168'=>'ll',
  '63169'=>'Scedilla',
  '63170'=>'scedilla',
  '63171'=>'commaaccent',
  '63172'=>'afii10063',
  '63173'=>'afii10064',
  '63174'=>'afii10192',
  '63175'=>'afii10831',
  '63176'=>'afii10832',
  '63177'=>'Acute',
  '63178'=>'Caron',
  '63179'=>'Dieresis',
  '63180'=>'DieresisAcute',
  '63181'=>'DieresisGrave',
  '63182'=>'Grave',
  '63183'=>'Hungarumlaut',
  '63184'=>'Macron',
  '63185'=>'cyrBreve',
  '63186'=>'cyrFlex',
  '63187'=>'dblGrave',
  '63188'=>'cyrbreve',
  '63189'=>'cyrflex',
  '63190'=>'dblgrave',
  '63191'=>'dieresisacute',
  '63192'=>'dieresisgrave',
  '63193'=>'copyrightserif',
  '63194'=>'registerserif',
  '63195'=>'trademarkserif',
  '63196'=>'onefitted',
  '63197'=>'rupiah',
  '63198'=>'threequartersemdash',
  '63199'=>'centinferior',
  '63200'=>'centsuperior',
  '63201'=>'commainferior',
  '63202'=>'commasuperior',
  '63203'=>'dollarinferior',
  '63204'=>'dollarsuperior',
  '63205'=>'hypheninferior',
  '63206'=>'hyphensuperior',
  '63207'=>'periodinferior',
  '63208'=>'periodsuperior',
  '63209'=>'asuperior',
  '63210'=>'bsuperior',
  '63211'=>'dsuperior',
  '63212'=>'esuperior',
  '63213'=>'isuperior',
  '63214'=>'lsuperior',
  '63215'=>'msuperior',
  '63216'=>'osuperior',
  '63217'=>'rsuperior',
  '63218'=>'ssuperior',
  '63219'=>'tsuperior',
  '63220'=>'Brevesmall',
  '63221'=>'Caronsmall',
  '63222'=>'Circumflexsmall',
  '63223'=>'Dotaccentsmall',
  '63224'=>'Hungarumlautsmall',
  '63225'=>'Lslashsmall',
  '63226'=>'OEsmall',
  '63227'=>'Ogoneksmall',
  '63228'=>'Ringsmall',
  '63229'=>'Scaronsmall',
  '63230'=>'Tildesmall',
  '63231'=>'Zcaronsmall',
  '63265'=>'exclamsmall',
  '63268'=>'dollaroldstyle',
  '63270'=>'ampersandsmall',
  '63280'=>'zerooldstyle',
  '63281'=>'oneoldstyle',
  '63282'=>'twooldstyle',
  '63283'=>'threeoldstyle',
  '63284'=>'fouroldstyle',
  '63285'=>'fiveoldstyle',
  '63286'=>'sixoldstyle',
  '63287'=>'sevenoldstyle',
  '63288'=>'eightoldstyle',
  '63289'=>'nineoldstyle',
  '63295'=>'questionsmall',
  '63328'=>'Gravesmall',
  '63329'=>'Asmall',
  '63330'=>'Bsmall',
  '63331'=>'Csmall',
  '63332'=>'Dsmall',
  '63333'=>'Esmall',
  '63334'=>'Fsmall',
  '63335'=>'Gsmall',
  '63336'=>'Hsmall',
  '63337'=>'Ismall',
  '63338'=>'Jsmall',
  '63339'=>'Ksmall',
  '63340'=>'Lsmall',
  '63341'=>'Msmall',
  '63342'=>'Nsmall',
  '63343'=>'Osmall',
  '63344'=>'Psmall',
  '63345'=>'Qsmall',
  '63346'=>'Rsmall',
  '63347'=>'Ssmall',
  '63348'=>'Tsmall',
  '63349'=>'Usmall',
  '63350'=>'Vsmall',
  '63351'=>'Wsmall',
  '63352'=>'Xsmall',
  '63353'=>'Ysmall',
  '63354'=>'Zsmall',
  '63393'=>'exclamdownsmall',
  '63394'=>'centoldstyle',
  '63400'=>'Dieresissmall',
  '63407'=>'Macronsmall',
  '63412'=>'Acutesmall',
  '63416'=>'Cedillasmall',
  '63423'=>'questiondownsmall',
  '63456'=>'Agravesmall',
  '63457'=>'Aacutesmall',
  '63458'=>'Acircumflexsmall',
  '63459'=>'Atildesmall',
  '63460'=>'Adieresissmall',
  '63461'=>'Aringsmall',
  '63462'=>'AEsmall',
  '63463'=>'Ccedillasmall',
  '63464'=>'Egravesmall',
  '63465'=>'Eacutesmall',
  '63466'=>'Ecircumflexsmall',
  '63467'=>'Edieresissmall',
  '63468'=>'Igravesmall',
  '63469'=>'Iacutesmall',
  '63470'=>'Icircumflexsmall',
  '63471'=>'Idieresissmall',
  '63472'=>'Ethsmall',
  '63473'=>'Ntildesmall',
  '63474'=>'Ogravesmall',
  '63475'=>'Oacutesmall',
  '63476'=>'Ocircumflexsmall',
  '63477'=>'Otildesmall',
  '63478'=>'Odieresissmall',
  '63480'=>'Oslashsmall',
  '63481'=>'Ugravesmall',
  '63482'=>'Uacutesmall',
  '63483'=>'Ucircumflexsmall',
  '63484'=>'Udieresissmall',
  '63485'=>'Yacutesmall',
  '63486'=>'Thornsmall',
  '63487'=>'Ydieresissmall',
  '63703'=>'a89',
  '63704'=>'a90',
  '63705'=>'a93',
  '63706'=>'a94',
  '63707'=>'a91',
  '63708'=>'a92',
  '63709'=>'a205',
  '63710'=>'a85',
  '63711'=>'a206',
  '63712'=>'a86',
  '63713'=>'a87',
  '63714'=>'a88',
  '63715'=>'a95',
  '63716'=>'a96',
  '63717'=>'radicalex',
  '63718'=>'arrowvertex',
  '63719'=>'arrowhorizex',
  '63720'=>'registersans',
  '63721'=>'copyrightsans',
  '63722'=>'trademarksans',
  '63723'=>'parenlefttp',
  '63724'=>'parenleftex',
  '63725'=>'parenleftbt',
  '63726'=>'bracketlefttp',
  '63727'=>'bracketleftex',
  '63728'=>'bracketleftbt',
  '63729'=>'bracelefttp',
  '63730'=>'braceleftmid',
  '63731'=>'braceleftbt',
  '63732'=>'braceex',
  '63733'=>'integralex',
  '63734'=>'parenrighttp',
  '63735'=>'parenrightex',
  '63736'=>'parenrightbt',
  '63737'=>'bracketrighttp',
  '63738'=>'bracketrightex',
  '63739'=>'bracketrightbt',
  '63740'=>'bracerighttp',
  '63741'=>'bracerightmid',
  '63742'=>'bracerightbt',
  '64256'=>'ff',
  '64257'=>'fi',
  '64258'=>'fl',
  '64259'=>'ffi',
  '64260'=>'ffl',
  '64287'=>'afii57705',
  '64298'=>'afii57694',
  '64299'=>'afii57695',
  '64309'=>'afii57723',
  '64331'=>'afii57700',
  ''=>'.notdef'
);

}
