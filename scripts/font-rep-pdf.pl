#!/usr/bin/perl

@en = qw( 
	Adobe-Standard Adobe-Symbol Adobe-Zapf-Dingbats 
	ISO_8859-1 ISO_8859-15 
	Latin-greek-1 
	Microsoft-Dingbats 
	cp1250 cp1251 cp1252 cp437 cp850 
	hp-roman8 
	macintosh 
);

if(!@ARGV) {
print qq|font-rep-pdf version 2000-12-31

options:

	-ttf  <font-file>
	-psf  <pfa/pfb-file>
	-afm  <afm-file>
	-name <font-name>
	-pdf  <pdf-name>
	-enc  <encoding>

required:
	either -ttf OR -psf & -afm OR -name
optional:
	-pdf , -enc

note:
	you can test fonts under common encodings with this utility.

	see 'umap -l' for a list of supported encodings

examples:
	
	font-rep-pdf.pl -ttf some-other-font.ttf

	font-rep-pdf.pl -name "Times-Roman" -enc latin1

	font-rep-pdf.pl -psf some-type1-font.pfb -afm some-type1-font.afm 
	
	font-rep-pdf.pl -psf some-type1-font2.pfa -afm some-type1-font2.afm 
|;
}

while($arg=shift @ARGV) {
	if($arg EQ '-ttf') {
		$ttf=shift @ARGV;
	} elsif($arg EQ '-psf') {
		$psf=shift @ARGV;
	} elsif($arg EQ '-afm') {
		$afm=shift @ARGV;
	} elsif($arg EQ '-name') {
		$name=shift @ARGV;
	} elsif($arg EQ '-pdf') {
		$out=shift @ARGV;
	} elsif($arg EQ '-enc') {
		@en=(shift @ARGV);
	} else {
		print STDERR "unsupported argument '$arg'\n";
	}
}

if($name) {$fn=$name;}

if($afm && $psf) {
	$fn=$fn || $fx[0].'-PS'; 
	@fx=($fn,$psf,$afm);
} elsif($ttf) {
	$fn=$fn || $fx[0].',TT'; 
	@fx=($fn,$ttf);
} elsif($name) {
	@fx=($name);
} else {
	die q|wrong arguments ...|;
}

if(!$out) {
	$out=$fx[0];
	$out=~s/^.*\///cgi;
	$out=~s/[^a-z0-9\-\.]+/-/cgi;
	$out.=".pdf";
}
	use POSIX qw( floor );
        use Text::PDF::API;
	
        $pdf=Text::PDF::API->new('pagesize'=>'a4','compression'=>1);
	$f1='Helvetica-Bold';
	$pdf->newFont($f1,'latin1');
        $pdf->newFont(@fx,'latin1');
	foreach $e (@en) {
		print "$e\n";
       		$pdf->newpage();
        	$pdf->useFont($f1,20);
		$pdf->showTextXY(50,800,"Font: $fn");
        	$pdf->useFont($f1,10);
		$pdf->showTextXY(50,785,"Encoding: $e");
		foreach $c (0..255) {
        		$pdf->useFont($fn,20,$e);
			$x=50+($c%16)*32;
			$y=700-floor($c/16)*35;
       			$pdf->showTextXY($x,$y,pack('C',$c));
			$y-=10;
        		$pdf->useFont($f1,7);
			$pdf->showTextXY($x,$y,$c);
		}
		$pdf->endpage();
	}
	print qq|Writing pdf to file '$out' ... |;
        $pdf->saveas($out);
	print qq|done.\n|;
        $pdf->end;

__END__
