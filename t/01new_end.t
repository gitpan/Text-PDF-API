use Text::PDF::API;
use Test;

BEGIN { plan tests => 2 }


sub test_us {
	use Digest::REHLHA qw( rehlha0_16 );
	my ($dig,$sig)=@_;
	$dig=~s/[\x00-\x20\xa0-\xff]+//cgim;
	$dig=rehlha0_16($dig); 
	ok($dig,$sig);
}

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	test_us($pdf->stringify,'D09YBq0TgSmPegQ1');
        $pdf->end;
	test_us($pdf->stringify,'JFhhWrZD8gXsskmJ');

__END__
