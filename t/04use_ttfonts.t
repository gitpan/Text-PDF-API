use Text::PDF::API;
use Test;
use strict;
BEGIN { plan tests => 3 }

        my $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	foreach my $ff (qw(
        	somewhereinspace.ttf
	)) {
		$pdf->newpage;
		$pdf->newFontTTF($ff,$ff);
		my $fk='TTx'.Text::PDF::API::genKEY($ff);
		ok(defined($pdf->{'ROOT'}->{'Resources'}->{'Font'}->{$fk})); 
                $pdf->useFont($ff,20);
                $pdf->showTextXY(50,800,qq|say hello to '$ff' !|); 
		my @f=($pdf->{'PAGE'}->{' curstrm'}->{' stream'}=~/($fk)/gm);
                ok((scalar @f)==1);
                $pdf->useFont($ff,20,'latin1');
                $pdf->showTextXY(50,750,qq|say hello to '$ff-latin1' !|); 
		@f=($pdf->{'PAGE'}->{' curstrm'}->{' stream'}=~/($fk)/gm);
                ok((scalar @f)==2);
                $pdf->endpage;
	}
        $pdf->end;
__END__
