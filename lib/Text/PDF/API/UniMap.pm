package Text::PDF::API::UniMap;


use vars qw ($VERSION @EXPORT @EXPORT_OK @EXPORT_TAGS @ISA);

BEGIN {
    @ISA         = qw(Exporter);
    @EXPORT      = qw ();
    @EXPORT_OK   = qw ( utf8_to_ucs2 utf16_to_ucs2 ucs2_to_utf8 );
    @EXPORT_TAGS = qw ();
    $VERSION     = "0.2.1";
}

sub utf8_to_ucs4 {
	my $string=shift @_;
	
}

sub utf8c_to_ucs4c {
	my $string=shift @_;
	my ($c,$out,$len);
	$c=vec($string,0,8);
	if($c & 0x80) {
		if(($c & 0xc0)==0xc0) {
			if(($c & 0xe0)==0xe0){
				if(($c & 0xf0)==0xf0) {
					if(($c & 0xf8)==0xf8) {
						if(($c & 0xfc)==0xfc) {
							if(($c & 0xfe)==0xfe) {
								# not valid !
								$len=0;
								$c=0;
							} else {
								# 6-byte utf8
								$len=6;
								$c = ($c & 0x01) << 30;
								$c|= (vec($string,1,8) & 0x3f) << 24;
								$c|= (vec($string,2,8) & 0x3f) << 18;
								$c|= (vec($string,3,8) & 0x3f) << 12;
								$c|= (vec($string,4,8) & 0x3f) << 6;
								$c|= (vec($string,5,8) & 0x3f);
							}
						} else {
							# 5-byte utf8
							$len=5;
							$c = ($c & 0x03) << 24;
							$c|= (vec($string,1,8) & 0x3f) << 18;
							$c|= (vec($string,2,8) & 0x3f) << 12;
							$c|= (vec($string,3,8) & 0x3f) << 6;
							$c|= (vec($string,4,8) & 0x3f);
						}
					} else {
						# 4-byte utf8
						$len=4;
						$c = ($c & 0x7) << 18;
						$c|= (vec($string,1,8) & 0x3f) << 12;
						$c|= (vec($string,2,8) & 0x3f) << 6;
						$c|= (vec($string,3,8) & 0x3f);
					}
				} else {
					# 3-byte utf8
					$len=3;
					$c=($c & 0x0f) << 12;
					$c|=((vec($string,1,8) & 0x3f) << 6);
					$c|=(vec($string,2,8) & 0x3f);
				}
			} else {
				# 2-byte utf8
				$len=2;
				$c&=0x1f;
				$c=$c<<6;
				$c|=(vec($string,1,8) & 0x3f);
			}		
		} else {
			# not valid
			$c=0;
			$len=0;
		}
	} else {
		## ASCII-7bits
		$len=1;
	}
	$out=pack('N',($c & 0xffffffff));
	return($out,$len);
}

sub utf8c_to_ucs2c {
	my ($string)=@_;
	my ($c,$len)=utf8c_to_ucs4c($string);
	$c=pack('n',(unpack('N',$c) & 0xffff));
	$c='' if($len>4);
	return($c,$len);
}

sub utf8_to_ucs2 {
	## use Unicode::String;
	my $string=shift @_;
	my($ucs,$len,$final);
	do {
		($ucs,$len)=utf8c_to_ucs2c($string);
		$final.=$ucs;
		$string=substr($string,$len-length($string),length($string)-$len);
	} while( ($len>0) && (length($string)>0) );
        ## my $u = Unicode::String::utf8($string);
        ## my $ordering = $u->ord;
        ## $u->byteswap if (defined($ordering) && ($ordering == 0xFFFE));
        ## my $final = $u->ucs2;
	return($final);
}

sub ucs2_to_utf8 {
	use Unicode::String;
	my $string=shift @_;
        my $u = Unicode::String::ucs2($string);
        my $final = $u->utf8;
	return($final);
}

sub utf16_to_ucs2 {
	use Unicode::String;
	my $string=shift @_;
        my $u = Unicode::String::utf16($string);
        ## my $ordering = $u->ord;
        ## $u->byteswap if (defined($ordering) && ($ordering == 0xFFFE));
        my $final = $u->ucs2;
	return($final);
}

sub new {
	my $class=shift(@_);
	my $encoding=lc(shift @_);
	my $this={};
	$encoding=~s/[^a-z0-9\-]+//cgi;
	bless($this,$class);
	my $buf;
	my $unimapdir; map {
		if(-d "$_/Text/PDF/API/UniMap"){
			$unimapdir="$_/Text/PDF/API/UniMap";
		}
	} @INC;
	if(! -e "$unimapdir/$encoding.map") {
		die " $encoding not supported.";
	} else {
		$this->{'enc'} = $encoding;
		$this->{'u2c'} = {};
		$this->{'c2u'} = {};
		$this->{'c2n'} = {};
		open(INF,"$unimapdir/$encoding.map");
		binmode(INF);
		read(INF,$buf,4);
		while(!eof(INF)) {
			read(INF,$buf,4);
			my ($ch,$um)=unpack('nn',$buf);
			$this->{'u2c'}->{$um}=$ch;
			$this->{'c2u'}->{$ch}=$um;
			$this->{'c2n'}->{$ch}=$u2n{$um} || sprintf('uni%04X',$um);
		}
		close(INF);
		if(wantarray) {
			return($this,$encoding);
		} else {
			return $this;
		}
	}
}

sub end {
	my $this=shift(@_);
	undef($this);
}

sub u2c {
	my $this=shift @_;
	my $um=shift @_;
	return($this->{'u2c'}->{$um});
}

sub c2u {
	my $this=shift @_;
	my $ch=shift @_;
	return($this->{'c2u'}->{$ch});
}

sub c2n {
	my $this=shift @_;
	my $ch=shift @_;
	return($this->{'c2n'}->{$ch});
}

sub glyphs {
	my $this=shift @_;
	return(map { $this->{'c2n'}->{$_} || '.notdef' } (0..255));
}

sub unimaps {
	my $unimapdir; map {
		if(-d "$_/Text/PDF/API/UniMap"){
			$unimapdir="$_/Text/PDF/API/UniMap";
		}
	} @INC;
	return( map { $_=~s/^$unimapdir\/(.*)\.map$/$1/cgi; lc($_); } glob("$unimapdir/*.map") );
}

sub isMap {
	my $encoding=lc(shift @_);
	return(undef) if(!$encoding);
	$encoding=~s/[^a-z0-9\-]+//cgi;
	return(scalar grep(/$encoding/,Text::PDF::API::UniMap::unimaps()));
}

1;

BEGIN {

%u2n=(
  '32'=>'space',
  '33'=>'exclam',
  '34'=>'quotedbl',
  '35'=>'numbersign',
  '36'=>'dollar',
  '37'=>'percent',
  '38'=>'ampersand',
  '39'=>'quotesingle',
  '40'=>'parenleft',
  '41'=>'parenright',
  '42'=>'asterisk',
  '43'=>'plus',
  '44'=>'comma',
  '45'=>'hyphen',
  '46'=>'period',
  '47'=>'slash',
  '48'=>'zero',
  '49'=>'one',
  '50'=>'two',
  '51'=>'three',
  '52'=>'four',
  '53'=>'five',
  '54'=>'six',
  '55'=>'seven',
  '56'=>'eight',
  '57'=>'nine',
  '58'=>'colon',
  '59'=>'semicolon',
  '60'=>'less',
  '61'=>'equal',
  '62'=>'greater',
  '63'=>'question',
  '64'=>'at',
  '65'=>'A',
  '66'=>'B',
  '67'=>'C',
  '68'=>'D',
  '69'=>'E',
  '70'=>'F',
  '71'=>'G',
  '72'=>'H',
  '73'=>'I',
  '74'=>'J',
  '75'=>'K',
  '76'=>'L',
  '77'=>'M',
  '78'=>'N',
  '79'=>'O',
  '80'=>'P',
  '81'=>'Q',
  '82'=>'R',
  '83'=>'S',
  '84'=>'T',
  '85'=>'U',
  '86'=>'V',
  '87'=>'W',
  '88'=>'X',
  '89'=>'Y',
  '90'=>'Z',
  '91'=>'bracketleft',
  '92'=>'backslash',
  '93'=>'bracketright',
  '94'=>'asciicircum',
  '95'=>'underscore',
  '96'=>'grave',
  '97'=>'a',
  '98'=>'b',
  '99'=>'c',
  '100'=>'d',
  '101'=>'e',
  '102'=>'f',
  '103'=>'g',
  '104'=>'h',
  '105'=>'i',
  '106'=>'j',
  '107'=>'k',
  '108'=>'l',
  '109'=>'m',
  '110'=>'n',
  '111'=>'o',
  '112'=>'p',
  '113'=>'q',
  '114'=>'r',
  '115'=>'s',
  '116'=>'t',
  '117'=>'u',
  '118'=>'v',
  '119'=>'w',
  '120'=>'x',
  '121'=>'y',
  '122'=>'z',
  '123'=>'braceleft',
  '124'=>'bar',
  '125'=>'braceright',
  '126'=>'asciitilde',
  '160'=>'space',
  '161'=>'exclamdown',
  '162'=>'cent',
  '163'=>'sterling',
  '164'=>'currency',
  '165'=>'yen',
  '166'=>'brokenbar',
  '167'=>'section',
  '168'=>'dieresis',
  '169'=>'copyright',
  '170'=>'ordfeminine',
  '171'=>'guillemotleft',
  '172'=>'logicalnot',
  '173'=>'hyphen',
  '174'=>'registered',
  '175'=>'macron',
  '176'=>'degree',
  '177'=>'plusminus',
  '178'=>'twosuperior',
  '179'=>'threesuperior',
  '180'=>'acute',
  '181'=>'mu',
  '182'=>'paragraph',
  '183'=>'periodcentered',
  '184'=>'cedilla',
  '185'=>'onesuperior',
  '186'=>'ordmasculine',
  '187'=>'guillemotright',
  '188'=>'onequarter',
  '189'=>'onehalf',
  '190'=>'threequarters',
  '191'=>'questiondown',
  '192'=>'Agrave',
  '193'=>'Aacute',
  '194'=>'Acircumflex',
  '195'=>'Atilde',
  '196'=>'Adieresis',
  '197'=>'Aring',
  '198'=>'AE',
  '199'=>'Ccedilla',
  '200'=>'Egrave',
  '201'=>'Eacute',
  '202'=>'Ecircumflex',
  '203'=>'Edieresis',
  '204'=>'Igrave',
  '205'=>'Iacute',
  '206'=>'Icircumflex',
  '207'=>'Idieresis',
  '208'=>'Eth',
  '209'=>'Ntilde',
  '210'=>'Ograve',
  '211'=>'Oacute',
  '212'=>'Ocircumflex',
  '213'=>'Otilde',
  '214'=>'Odieresis',
  '215'=>'multiply',
  '216'=>'Oslash',
  '217'=>'Ugrave',
  '218'=>'Uacute',
  '219'=>'Ucircumflex',
  '220'=>'Udieresis',
  '221'=>'Yacute',
  '222'=>'Thorn',
  '223'=>'germandbls',
  '224'=>'agrave',
  '225'=>'aacute',
  '226'=>'acircumflex',
  '227'=>'atilde',
  '228'=>'adieresis',
  '229'=>'aring',
  '230'=>'ae',
  '231'=>'ccedilla',
  '232'=>'egrave',
  '233'=>'eacute',
  '234'=>'ecircumflex',
  '235'=>'edieresis',
  '236'=>'igrave',
  '237'=>'iacute',
  '238'=>'icircumflex',
  '239'=>'idieresis',
  '240'=>'eth',
  '241'=>'ntilde',
  '242'=>'ograve',
  '243'=>'oacute',
  '244'=>'ocircumflex',
  '245'=>'otilde',
  '246'=>'odieresis',
  '247'=>'divide',
  '248'=>'oslash',
  '249'=>'ugrave',
  '250'=>'uacute',
  '251'=>'ucircumflex',
  '252'=>'udieresis',
  '253'=>'yacute',
  '254'=>'thorn',
  '255'=>'ydieresis',
  '256'=>'Amacron',
  '257'=>'amacron',
  '258'=>'Abreve',
  '259'=>'abreve',
  '260'=>'Aogonek',
  '261'=>'aogonek',
  '262'=>'Cacute',
  '263'=>'cacute',
  '264'=>'Ccircumflex',
  '265'=>'ccircumflex',
  '266'=>'Cdotaccent',
  '267'=>'cdotaccent',
  '268'=>'Ccaron',
  '269'=>'ccaron',
  '270'=>'Dcaron',
  '271'=>'dcaron',
  '272'=>'Dcroat',
  '273'=>'dcroat',
  '274'=>'Emacron',
  '275'=>'emacron',
  '276'=>'Ebreve',
  '277'=>'ebreve',
  '278'=>'Edotaccent',
  '279'=>'edotaccent',
  '280'=>'Eogonek',
  '281'=>'eogonek',
  '282'=>'Ecaron',
  '283'=>'ecaron',
  '284'=>'Gcircumflex',
  '285'=>'gcircumflex',
  '286'=>'Gbreve',
  '287'=>'gbreve',
  '288'=>'Gdotaccent',
  '289'=>'gdotaccent',
  '290'=>'Gcommaaccent',
  '291'=>'gcommaaccent',
  '292'=>'Hcircumflex',
  '293'=>'hcircumflex',
  '294'=>'Hbar',
  '295'=>'hbar',
  '296'=>'Itilde',
  '297'=>'itilde',
  '298'=>'Imacron',
  '299'=>'imacron',
  '300'=>'Ibreve',
  '301'=>'ibreve',
  '302'=>'Iogonek',
  '303'=>'iogonek',
  '304'=>'Idotaccent',
  '305'=>'dotlessi',
  '306'=>'IJ',
  '307'=>'ij',
  '308'=>'Jcircumflex',
  '309'=>'jcircumflex',
  '310'=>'Kcommaaccent',
  '311'=>'kcommaaccent',
  '312'=>'kgreenlandic',
  '313'=>'Lacute',
  '314'=>'lacute',
  '315'=>'Lcommaaccent',
  '316'=>'lcommaaccent',
  '317'=>'Lcaron',
  '318'=>'lcaron',
  '319'=>'Ldot',
  '320'=>'ldot',
  '321'=>'Lslash',
  '322'=>'lslash',
  '323'=>'Nacute',
  '324'=>'nacute',
  '325'=>'Ncommaaccent',
  '326'=>'ncommaaccent',
  '327'=>'Ncaron',
  '328'=>'ncaron',
  '329'=>'napostrophe',
  '330'=>'Eng',
  '331'=>'eng',
  '332'=>'Omacron',
  '333'=>'omacron',
  '334'=>'Obreve',
  '335'=>'obreve',
  '336'=>'Ohungarumlaut',
  '337'=>'ohungarumlaut',
  '338'=>'OE',
  '339'=>'oe',
  '340'=>'Racute',
  '341'=>'racute',
  '342'=>'Rcommaaccent',
  '343'=>'rcommaaccent',
  '344'=>'Rcaron',
  '345'=>'rcaron',
  '346'=>'Sacute',
  '347'=>'sacute',
  '348'=>'Scircumflex',
  '349'=>'scircumflex',
  '350'=>'Scedilla',
  '351'=>'scedilla',
  '352'=>'Scaron',
  '353'=>'scaron',
  '354'=>'Tcommaaccent',
  '355'=>'tcommaaccent',
  '356'=>'Tcaron',
  '357'=>'tcaron',
  '358'=>'Tbar',
  '359'=>'tbar',
  '360'=>'Utilde',
  '361'=>'utilde',
  '362'=>'Umacron',
  '363'=>'umacron',
  '364'=>'Ubreve',
  '365'=>'ubreve',
  '366'=>'Uring',
  '367'=>'uring',
  '368'=>'Uhungarumlaut',
  '369'=>'uhungarumlaut',
  '370'=>'Uogonek',
  '371'=>'uogonek',
  '372'=>'Wcircumflex',
  '373'=>'wcircumflex',
  '374'=>'Ycircumflex',
  '375'=>'ycircumflex',
  '376'=>'Ydieresis',
  '377'=>'Zacute',
  '378'=>'zacute',
  '379'=>'Zdotaccent',
  '380'=>'zdotaccent',
  '381'=>'Zcaron',
  '382'=>'zcaron',
  '383'=>'longs',
  '402'=>'florin',
  '416'=>'Ohorn',
  '417'=>'ohorn',
  '431'=>'Uhorn',
  '432'=>'uhorn',
  '486'=>'Gcaron',
  '487'=>'gcaron',
  '506'=>'Aringacute',
  '507'=>'aringacute',
  '508'=>'AEacute',
  '509'=>'aeacute',
  '510'=>'Oslashacute',
  '511'=>'oslashacute',
  '536'=>'Scommaaccent',
  '537'=>'scommaaccent',
  '538'=>'Tcommaaccent',
  '539'=>'tcommaaccent',
  '700'=>'afii57929',
  '701'=>'afii64937',
  '710'=>'circumflex',
  '711'=>'caron',
  '713'=>'macron',
  '728'=>'breve',
  '729'=>'dotaccent',
  '730'=>'ring',
  '731'=>'ogonek',
  '732'=>'tilde',
  '733'=>'hungarumlaut',
  '768'=>'gravecomb',
  '769'=>'acutecomb',
  '771'=>'tildecomb',
  '777'=>'hookabovecomb',
  '803'=>'dotbelowcomb',
  '900'=>'tonos',
  '901'=>'dieresistonos',
  '902'=>'Alphatonos',
  '903'=>'anoteleia',
  '904'=>'Epsilontonos',
  '905'=>'Etatonos',
  '906'=>'Iotatonos',
  '908'=>'Omicrontonos',
  '910'=>'Upsilontonos',
  '911'=>'Omegatonos',
  '912'=>'iotadieresistonos',
  '913'=>'Alpha',
  '914'=>'Beta',
  '915'=>'Gamma',
  '916'=>'Delta',
  '917'=>'Epsilon',
  '918'=>'Zeta',
  '919'=>'Eta',
  '920'=>'Theta',
  '921'=>'Iota',
  '922'=>'Kappa',
  '923'=>'Lambda',
  '924'=>'Mu',
  '925'=>'Nu',
  '926'=>'Xi',
  '927'=>'Omicron',
  '928'=>'Pi',
  '929'=>'Rho',
  '931'=>'Sigma',
  '932'=>'Tau',
  '933'=>'Upsilon',
  '934'=>'Phi',
  '935'=>'Chi',
  '936'=>'Psi',
  '937'=>'Omega',
  '938'=>'Iotadieresis',
  '939'=>'Upsilondieresis',
  '940'=>'alphatonos',
  '941'=>'epsilontonos',
  '942'=>'etatonos',
  '943'=>'iotatonos',
  '944'=>'upsilondieresistonos',
  '945'=>'alpha',
  '946'=>'beta',
  '947'=>'gamma',
  '948'=>'delta',
  '949'=>'epsilon',
  '950'=>'zeta',
  '951'=>'eta',
  '952'=>'theta',
  '953'=>'iota',
  '954'=>'kappa',
  '955'=>'lambda',
  '956'=>'mu',
  '957'=>'nu',
  '958'=>'xi',
  '959'=>'omicron',
  '960'=>'pi',
  '961'=>'rho',
  '962'=>'sigma1',
  '963'=>'sigma',
  '964'=>'tau',
  '965'=>'upsilon',
  '966'=>'phi',
  '967'=>'chi',
  '968'=>'psi',
  '969'=>'omega',
  '970'=>'iotadieresis',
  '971'=>'upsilondieresis',
  '972'=>'omicrontonos',
  '973'=>'upsilontonos',
  '974'=>'omegatonos',
  '977'=>'theta1',
  '978'=>'Upsilon1',
  '981'=>'phi1',
  '982'=>'omega1',
  '1025'=>'afii10023',
  '1026'=>'afii10051',
  '1027'=>'afii10052',
  '1028'=>'afii10053',
  '1029'=>'afii10054',
  '1030'=>'afii10055',
  '1031'=>'afii10056',
  '1032'=>'afii10057',
  '1033'=>'afii10058',
  '1034'=>'afii10059',
  '1035'=>'afii10060',
  '1036'=>'afii10061',
  '1038'=>'afii10062',
  '1039'=>'afii10145',
  '1040'=>'afii10017',
  '1041'=>'afii10018',
  '1042'=>'afii10019',
  '1043'=>'afii10020',
  '1044'=>'afii10021',
  '1045'=>'afii10022',
  '1046'=>'afii10024',
  '1047'=>'afii10025',
  '1048'=>'afii10026',
  '1049'=>'afii10027',
  '1050'=>'afii10028',
  '1051'=>'afii10029',
  '1052'=>'afii10030',
  '1053'=>'afii10031',
  '1054'=>'afii10032',
  '1055'=>'afii10033',
  '1056'=>'afii10034',
  '1057'=>'afii10035',
  '1058'=>'afii10036',
  '1059'=>'afii10037',
  '1060'=>'afii10038',
  '1061'=>'afii10039',
  '1062'=>'afii10040',
  '1063'=>'afii10041',
  '1064'=>'afii10042',
  '1065'=>'afii10043',
  '1066'=>'afii10044',
  '1067'=>'afii10045',
  '1068'=>'afii10046',
  '1069'=>'afii10047',
  '1070'=>'afii10048',
  '1071'=>'afii10049',
  '1072'=>'afii10065',
  '1073'=>'afii10066',
  '1074'=>'afii10067',
  '1075'=>'afii10068',
  '1076'=>'afii10069',
  '1077'=>'afii10070',
  '1078'=>'afii10072',
  '1079'=>'afii10073',
  '1080'=>'afii10074',
  '1081'=>'afii10075',
  '1082'=>'afii10076',
  '1083'=>'afii10077',
  '1084'=>'afii10078',
  '1085'=>'afii10079',
  '1086'=>'afii10080',
  '1087'=>'afii10081',
  '1088'=>'afii10082',
  '1089'=>'afii10083',
  '1090'=>'afii10084',
  '1091'=>'afii10085',
  '1092'=>'afii10086',
  '1093'=>'afii10087',
  '1094'=>'afii10088',
  '1095'=>'afii10089',
  '1096'=>'afii10090',
  '1097'=>'afii10091',
  '1098'=>'afii10092',
  '1099'=>'afii10093',
  '1100'=>'afii10094',
  '1101'=>'afii10095',
  '1102'=>'afii10096',
  '1103'=>'afii10097',
  '1105'=>'afii10071',
  '1106'=>'afii10099',
  '1107'=>'afii10100',
  '1108'=>'afii10101',
  '1109'=>'afii10102',
  '1110'=>'afii10103',
  '1111'=>'afii10104',
  '1112'=>'afii10105',
  '1113'=>'afii10106',
  '1114'=>'afii10107',
  '1115'=>'afii10108',
  '1116'=>'afii10109',
  '1118'=>'afii10110',
  '1119'=>'afii10193',
  '1122'=>'afii10146',
  '1123'=>'afii10194',
  '1138'=>'afii10147',
  '1139'=>'afii10195',
  '1140'=>'afii10148',
  '1141'=>'afii10196',
  '1168'=>'afii10050',
  '1169'=>'afii10098',
  '1241'=>'afii10846',
  '1456'=>'afii57799',
  '1457'=>'afii57801',
  '1458'=>'afii57800',
  '1459'=>'afii57802',
  '1460'=>'afii57793',
  '1461'=>'afii57794',
  '1462'=>'afii57795',
  '1463'=>'afii57798',
  '1464'=>'afii57797',
  '1465'=>'afii57806',
  '1467'=>'afii57796',
  '1468'=>'afii57807',
  '1469'=>'afii57839',
  '1470'=>'afii57645',
  '1471'=>'afii57841',
  '1472'=>'afii57842',
  '1473'=>'afii57804',
  '1474'=>'afii57803',
  '1475'=>'afii57658',
  '1488'=>'afii57664',
  '1489'=>'afii57665',
  '1490'=>'afii57666',
  '1491'=>'afii57667',
  '1492'=>'afii57668',
  '1493'=>'afii57669',
  '1494'=>'afii57670',
  '1495'=>'afii57671',
  '1496'=>'afii57672',
  '1497'=>'afii57673',
  '1498'=>'afii57674',
  '1499'=>'afii57675',
  '1500'=>'afii57676',
  '1501'=>'afii57677',
  '1502'=>'afii57678',
  '1503'=>'afii57679',
  '1504'=>'afii57680',
  '1505'=>'afii57681',
  '1506'=>'afii57682',
  '1507'=>'afii57683',
  '1508'=>'afii57684',
  '1509'=>'afii57685',
  '1510'=>'afii57686',
  '1511'=>'afii57687',
  '1512'=>'afii57688',
  '1513'=>'afii57689',
  '1514'=>'afii57690',
  '1520'=>'afii57716',
  '1521'=>'afii57717',
  '1522'=>'afii57718',
  '1548'=>'afii57388',
  '1563'=>'afii57403',
  '1567'=>'afii57407',
  '1569'=>'afii57409',
  '1570'=>'afii57410',
  '1571'=>'afii57411',
  '1572'=>'afii57412',
  '1573'=>'afii57413',
  '1574'=>'afii57414',
  '1575'=>'afii57415',
  '1576'=>'afii57416',
  '1577'=>'afii57417',
  '1578'=>'afii57418',
  '1579'=>'afii57419',
  '1580'=>'afii57420',
  '1581'=>'afii57421',
  '1582'=>'afii57422',
  '1583'=>'afii57423',
  '1584'=>'afii57424',
  '1585'=>'afii57425',
  '1586'=>'afii57426',
  '1587'=>'afii57427',
  '1588'=>'afii57428',
  '1589'=>'afii57429',
  '1590'=>'afii57430',
  '1591'=>'afii57431',
  '1592'=>'afii57432',
  '1593'=>'afii57433',
  '1594'=>'afii57434',
  '1600'=>'afii57440',
  '1601'=>'afii57441',
  '1602'=>'afii57442',
  '1603'=>'afii57443',
  '1604'=>'afii57444',
  '1605'=>'afii57445',
  '1606'=>'afii57446',
  '1607'=>'afii57470',
  '1608'=>'afii57448',
  '1609'=>'afii57449',
  '1610'=>'afii57450',
  '1611'=>'afii57451',
  '1612'=>'afii57452',
  '1613'=>'afii57453',
  '1614'=>'afii57454',
  '1615'=>'afii57455',
  '1616'=>'afii57456',
  '1617'=>'afii57457',
  '1618'=>'afii57458',
  '1632'=>'afii57392',
  '1633'=>'afii57393',
  '1634'=>'afii57394',
  '1635'=>'afii57395',
  '1636'=>'afii57396',
  '1637'=>'afii57397',
  '1638'=>'afii57398',
  '1639'=>'afii57399',
  '1640'=>'afii57400',
  '1641'=>'afii57401',
  '1642'=>'afii57381',
  '1645'=>'afii63167',
  '1657'=>'afii57511',
  '1662'=>'afii57506',
  '1670'=>'afii57507',
  '1672'=>'afii57512',
  '1681'=>'afii57513',
  '1688'=>'afii57508',
  '1700'=>'afii57505',
  '1711'=>'afii57509',
  '1722'=>'afii57514',
  '1746'=>'afii57519',
  '1749'=>'afii57534',
  '7808'=>'Wgrave',
  '7809'=>'wgrave',
  '7810'=>'Wacute',
  '7811'=>'wacute',
  '7812'=>'Wdieresis',
  '7813'=>'wdieresis',
  '7922'=>'Ygrave',
  '7923'=>'ygrave',
  '8204'=>'afii61664',
  '8205'=>'afii301',
  '8206'=>'afii299',
  '8207'=>'afii300',
  '8210'=>'figuredash',
  '8211'=>'endash',
  '8212'=>'emdash',
  '8213'=>'afii00208',
  '8215'=>'underscoredbl',
  '8216'=>'quoteleft',
  '8217'=>'quoteright',
  '8218'=>'quotesinglbase',
  '8219'=>'quotereversed',
  '8220'=>'quotedblleft',
  '8221'=>'quotedblright',
  '8222'=>'quotedblbase',
  '8224'=>'dagger',
  '8225'=>'daggerdbl',
  '8226'=>'bullet',
  '8228'=>'onedotenleader',
  '8229'=>'twodotenleader',
  '8230'=>'ellipsis',
  '8236'=>'afii61573',
  '8237'=>'afii61574',
  '8238'=>'afii61575',
  '8240'=>'perthousand',
  '8242'=>'minute',
  '8243'=>'second',
  '8249'=>'guilsinglleft',
  '8250'=>'guilsinglright',
  '8252'=>'exclamdbl',
  '8260'=>'fraction',
  '8304'=>'zerosuperior',
  '8308'=>'foursuperior',
  '8309'=>'fivesuperior',
  '8310'=>'sixsuperior',
  '8311'=>'sevensuperior',
  '8312'=>'eightsuperior',
  '8313'=>'ninesuperior',
  '8317'=>'parenleftsuperior',
  '8318'=>'parenrightsuperior',
  '8319'=>'nsuperior',
  '8320'=>'zeroinferior',
  '8321'=>'oneinferior',
  '8322'=>'twoinferior',
  '8323'=>'threeinferior',
  '8324'=>'fourinferior',
  '8325'=>'fiveinferior',
  '8326'=>'sixinferior',
  '8327'=>'seveninferior',
  '8328'=>'eightinferior',
  '8329'=>'nineinferior',
  '8333'=>'parenleftinferior',
  '8334'=>'parenrightinferior',
  '8353'=>'colonmonetary',
  '8355'=>'franc',
  '8356'=>'lira',
  '8359'=>'peseta',
  '8362'=>'afii57636',
  '8363'=>'dong',
  '8364'=>'Euro',
  '8453'=>'afii61248',
  '8465'=>'Ifraktur',
  '8467'=>'afii61289',
  '8470'=>'afii61352',
  '8472'=>'weierstrass',
  '8476'=>'Rfraktur',
  '8478'=>'prescription',
  '8482'=>'trademark',
  '8486'=>'Omega',
  '8494'=>'estimated',
  '8501'=>'aleph',
  '8531'=>'onethird',
  '8532'=>'twothirds',
  '8539'=>'oneeighth',
  '8540'=>'threeeighths',
  '8541'=>'fiveeighths',
  '8542'=>'seveneighths',
  '8592'=>'arrowleft',
  '8593'=>'arrowup',
  '8594'=>'arrowright',
  '8595'=>'arrowdown',
  '8596'=>'arrowboth',
  '8597'=>'arrowupdn',
  '8616'=>'arrowupdnbse',
  '8629'=>'carriagereturn',
  '8656'=>'arrowdblleft',
  '8657'=>'arrowdblup',
  '8658'=>'arrowdblright',
  '8659'=>'arrowdbldown',
  '8660'=>'arrowdblboth',
  '8704'=>'universal',
  '8706'=>'partialdiff',
  '8707'=>'existential',
  '8709'=>'emptyset',
  '8710'=>'Delta',
  '8711'=>'gradient',
  '8712'=>'element',
  '8713'=>'notelement',
  '8715'=>'suchthat',
  '8719'=>'product',
  '8721'=>'summation',
  '8722'=>'minus',
  '8725'=>'fraction',
  '8727'=>'asteriskmath',
  '8729'=>'periodcentered',
  '8730'=>'radical',
  '8733'=>'proportional',
  '8734'=>'infinity',
  '8735'=>'orthogonal',
  '8736'=>'angle',
  '8743'=>'logicaland',
  '8744'=>'logicalor',
  '8745'=>'intersection',
  '8746'=>'union',
  '8747'=>'integral',
  '8756'=>'therefore',
  '8764'=>'similar',
  '8773'=>'congruent',
  '8776'=>'approxequal',
  '8800'=>'notequal',
  '8801'=>'equivalence',
  '8804'=>'lessequal',
  '8805'=>'greaterequal',
  '8834'=>'propersubset',
  '8835'=>'propersuperset',
  '8836'=>'notsubset',
  '8838'=>'reflexsubset',
  '8839'=>'reflexsuperset',
  '8853'=>'circleplus',
  '8855'=>'circlemultiply',
  '8869'=>'perpendicular',
  '8901'=>'dotmath',
  '8962'=>'house',
  '8976'=>'revlogicalnot',
  '8992'=>'integraltp',
  '8993'=>'integralbt',
  '9001'=>'angleleft',
  '9002'=>'angleright',
  '9312'=>'a120',
  '9313'=>'a121',
  '9314'=>'a122',
  '9315'=>'a123',
  '9316'=>'a124',
  '9317'=>'a125',
  '9318'=>'a126',
  '9319'=>'a127',
  '9320'=>'a128',
  '9321'=>'a129',
  '9472'=>'SF100000',
  '9474'=>'SF110000',
  '9484'=>'SF010000',
  '9488'=>'SF030000',
  '9492'=>'SF020000',
  '9496'=>'SF040000',
  '9500'=>'SF080000',
  '9508'=>'SF090000',
  '9516'=>'SF060000',
  '9524'=>'SF070000',
  '9532'=>'SF050000',
  '9552'=>'SF430000',
  '9553'=>'SF240000',
  '9554'=>'SF510000',
  '9555'=>'SF520000',
  '9556'=>'SF390000',
  '9557'=>'SF220000',
  '9558'=>'SF210000',
  '9559'=>'SF250000',
  '9560'=>'SF500000',
  '9561'=>'SF490000',
  '9562'=>'SF380000',
  '9563'=>'SF280000',
  '9564'=>'SF270000',
  '9565'=>'SF260000',
  '9566'=>'SF360000',
  '9567'=>'SF370000',
  '9568'=>'SF420000',
  '9569'=>'SF190000',
  '9570'=>'SF200000',
  '9571'=>'SF230000',
  '9572'=>'SF470000',
  '9573'=>'SF480000',
  '9574'=>'SF410000',
  '9575'=>'SF450000',
  '9576'=>'SF460000',
  '9577'=>'SF400000',
  '9578'=>'SF540000',
  '9579'=>'SF530000',
  '9580'=>'SF440000',
  '9600'=>'upblock',
  '9604'=>'dnblock',
  '9608'=>'block',
  '9612'=>'lfblock',
  '9616'=>'rtblock',
  '9617'=>'ltshade',
  '9618'=>'shade',
  '9619'=>'dkshade',
  '9632'=>'filledbox',
  '9633'=>'H22073',
  '9642'=>'H18543',
  '9643'=>'H18551',
  '9644'=>'filledrect',
  '9650'=>'triagup',
  '9658'=>'triagrt',
  '9660'=>'triagdn',
  '9668'=>'triaglf',
  '9670'=>'a78',
  '9674'=>'lozenge',
  '9675'=>'circle',
  '9679'=>'a71',
  '9687'=>'a81',
  '9688'=>'invbullet',
  '9689'=>'invcircle',
  '9702'=>'openbullet',
  '9733'=>'a35',
  '9742'=>'a4',
  '9755'=>'a11',
  '9758'=>'a12',
  '9786'=>'smileface',
  '9787'=>'invsmileface',
  '9788'=>'sun',
  '9792'=>'female',
  '9794'=>'male',
  '9824'=>'spade',
  '9827'=>'club',
  '9829'=>'heart',
  '9830'=>'diamond',
  '9834'=>'musicalnote',
  '9835'=>'musicalnotedbl',
  '9985'=>'a1',
  '9986'=>'a2',
  '9987'=>'a202',
  '9988'=>'a3',
  '9990'=>'a5',
  '9991'=>'a119',
  '9992'=>'a118',
  '9993'=>'a117',
  '9996'=>'a13',
  '9997'=>'a14',
  '9998'=>'a15',
  '9999'=>'a16',
  '10000'=>'a105',
  '10001'=>'a17',
  '10002'=>'a18',
  '10003'=>'a19',
  '10004'=>'a20',
  '10005'=>'a21',
  '10006'=>'a22',
  '10007'=>'a23',
  '10008'=>'a24',
  '10009'=>'a25',
  '10010'=>'a26',
  '10011'=>'a27',
  '10012'=>'a28',
  '10013'=>'a6',
  '10014'=>'a7',
  '10015'=>'a8',
  '10016'=>'a9',
  '10017'=>'a10',
  '10018'=>'a29',
  '10019'=>'a30',
  '10020'=>'a31',
  '10021'=>'a32',
  '10022'=>'a33',
  '10023'=>'a34',
  '10025'=>'a36',
  '10026'=>'a37',
  '10027'=>'a38',
  '10028'=>'a39',
  '10029'=>'a40',
  '10030'=>'a41',
  '10031'=>'a42',
  '10032'=>'a43',
  '10033'=>'a44',
  '10034'=>'a45',
  '10035'=>'a46',
  '10036'=>'a47',
  '10037'=>'a48',
  '10038'=>'a49',
  '10039'=>'a50',
  '10040'=>'a51',
  '10041'=>'a52',
  '10042'=>'a53',
  '10043'=>'a54',
  '10044'=>'a55',
  '10045'=>'a56',
  '10046'=>'a57',
  '10047'=>'a58',
  '10048'=>'a59',
  '10049'=>'a60',
  '10050'=>'a61',
  '10051'=>'a62',
  '10052'=>'a63',
  '10053'=>'a64',
  '10054'=>'a65',
  '10055'=>'a66',
  '10056'=>'a67',
  '10057'=>'a68',
  '10058'=>'a69',
  '10059'=>'a70',
  '10061'=>'a72',
  '10063'=>'a74',
  '10064'=>'a203',
  '10065'=>'a75',
  '10066'=>'a204',
  '10070'=>'a79',
  '10072'=>'a82',
  '10073'=>'a83',
  '10074'=>'a84',
  '10075'=>'a97',
  '10076'=>'a98',
  '10077'=>'a99',
  '10078'=>'a100',
  '10081'=>'a101',
  '10082'=>'a102',
  '10083'=>'a103',
  '10084'=>'a104',
  '10085'=>'a106',
  '10086'=>'a107',
  '10087'=>'a108',
  '10102'=>'a130',
  '10103'=>'a131',
  '10104'=>'a132',
  '10105'=>'a133',
  '10106'=>'a134',
  '10107'=>'a135',
  '10108'=>'a136',
  '10109'=>'a137',
  '10110'=>'a138',
  '10111'=>'a139',
  '10112'=>'a140',
  '10113'=>'a141',
  '10114'=>'a142',
  '10115'=>'a143',
  '10116'=>'a144',
  '10117'=>'a145',
  '10118'=>'a146',
  '10119'=>'a147',
  '10120'=>'a148',
  '10121'=>'a149',
  '10122'=>'a150',
  '10123'=>'a151',
  '10124'=>'a152',
  '10125'=>'a153',
  '10126'=>'a154',
  '10127'=>'a155',
  '10128'=>'a156',
  '10129'=>'a157',
  '10130'=>'a158',
  '10131'=>'a159',
  '10132'=>'a160',
  '10136'=>'a196',
  '10137'=>'a165',
  '10138'=>'a192',
  '10139'=>'a166',
  '10140'=>'a167',
  '10141'=>'a168',
  '10142'=>'a169',
  '10143'=>'a170',
  '10144'=>'a171',
  '10145'=>'a172',
  '10146'=>'a173',
  '10147'=>'a162',
  '10148'=>'a174',
  '10149'=>'a175',
  '10150'=>'a176',
  '10151'=>'a177',
  '10152'=>'a178',
  '10153'=>'a179',
  '10154'=>'a193',
  '10155'=>'a180',
  '10156'=>'a199',
  '10157'=>'a181',
  '10158'=>'a200',
  '10159'=>'a182',
  '10161'=>'a201',
  '10162'=>'a183',
  '10163'=>'a184',
  '10164'=>'a197',
  '10165'=>'a185',
  '10166'=>'a194',
  '10167'=>'a198',
  '10168'=>'a186',
  '10169'=>'a195',
  '10170'=>'a187',
  '10171'=>'a188',
  '10172'=>'a189',
  '10173'=>'a190',
  '10174'=>'a191',
  '63166'=>'dotlessj',
  '63167'=>'LL',
  '63168'=>'ll',
  '63169'=>'Scedilla',
  '63170'=>'scedilla',
  '63171'=>'commaaccent',
  '63172'=>'afii10063',
  '63173'=>'afii10064',
  '63174'=>'afii10192',
  '63175'=>'afii10831',
  '63176'=>'afii10832',
  '63177'=>'Acute',
  '63178'=>'Caron',
  '63179'=>'Dieresis',
  '63180'=>'DieresisAcute',
  '63181'=>'DieresisGrave',
  '63182'=>'Grave',
  '63183'=>'Hungarumlaut',
  '63184'=>'Macron',
  '63185'=>'cyrBreve',
  '63186'=>'cyrFlex',
  '63187'=>'dblGrave',
  '63188'=>'cyrbreve',
  '63189'=>'cyrflex',
  '63190'=>'dblgrave',
  '63191'=>'dieresisacute',
  '63192'=>'dieresisgrave',
  '63193'=>'copyrightserif',
  '63194'=>'registerserif',
  '63195'=>'trademarkserif',
  '63196'=>'onefitted',
  '63197'=>'rupiah',
  '63198'=>'threequartersemdash',
  '63199'=>'centinferior',
  '63200'=>'centsuperior',
  '63201'=>'commainferior',
  '63202'=>'commasuperior',
  '63203'=>'dollarinferior',
  '63204'=>'dollarsuperior',
  '63205'=>'hypheninferior',
  '63206'=>'hyphensuperior',
  '63207'=>'periodinferior',
  '63208'=>'periodsuperior',
  '63209'=>'asuperior',
  '63210'=>'bsuperior',
  '63211'=>'dsuperior',
  '63212'=>'esuperior',
  '63213'=>'isuperior',
  '63214'=>'lsuperior',
  '63215'=>'msuperior',
  '63216'=>'osuperior',
  '63217'=>'rsuperior',
  '63218'=>'ssuperior',
  '63219'=>'tsuperior',
  '63220'=>'Brevesmall',
  '63221'=>'Caronsmall',
  '63222'=>'Circumflexsmall',
  '63223'=>'Dotaccentsmall',
  '63224'=>'Hungarumlautsmall',
  '63225'=>'Lslashsmall',
  '63226'=>'OEsmall',
  '63227'=>'Ogoneksmall',
  '63228'=>'Ringsmall',
  '63229'=>'Scaronsmall',
  '63230'=>'Tildesmall',
  '63231'=>'Zcaronsmall',
  '63265'=>'exclamsmall',
  '63268'=>'dollaroldstyle',
  '63270'=>'ampersandsmall',
  '63280'=>'zerooldstyle',
  '63281'=>'oneoldstyle',
  '63282'=>'twooldstyle',
  '63283'=>'threeoldstyle',
  '63284'=>'fouroldstyle',
  '63285'=>'fiveoldstyle',
  '63286'=>'sixoldstyle',
  '63287'=>'sevenoldstyle',
  '63288'=>'eightoldstyle',
  '63289'=>'nineoldstyle',
  '63295'=>'questionsmall',
  '63328'=>'Gravesmall',
  '63329'=>'Asmall',
  '63330'=>'Bsmall',
  '63331'=>'Csmall',
  '63332'=>'Dsmall',
  '63333'=>'Esmall',
  '63334'=>'Fsmall',
  '63335'=>'Gsmall',
  '63336'=>'Hsmall',
  '63337'=>'Ismall',
  '63338'=>'Jsmall',
  '63339'=>'Ksmall',
  '63340'=>'Lsmall',
  '63341'=>'Msmall',
  '63342'=>'Nsmall',
  '63343'=>'Osmall',
  '63344'=>'Psmall',
  '63345'=>'Qsmall',
  '63346'=>'Rsmall',
  '63347'=>'Ssmall',
  '63348'=>'Tsmall',
  '63349'=>'Usmall',
  '63350'=>'Vsmall',
  '63351'=>'Wsmall',
  '63352'=>'Xsmall',
  '63353'=>'Ysmall',
  '63354'=>'Zsmall',
  '63393'=>'exclamdownsmall',
  '63394'=>'centoldstyle',
  '63400'=>'Dieresissmall',
  '63407'=>'Macronsmall',
  '63412'=>'Acutesmall',
  '63416'=>'Cedillasmall',
  '63423'=>'questiondownsmall',
  '63456'=>'Agravesmall',
  '63457'=>'Aacutesmall',
  '63458'=>'Acircumflexsmall',
  '63459'=>'Atildesmall',
  '63460'=>'Adieresissmall',
  '63461'=>'Aringsmall',
  '63462'=>'AEsmall',
  '63463'=>'Ccedillasmall',
  '63464'=>'Egravesmall',
  '63465'=>'Eacutesmall',
  '63466'=>'Ecircumflexsmall',
  '63467'=>'Edieresissmall',
  '63468'=>'Igravesmall',
  '63469'=>'Iacutesmall',
  '63470'=>'Icircumflexsmall',
  '63471'=>'Idieresissmall',
  '63472'=>'Ethsmall',
  '63473'=>'Ntildesmall',
  '63474'=>'Ogravesmall',
  '63475'=>'Oacutesmall',
  '63476'=>'Ocircumflexsmall',
  '63477'=>'Otildesmall',
  '63478'=>'Odieresissmall',
  '63480'=>'Oslashsmall',
  '63481'=>'Ugravesmall',
  '63482'=>'Uacutesmall',
  '63483'=>'Ucircumflexsmall',
  '63484'=>'Udieresissmall',
  '63485'=>'Yacutesmall',
  '63486'=>'Thornsmall',
  '63487'=>'Ydieresissmall',
  '63703'=>'a89',
  '63704'=>'a90',
  '63705'=>'a93',
  '63706'=>'a94',
  '63707'=>'a91',
  '63708'=>'a92',
  '63709'=>'a205',
  '63710'=>'a85',
  '63711'=>'a206',
  '63712'=>'a86',
  '63713'=>'a87',
  '63714'=>'a88',
  '63715'=>'a95',
  '63716'=>'a96',
  '63717'=>'radicalex',
  '63718'=>'arrowvertex',
  '63719'=>'arrowhorizex',
  '63720'=>'registersans',
  '63721'=>'copyrightsans',
  '63722'=>'trademarksans',
  '63723'=>'parenlefttp',
  '63724'=>'parenleftex',
  '63725'=>'parenleftbt',
  '63726'=>'bracketlefttp',
  '63727'=>'bracketleftex',
  '63728'=>'bracketleftbt',
  '63729'=>'bracelefttp',
  '63730'=>'braceleftmid',
  '63731'=>'braceleftbt',
  '63732'=>'braceex',
  '63733'=>'integralex',
  '63734'=>'parenrighttp',
  '63735'=>'parenrightex',
  '63736'=>'parenrightbt',
  '63737'=>'bracketrighttp',
  '63738'=>'bracketrightex',
  '63739'=>'bracketrightbt',
  '63740'=>'bracerighttp',
  '63741'=>'bracerightmid',
  '63742'=>'bracerightbt',
  '64256'=>'ff',
  '64257'=>'fi',
  '64258'=>'fl',
  '64259'=>'ffi',
  '64260'=>'ffl',
  '64287'=>'afii57705',
  '64298'=>'afii57694',
  '64299'=>'afii57695',
  '64309'=>'afii57723',
  '64331'=>'afii57700',
  ''=>'.notdef'
);

}

__END__
