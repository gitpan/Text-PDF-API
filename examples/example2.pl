        use Text::PDF::API;

package Text::PDF::API;

sub arcXYabDG {
	my $self = shift @_;
	my $x = shift @_;
	my $y = shift @_;
	my $a = shift @_;
	my $b = shift @_;
	my $alpha = shift @_;
	my $beta = shift @_;
	my $move = shift @_;
	my $test = shift @_;
	if(abs($beta-$alpha) > 180) {
		my ($p0_x,$p0_y) =
			$self->arcXYabDG($x,$y,$a,$b,$alpha,($beta+$alpha)/2,$move,$test);
		my ($p2_x,$p2_y,$p3_x,$p3_y) = 
			$self->arcXYabDG($x,$y,$a,$b,($beta+$alpha)/2,$beta,$move,$test);
		return($p0_x,$p0_y,$p3_x,$p3_y);
	} else {
		$alpha = ($alpha * 3.1415 / 180);	
		$beta  = ($beta * 3.1415 / 180);	

		my $bcp = (4.0/3 * (1 - cos(($beta - $alpha)/2)) / sin(($beta - $alpha)/2));
	    
		my $sin_alpha = sin($alpha);
		my $sin_beta =  sin($beta);
		my $cos_alpha = cos($alpha);
		my $cos_beta =  cos($beta);

		my $p0_x = $x + $a * $cos_alpha;
		my $p0_y = $y + $b * $sin_alpha;
		my $p1_x = $x + $a * ($cos_alpha - $bcp * $sin_alpha);
		my $p1_y = $y + $b * ($sin_alpha + $bcp * $cos_alpha);
		my $p2_x = $x + $a * ($cos_beta + $bcp * $sin_beta);
		my $p2_y = $y + $b * ($sin_beta - $bcp * $cos_beta);
		my $p3_x = $x + $a * $cos_beta;
		my $p3_y = $y + $b * $sin_beta;	
	
		if(!$test) {
			$self->moveTo($p0_x,$p0_y) if($move);
			$self->curveTo($p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);
		}
		return($p0_x,$p0_y,$p3_x,$p3_y);
	}

}

sub arcXYrDG {
	my $self = shift @_;
	my $x = shift @_;
	my $y = shift @_;
	my $r = shift @_;
	my $alpha = shift @_;
	my $beta = shift @_;
	my $move = shift @_;
	my $test = shift @_;

	return($self->arcXYabDG($x,$y,$r,$r,$alpha,$beta,$move,$test));
}


package main;

        $pdf=Text::PDF::API->new('compression'=>0);
        $pdf->newpage(2376,2376);
        $pdf->newFont('Helvetica-Bold');
        $pdf->useGfxLineWidth(0.5);
        $pdf->useGfxLineDash(3,3);
	foreach $x (1..32) {
		$pdf->lineXY($x*72,72,$x*72,2304);$pdf->stroke;
		$pdf->lineXY(72,$x*72,2304,$x*72);$pdf->stroke;
	}
        $pdf->useFont('Helvetica-Bold',10,'latin1');
	foreach $x (1..31) {
		foreach $y (1..31) {
        		$pdf->showTextXY(3+($x*72),3+($y*72),sprintf("%i,%i",$x,$y));
		}
	}
        $pdf->useGfxLineWidth(5);
        $pdf->useGfxLineDash(1,0);
	($px,$py)=$pdf->arcXYabDG(1188,1188,500,1000,0,-270,0,1);
	$pdf->moveTo($px,$py);
	$pdf->arcXYabDG(1188,1188,500,1000,0,-270);
	$pdf->stroke();
        $pdf->endpage();
        $pdf->saveas("example2.pdf");
        $pdf->end;
