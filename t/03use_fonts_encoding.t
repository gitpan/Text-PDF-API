use Text::PDF::API;
use Test;

BEGIN { plan tests => 20 }

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	$ff='Times-Roman';
        $pdf->newFontCore($ff);
        $fk='ACx'.Text::PDF::API::genKEY($ff);
	foreach $ee (qw(
		latin1
		adobe-standard
		adobe-symbol
		adobe-zapf-dingbats
		cp1250
		cp1251
		cp1252
		cp1253
		cp1254
		microsoft-dingbats
	)) {
		$pdf->newpage;
		$pdf->useFont($ff,20,$ee);
		$fke="$fk-$ee";
                ok(defined($pdf->{'ROOT'}->{'Resources'}->{'Font'}->{$fke}));
                $pdf->showTextXY(50,800,qq|say hello to '$ff-$ee' !|); 
                ok($pdf->{'PAGE'}->{' curstrm'}->{' stream'}=~/$fke/);
                $pdf->endpage;

	}
        $pdf->end;
__END__
