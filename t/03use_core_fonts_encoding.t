use Text::PDF::API;
use Test;

BEGIN { plan tests => 6 }

sub test_us {
        use Digest::REHLHA qw( rehlha0_16 );
        my ($dig,$sig)=@_;
        $dig=~s/[\x00-\x20\xa0-\xff]+//cgim;
        $dig=rehlha0_16($dig);
        ok($dig,$sig);
}

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
                test_us($pdf->stringify,'D09YBq0TgSmPegQ1');
	$pdf->newFontCore('Times-Bold'); 
                test_us($pdf->stringify,'jRDgNlOUs5CeUsx.');
	$pdf->useFont('Times-Bold',2,'Adobe-Standard'); 
                test_us($pdf->stringify,'X2aPh02nt2D8qppp');
	$pdf->useFont('Times-Bold',2,'latin1'); 
                test_us($pdf->stringify,'XCGNm2CMnWdMrKH6');
	$pdf->useFont('Times-Bold',2,'MacRoman'); 
                test_us($pdf->stringify,'sVliNF6dklPow0ms');
        $pdf->end;
                test_us($pdf->stringify,'HNijnUGYWzIjGO0w');

__END__