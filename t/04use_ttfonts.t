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
#	$pdf->newFontTTF('Some,other,font','somewhereinspace.ttf'); 
 #               test_us($pdf->stringify,'TI0vjEKf3Fd6m2iI');
#	$pdf->useFont('Some,other,font',20,'latin1'); 
 #               test_us($pdf->stringify,'jSsgp2vniBvmw1WS');
  #      $pdf->end;
   #             test_us($pdf->stringify,'jSsgp2vniBvmw1WS');
__END__
