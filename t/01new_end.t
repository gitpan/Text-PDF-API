use Text::PDF::API;
use Test;

BEGIN { plan tests => 2 }

sub test_us {
	use Digest::REHLHA qw( rehlha0_16 );
	use Data::DumpXML qw( dump_xml );
	my ($pdf,$sig)=@_;
	my $dig=dump_xml($pdf); 
	$dig=~s/[\x00-\x20\s]+//cgi; 
	$dig=rehlha0_16($dig); 
	ok($dig,$sig);
}

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	test_us($pdf,'eMnZsTGNP93V5r7V');
        $pdf->end;
	test_us($pdf,'eMnZsTGNP93V5r7V');
__END__
