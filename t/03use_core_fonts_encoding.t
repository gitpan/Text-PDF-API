use Text::PDF::API;
use Test;

BEGIN { plan tests => 6 }

sub test_us {
	use MD5;
	use Data::DumpXML qw( dump_xml );
	my ($pdf,$sig)=@_;
	my $dig=dump_xml($pdf); 
	$dig=~s/[\x00-\x20\s]+//cgi; 
	$dig=MD5->hexhash($dig); 
	ok($dig,$sig);
}

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	$pdf->newFontCore('Times-Bold'); 
	$pdf->useFont('Times-Bold',2,'Adobe-Standard'); test_us($pdf,'a5a6d4ff7e1e6ef1a42317870c3ef703');
	$pdf->useFont('Times-Bold',2,'cp437'); test_us($pdf,'7d237de1f0bcece73e34b675f6d38606');
	$pdf->useFont('Times-Bold',2,'cp850'); test_us($pdf,'4d2932086b5d308efb9631f5a211ca38');
	$pdf->useFont('Times-Bold',2,'ISO_8859-1'); test_us($pdf,'a62212b1e6cbc0ca1e7305ff2fc6c649');
	$pdf->useFont('Times-Bold',2,'MacRoman'); test_us($pdf,'3f4eae6d5249f4ac5ad285dfd00a8ec1');
	$pdf->useFont('Times-Bold',2,'WinLatin1'); test_us($pdf,'eca04409286075f0267aecf72f122c37');
        $pdf->end;
__END__
