use Text::PDF::API;
use Test;

BEGIN { plan tests => 14 }

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
	$pdf->newFont('Courier-Bold'); test_us($pdf,'cf17c0aeef705d59932b1e47a95ad600');
	$pdf->newFont('Courier-BoldOblique'); test_us($pdf,'79eff568a06ff940117e05c5e16e9d41');
	$pdf->newFont('Courier-Oblique'); test_us($pdf,'f13074d9b652c187636ccabd43bcb8f8');
	$pdf->newFont('Courier'); test_us($pdf,'304ea4816fd50ca1a583301d3dda45cf');
	$pdf->newFont('Helvetica-Bold'); test_us($pdf,'6a1ef41e7247235d0b20287aafce1794');
	$pdf->newFont('Helvetica-BoldOblique'); test_us($pdf,'66805a3f47dfd06bfbf2fec5c656c488');
	$pdf->newFont('Helvetica-Oblique'); test_us($pdf,'532c921d660aa2f9021f74986be6f4cb');
	$pdf->newFont('Helvetica'); test_us($pdf,'7c8013534afcf90d54dd21e61dba2922');
	$pdf->newFont('Symbol'); test_us($pdf,'74307c37cd1488fe4269e6cc83e59241');
	$pdf->newFont('Times-Bold'); test_us($pdf,'abda2b1626dc267f5890a67d19ad8890');
	$pdf->newFont('Times-BoldItalic'); test_us($pdf,'9c3221a29101cd12afd4ded750358ef3');
	$pdf->newFont('Times-Italic'); test_us($pdf,'8e99d11b5590403f0b047bc0ef77f990');
	$pdf->newFont('Times-Roman'); test_us($pdf,'206be48d06380697d24500af56ed4137');
	$pdf->newFont('ZapfDingbats'); test_us($pdf,'1fed1caa5139468ff11e043b6b92848a');
        $pdf->end;
__END__
