use Text::PDF::API;
use Test;

BEGIN { plan tests => 1 }
sub test_us {
        use Text::PDF::API::REHLHA qw( rehlha_16 );
        my ($pdf,$sig)=@_;
        my $dig=rehlha_16($pdf); 
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
