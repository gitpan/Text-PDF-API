use Text::PDF::API;
use Test;

BEGIN { plan tests => 14 }

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	foreach $ff (qw(
        	Courier         Courier-Bold    Courier-Oblique         Courier-BoldOblique
        	Times-Roman     Times-Bold      Times-Italic            Times-BoldItalic
        	Helvetica       Helvetica-Bold  Helvetica-Oblique       Helvetica-BoldOblique
        	Symbol
        	ZapfDingbats
	)) {
		$pdf->newFontCore($ff);
		$pdf->useFont($ff,20,'latin1');
		$fk='ACx'.Text::PDF::API::genKEY($ff).'-latin1';
		ok(defined($pdf->{'ROOT'}->{'Resources'}->{'Font'}->{$fk})); 
	}
        $pdf->end;
__END__
