package Text::PDF::API::REHLHA;

# (R)adikal
# (E)infacher
# (H)uman
# (L)esbarer
# (H)ashing
# (A)lgorithmus

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

$VERSION = '0.02_01';  

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw();            
@EXPORT_OK = qw( 
	rehlha rehlha_8 rehlha_16 rehlha_24 rehlha_32 rehlha_48 rehlha_64 rehlha_96 
);

sub rehlha {
	my $b=shift @_;
	my $ddata=join('',@_);
	my $mdkey='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890Kj';
	my @data=split(//,$ddata);
	my $offset=0;
	my $it=(length($ddata) >> 3)+1;
	my $d=0;
	$ddata="0" x $b;
	foreach (0..$it) {
		foreach my $v (0..($b-1)) {
			$d=shift @data ||1;
			$offset+=defined(ord($d)) ? ord($d) : 1; 
			$offset+=vec($ddata,$v,8);
			$offset=$offset & 0x3f;
			vec($ddata,$v,8)=vec($mdkey,$offset,8);
		}
	}
	return($ddata);
}

sub rehlha_8  { return rehlha( 8,@_); }
sub rehlha_16 { return rehlha(16,@_); }
sub rehlha_24 { return rehlha(24,@_); }
sub rehlha_32 { return rehlha(32,@_); }
sub rehlha_64 { return rehlha(64,@_); }
sub rehlha_48 { return rehlha(48,@_); }
sub rehlha_96 { return rehlha(96,@_); }

1;

__END__

