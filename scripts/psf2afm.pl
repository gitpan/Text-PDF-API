#!/usr/bin/perl

sub readPSF {
        my ($ascii,$bin)=@_;
        my (@asci,%h);

        @asci=split(/[\x0d\x0a]+/,$ascii);
        foreach my $line (@asci){
                $h{lc($1)}=$2 if($line=~/^\/(\w+)([^\w].*)def$/) ;
        } 
        foreach my $x (keys %h) {
                $h{$x}=~s/^\s*[\(\[\{](.+)[\}\]\)]\s*readonly\s*$/$1/ci if($h{$x}=~/readonly/);
                $h{$x}=~s/^\s+//cgi;
                $h{$x}=~s/\s+$//cgi;
	#	print "$x == '$h{$x}'\n";
        }     
	$h{'fontname'}=~s|/||cgi;
    my $newdata = "";

    # Conversion based on an C-program marked as follows:
    # /* Written by Carsten Wiethoff 1989 */
    # /* You may do what you want with this code,
    #    as long as this notice stays in it */

    my $input;
    my $output;
    my $ignore = 4;
    my $buffer = 0xd971;

    while ( length($bin) > 0 ) {
        ($input, $bin) = $bin =~ /^(.)(.*)$/s;
        $input = ord ($input);
        $output = $input ^ ($buffer >> 8);
        $buffer = (($input + $buffer) * 0xce6d + 0x58bf) & 0xffff;
        next if $ignore-- > 0;
        $newdata .= pack ("C", $output);
    }

#       print $newdata;
    # End conversion.

        @asci=split(/\x0a/,$newdata);
	map { 
		my($s,$t)=$_=~/^\/(\w+)\s(.+)\sdef$/;
		$t=~s|[\/\(\)\[\]\{\}]||cgi;
		$t=~s|^\s+||cgi;
		$t=~s|\s+$||cgi;
		$t=~s|\s+noaccess$||cgi;
		$h{lc($s)}=$t; 
	#	print lc($s)." == '$t'\n";
	} grep(/^\/(\w+)\s(.+)\sdef$/,@asci);
        @asci=grep(/^\/\w+\s\d+\sRD\s/,@asci);
	
	my @bbx=split(/\s+/,$h{'fontbbox'});

        $h{'wx'}=();   
        $h{'bbx'}=();  

        foreach my $line (@asci) {
                my($ch,$num,$bin)=($line=~/^\/(\w+)\s+(\d+)\s+RD\s+(.+)$/);
                my @values;
                $input='';
                $output='';
                $ignore=4;
                $buffer=0x10ea; # =4330;
                # print "values1='".join('.',map { sprintf('%02X',unpack('C',$_)) } split(//,$bin))."'\n";
                # print "values1='".pack('H*',unpack('C*',split(//,$bin)))."'\n";
                while ( length($bin) > 0 ) {
                        ($input, $bin) = $bin =~ /^(.)(.*)$/s;
                        $input = ord ($input);
                        $output = $input ^ ($buffer >> 8);
                        $buffer = (($input + $buffer) * 0xce6d + 0x58bf) & 0xffff;
                        next if $ignore-- > 0;
                        push(@values,$output);
                }
                # print "values2='".join(':',@values)."'\n";
                my @v2;
                while($input=shift @values) {
                        if($input<32){
                                push(@v2,$input);
                                last;
                        } elsif($input<247) {
                                push(@v2,$input-139);
                        } elsif($input<251) {
                                my $w=shift @values;
                                push(@v2,(($input-247)*256)+$w+108);
                        } elsif($input<255) {
                                my $w=shift @values;
                                push(@v2,(-($input-251)*256)-$w-108);
                        } else { # == 255
                                #
                                $output=pack('C',shift @values);
                                $output.=pack('C',shift @values);
                                $output.=pack('C',shift @values);
                                $output.=pack('C',shift @values);
                                $output=unpack('N',$output);
                                push(@v2,$output);
                        }
                }
                $input=pop(@v2);
                if($input==12){
                        # print "unknown bbx command at glyph='$ch' stack='".join(',',@v2)."' command='$input'\n";
                        $h{'wx'}{$ch}=$v2[2];
                        $h{'bbx'}{$ch}=sprintf("%d %d %d %d",$v2[0],$v2[1],$v2[2]-$v2[0],$v2[3]-$v2[1]);
                     #   print "G='$ch' WX='$v2[2]' BBX='".$h{'bbx'}{$ch}."'\n";
                } elsif($input==13) {
                        # print "unknown bbx command at glyph='$ch' stack='".join(',',@v2)."' command='$input'\n";
                        $h{'wx'}{$ch}=$v2[1];
                        $h{'bbx'}{$ch}=sprintf("%d %d %d %d",$v2[0],0,$v2[1]-$v2[0],$bbx[3]);
                     #   print "G='$ch' WX='$v2[1]' BBX='".$h{'bbx'}{$ch}."'\n";
                } else {
                  #      print "unknown bbx command at glyph='$ch' stack='".join(',',@v2)."' command='$input'\n";
                        $h{'wx'}{$ch}=0;
                        $h{'bbx'}{$ch}="0 0 0 0";
                }

        }
	my($llx,$lly,$urx,$ury,$l);
	# now we get the rest of the required parameters
	my @blue_val=split(/\s+/,$h{'bluevalues'});
	#
	#capheight 
	# get ury from H or bbx and adjust per delta blue
	($llx,$lly,$urx,$ury)=split(/\s+/,$h{'bbx'}{'H'});
	$l=$ury||$bbx[3];
	foreach my $b (reverse sort @blue_val) {
		if($b<$l){
			$h{'capheight'}=$b;
			last;
		}
	}

	#xheight 
	# get ury from x or bbx/2 and adjust per delta blue
	($llx,$lly,$urx,$ury)=split(/\s+/,$h{'bbx'}{'x'});
	if($ury==$bbx[3]) { 
		$h{'xheight'}=$ury/2; 
	} else {
		$l=$ury||($bbx[3]/2);
		foreach my $b (reverse sort @blue_val) {
			if($b<$l){
				$h{'xheight'}=$b;
				last;
			}
		}
	}
	$h{'ascender'}=0;
	$h{'descender'}=0;

        return(%h);
}

sub parsePS {
        my ($file)=@_;
        my ($l,$l1,$l2,$l3,$stream,@lines,$line,$head,$body,$tail);
        $l=-s $file;
        open(INF,$file);
        binmode(INF);
        read(INF,$line,2);
        @lines=unpack('C*',$line);
        if(($lines[0]==0x80) && ($lines[1]==1)) {
                read(INF,$line,4);
                $l1=unpack('V',$line);
                seek(INF,$l1,1);
                read(INF,$line,2);
                @lines=unpack('C*',$line);
                if(($lines[0]==0x80) && ($lines[1]==2)) {
                        read(INF,$line,4);
                        $l2=unpack('V',$line);
                } else {
                        die "corrupt pfb in file '$file' at marker='2'.";
                }
                seek(INF,$l2,1);
                read(INF,$line,2);
                @lines=unpack('C*',$line);
                if(($lines[0]==0x80) && ($lines[1]==1)) {
                        read(INF,$line,4);
                        $l3=unpack('V',$line);
                } else {
                        die "corrupt pfb in file '$file' at marker='3'.";
                }
                seek(INF,0,0);
                @lines=<INF>;
                close(INF);
                $stream=join('',@lines);
        } elsif($line EQ '%!') {
                seek(INF,0,0);
                while($line=<INF>) {
                        if(!$l1) {
                                $head.=$line;
                                if($line=~/eexec$/){
                                        chomp($head);
                                        $head.="\x0d";
                                        $l1=length($head);
                                }
                        } elsif(!$l2) {
                                if($line=~/^0+$/) {
                                        $l2=length($body);
                                        $tail=$line;
                                } else {
                                        chomp($line);
                                        $body.=pack('H*',$line);
                                }
                        } else {
                                $tail.=$line;
                        }
                }
                $l3=length($tail);
                $stream=pack('C2V',0x80,1,$l1).$head;
                $stream.=pack('C2V',0x80,2,$l2).$body;
                $stream.=pack('C2V',0x80,1,$l3).$tail;
        } else {
                die "unsupported font-format in file '$file' at marker='1'.";
        }
        # now we process the portions to return a hash which makes data available
        # if we dont have a good enough afm or pfm file to parse (especially pfm :)
       my %h=readPSF(
               substr($stream,6,$l1) ,         # this is the ascii portion of the font
               substr($stream,12+$l1,$l2)      # this is the binary portion of the font
       );
        foreach my $x (keys %h) {
	#	print "$x == '$h{$x}'\n";
        }     
        return($l1,$l2,$l3,$stream,%h);
}

	my($x,$x,$x,$x,%h)=parsePS($ARGV[0]);

print qq|StartFontMetrics 3.0\n|;
print qq|FontName $h{'fontname'}
FullName $h{'fullname'}
FamilyName $h{'familyname'}
Weight $h{'weight'}
FontBBox $h{'fontbbox'}
Version $h{'version'}
Notice $h{'notice'}
EncodingScheme $h{'encoding'}
CapHeight $h{'capheight'}
XHeight $h{'xheight'}
Ascender $h{'ascender'}
Descender $h{'descender'}
UnderlinePosition $h{'underlineposition'}
UnderlineThickness $h{'underlinethickness'}
ItalicAngle $h{'italicangle'}
IsFixedPitch $h{'isfixedpitch'}
StartCharMetrics |.(scalar keys %{$h{'wx'}}).qq|\n|;
foreach $n (keys %{$h{'wx'}}) {
	print qq|C -1 ; WX $h{'wx'}{$n} ; N $n ; B $h{'bbx'}{$n} ;\n|;
}
print qq|EndCharMetrics\n|;
print qq|EndFontMetrics\n|;

__END__
