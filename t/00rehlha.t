use Test;
use strict;

BEGIN { plan tests => 1 }

sub test_us {
	use Text::PDF::API::REHLHA qw( rehlha_16 );
	my ($pdf,$sig)=@_;
	my $dig=rehlha_16($pdf); 
	ok($dig,$sig);
}

	test_us('hello lovely world !!','vFehdTJH9FfqRvvF');

__END__
