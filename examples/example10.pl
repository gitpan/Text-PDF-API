use Text::PDF::API::Color;
use Text::PDF::API;
use Math::Trig;

        $d=-20;
        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
        $pdf->newpage();

	$x=250;
	$y=600;
	$r=10;
	$c=Text::PDF::API::Color->new;
	foreach $l (0,0.25,0.5,0.75,1) {
		
		foreach $d (0,30,60,90,120,150,180,210,240,270,300,330) {
			$c->setHSV($d,1,$l**0.5);
			$x1=cos(deg2rad($d))*(2*$r*$l*4);
			$y1=sin(deg2rad($d))*(2*$r*$l*4);
			$pdf->setColorFill($c->asCMYK);
			printf "r=%f,g=%f,b=%f\n",$c->asRGB;
			printf "c=%f,m=%f,y=%f,k=%f\n",$c->asCMYK;
			$pdf->circleXYR($x+$x1,$y+$y1,$r);
			$pdf->fill;
			$c->rotHue(30);
		}
	}
        $pdf->endpage();
        $pdf->saveas("$0.pdf");
        $pdf->end;



__END__

