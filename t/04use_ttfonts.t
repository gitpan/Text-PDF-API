use Text::PDF::API;
use Test;

BEGIN { plan tests => 1 }

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	foreach $ff (qw(
        	somewhereinspace.ttf
	)) {
		$pdf->newFontTTF($ff,$ff);
		$fk='TTx'.Text::PDF::API::genKEY($ff);
		ok(defined($pdf->{'ROOT'}->{'Resources'}->{'Font'}->{$fk})); 
	}
        $pdf->end;
__END__
