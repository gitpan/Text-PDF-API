#!/usr/local/bin/perl

        use Text::PDF::API;
        $pdf=Text::PDF::API->new('pagesize'=>'a4','compression'=>0);
        $pdf->newpage();
	$fn='Helvetica-some-really-stupid-somes';
        $fk=$pdf->newFont($fn,'bchb.pfa','bchb.afm','EBCDIC-AT-DE');
        $pdf->useFont($fn,20);
       	$pdf->showTextXY_R(72,72,'agsjhgjhWERWZTFUZJGMGd');
        $pdf->useFont($fn,20,'latin1');
       	$pdf->showTextXY(72,140,'agsjhgjhWERWZTFUZJGMGdd');
	$pdf->newFontPSreencode($fk,"MacRomanEncoding");
        $pdf->useFont($fn,20,'MacRomanEncoding');
       	$pdf->showTextXY_R(72,200,'agsjhgjhWERWZTFUZJGMGddy');
        $pdf->endpage();
        $pdf->saveas("example4.pdf");
        $pdf->end;

__END__
