#!/usr/local/bin/perl

$ff='msm.ttf';
$ff='zumbelsburg_plain.ttf';

        use Text::PDF::API;
        $pdf=Text::PDF::API->new('pagesize'=>'a4','compression'=>0);
       	$pdf->newFontCore('Helvetica-Bold');
##       	$pdf->newFontTTF('msm',$ff);
	foreach $e (qw(
		jis-c6220-1969-jp
		jis-c6229-1984-kana
		jis-x0201
		uc
	)) {
        	$pdf->newpage();
  ##      	$pdf->useFont('msm',20,$e);
        	$pdf->useFont('Helvetica-Bold',20,$e);
		foreach $x (0..15) {
			foreach $y (0..15) {
				$c=pack('C',($x*16)+$y);
				$c="\x00$c" if($e eq 'uc');
				$pdf->showTextXY(
					30+(30*$x),
					800-(40*$y),
					$c
				);
			}
		}
		$pdf->useFont('Helvetica-Bold',20,'latin1');
		$pdf->showTextXY(20,20,"encoding = $e");
        	$pdf->endpage();
	}
        $pdf->saveas("$0.pdf");
        $pdf->end;

__END__
