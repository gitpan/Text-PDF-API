package Text::PDF::API::Image;

#
# USAGE:
#	use Text::PDF::API::Image;
#	($w,$h,$bpc,$cs,$img)=Text::PDF::API::Image::parseImage('filename');
#


require 5.002;

use strict;
use Exporter;
use vars qw( @EXPORT @EXPORT_OK %EXPORT_TAGS );

@EXPORT      = qw( parseImage );
@EXPORT_OK   = qw( parseImage );
%EXPORT_TAGS = ('all' => [@EXPORT_OK]);

sub parseImage {
	my $file=shift @_;
	my ($buf);
	my ($w,$h,$bpc,$cs,$img)=(0,0,'','','');
	if(ref($file) EQ '') {
		open(INF,$file);
		read(INF,$buf,100,0);
		close(INF);
		if($buf=~/^GIF8[7,9]a/) {
			die "Image File format 'GIF' not supported";
		} elsif ($buf=~/^\xFF\xD8/) {
			die "Image File format 'JPEG' not supported";
		} elsif ($buf=~/^\x89PNG/) {
			($w,$h,$bpc,$cs,$img)=parsePNG($file,$buf);
		} elsif ($buf=~/^P[456][\s\n]/) {
			($w,$h,$bpc,$cs,$img)=parsePNM($file,$buf);
		} else {
			die "Image File format not supported";
		}
	} elsif(ref($file) EQ 'GD::Image') {
		($w,$h,$bpc,$cs,$img)=parseGD($file);
	} elsif(ref($file)=~/^Image\:\:/) {
		($w,$h,$bpc,$cs,$img)=parseImageBase($file);
	} else {
		die "Image Object format: '".ref($file)."' not supported";
	}
	return ($w,$h,$bpc,$cs,$img);
}

sub parsePNM {
	my $file=shift @_;
	my $buf=shift @_;
	my ($t,$s,$line);
	my ($w,$h,$bpc,$cs,$img,@img)=(0,0,'','','');
	($t)=($buf=~/^(P\d+)\s+/);
	open(INF,$file);
	binmode(INF);
	if($t EQ 'P4') {
		($t,$w,$h)=($buf=~/^(P\d+)\s+(\d+)\s+(\d+)\s+/);
		$bpc=1;
		$s=0;
		$line=<INF>;
		$line=<INF>;
		for($line=($w*$h/8);$line>0;$line--) {
			read(INF,$buf,1);
			push(@img,$buf);
		}
		$cs='DeviceGray';
	} elsif($t EQ 'P5') {
		($t,$w,$h,$bpc)=($buf=~/^(P\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+/);
		if($bpc==255){
			$s=0;
		} else {
			$s=255/$bpc;
		}
		$bpc=8;
		$line=<INF>;
		$line=<INF>;
		$line=<INF>;
		for($line=($w*$h);$line>0;$line--) {
			read(INF,$buf,1);
			if($s>0) {
				$buf=pack('C',(unpack('C',$buf)*$s));
			}
			push(@img,$buf);
		}
		$cs='DeviceGray';
	} elsif($t EQ 'P6') {
		($t,$w,$h,$bpc)=($buf=~/^(P\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+/);
		if($bpc==255){
			$s=0;
		} else {
			$s=255/$bpc;
		}
		$bpc=8;
		$line=<INF>;
		$line=<INF>;
		$line=<INF>;
		if($s>0) {
			for($line=($w*$h);$line>0;$line--) {
				read(INF,$buf,1);
				push(@img,pack('C',(unpack('C',$buf)*$s)));
				read(INF,$buf,1);
				push(@img,pack('C',(unpack('C',$buf)*$s)));
				read(INF,$buf,1);
				push(@img,pack('C',(unpack('C',$buf)*$s)));
			}
		} else {
			@img=<INF>;
		}
		$cs='DeviceRGB';
	}
	close(INF);
	return ($w,$h,$bpc,$cs,join('',@img));
}

sub parsePNG {
	my $file=shift @_;
	my $buf=shift @_;
	my ($l,$crc,$w,$h,$bpc,$cs,$cm,$fm,$im,@pal,$img,@img,$filter);
	open(INF,$file);
	binmode(INF);
	seek(INF,8,0);
	while(!eof(INF)) {
		read(INF,$buf,4);
		$l=unpack('N',$buf);
		read(INF,$buf,4);
		if($buf EQ 'IHDR') {
			read(INF,$buf,$l);
			($w,$h,$bpc,$cs,$cm,$fm,$im)=unpack('NNCCCCC',$buf);
			if($im>0) {die "PNG InterlaceMethod=$im not supported";}
		} elsif($buf EQ 'PLTE') {
			while($l) {
				read(INF,$buf,3);
				push(@pal,$buf);
				$l-=3;
			}
		} elsif($buf EQ 'IDAT') {
			while($l>512) {
				read(INF,$buf,512);
				push(@img,$buf);
				$l-=512;
			}
			read(INF,$buf,$l);
			push(@img,$buf);
		} elsif($buf EQ '') {
		} elsif($buf EQ 'IEND') {
			last;
		} else {
			# skip ahead
			seek(INF,$l,1);
		}
		read(INF,$buf,4);
		$crc=$buf;
	}
	close(INF);
	$img=join('',@img);
	use Compress::Zlib;
	$img=uncompress($img);
	@img=split(//,$img);
	$img='';
	my $bpcm=($bpc>8) ? 8 : $bpc/8;
	foreach my $y (1..$h) {
		$filter=unpack('C',shift(@img));
		if($filter>0){die "PNG FilterType=$filter unsupported";}
		foreach my $x (1..POSIX::ceil($w*$bpcm)) {
			if($cs==0) { # grayscale
				if($bpc==1) {
					$buf=shift(@img);
					$buf=unpack('C',$buf);
					foreach my $bit (7,6,5,4,3,2,1,0) {
						$img.=pack('C',(($buf >> $bit) & 1)*255);
					}
				} elsif($bpc==2) {
					$buf=shift(@img);
					$buf=unpack('C',$buf);
					foreach my $bit (6,4,2,0) {
						$img.=pack('C',((($buf >> $bit) & 3)+1)*64-1);
					}
				} elsif($bpc==4) {
					$buf=shift(@img);
					$buf=unpack('C',$buf);
					foreach my $bit (4,0) {
						$img.=pack('C',((($buf >> $bit) & 15)+1)*16-1);
					}
				} elsif($bpc==8) {
					$img.=shift(@img);
				} elsif($bpc==16) {
					$buf=shift(@img).shift(@img);
					$buf=unpack('n',$buf);
					$buf=(($buf+1)/256)-1;
					$img.=pack('C',$buf);
				}
			} elsif($cs==2) { # RGB
				if($bpc==8) {
					$img.=shift(@img).shift(@img).shift(@img);
				} elsif($bpc==16) {
					foreach(1..3) {
						$buf=shift(@img).shift(@img);
						$buf=unpack('n',$buf);
						$buf=(($buf+1)/256)-1;
						$img.=pack('C',$buf);
					}
				}
			} elsif($cs==3) { # indexed
				if($bpc==1) {
					$buf=shift(@img);
					$buf=unpack('C',$buf);
					foreach my $bit (7,6,5,4,3,2,1,0) {
						$img.=pack('C',$pal[(($buf >> $bit) & 1)]);
					}
				} elsif($bpc==2) {
					$buf=shift(@img);
					$buf=unpack('C',$buf);
					foreach my $bit (6,4,2,0) {
						$img.=pack('C',$pal[(($buf >> $bit) & 3)]);
					}
				} elsif($bpc==4) {
					$buf=shift(@img);
					$buf=unpack('C',$buf);
					foreach my $bit (4,0) {
						$img.=pack('C',$pal[(($buf >> $bit) & 15)]);
					}
				} elsif($bpc==8) {
					$img.=$pal[unpack('C',shift(@img))];
				}
			} elsif($cs==4) { # gray + alpha
				if($bpc==8) {
					$img.=shift(@img);
					shift(@img);
				} elsif($bpc==16) {
					$buf=shift(@img).shift(@img);
					$buf=unpack('n',$buf);
					$buf=(($buf+1)/256)-1;
					$img.=pack('C',$buf);
					shift(@img);
					shift(@img);
				}
			} elsif($cs==6) { # RGB + alpha
				if($bpc==8) {
					$img.=shift(@img).shift(@img).shift(@img);
					shift(@img);
				} elsif($bpc==16) {
					foreach(1..3) {
						$buf=shift(@img).shift(@img);
						$buf=unpack('n',$buf);
						$buf=(($buf+1)/256)-1;
						$img.=pack('C',$buf);
					}
					shift(@img);
					shift(@img);
				}
			}
		}
	}
	if( ($cs==0) || ($cs==4) ) { 
		$cs='DeviceGray';
	} elsif ( ($cs==2) || ($cs==3) || ($cs==6) ) {
		$cs='DeviceRGB';
	} else {
		$cs='';
	}
	$bpc=8; # all images have been converted to 8bit values !!
	return ($w,$h,$bpc,$cs,$img);
}

1;

__END__
