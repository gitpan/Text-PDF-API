use Test;
use strict;

BEGIN { plan tests => 4 }

sub test_us {
	use Text::PDF::API::REHLHA qw( rehlha_16 );
	my ($pdf,$sig)=@_;
	my $dig=rehlha_16($pdf); 
	ok($dig,$sig);
}

	test_us('this is a rehlha test','XWrSSlqWzc.JA5vx');
	test_us('hello lovely world !!','vFehdTJH9FfqRvvF');
	test_us('smack my bitch up !!!','A3ol9LgOikqVmEhX');
	test_us('trust the PDF the PDF is your friend','TuEcNQRhOM9fijmQ');

__END__
