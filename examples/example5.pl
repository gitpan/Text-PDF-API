#!/usr/local/bin/perl

        use Text::PDF::API;
        $pdf=Text::PDF::API->new('pagesize'=>'a4','compression'=>0);
        $pdf->newpage();
	$fn='Helvetica-Bold';
        $fk=$pdf->newFont($fn,'EBCDIC-AT-DE');
        $pdf->useFont($fn,20);
       	$pdf->showTextXY_R(72,72,'agsjhgjhWERWZTFUZJGMGd');
        $pdf->useFont($fn,20,'latin1');
       	$pdf->showTextXY(72,140,'agsjhgjhWERWZTFUZJGMGdd');
	$pdf->newFontT1reencode($fk,'AC',"MacRomanEncoding");
        $pdf->useFont($fn,20,'MacRomanEncoding');
       	$pdf->showTextXY_R(72,200,'agsjhgjhWERWZTFUZJGMGddy');
        $pdf->endpage();
        $pdf->saveas("example5.pdf");
        $pdf->end;

__END__
