package Text::PDF::API;

$VERSION = "0.05";

use Text::PDF::File;
use Text::PDF::Page;
use Text::PDF::Utils;
use Text::PDF::SFont;
use Text::PDF::TTFont;
use Text::PDF::TTFont0;

@Text::PDF::API::parameterlist=qw(
	pagesize
	pagewidth
	pageheight
	pageorientation
	compression
	pdfversion
);

@Text::PDF::API::COREFONTS=(
	@Text::PDF::API::CORETYPEFONTS,
	@Text::PDF::API::CORESYMBOLFONTS
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
	#	$this->{'PAGE'}->ship_out($this->{'PDF'});
	#	$this->{'PAGE'}->empty;
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
	use Unicode::Map8;
	my $m= Unicode::Map8->new($enc);
	return($m->to_char16($char));
}

sub lookUPu2c {
	my ($this,$enc,$char)=@_;
	use Unicode::Map8;
	my $m= Unicode::Map8->new($enc);
	return($m->to_char8($char));
}

sub lookUPu2n {
	my ($this,$ucode)=@_;
}

sub lookUPn2c {
	my ($this,$name)=@_;
}

sub lookUpEncoding {
	my ($this,$encoding,$code)=@_;
	if(!$this->{'ENCODINGS'}){
		use Text::PDF::API::Encoding;
		$this->{'ENCODINGS'}=Text::PDF::API::Encoding->new;
		die "cannot add encoding named '$encoding', either unsupported or unknown" unless $this->{'ENCODINGS'}->add($encoding);
	}
	return $this->{'ENCODINGS'}->lookUp($encoding,$code);
}

sub addEncoding {
	my ($this,$encoding)=@_;
	if(!$this->{'ENCODINGS'}){
		use Text::PDF::API::Encoding;
		$this->{'ENCODINGS'}=Text::PDF::API::Encoding->new;
		return undef unless $this->{'ENCODINGS'};
	}
	return $this->{'ENCODINGS'}->add($encoding);
}

sub resolveFontFile {
	my $this=shift @_;
	my $file=shift @_;
	my $fontfile=undef;
	map {
		$fontfile="$_/PDF/API/fonts/$file";
		if(-e $fontfile) { return $fontfile; }
	} @INC;
	if( -e $this->{'FONTDIR'}.'/'.$file ) {
		$fontfile=$this->{'FONTDIR'}.'/'.$file;
		return $fontfile;
	} elsif ( -e $file ) {
		$fontfile=$file;
		return $fontfile;
	} else {
		foreach my $dir (@{$this->{'FONTPATH'}}) {
			if( -e $dir.'/'.$file ) {
				$fontfile=$dir.'/'.$file;
				return $fontfile;
			}
		}
	}
	return undef;
}

sub newFont {
	use Digest::MD5 qw( md5_hex );
	my ($this,$name,$file,$file2,$encoding);
	my ($fontfile,$fontfile2,$fontkey,$ttf,$font,$glyph,$fontype,$fontname,@map);

	$this=shift @_;
	$name=shift @_;
	$fontkey=md5_hex($this.$name);

	if(!$this->{'FONTS'}) {
		$this->{'FONTS'}={};
	}

	if(!$this->{'FONTS'}->{$fontkey}) {
		if(grep(/$name/,@Text::PDF::API::COREFONTS)) {
			$fontype='CORE';
			$fontname='F'.$fontype.'0x0'.$fontkey;
			if($^O eq "MacOS") {
				$font=Text::PDF::SFont->new($this->{'PDF'}, $name, $fontname, 2);
			} elsif ($^O eq "MSWin32") {
				$font=Text::PDF::SFont->new($this->{'PDF'}, $name, $fontname, 1);
			} else {
				$font=Text::PDF::SFont->new($this->{'PDF'}, $name, $fontname, 1);
			}
		} elsif($name=~/\,/) {
			$fontype='TT0';
			$fontname='F'.$fontype.'0x0'.$fontkey;
			$file=shift @_;
			$fontfile=$this->resolveFontFile($file);
			die "can not find requested font '$file'" unless($fontfile);

			$font=Text::PDF::TTFont0->new($this->{'PDF'}, $fontfile, $fontname);
		} else {
			$fontype='APS';
			$fontname='F'.$fontype.'0x0'.$fontkey;
			$file=shift @_;
			$file2=shift @_;
			$fontfile=$this->resolveFontFile($file);
			$fontfile2=$this->resolveFontFile($file2);
			$this->_error('newFont',"unresolved file-reference font='$name', file='$fontfile'") unless($fontfile);
			$this->_error('newFont',"unresolved file-reference font='$name', file='$fontfile2'") unless($fontfile2);
		# supposed extension to the pdf postscript font handling in Text::PDF
		# $fontfile = pfb-file and $fontfile2 = afm-file
		#	$font=Text::PDF::AFont->new($this->{'PDF'}, $fontfile, $fontfile2, $fontname);
		}
		$this->{'FONTS'}->{$fontkey}={
			'type'	=> $fontype,
			'pdfobj'=> $font,
		};
		if(!$this->_getCurrent('Root')) {
			$this->_newroot();
		}
		$this->{'ROOT'}->add_font($font);
	} else {
		if(!grep(/$name/,@Text::PDF::API::COREFONTS)) {
			shift @_;
		}
		$fontype=$this->{'FONTS'}->{$fontkey}->{'type'};
		$font=$this->{'FONTS'}->{$fontkey}->{'pdfobj'};
	} 

	#if($^O eq "MacOS") {
	#	($encoding)=$this->addEncoding(shift @_ || 'MacRoman');
	#} elsif ($^O eq "MSWin32") {
	#	($encoding)=$this->addEncoding(shift @_ || 'MicrosoftAnsi');
	#} else {
	#	($encoding)=$this->addEncoding(shift @_ || 'Latin1');
	#}

	if(grep(/$name/,@Text::PDF::API::CORETYPEFONTS)) {
		if(!$font->{'Encoding'}){
			$font->{'Encoding'}=PDFDict();
			$font->{'Encoding'}->{'Type'}=PDFName('Encoding');
			if($^O eq "MacOS") {
				$font->{'Encoding'}->{'BaseEncoding'}=PDFName('MacRomanEncoding');
			} elsif ($^O eq "MSWin32") {
				$font->{'Encoding'}->{'BaseEncoding'}=PDFName('WinAnsiEncoding');
			} else {
				$font->{'Encoding'}->{'BaseEncoding'}=PDFName('WinAnsiEncoding');
			#	$font->{'Encoding'}->{'Differences'}=PDFArray();
			#	foreach my $x (1..255) {
			#		if($this->{'ENCODINGS'}->{'ISOLatin1'}{'e2n'}{$x}) {
			#			$font->{'Encoding'}->{'Differences'}->add_elements(PDFNum($x),PDFName($this->{'ENCODINGS'}->{'ISOLatin1'}{'e2n'}{$x}));
			#		}
			#	}
			}
		}
	} elsif(grep(/$name/,@Text::PDF::API::CORESYMBOLFONTS)) {
	} elsif($fontype EQ 'APS') {
	} elsif($fontype EQ 'TT0') {
		$ttf=$font->{' font'};
		$ttf->{'cmap'}->read;
		$ttf->{'hmtx'}->read;
		$ttf->{'post'}->read;
		my $upem = $ttf->{'head'}->read->{'unitsPerEm'};
		if(!$this->{'FONTS'}->{$fontkey}->{'u2g'}) {
			$this->{'FONTS'}->{$fontkey}->{'u2g'}=();
			$this->{'FONTS'}->{$fontkey}->{'u2w'}=();
			@map=$ttf->{'cmap'}->reverse;
			foreach my $x (0..$#map) {
				$this->{'FONTS'}->{$fontkey}->{'u2g'}{$map[$x]}=$x;
				$this->{'FONTS'}->{$fontkey}->{'u2w'}{$map[$x]}=$ttf->{'hmtx'}{'advance'}[$x]/$upem;
			}
		}
	} else {
		$this->_error('newFont',"unresolved encoding dependency name='$name', type='$fontype', encoding='$encoding' ");
	}
	if(1) {
		return $fontkey;
	} else {
		return ($fontkey,$encoding);
	}
}

sub getFont {
	use Digest::MD5 qw( md5_hex );
	my ($this,$name)=@_;
	my $fontkey=md5_hex($this.$name);
	if($this->{'FONTS'}->{$fontkey}) {
		return $fontkey;
	} else {
		return undef;
	}
}

sub _getFontpdfname {
	use Digest::MD5 qw( md5_hex );
	my ($this,$name)=@_;
	my $fontkey=md5_hex($this.$name);
	if($this->{'FONTS'}->{$fontkey}) {
		return 'F'.$this->{'FONTS'}->{$fontkey}->{'type'}.'0x0'.$fontkey;
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
	use Digest::MD5 qw( md5_hex );
	my ($this,$name,$size,$enc)=@_;
	my $fontkey=md5_hex($this.$name);
	$this->initFontCurrent;
	$this->{'CURRENT'}{'font'}{'Name'}=$name;
	$this->{'CURRENT'}{'font'}{'Key'}=$fontkey;
	$this->{'CURRENT'}{'font'}{'PDFN'}=$this->_getFontpdfname($name);
	$this->{'CURRENT'}{'font'}{'Size'}=$size;
	$this->{'CURRENT'}{'font'}{'Type'}=$this->{'FONTS'}->{$fontkey}{'type'};
	$this->{'CURRENT'}{'font'}{'Encoding'}=$enc || 'Latin1';

}

sub setFontTranslate {
	use Math::Matrix;
	my ($this,$x,$y)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixTranslate'}) {
		$this->{'CURRENT'}{'font'}{'MatrixTranslate'}=Math::Matrix->new(
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
	use Math::Matrix;
	my ($this,$x,$y)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixScale'}) {
		$this->{'CURRENT'}{'font'}{'MatrixScale'}=Math::Matrix->new(
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
	use Math::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixSkew'}) {
		$this->{'CURRENT'}{'font'}{'MatrixSkew'}=Math::Matrix->new(
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
	use Math::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixRotation'}) {
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}=Math::Matrix->new(
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
	use Math::Matrix;
	my ($this)=@_;
	my $tm=Math::Matrix->new([1,0,0],[0,1,0],[0,0,1]);
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

sub calcTextWidth {
	my ($this,$text)=@_;

	my $k=$this->{'CURRENT'}{'font'}{'Key'};
	my $size=$this->{'CURRENT'}{'font'}{'Size'};
	my $enc=$this->{'CURRENT'}{'font'}{'Encoding'};
	my $font=$this->{'FONTS'}{$k}{'pdfobj'};
	my $type=$this->{'FONTS'}{$k}{'type'};
	my $wm=0;

	$this->calcFontMatrix;

	if($type EQ 'CORE') {
		$wm=$font->width($text)*$size;
	} elsif($type EQ 'TT0') {
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

sub showText {
	my ($this,$text)=@_;
	$this->initFontCurrent;
	my $k=$this->{'CURRENT'}{'font'}{'Key'};
	my $font=$this->{'CURRENT'}{'font'}{'PDFN'};
	my $size=$this->{'CURRENT'}{'font'}{'Size'};
	my $enc=$this->{'CURRENT'}{'font'}{'Encoding'};
	my @tm=@{$this->{'CURRENT'}{'font'}{'Matrix'}};
	
	my $cs=$this->{'CURRENT'}{'font'}{'CharSpacing'} || 0;
	my $ws=$this->{'CURRENT'}{'font'}{'WordSpacing'} || 0;
	my $tl=$this->{'CURRENT'}{'font'}{'TextLeading'} || 0;
	my $ts=$this->{'CURRENT'}{'font'}{'TextRise'} || 0;
	my $tr=$this->{'CURRENT'}{'font'}{'TextRendering'} || 0;

	$this->_addtopage(sprintf("BT %.9f Tc %.9f Tw %.9f TL %.9f Ts %i Tr /$font %.9f Tf %.9f %.9f %.9f %.9f %.9f %.9f Tm <",$cs,$ws,$tl,$ts,$tr,$size,@tm));
	foreach my $c (split(//,$text)) {
		if($this->{'CURRENT'}{'font'}{'Type'} EQ 'CORE') {
			$this->_addtopage(sprintf('%02x',unpack('C',$c)));
		} else {
			$this->_addtopage(sprintf('%04x',$this->{'FONTS'}{$k}{"u2g"}{$this->lookUPc2u($enc,ord($c))}));
		}
	}
	$this->_addtopage("> Tj ET\n");
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
	my $k=$this->getFont($font);
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
	use Math::Matrix;
	my ($this,$x,$y)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixTranslate'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixTranslate'}=Math::Matrix->new(
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
	use Math::Matrix;
	my ($this,$x,$y)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixScale'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixScale'}=Math::Matrix->new(
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
	use Math::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixSkew'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixSkew'}=Math::Matrix->new(
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
	use Math::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixRotation'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixRotation'}=Math::Matrix->new(
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
	use Math::Matrix;
	my ($this)=@_;
	my $tm=Math::Matrix->new(
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

	$this->_addtopage(join(' ',@tm)." cm\n");
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

sub ellipsisXYAB {
	my ($this,$x,$y,$a,$b)=@_;
	$this->moveTo($x-$a,$y);
	$this->curveTo($x-$a,$y+($b*4/3),$x+$a,$y+($b*4/3),$x+$a,$y);
	$this->curveTo($x+$a,$y-($b*4/3),$x-$a,$y-($b*4/3),$x-$a,$y);
	$this->closePath;
}

sub circleXYR {
	my ($this,$x,$y,$r)=@_;
	$this->ellipsisXYAB($x,$y,$r,$r);
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

sub newImage {
	use Digest::MD5 qw( md5_hex );
	my ($this,$file)=@_;
	my $xo;
	my $key='IMAGE0x0'.md5_hex($this.$file);

	use Text::PDF::API::Image;
	my ($w,$h,$bpc,$cs,$img)=Text::PDF::API::Image::parseImage($file);

	if(!defined($this->{'IMAGES'}{$key})) {
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

=item $pdf->newFont $name, $ttfile

=item $pdf->newFont $name 

Adds a new font to the pdf-object. Based on the fonts name
either a core, truetype or postscript font is assumed:
TrueType have a ',' between the family and style names whereas
the postscript and core fonts use a '-'.

B<BEWARE:> Postscript fonts other than the core fonts are not supported 
AND you have only one encoding available for the core fonts.

=item $pdf->addCoreFonts 

This is a shortcut to add all pdf-core-fonts to the pdf-object.

=item $pdf->useFont $name, $size,$encoding

This selects the font at the specified size and encoding.
The font must have been loaded with the same $name 
parameter with $pdf->newFont

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

=head2 Text Methods

=over 4

=item $pdf->showText $text

Displays the $text based on the parameters given by the *Font* functions.

=item $pdf->showTextXY $x, $y, $text

=item $pdf->showTextXY_R $x, $y, $text

=item $pdf->showTextXY_C $x, $y, $text

Like $pdf->showText but overrides the x,y-offsets of the Matrices.
The *_R and *_C variants perform right and center alignment !

=item $pdf->printText $x, $y, $font, $size, $encoding, $text

Like a $pdf->useFont followed by a $pdf->showTextXY.

=item $pdf->calcTextWidth $text

Calculates the width of the text based on the parameters set by useFont.

B<BEWARE:> Does not consider parameters specified by setFont* and *Matrix functions.

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

=item ( $key , $width , $height ) = $pdf->newImage $imgobj

Current loading support includes NetPBM images of the
RAW_BITS variation and non-interlaced/non-filtered PNG.
Transperancy/Opacity information is currently ignored
as well as Alpha-Channel information.

The usage of GD::Image (GIF or PNG/JPEG) or Image::* (XBM/XPM)
objects will be supported in the near future.

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

=back

=head1 BUGS

MANY! If you find some report them to L<perl-text-pdf-modules@egroups.com>.

=head1 TODO ( in no particular order )

documentation ?

drawing functions ?

more encodings ?

fix encoding for core fonts ?

bitmap import functions (jpeg,xbm,xpm, ...?)

=cut
