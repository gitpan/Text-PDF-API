use Color::Object;
use Text::PDF::API;

        $f=5;
        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>1);
        $pdf->newFont('Helvetica-Bold');
        $pdf->useFont('Helvetica-Bold',$f);
	$ff=Color::Object->new();
	@colors=sort keys %col;
	foreach $h(0,60,120,180,240,300) {
        	$pdf->newpage();
		foreach $s (0,0x33,0x66,0x99,0xCC,0xFF) {
			foreach $b (0,0x33,0x66,0x99,0xCC,0xFF) {
				$ff->setHSV($h,$s/255,$b/255);
				$x=50+592*$s/300;
				$y=50+842*$b/300;
				$pdf->setColorFill($ff->asCMYK);
				$pdf->circleXYR($x,$y,20);
				$pdf->fill;
			}
		}
		
        	$pdf->endpage();
	}

        $pdf->saveas("$0.pdf");
        $pdf->end;
__END__
