use Text::PDF::API;
use Test;

BEGIN { plan tests => 3  }

sub test_us {
        use Digest::REHLHA qw( rehlha0_16 );
        my ($dig,$sig)=@_;
        $dig=~s/[\x00-\x20\xa0-\xff]+//cgim;
        $dig=rehlha0_16($dig);
        ok($dig,$sig);
}

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
                test_us($pdf->stringify,'D09YBq0TgSmPegQ1');
	$pdf->newFontTTF('Some,other,font','somewhereinspace.ttf'); 
                test_us($pdf->stringify,'TI0vjEKf3Fd6m2iI');
	$pdf->useFont('Some,other,font',20,'latin1'); 
                test_us($pdf->stringify,'jSsgp2vniBvmw1WS');
        $pdf->end;
                test_us($pdf->stringify,'jSsgp2vniBvmw1WS');
__END__
