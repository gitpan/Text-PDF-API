use Text::PDF::API;
use POSIX qw( ceil floor );


$swidth=270;
$sheight=700;
        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	$pdf->newFont('Helvetica-Bold');
	$pdf->newFont('Times-Roman');
	foreach $i (1,5,7,10,12,15,17,20,25,30,40,50) {
		$t=q|Ypsom losorum daran, dices services dolorum et 
japales romanuim est. | x ($i).'<===';
		($f,$ff)=$pdf->paragraphFit('Times-Roman',undef,1.2,$swidth,$sheight,$t,0.95);
		print "inital fontsize would be = $f ($ff)\n";
	#	@sizes=(1,2,3,4,5,6,7,8,9,10,11,12,14,16,18,20,22,24,26,28,36,48,72);
	#	do {
	#
	#		$f=shift @sizes;
	#		$fl=$f*1.2;
 	#		$wi=$pdf->calcTextWidthFSET('Times-Roman',$f,'',$t);
 	#		$ws=2*$swidth*$sheight/$fl;
	#		print "$f\n";
	#	
	#	} while ($ws>$wi);
	#	do {
	#	
	#		$f*=0.99;
	#		## $f-=0.1;
			$fl=$f*1.2;
	#		$fudge=1-(2*$fl/$sheight);
 	#		$wi=$pdf->calcTextWidthFSET('Times-Roman',$f,'',$t)/$fudge;
 	#		## $ws=2*$fudge*$swidth*$sheight/$fl;
 	#		$ws=2*$swidth*$sheight/$fl;
	#		print "$f\n";
	#		
	#	} while ($ws<$wi);
       		$pdf->newpage();
		$pdf->useFont('Helvetica-Bold',10);
		$pdf->showTextXY(20,800,"font size=$f");
		$pdf->showTextXY(20,790,"leading=$fl");
		$pdf->showTextXY(20,780,"words=$no_words");
		$pdf->showTextXY(20,770,"rawtext width=$wi");
		$pdf->showTextXY(20,760,"avail.width=$ws");
		$pdf->showTextXY(20,750,"fudge=$fudge");
		$pdf->useFont('Times-Roman',$f);
		$pdf->setTextLeading($fl);
		($w,$h,$t2)=$pdf->textParagraph(20,$sheight,$swidth,$sheight,$t,1);
		($w,$h,$t2)=$pdf->textParagraph(310,$sheight,$swidth,$sheight,$t2,1);
       		$pdf->endpage();
	}

        $pdf->saveas("$0.pdf");
        $pdf->end;


__END__


