package Digest::REHLHA;

# (R)adikal
# (E)infacher
# (H)uman
# (L)esbarer
# (H)ashing
# (A)lgorithmus

## use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

$VERSION = '0.01';  

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw();            
@EXPORT_OK = qw( 
	rehlha0 rehlha0_8 rehlha0_16 rehlha0_24 rehlha0_32 rehlha0_48 rehlha0_64 rehlha0_96 
);

sub rehlha0 {
	my $b=shift @_;
	my $ddata=join('',@_);
	my $mdkey='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890.-';
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
			## $offset=($offset+ ord($d)+ vec($ddata,$v,8)) & 0x3f;
			vec($ddata,$v,8)=vec($mdkey,$offset,8);
		}
	}
	return($ddata);
}

sub rehlha0_8 { return rehlha0(8,@_); }
sub rehlha0_16 { return rehlha0(16,@_); }
sub rehlha0_24 { return rehlha0(24,@_); }
sub rehlha0_32 { return rehlha0(32,@_); }
sub rehlha0_64 { return rehlha0(64,@_); }
sub rehlha0_48 { return rehlha0(48,@_); }
sub rehlha0_96 { return rehlha0(96,@_); }

sub rehlha1 {
	my $b=shift @_;
	my $ddata=join('',@_);
	my $mdkey='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890.-'.
		'ABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890.-abcdefghijklmnopqrstuvwxyz';
	my @data=split(//,$ddata);
	my $offset=0;
	my $it=(length($ddata) >> 4)+1;
	$ddata='';
	foreach (0..$it) {
		foreach my $v (0..($b-1)) {
			$offset=($offset+ord(shift @data)+vec($ddata,$v,8)) & 0x7f;
			vec($ddata,$v,8)=vec($mdkey,$offset,8);
		}
	}
	return($ddata);
}

1;

__END__

