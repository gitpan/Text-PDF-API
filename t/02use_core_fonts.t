use Text::PDF::API;
use Test;

BEGIN { plan tests => 28 }

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	foreach $ff (qw(
        	Courier         Courier-Bold    Courier-Oblique         Courier-BoldOblique
        	Times-Roman     Times-Bold      Times-Italic            Times-BoldItalic
        	Helvetica       Helvetica-Bold  Helvetica-Oblique       Helvetica-BoldOblique
        	Symbol
        	ZapfDingbats
	)) {
		$pdf->newpage;
		$pdf->newFontCore($ff);
		$fk='ACx'.Text::PDF::API::genKEY($ff);
		ok(defined($pdf->{'ROOT'}->{'Resources'}->{'Font'}->{$fk}));
		$pdf->useFont($ff,20);
		$pdf->showTextXY(50,800,qq|say hello to '$ff' !|); 
		ok($pdf->{'PAGE'}->{' curstrm'}->{' stream'}=~/$fk/);
		$pdf->endpage;
	}
        $pdf->end;
__END__
