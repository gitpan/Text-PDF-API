        use Text::PDF::API;
        $pdf=Text::PDF::API->new('compression'=>1);
        $pdf->newpage(2376,2376);
        $pdf->newFont('arial,normal','/web/arial.ttf');
        $pdf->useGfxLineWidth(1);
        $pdf->useGfxLineDash(3,3);
	foreach $x (1..32) {
		$pdf->lineXY($x*72,72,$x*72,2304);$pdf->stroke;
		$pdf->lineXY(72,$x*72,2304,$x*72);$pdf->stroke;
	}
        $pdf->useFont('arial,normal',10,'latin1');
	foreach $x (1..31) {
		foreach $y (1..31) {
        		$pdf->showTextXY(3+($x*72),3+($y*72),sprintf("%i,%i",$x,$y));
		}
	}
        $pdf->endpage();
        $pdf->saveas("example2.pdf");
        $pdf->end;
