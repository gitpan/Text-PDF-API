use Text::PDF::API;
use Test;

BEGIN { plan tests => 1 }

sub test_us {
        use Digest::REHLHA qw( rehlha0_16 );
        my ($dig,$sig)=@_;
        $dig=~s/[\x00-\x20\xa0-\xff]+//cgim;
        $dig=rehlha0_16($dig);
        ok($dig,$sig);
}

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
        	test_us($pdf->stringify,'D09YBq0TgSmPegQ1');
	# $pdf->newFont('Courier-Bold'); 
        #	test_us($pdf->stringify,'Z9EEcKi9vDXzc9zc');
	# $pdf->newFont('Helvetica-Bold'); 
        #	test_us($pdf->stringify,'uZoLNK3YVpUhhhfT');
	# $pdf->newFont('Symbol'); 
        #	test_us($pdf->stringify,'o3XiBnfD.QrhIwbx');
	# $pdf->newFont('Times-Roman'); 
        #	test_us($pdf->stringify,'CpZx.t9zCw914x5D');
	# $pdf->newFont('ZapfDingbats'); 
        #	test_us($pdf->stringify,'pUK7cSwtWfKmjUt4');
        # $pdf->end;
        #	test_us($pdf->stringify,'2Zsx5cHNphWLnZCu');
__END__
