use Text::PDF::API;
use Test;

BEGIN { plan tests => 1 }

        $pdf=Text::PDF::API->new(pagesize=>'a4', 'compression'=>0);
	ok(defined($pdf));

__END__
