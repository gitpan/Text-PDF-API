#!/usr/local/bin/perl

        use Text::PDF::API;
        $pdf=Text::PDF::API->new('pagesize'=>'a4','compression'=>1);
	foreach $f (qw|
        	Courier         Courier-Bold    Courier-Oblique         Courier-BoldOblique
        	Times-Roman     Times-Bold      Times-Italic            Times-BoldItalic
        	Helvetica       Helvetica-Bold  Helvetica-Oblique       Helvetica-BoldOblique
        	Symbol ZapfDingbats 
	|) {
        	$pdf->newpage();
        	$pdf->newFont($f);
        	$pdf->useFont($f,20);
		foreach $x (0..15) {
			foreach $y (0..15) {
				$pdf->showTextXY(
					30+(30*$x),
					800-(40*$y),
					pack('C',($x*16)+$y)
				);
			}
		}
        	$pdf->endpage();
	}
        $pdf->saveas("example3.pdf");
        $pdf->end;

__END__
