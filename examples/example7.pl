use Text::PDF::API;
use Color::Object;



sub piechart {
	my $pdf=shift @_;
	my %param=%{shift @_};
	my @data=@{shift @_};
	my $useCMYK=$param{'useCMYK'};
	my $width=$param{'width'};
	my $height=$param{'height'};
	my $cx=$width/2;
	my $cy=$height/2;
	my $thick=$param{'thickness'}*$ry;
	my ($rx,$ry)=(
		$width*0.5-$param{'pad'},
		$height*0.5-$param{'pad'}
	);
	@data = sort { $a->{'val'} <=> $b->{'val'} } @data;
	my $thick=$param{'thickness'}*$ry;
	$ry-=$thick;
	if($param{'explode'}) {
		$rx*=(1-$param{'thickness'});
		$ry*=(1-$param{'thickness'});
	}
	$pdf->useGfxLineCap(1);
	$pdf->useGfxLineJoin(1);
	$pdf->useGfxLineWidth($param{'pielinewidth'});
	my $datasum;
	my ($a_start,$a_end);
	map { $datasum+=$_->{'val'}; } @data;
	$l_begin=90;
	$r_begin=90;
	foreach $dat (@data) {
		if(abs($l_begin-90)<abs($r_begin-90)) {
			$a_start=$l_begin;
			$a_end=$a_start+(360*$dat->{'val'}/$datasum);
			$a_mid=$a_start+(180*$dat->{'val'}/$datasum);
			$l_begin=$a_end;
		} else {
			$a_start=$r_begin-(360*$dat->{'val'}/$datasum);
			$a_end=$r_begin;
			$a_mid=$r_begin-(180*$dat->{'val'}/$datasum);
			$r_begin=$a_start;
		}
		while($a_start<0){
			$a_start+=360;
			$a_end+=360;
			$a_mid+=360;	
		}
		my ($px,$py,$p2x,$p2y)=$pdf->arcXYabDG($cx,$cy,$rx,$ry, $a_start,$a_mid, 0,1);
		$pdf->saveState;
		if($param{'explode'}) {
			$pdf->setGfxTranslate(
				($p2x-$cx)*1.25*$param{'thickness'},
				($p2y-$cy)*1.25*$param{'thickness'}
			);
			$pdf->calcGfxMatrix;
			$pdf->useGfxState;
		}
		$pdf->setColorFill(@{$dat->{'col'}});
		($px,$py,$p2x,$p2y)=$pdf->arcXYabDG($cx,$cy,$rx*0.9,$ry*0.9,$a_start,$a_end, 0,1);
		if($param{'explode'} && $param{'3d'}) {
			if(($a_start<90)||($a_start>270)) {
				$pdf->moveTo($cx,$cy);
				$pdf->lineTo($px,$py);
				$pdf->lineTo(
					$px,
					$py-$ry*$param{'thickness'}
				);
				$pdf->lineTo(
					$cx,
					$cy-$ry*$param{'thickness'}
				);
				$pdf->closefillstroke;
			}
			if(($a_end>90)&&($a_end<270)) {
				$pdf->moveTo($cx,$cy);
				$pdf->lineTo($p2x,$p2y);
				$pdf->lineTo(
					$p2x,
					$p2y-$ry*$param{'thickness'}
				);
				$pdf->lineTo(
					$cx,
					$cy-$ry*$param{'thickness'}
				);
				$pdf->closefillstroke;
			}
		}
		if($param{'3d'}) {
			my($r_s,$r_e,$r_m);

			if( ($a_start<180) && ($a_end>180) && ($a_end<360) ) {
				$r_s=180;
				$r_e=$a_end;
				$r_m=($r_s+$r_e)/2;
			} elsif(($a_start>180) && ($a_end<360)) {
				$r_s=$a_start;
				$r_e=$a_end;
				$r_m=$a_mid;
			} elsif( ($a_start<360) && ($a_start>180) && ($a_end>360) ) {
				$r_s=$a_start;
				$r_e=360;
				$r_m=($r_s+$r_e)/2;
			} elsif ( ($a_start<180) && ($a_end>360) ) {
				$r_s=180;
				$r_e=360;
				$r_m=270;
			}
			print "A= $a_start , $a_end\n";
			print "R= $r_s , $r_e\n";
			if($r_s||$r_e||$r_m) {
				my ($p1x,$p1y)=$pdf->arcXYabDG( $cx,$cy, $rx*0.9,$ry*0.9, $r_s,$r_m,0,1);
				my ($pmx,$pmy,$p2x,$p2y)=$pdf->arcXYabDG( $cx,$cy, $rx*0.9,$ry*0.9, $r_m,$r_e,0,1);
				$pdf->moveTo($p1x,$p1y);
				$pdf->lineTo($pmx,$pmy);
				$pdf->lineTo($p2x,$p2y);
				$pdf->lineTo($p2x,$p2y-$ry*$param{'thickness'});
				($p1x,$p1y,$p2x,$p2y)=$pdf->arcXYabDG(
					$cx,$cy-$ry*$param{'thickness'},
					$rx*0.9,$ry*0.9,
					$r_e,$r_s
				);
				$pdf->closefillstroke();
			}
		}
		$pdf->moveTo($cx,$cy);
		$pdf->lineTo($px,$py);
		$pdf->arcXYabDG($cx,$cy,$rx*0.9,$ry*0.9,$a_start,$a_end);
		$pdf->closefillstroke;
		if($param{'usegraphtext'}) {
			$pdf->useFont($param{'textfont'},$param{'pietextsize'});
			$pdf->setColorFill(0);
			($px,$py,$p2x,$p2y)=$pdf->arcXYabDG($cx,$cy,$rx,$ry, $a_start,$a_mid, 0,1);
			if($param{'3d'}) {
				if($a_mid < 180) {
				##	$p2y+=$param{'pietextsize'};
				} elsif($a_mid < 360) {
					$p2y-=$thick;
				}
			} else {
				if($a_mid < 180) {
				##	$p2y+=$param{'pietextsize'};
				} elsif($a_mid < 360) {
					$p2y-=$param{'pietextsize'};
				}
			}
			$pdf->showTextXY_C($p2x,$p2y,$dat->{'txt'});
		}
		$pdf->restoreState;
	}
}


	my $col=Color::Object->newRGB(1,0,0);
	$data=[];
	$data->[0]={};
	$data->[0]->{'txt'}="#0";
	$data->[0]->{'val'}=500;
	$data->[0]->{'col'}=[$col->asCMYK2];
	$col->rotHue(18);	
        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>1);
        $pdf->newFont('Helvetica-Bold');
	foreach $f (1..19) {
$param={
	'pad'		=> 10,
	'thickness'	=> 0.3,
	'textfont'	=> 'Helvetica-Bold',
	'pietextsize'	=> 10,
	'sidetextsize'	=> 10,
	'explode'	=> 1,
	'3d'		=> 1,	
	'usegraphtext'	=> 1,
	'width'		=> 300,
	'height'	=> 250,
	'pielinewidth'	=> 0.75,
};
        	$pdf->newpage();
		$data->[$f]={};
		$data->[$f]->{'txt'}="#$f";
		$data->[$f]->{'val'}=rand(100);
		$data->[$f]->{'col'}=[$col->asRGB];
		$col->rotHue(18);	
		$pdf->saveState;
		$pdf->setGfxTranslate(200,600);
		$pdf->calcGfxMatrix;
		$pdf->useGfxState;
		piechart($pdf,$param,$data);
		$pdf->restoreState;

		$param->{'explode'}=0;
		$pdf->saveState;
		$pdf->setGfxTranslate(200,400);
		$pdf->calcGfxMatrix;
		$pdf->useGfxState;
		$pdf->rect(0,0,300,250);$pdf->stroke;
		piechart($pdf,$param,$data);
		$pdf->restoreState;

		$param->{'3d'}=0;
		$pdf->saveState;
		$pdf->setGfxTranslate(200,200);
		$pdf->calcGfxMatrix;
		$pdf->useGfxState;
		$pdf->rect(0,0,300,250);$pdf->stroke;
		piechart($pdf,$param,$data);
		$pdf->restoreState;

		$param->{'explode'}=1;
		$pdf->saveState;
		$pdf->setGfxTranslate(200,0);
		$pdf->calcGfxMatrix;
		$pdf->useGfxState;
		$pdf->rect(0,0,300,250);$pdf->stroke;
		piechart($pdf,$param,$data);
		$pdf->restoreState;

        	$pdf->endpage();
	}


        $pdf->saveas("$0.pdf");
        $pdf->end;

__END__
