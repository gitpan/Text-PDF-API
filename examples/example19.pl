#!/usr/local/bin/perl

$ff='msm.ttf';
$ff='tahoma_bold.ttf';

        use Text::PDF::API;
        $pdf=Text::PDF::API->new('pagesize'=>'a4','compression'=>1);
       	$pdf->newFontCore('Helvetica-Bold');
       	$pdf->newFontTTF('msm',$ff);
       	$pdf->newFontTTF('ali','alienation_regular.ttf');
foreach $n (qw( msm ali )) {
	foreach $e (qw(
		uc16
	)) {
##		latin1
		foreach $z (0..10) {
        	$pdf->newpage();
        	$pdf->useFont($n,20,$e);
		foreach $x (0..15) {
			foreach $y (0..15) {
				$c=pack('C',($x*16)+$y);
				$c=pack('CC',$z,($x*16)+$y) if($e eq 'uc16');
				$pdf->showTextXY(
					30+(30*$x),
					800-(40*$y),
					$c
				);
			}
		}
		$pdf->useFont('Helvetica-Bold',20,'latin1');
		$pdf->showTextXY(20,20,"encoding = $e ,  c= $z .");
		print STDERR "$z ";
        	$pdf->endpage();
		}
	}
}
        $pdf->saveas("$0.pdf");
        $pdf->end;

__END__
