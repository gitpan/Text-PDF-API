use Tet::PDF::API;

	$d=-20;
        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
       	$pdf->newFont('Times-Roman');
	foreach $f (6 .. 24) {
		
        	$pdf->newpage();

		$pdf->useFont('Times-Roman',$f);
		$pdf->setTextLeading($f*1.2);
		($x,$y,$text)= $pdf->textParagraph(10,800,250,800, join(' ',q|Liber vel Legis. inforom summa cum laude. | x (1000/$f)));
		printf "x=%f,y=%f\n",$x,$y;
		($x,$y,$text)= $pdf->textParagraph(290,800,250,800, $text);	
		printf "x=%f,y=%f\n",$x,$y;

        	$pdf->endpage();
	}
        $pdf->saveas("$0.pdf");
        $pdf->end;

__END__
