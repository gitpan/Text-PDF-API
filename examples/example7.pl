use Text::PDF::API;

	$d=-20;
        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
        $pdf->newpage();
        $pdf->newFont('Helvetica-Bold');
	$pdf->useFont('Helvetica-Bold',10);
        $pdf->useGfxLineWidth(0.5);
	$la=0;
	foreach $x (10,20,40,80,120,200,290,300,330,360) {
		$pdf->moveTo(250,400);
		($px,$py,$p2x,$p2y)=$pdf->arcXYabDG(250,400,100,60,$la,$x,0,1);
		$pdf->lineTo($px,$py);
		$pdf->arcXYabDG(250,400,100,60,$la,$x);
		$pdf->stroke();
		($px,$py,$p2x,$p2y)=$pdf->arcXYabDG(250,400,100,60,$la,($x+$la)/2,0,1);
		$pdf->showTextXY_C($p2x,$p2y,$x);
		if ($x >180){
			if($la>180) {
				($p1x,$p1y,$p2x,$p2y)=$pdf->arcXYabDG(250,400,100,60,$la,$x,1);
				$pdf->lineTo($p2x,$p2y+$d);
				($p1x,$p1y,$p2x,$p2y)=$pdf->arcXYabDG(250,400+$d,100,60,$x,$la);
				$pdf->closestroke();
			} else {
				($p1x,$p1y,$p2x,$p2y)=$pdf->arcXYabDG(250,400,100,60,180,$x,1);
				$pdf->lineTo($p2x,$p2y+$d);
				($p1x,$p1y,$p2x,$p2y)=$pdf->arcXYabDG(250,400+$d,100,60,$x,180);
				$pdf->closestroke();
			}
		}
		$la=$x;
	}
        $pdf->endpage();
        $pdf->saveas("example7.pdf");
        $pdf->end;
