use Text::PDF::API;
use POSIX qw( ceil floor );
        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	$pdf->newFont('Helvetica-Bold','latin1');
	$pdf->newFont('Times-Roman','latin1');
	foreach $f (5,6,7,8,9,10,
		12,14,16,18,20,22,24,26,28,36,
		48) {
		$fl=$f*1.2;
		$t=q|Ypsom losorum daran, dices services dolorum et japales romanuim est. | x (1000/$fl);
		$w=scalar split(/\s+/,$t);
		$pdf->useFont('Times-Roman',$f,'latin1');
		$h=$pdf->calcTextWidth($t);
		$l=ceil($h/260);
		$wpl=floor(10*$w/$l)/10;
		$l=ceil($w/$wpl);
        	$pdf->newpage();
		$pdf->useFont('Helvetica-Bold',10,'latin1');
		$pdf->showTextXY(20,800,"font size=$f / leading=$fl / words=$w / rawtext width=$h / wpl=$wpl / est.lines=$l");
		$pdf->useFont('Times-Roman',$f,'latin1');
		$pdf->setTextLeading($fl);
		($w,$h,$t)=$pdf->textParagraph(20,700,260,700,$t,1);
		($w,$h,$t)=$pdf->textParagraph(300,700,280,700,$t,1);
		## print "$f :: $t \n";
        	$pdf->endpage();
	}

        $pdf->saveas("$0.pdf");
        $pdf->end;



__END__

