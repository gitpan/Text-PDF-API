use Color::Object;
use Text::PDF::API;

        $d=-20;
        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
        $pdf->newpage();
        $pdf->newFont('Times-Roman');
        $pdf->newFont('Helvetica-Bold');
        $pdf->useFont('Helvetica-Bold',10);

	$t=$ARGV[0];
	$h=842/$t;
	$c=Color::Object->newRGB(1,0,0);
	foreach $x (0..($t-1)) {
		$pdf->setColorFill($c->asRGB);
		$pdf->rect(0,$x*$h,75,$h);
		$pdf->closefill;
		$pdf->setColorFill(map{ $_*0.77 }$c->asRGB);
		$pdf->rect(75,$x*$h,150,$h);
		$pdf->closefill;
		$pdf->setColorFill($c->asCMY,0);
		$pdf->rect(150,$x*$h,225,$h);
		$pdf->closefill;
		$pdf->setColorFill($c->asCMYK);
		$pdf->rect(225,$x*$h,262,$h);
		$pdf->closefill;
		$pdf->setColorFill(map{$_*0.77}$c->asCMY,0);
		$pdf->rect(262,$x*$h,300,$h);
		$pdf->closefill;
		$pdf->setColorFill($c->asGrey);
		$pdf->rect(300,$x*$h,450,$h);
		$pdf->closefill;
		$pdf->setColorFill($c->asGrey2);
		$pdf->rect(450,$x*$h,600,$h);
		$pdf->closefill;
		$c->rotHue(360/$t);
	}
        $pdf->endpage();
        $pdf->saveas("$0.pdf");
        $pdf->end;



__END__

