use Text::PDF::API;
use Test;

BEGIN { plan tests => 2 , todo => [1,2] }

sub test_us {
        use Digest::MD5 qw(md5_hex);
        use Data::DumpXML qw( dump_xml );
        my ($pdf,$sig)=@_;
        my $dig=dump_xml($pdf);
        $dig=~s/[\x00-\x20\s]+//cgi;
        $dig=md5_hex($dig);     
        ok($dig,$sig);
        return($dig);
}

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	$pdf->newFontTTF('Some,other,font','somewhereinspace.ttf'); test_us($pdf,'68f50c0579fbd5bb9651befae953fcd0');
	$pdf->useFont('Some,other,font',20,'latin1'); test_us($pdf,'55f32a1470e2bf490162c4d12c5cb34f');
        $pdf->end;
__END__
