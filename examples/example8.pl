use Text::PDF::API;

	$d=-20;
        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
        $pdf->newpage();
        $pdf->newFont('Times-Roman');
        $pdf->newFont('Helvetica-Bold');
	$pdf->useFont('Helvetica-Bold',10);

        $pdf->beginText();				# begin text block

	$pdf->textFont();				# set font to last useFont

	$pdf->textLeading(14);				# set distance between lines
							# this should usually be 110% to 135% of fontsize

	$pdf->setColorFill(1,0,0);			# set textcolor to red

	$pdf->textPos(100,100);				# set text position

	$pdf->textAdd('this is read ');			# text

	$pdf->textNewLine;				# next line (100,86) !

	$pdf->setColorFill(0,1,0);			# color green
	
	$pdf->textFont('Times-Roman',20,'latin1');	# set font 

	$pdf->textAdd('this is green ');		# text

	$pdf->clearFontMatrix;				# make new matrix

	$pdf->setFontRotation(45);			# set rotation

	$pdf->calcFontMatrix;				# create final matrix

	$pdf->textFont('Times-Roman',20,'latin1');	# set font to last useFont

	$pdf->textPos(200,100);				# set position (includes matrix)

	$pdf->setColorFill(0,0,1);			# set blue

	$pdf->textAdd('this is plue ');			# text

	$pdf->endText();
        $pdf->endpage();
        $pdf->saveas("$0.pdf");
        $pdf->end;

__END__
