package Text::PDF::API;

$VERSION = "0.5";

use Text::PDF::File;
use Text::PDF::AFont;
use Text::PDF::Page;
use Text::PDF::Utils;
use Text::PDF::SFont;
use Text::PDF::TTFont;
use Text::PDF::TTFont0;
use Text::PDF::TTFont0;

@Text::PDF::API::parameterlist=qw(
	pagesize
	pagewidth
	pageheight
	pageorientation
	compression
	pdfversion
);

@Text::PDF::API::CORETYPEFONTS=qw(
	Courier		Courier-Bold	Courier-Oblique		Courier-BoldOblique
	Times-Roman	Times-Bold	Times-Italic		Times-BoldItalic
	Helvetica	Helvetica-Bold	Helvetica-Oblique	Helvetica-BoldOblique
);
@Text::PDF::API::CORESYMBOLFONTS=qw(
	Symbol
	ZapfDingbats
);
@Text::PDF::API::COREFONTS=(
	@Text::PDF::API::CORETYPEFONTS,
	@Text::PDF::API::CORESYMBOLFONTS
);

%u2n=(
		q/32/ => qw/ space /, q/33/ => qw/ exclam /, q/34/ => qw/ quotedbl /, q/35/ => qw/ numbersign /, q/36/ => qw/ dollar /, q/37/ => qw/ percent /, q/38/ => qw/ ampersand /, q/39/ => qw/ quotesingle /, q/40/ => qw/ parenleft /, q/41/ => qw/ parenright /, q/42/ => qw/ asterisk /, q/43/ => qw/ plus /, q/44/ => qw/ comma /, q/45/ => qw/ hyphen /, q/46/ => qw/ period /, q/47/ => qw/ slash /, q/48/ => qw/ zero /, q/49/ => qw/ one /, q/50/ => qw/ two /, q/51/ => qw/ three /, q/52/ => qw/ four /, q/53/ => qw/ five /, q/54/ => qw/ six /, q/55/ => qw/ seven /, q/56/ => qw/ eight /, q/57/ => qw/ nine /, q/58/ => qw/ colon /, q/59/ => qw/ semicolon /, q/60/ => qw/ less /, q/61/ => qw/ equal /, q/62/ => qw/ greater /, q/63/ => qw/ question /,
		q/64/ => qw/ at /, q/65/ => qw/ A /, q/66/ => qw/ B /, q/67/ => qw/ C /, q/68/ => qw/ D /, q/69/ => qw/ E /, q/70/ => qw/ F /, q/71/ => qw/ G /, q/72/ => qw/ H /, q/73/ => qw/ I /, q/74/ => qw/ J /, q/75/ => qw/ K /, q/76/ => qw/ L /, q/77/ => qw/ M /, q/78/ => qw/ N /, q/79/ => qw/ O /, q/80/ => qw/ P /, q/81/ => qw/ Q /, q/82/ => qw/ R /, q/83/ => qw/ S /, q/84/ => qw/ T /, q/85/ => qw/ U /, q/86/ => qw/ V /, q/87/ => qw/ W /, q/88/ => qw/ X /, q/89/ => qw/ Y /, q/90/ => qw/ Z /, q/91/ => qw/ bracketleft /, q/92/ => qw/ backslash /, q/93/ => qw/ bracketright /, q/94/ => qw/ asciicircum /, q/95/ => qw/ underscore /, q/96/ => qw/ grave /, q/97/ => qw/ a /, q/98/ => qw/ b /, q/99/ => qw/ c /, q/100/ => qw/ d /, q/101/ => qw/ e /, q/102/ => qw/ f /,
		q/103/ => qw/ g /, q/104/ => qw/ h /, q/105/ => qw/ i /, q/106/ => qw/ j /, q/107/ => qw/ k /, q/108/ => qw/ l /, q/109/ => qw/ m /, q/110/ => qw/ n /, q/111/ => qw/ o /, q/112/ => qw/ p /, q/113/ => qw/ q /, q/114/ => qw/ r /, q/115/ => qw/ s /, q/116/ => qw/ t /, q/117/ => qw/ u /, q/118/ => qw/ v /, q/119/ => qw/ w /, q/120/ => qw/ x /, q/121/ => qw/ y /, q/122/ => qw/ z /, q/123/ => qw/ braceleft /, q/124/ => qw/ bar /, q/125/ => qw/ braceright /, q/126/ => qw/ asciitilde /, q/160/ => qw/ space /, q/161/ => qw/ exclamdown /, q/162/ => qw/ cent /, q/163/ => qw/ sterling /, q/164/ => qw/ currency /, q/165/ => qw/ yen /, q/166/ => qw/ brokenbar /, q/167/ => qw/ section /, q/168/ => qw/ dieresis /, q/169/ => qw/ copyright /, q/170/ => qw/ ordfeminine /,
		q/171/ => qw/ guillemotleft /, q/172/ => qw/ logicalnot /, q/173/ => qw/ hyphen /, q/174/ => qw/ registered /, q/175/ => qw/ macron /, q/176/ => qw/ degree /, q/177/ => qw/ plusminus /, q/178/ => qw/ twosuperior /, q/179/ => qw/ threesuperior /, q/180/ => qw/ acute /, q/181/ => qw/ mu /, q/182/ => qw/ paragraph /, q/183/ => qw/ periodcentered /, q/184/ => qw/ cedilla /, q/185/ => qw/ onesuperior /, q/186/ => qw/ ordmasculine /, q/187/ => qw/ guillemotright /, q/188/ => qw/ onequarter /, q/189/ => qw/ onehalf /, q/190/ => qw/ threequarters /, q/191/ => qw/ questiondown /, q/192/ => qw/ Agrave /, q/193/ => qw/ Aacute /, q/194/ => qw/ Acircumflex /, q/195/ => qw/ Atilde /, q/196/ => qw/ Adieresis /, q/197/ => qw/ Aring /, q/198/ => qw/ AE /, q/199/ => qw/ Ccedilla /,
		q/200/ => qw/ Egrave /, q/201/ => qw/ Eacute /, q/202/ => qw/ Ecircumflex /, q/203/ => qw/ Edieresis /, q/204/ => qw/ Igrave /, q/205/ => qw/ Iacute /, q/206/ => qw/ Icircumflex /, q/207/ => qw/ Idieresis /, q/208/ => qw/ Eth /, q/209/ => qw/ Ntilde /, q/210/ => qw/ Ograve /, q/211/ => qw/ Oacute /, q/212/ => qw/ Ocircumflex /, q/213/ => qw/ Otilde /, q/214/ => qw/ Odieresis /, q/215/ => qw/ multiply /, q/216/ => qw/ Oslash /, q/217/ => qw/ Ugrave /, q/218/ => qw/ Uacute /, q/219/ => qw/ Ucircumflex /, q/220/ => qw/ Udieresis /, q/221/ => qw/ Yacute /, q/222/ => qw/ Thorn /, q/223/ => qw/ germandbls /, q/224/ => qw/ agrave /, q/225/ => qw/ aacute /, q/226/ => qw/ acircumflex /, q/227/ => qw/ atilde /, q/228/ => qw/ adieresis /,
		q/229/ => qw/ aring /, q/230/ => qw/ ae /, q/231/ => qw/ ccedilla /, q/232/ => qw/ egrave /, q/233/ => qw/ eacute /, q/234/ => qw/ ecircumflex /, q/235/ => qw/ edieresis /, q/236/ => qw/ igrave /, q/237/ => qw/ iacute /, q/238/ => qw/ icircumflex /, q/239/ => qw/ idieresis /, q/240/ => qw/ eth /, q/241/ => qw/ ntilde /, q/242/ => qw/ ograve /, q/243/ => qw/ oacute /, q/244/ => qw/ ocircumflex /, q/245/ => qw/ otilde /, q/246/ => qw/ odieresis /, q/247/ => qw/ divide /, q/248/ => qw/ oslash /, q/249/ => qw/ ugrave /, q/250/ => qw/ uacute /, q/251/ => qw/ ucircumflex /, q/252/ => qw/ udieresis /, q/253/ => qw/ yacute /, q/254/ => qw/ thorn /, q/255/ => qw/ ydieresis /, q/256/ => qw/ Amacron /, q/257/ => qw/ amacron /, q/258/ => qw/ Abreve /, q/259/ => qw/ abreve /, q/260/ => qw/ Aogonek /,
		q/261/ => qw/ aogonek /, q/262/ => qw/ Cacute /, q/263/ => qw/ cacute /, q/264/ => qw/ Ccircumflex /, q/265/ => qw/ ccircumflex /, q/266/ => qw/ Cdotaccent /, q/267/ => qw/ cdotaccent /, q/268/ => qw/ Ccaron /, q/269/ => qw/ ccaron /, q/270/ => qw/ Dcaron /, q/271/ => qw/ dcaron /, q/272/ => qw/ Dcroat /, q/273/ => qw/ dcroat /, q/274/ => qw/ Emacron /, q/275/ => qw/ emacron /, q/276/ => qw/ Ebreve /, q/277/ => qw/ ebreve /, q/278/ => qw/ Edotaccent /, q/279/ => qw/ edotaccent /, q/280/ => qw/ Eogonek /, q/281/ => qw/ eogonek /, q/282/ => qw/ Ecaron /, q/283/ => qw/ ecaron /, q/284/ => qw/ Gcircumflex /, q/285/ => qw/ gcircumflex /, q/286/ => qw/ Gbreve /, q/287/ => qw/ gbreve /, q/288/ => qw/ Gdotaccent /, q/289/ => qw/ gdotaccent /, q/290/ => qw/ Gcommaaccent /, q/291/ => qw/ gcommaaccent /, q/292/ => qw/ Hcircumflex /, q/293/ => qw/ hcircumflex /, q/294/ => qw/ Hbar /, q/295/ => qw/ hbar /,
		q/296/ => qw/ Itilde /, q/297/ => qw/ itilde /, q/298/ => qw/ Imacron /, q/299/ => qw/ imacron /, q/300/ => qw/ Ibreve /, q/301/ => qw/ ibreve /, q/302/ => qw/ Iogonek /, q/303/ => qw/ iogonek /, q/304/ => qw/ Idotaccent /, q/305/ => qw/ dotlessi /, q/306/ => qw/ IJ /, q/307/ => qw/ ij /, q/308/ => qw/ Jcircumflex /, q/309/ => qw/ jcircumflex /, q/310/ => qw/ Kcommaaccent /, q/311/ => qw/ kcommaaccent /, q/312/ => qw/ kgreenlandic /, q/313/ => qw/ Lacute /, q/314/ => qw/ lacute /, q/315/ => qw/ Lcommaaccent /, q/316/ => qw/ lcommaaccent /, q/317/ => qw/ Lcaron /, q/318/ => qw/ lcaron /, q/319/ => qw/ Ldot /, q/320/ => qw/ ldot /,
		q/321/ => qw/ Lslash /, q/322/ => qw/ lslash /, q/323/ => qw/ Nacute /, q/324/ => qw/ nacute /, q/325/ => qw/ Ncommaaccent /, q/326/ => qw/ ncommaaccent /, q/327/ => qw/ Ncaron /, q/328/ => qw/ ncaron /, q/329/ => qw/ napostrophe /, q/330/ => qw/ Eng /, q/331/ => qw/ eng /, q/332/ => qw/ Omacron /, q/333/ => qw/ omacron /, q/334/ => qw/ Obreve /, q/335/ => qw/ obreve /, q/336/ => qw/ Ohungarumlaut /, q/337/ => qw/ ohungarumlaut /, q/338/ => qw/ OE /, q/339/ => qw/ oe /, q/340/ => qw/ Racute /, q/341/ => qw/ racute /, q/342/ => qw/ Rcommaaccent /, q/343/ => qw/ rcommaaccent /, q/344/ => qw/ Rcaron /, q/345/ => qw/ rcaron /, q/346/ => qw/ Sacute /, q/347/ => qw/ sacute /, q/348/ => qw/ Scircumflex /, q/349/ => qw/ scircumflex /, q/350/ => qw/ Scedilla /,
		q/351/ => qw/ scedilla /, q/352/ => qw/ Scaron /, q/353/ => qw/ scaron /, q/354/ => qw/ Tcommaaccent /, q/355/ => qw/ tcommaaccent /, q/356/ => qw/ Tcaron /, q/357/ => qw/ tcaron /, q/358/ => qw/ Tbar /, q/359/ => qw/ tbar /, q/360/ => qw/ Utilde /, q/361/ => qw/ utilde /, q/362/ => qw/ Umacron /, q/363/ => qw/ umacron /, q/364/ => qw/ Ubreve /, q/365/ => qw/ ubreve /, q/366/ => qw/ Uring /, q/367/ => qw/ uring /, q/368/ => qw/ Uhungarumlaut /, q/369/ => qw/ uhungarumlaut /, q/370/ => qw/ Uogonek /, q/371/ => qw/ uogonek /, q/372/ => qw/ Wcircumflex /, q/373/ => qw/ wcircumflex /, q/374/ => qw/ Ycircumflex /, q/375/ => qw/ ycircumflex /, q/376/ => qw/ Ydieresis /, q/377/ => qw/ Zacute /, q/378/ => qw/ zacute /, q/379/ => qw/ Zdotaccent /, q/380/ => qw/ zdotaccent /, q/381/ => qw/ Zcaron /, q/382/ => qw/ zcaron /, q/383/ => qw/ longs /, q/402/ => qw/ florin /, q/416/ => qw/ Ohorn /, q/417/ => qw/ ohorn /, q/431/ => qw/ Uhorn /, q/432/ => qw/ uhorn /, q/486/ => qw/ Gcaron /, q/487/ => qw/ gcaron /, q/506/ => qw/ Aringacute /,
		q/507/ => qw/ aringacute /, q/508/ => qw/ AEacute /, q/509/ => qw/ aeacute /, q/510/ => qw/ Oslashacute /, q/511/ => qw/ oslashacute /, q/536/ => qw/ Scommaaccent /, q/537/ => qw/ scommaaccent /, q/538/ => qw/ Tcommaaccent /, q/539/ => qw/ tcommaaccent /, q/700/ => qw/ afii57929 /, q/701/ => qw/ afii64937 /, q/710/ => qw/ circumflex /, q/711/ => qw/ caron /, q/713/ => qw/ macron /, q/728/ => qw/ breve /, q/729/ => qw/ dotaccent /, q/730/ => qw/ ring /, q/731/ => qw/ ogonek /, q/732/ => qw/ tilde /, q/733/ => qw/ hungarumlaut /, q/768/ => qw/ gravecomb /, q/769/ => qw/ acutecomb /, q/771/ => qw/ tildecomb /, q/777/ => qw/ hookabovecomb /, q/803/ => qw/ dotbelowcomb /, q/900/ => qw/ tonos /, q/901/ => qw/ dieresistonos /, q/902/ => qw/ Alphatonos /, q/903/ => qw/ anoteleia /, q/904/ => qw/ Epsilontonos /, q/905/ => qw/ Etatonos /, q/906/ => qw/ Iotatonos /, q/908/ => qw/ Omicrontonos /,
		q/910/ => qw/ Upsilontonos /, q/911/ => qw/ Omegatonos /, q/912/ => qw/ iotadieresistonos /, q/913/ => qw/ Alpha /, q/914/ => qw/ Beta /, q/915/ => qw/ Gamma /, q/916/ => qw/ Delta /, q/917/ => qw/ Epsilon /, q/918/ => qw/ Zeta /, q/919/ => qw/ Eta /, q/920/ => qw/ Theta /, q/921/ => qw/ Iota /, q/922/ => qw/ Kappa /, q/923/ => qw/ Lambda /, q/924/ => qw/ Mu /, q/925/ => qw/ Nu /, q/926/ => qw/ Xi /, q/927/ => qw/ Omicron /, q/928/ => qw/ Pi /, q/929/ => qw/ Rho /, q/931/ => qw/ Sigma /, q/932/ => qw/ Tau /, q/933/ => qw/ Upsilon /, q/934/ => qw/ Phi /, q/935/ => qw/ Chi /, q/936/ => qw/ Psi /, q/937/ => qw/ Omega /, q/938/ => qw/ Iotadieresis /, q/939/ => qw/ Upsilondieresis /, q/940/ => qw/ alphatonos /, q/941/ => qw/ epsilontonos /, q/942/ => qw/ etatonos /,
		q/943/ => qw/ iotatonos /, q/944/ => qw/ upsilondieresistonos /, q/945/ => qw/ alpha /, q/946/ => qw/ beta /, q/947/ => qw/ gamma /, q/948/ => qw/ delta /, q/949/ => qw/ epsilon /, q/950/ => qw/ zeta /, q/951/ => qw/ eta /, q/952/ => qw/ theta /, q/953/ => qw/ iota /, q/954/ => qw/ kappa /, q/955/ => qw/ lambda /, q/956/ => qw/ mu /, q/957/ => qw/ nu /, q/958/ => qw/ xi /, q/959/ => qw/ omicron /, q/960/ => qw/ pi /, q/961/ => qw/ rho /, q/962/ => qw/ sigma1 /, q/963/ => qw/ sigma /, q/964/ => qw/ tau /, q/965/ => qw/ upsilon /, q/966/ => qw/ phi /, q/967/ => qw/ chi /, q/968/ => qw/ psi /, q/969/ => qw/ omega /, q/970/ => qw/ iotadieresis /, q/971/ => qw/ upsilondieresis /, q/972/ => qw/ omicrontonos /, q/973/ => qw/ upsilontonos /, q/974/ => qw/ omegatonos /,
		q/977/ => qw/ theta1 /, q/978/ => qw/ Upsilon1 /, q/981/ => qw/ phi1 /, q/982/ => qw/ omega1 /, q/1025/ => qw/ afii10023 /, q/1026/ => qw/ afii10051 /, q/1027/ => qw/ afii10052 /, q/1028/ => qw/ afii10053 /, q/1029/ => qw/ afii10054 /, q/1030/ => qw/ afii10055 /, q/1031/ => qw/ afii10056 /, q/1032/ => qw/ afii10057 /, q/1033/ => qw/ afii10058 /, q/1034/ => qw/ afii10059 /, q/1035/ => qw/ afii10060 /, q/1036/ => qw/ afii10061 /, q/1038/ => qw/ afii10062 /, q/1039/ => qw/ afii10145 /, q/1040/ => qw/ afii10017 /, q/1041/ => qw/ afii10018 /, q/1042/ => qw/ afii10019 /, q/1043/ => qw/ afii10020 /, q/1044/ => qw/ afii10021 /, q/1045/ => qw/ afii10022 /, q/1046/ => qw/ afii10024 /, q/1047/ => qw/ afii10025 /, q/1048/ => qw/ afii10026 /, q/1049/ => qw/ afii10027 /,
		q/1050/ => qw/ afii10028 /, q/1051/ => qw/ afii10029 /, q/1052/ => qw/ afii10030 /, q/1053/ => qw/ afii10031 /, q/1054/ => qw/ afii10032 /, q/1055/ => qw/ afii10033 /, q/1056/ => qw/ afii10034 /, q/1057/ => qw/ afii10035 /, q/1058/ => qw/ afii10036 /, q/1059/ => qw/ afii10037 /, q/1060/ => qw/ afii10038 /, q/1061/ => qw/ afii10039 /, q/1062/ => qw/ afii10040 /, q/1063/ => qw/ afii10041 /, q/1064/ => qw/ afii10042 /, q/1065/ => qw/ afii10043 /, q/1066/ => qw/ afii10044 /, q/1067/ => qw/ afii10045 /, q/1068/ => qw/ afii10046 /, q/1069/ => qw/ afii10047 /, q/1070/ => qw/ afii10048 /, q/1071/ => qw/ afii10049 /, q/1072/ => qw/ afii10065 /, q/1073/ => qw/ afii10066 /, q/1074/ => qw/ afii10067 /, q/1075/ => qw/ afii10068 /, q/1076/ => qw/ afii10069 /, q/1077/ => qw/ afii10070 /, q/1078/ => qw/ afii10072 /, q/1079/ => qw/ afii10073 /, q/1080/ => qw/ afii10074 /, q/1081/ => qw/ afii10075 /,
		q/1082/ => qw/ afii10076 /, q/1083/ => qw/ afii10077 /, q/1084/ => qw/ afii10078 /, q/1085/ => qw/ afii10079 /, q/1086/ => qw/ afii10080 /, q/1087/ => qw/ afii10081 /, q/1088/ => qw/ afii10082 /, q/1089/ => qw/ afii10083 /, q/1090/ => qw/ afii10084 /, q/1091/ => qw/ afii10085 /, q/1092/ => qw/ afii10086 /, q/1093/ => qw/ afii10087 /, q/1094/ => qw/ afii10088 /, q/1095/ => qw/ afii10089 /, q/1096/ => qw/ afii10090 /, q/1097/ => qw/ afii10091 /, q/1098/ => qw/ afii10092 /, q/1099/ => qw/ afii10093 /, q/1100/ => qw/ afii10094 /, q/1101/ => qw/ afii10095 /, q/1102/ => qw/ afii10096 /, q/1103/ => qw/ afii10097 /, q/1105/ => qw/ afii10071 /, q/1106/ => qw/ afii10099 /, q/1107/ => qw/ afii10100 /, q/1108/ => qw/ afii10101 /, q/1109/ => qw/ afii10102 /, q/1110/ => qw/ afii10103 /, q/1111/ => qw/ afii10104 /, q/1112/ => qw/ afii10105 /, q/1113/ => qw/ afii10106 /, q/1114/ => qw/ afii10107 /,
		q/1115/ => qw/ afii10108 /, q/1116/ => qw/ afii10109 /, q/1118/ => qw/ afii10110 /, q/1119/ => qw/ afii10193 /, q/1122/ => qw/ afii10146 /, q/1123/ => qw/ afii10194 /, q/1138/ => qw/ afii10147 /, q/1139/ => qw/ afii10195 /, q/1140/ => qw/ afii10148 /, q/1141/ => qw/ afii10196 /, q/1168/ => qw/ afii10050 /, q/1169/ => qw/ afii10098 /, q/1241/ => qw/ afii10846 /, q/1456/ => qw/ afii57799 /, q/1457/ => qw/ afii57801 /, q/1458/ => qw/ afii57800 /, q/1459/ => qw/ afii57802 /, q/1460/ => qw/ afii57793 /, q/1461/ => qw/ afii57794 /, q/1462/ => qw/ afii57795 /, q/1463/ => qw/ afii57798 /, q/1464/ => qw/ afii57797 /, q/1465/ => qw/ afii57806 /, q/1467/ => qw/ afii57796 /, q/1468/ => qw/ afii57807 /, q/1469/ => qw/ afii57839 /, q/1470/ => qw/ afii57645 /, q/1471/ => qw/ afii57841 /, q/1472/ => qw/ afii57842 /, q/1473/ => qw/ afii57804 /, q/1474/ => qw/ afii57803 /, q/1475/ => qw/ afii57658 /,
		q/1488/ => qw/ afii57664 /, q/1489/ => qw/ afii57665 /, q/1490/ => qw/ afii57666 /, q/1491/ => qw/ afii57667 /, q/1492/ => qw/ afii57668 /, q/1493/ => qw/ afii57669 /, q/1494/ => qw/ afii57670 /, q/1495/ => qw/ afii57671 /, q/1496/ => qw/ afii57672 /, q/1497/ => qw/ afii57673 /, q/1498/ => qw/ afii57674 /, q/1499/ => qw/ afii57675 /, q/1500/ => qw/ afii57676 /, q/1501/ => qw/ afii57677 /, q/1502/ => qw/ afii57678 /, q/1503/ => qw/ afii57679 /, q/1504/ => qw/ afii57680 /, q/1505/ => qw/ afii57681 /, q/1506/ => qw/ afii57682 /, q/1507/ => qw/ afii57683 /, q/1508/ => qw/ afii57684 /, q/1509/ => qw/ afii57685 /, q/1510/ => qw/ afii57686 /, q/1511/ => qw/ afii57687 /, q/1512/ => qw/ afii57688 /, q/1513/ => qw/ afii57689 /, q/1514/ => qw/ afii57690 /, q/1520/ => qw/ afii57716 /, q/1521/ => qw/ afii57717 /, q/1522/ => qw/ afii57718 /, q/1548/ => qw/ afii57388 /, q/1563/ => qw/ afii57403 /, q/1567/ => qw/ afii57407 /, q/1569/ => qw/ afii57409 /, q/1570/ => qw/ afii57410 /, q/1571/ => qw/ afii57411 /, q/1572/ => qw/ afii57412 /,
		q/1573/ => qw/ afii57413 /, q/1574/ => qw/ afii57414 /, q/1575/ => qw/ afii57415 /, q/1576/ => qw/ afii57416 /, q/1577/ => qw/ afii57417 /, q/1578/ => qw/ afii57418 /, q/1579/ => qw/ afii57419 /, q/1580/ => qw/ afii57420 /, q/1581/ => qw/ afii57421 /, q/1582/ => qw/ afii57422 /, q/1583/ => qw/ afii57423 /, q/1584/ => qw/ afii57424 /, q/1585/ => qw/ afii57425 /, q/1586/ => qw/ afii57426 /, q/1587/ => qw/ afii57427 /, q/1588/ => qw/ afii57428 /, q/1589/ => qw/ afii57429 /, q/1590/ => qw/ afii57430 /, q/1591/ => qw/ afii57431 /, q/1592/ => qw/ afii57432 /, q/1593/ => qw/ afii57433 /, q/1594/ => qw/ afii57434 /, q/1600/ => qw/ afii57440 /, q/1601/ => qw/ afii57441 /, q/1602/ => qw/ afii57442 /, q/1603/ => qw/ afii57443 /, q/1604/ => qw/ afii57444 /, q/1605/ => qw/ afii57445 /, q/1606/ => qw/ afii57446 /, q/1607/ => qw/ afii57470 /, q/1608/ => qw/ afii57448 /, q/1609/ => qw/ afii57449 /,
		q/1610/ => qw/ afii57450 /, q/1611/ => qw/ afii57451 /, q/1612/ => qw/ afii57452 /, q/1613/ => qw/ afii57453 /, q/1614/ => qw/ afii57454 /, q/1615/ => qw/ afii57455 /, q/1616/ => qw/ afii57456 /, q/1617/ => qw/ afii57457 /, q/1618/ => qw/ afii57458 /, q/1632/ => qw/ afii57392 /, q/1633/ => qw/ afii57393 /, q/1634/ => qw/ afii57394 /, q/1635/ => qw/ afii57395 /, q/1636/ => qw/ afii57396 /, q/1637/ => qw/ afii57397 /, q/1638/ => qw/ afii57398 /, q/1639/ => qw/ afii57399 /, q/1640/ => qw/ afii57400 /, q/1641/ => qw/ afii57401 /, q/1642/ => qw/ afii57381 /, q/1645/ => qw/ afii63167 /, q/1657/ => qw/ afii57511 /, q/1662/ => qw/ afii57506 /,
		q/1670/ => qw/ afii57507 /, q/1672/ => qw/ afii57512 /, q/1681/ => qw/ afii57513 /, q/1688/ => qw/ afii57508 /, q/1700/ => qw/ afii57505 /, q/1711/ => qw/ afii57509 /, q/1722/ => qw/ afii57514 /, q/1746/ => qw/ afii57519 /, q/1749/ => qw/ afii57534 /, q/7808/ => qw/ Wgrave /, q/7809/ => qw/ wgrave /, q/7810/ => qw/ Wacute /, q/7811/ => qw/ wacute /, q/7812/ => qw/ Wdieresis /, q/7813/ => qw/ wdieresis /, q/7922/ => qw/ Ygrave /, q/7923/ => qw/ ygrave /, q/8204/ => qw/ afii61664 /, q/8205/ => qw/ afii301 /, q/8206/ => qw/ afii299 /, q/8207/ => qw/ afii300 /, q/8210/ => qw/ figuredash /, q/8211/ => qw/ endash /, q/8212/ => qw/ emdash /, q/8213/ => qw/ afii00208 /, q/8215/ => qw/ underscoredbl /, q/8216/ => qw/ quoteleft /, q/8217/ => qw/ quoteright /, q/8218/ => qw/ quotesinglbase /, q/8219/ => qw/ quotereversed /, q/8220/ => qw/ quotedblleft /, q/8221/ => qw/ quotedblright /,
		q/8222/ => qw/ quotedblbase /, q/8224/ => qw/ dagger /, q/8225/ => qw/ daggerdbl /, q/8226/ => qw/ bullet /, q/8228/ => qw/ onedotenleader /, q/8229/ => qw/ twodotenleader /, q/8230/ => qw/ ellipsis /, q/8236/ => qw/ afii61573 /, q/8237/ => qw/ afii61574 /, q/8238/ => qw/ afii61575 /, q/8240/ => qw/ perthousand /, q/8242/ => qw/ minute /, q/8243/ => qw/ second /, q/8249/ => qw/ guilsinglleft /, q/8250/ => qw/ guilsinglright /, q/8252/ => qw/ exclamdbl /, q/8260/ => qw/ fraction /, q/8304/ => qw/ zerosuperior /, q/8308/ => qw/ foursuperior /, q/8309/ => qw/ fivesuperior /, q/8310/ => qw/ sixsuperior /, q/8311/ => qw/ sevensuperior /, q/8312/ => qw/ eightsuperior /, q/8313/ => qw/ ninesuperior /, q/8317/ => qw/ parenleftsuperior /, q/8318/ => qw/ parenrightsuperior /, q/8319/ => qw/ nsuperior /, q/8320/ => qw/ zeroinferior /, q/8321/ => qw/ oneinferior /, q/8322/ => qw/ twoinferior /,
		q/8323/ => qw/ threeinferior /, q/8324/ => qw/ fourinferior /, q/8325/ => qw/ fiveinferior /, q/8326/ => qw/ sixinferior /, q/8327/ => qw/ seveninferior /, q/8328/ => qw/ eightinferior /, q/8329/ => qw/ nineinferior /, q/8333/ => qw/ parenleftinferior /, q/8334/ => qw/ parenrightinferior /, q/8353/ => qw/ colonmonetary /, q/8355/ => qw/ franc /, q/8356/ => qw/ lira /, q/8359/ => qw/ peseta /, q/8362/ => qw/ afii57636 /, q/8363/ => qw/ dong /, q/8364/ => qw/ Euro /, q/8453/ => qw/ afii61248 /, q/8465/ => qw/ Ifraktur /, q/8467/ => qw/ afii61289 /, q/8470/ => qw/ afii61352 /, q/8472/ => qw/ weierstrass /, q/8476/ => qw/ Rfraktur /, q/8478/ => qw/ prescription /, q/8482/ => qw/ trademark /, q/8486/ => qw/ Omega /, q/8494/ => qw/ estimated /, q/8501/ => qw/ aleph /, q/8531/ => qw/ onethird /, q/8532/ => qw/ twothirds /, q/8539/ => qw/ oneeighth /, q/8540/ => qw/ threeeighths /, q/8541/ => qw/ fiveeighths /, q/8542/ => qw/ seveneighths /, q/8592/ => qw/ arrowleft /, q/8593/ => qw/ arrowup /, q/8594/ => qw/ a161 arrowright /,
		q/8595/ => qw/ arrowdown /, q/8596/ => qw/ a163 arrowboth /, q/8597/ => qw/ a164 arrowupdn /, q/8616/ => qw/ arrowupdnbse /, q/8629/ => qw/ carriagereturn /, q/8656/ => qw/ arrowdblleft /, q/8657/ => qw/ arrowdblup /, q/8658/ => qw/ arrowdblright /, q/8659/ => qw/ arrowdbldown /, q/8660/ => qw/ arrowdblboth /, q/8704/ => qw/ universal /, q/8706/ => qw/ partialdiff /, q/8707/ => qw/ existential /, q/8709/ => qw/ emptyset /, q/8710/ => qw/ Delta /, q/8711/ => qw/ gradient /, q/8712/ => qw/ element /, q/8713/ => qw/ notelement /, q/8715/ => qw/ suchthat /, q/8719/ => qw/ product /, q/8721/ => qw/ summation /, q/8722/ => qw/ minus /, q/8725/ => qw/ fraction /, q/8727/ => qw/ asteriskmath /, q/8729/ => qw/ periodcentered /, q/8730/ => qw/ radical /, q/8733/ => qw/ proportional /, q/8734/ => qw/ infinity /, q/8735/ => qw/ orthogonal /, q/8736/ => qw/ angle /, q/8743/ => qw/ logicaland /,
		q/8744/ => qw/ logicalor /, q/8745/ => qw/ intersection /, q/8746/ => qw/ union /, q/8747/ => qw/ integral /, q/8756/ => qw/ therefore /, q/8764/ => qw/ similar /, q/8773/ => qw/ congruent /, q/8776/ => qw/ approxequal /, q/8800/ => qw/ notequal /, q/8801/ => qw/ equivalence /, q/8804/ => qw/ lessequal /, q/8805/ => qw/ greaterequal /, q/8834/ => qw/ propersubset /, q/8835/ => qw/ propersuperset /, q/8836/ => qw/ notsubset /, q/8838/ => qw/ reflexsubset /, q/8839/ => qw/ reflexsuperset /, q/8853/ => qw/ circleplus /, q/8855/ => qw/ circlemultiply /, q/8869/ => qw/ perpendicular /, q/8901/ => qw/ dotmath /, q/8962/ => qw/ house /, q/8976/ => qw/ revlogicalnot /, q/8992/ => qw/ integraltp /, q/8993/ => qw/ integralbt /, q/9001/ => qw/ angleleft /, q/9002/ => qw/ angleright /, q/9312/ => qw/ a120 /, q/9313/ => qw/ a121 /, q/9314/ => qw/ a122 /, q/9315/ => qw/ a123 /, q/9316/ => qw/ a124 /, q/9317/ => qw/ a125 /, q/9318/ => qw/ a126 /, q/9319/ => qw/ a127 /, q/9320/ => qw/ a128 /, q/9321/ => qw/ a129 /, q/9472/ => qw/ SF100000 /,
		q/9474/ => qw/ SF110000 /, q/9484/ => qw/ SF010000 /, q/9488/ => qw/ SF030000 /, q/9492/ => qw/ SF020000 /, q/9496/ => qw/ SF040000 /, q/9500/ => qw/ SF080000 /, q/9508/ => qw/ SF090000 /, q/9516/ => qw/ SF060000 /, q/9524/ => qw/ SF070000 /, q/9532/ => qw/ SF050000 /, q/9552/ => qw/ SF430000 /, q/9553/ => qw/ SF240000 /, q/9554/ => qw/ SF510000 /, q/9555/ => qw/ SF520000 /, q/9556/ => qw/ SF390000 /, q/9557/ => qw/ SF220000 /, q/9558/ => qw/ SF210000 /, q/9559/ => qw/ SF250000 /, q/9560/ => qw/ SF500000 /, q/9561/ => qw/ SF490000 /, q/9562/ => qw/ SF380000 /, q/9563/ => qw/ SF280000 /, q/9564/ => qw/ SF270000 /, q/9565/ => qw/ SF260000 /, q/9566/ => qw/ SF360000 /, q/9567/ => qw/ SF370000 /, q/9568/ => qw/ SF420000 /, q/9569/ => qw/ SF190000 /, q/9570/ => qw/ SF200000 /, q/9571/ => qw/ SF230000 /, q/9572/ => qw/ SF470000 /, q/9573/ => qw/ SF480000 /, q/9574/ => qw/ SF410000 /, q/9575/ => qw/ SF450000 /, q/9576/ => qw/ SF460000 /, q/9577/ => qw/ SF400000 /, q/9578/ => qw/ SF540000 /, q/9579/ => qw/ SF530000 /, q/9580/ => qw/ SF440000 /, q/9600/ => qw/ upblock /, q/9604/ => qw/ dnblock /, q/9608/ => qw/ block /, q/9612/ => qw/ lfblock /, q/9616/ => qw/ rtblock /, q/9617/ => qw/ ltshade /, q/9618/ => qw/ shade /,
		q/9619/ => qw/ dkshade /, q/9632/ => qw/ a73 filledbox /, q/9633/ => qw/ H22073 /, q/9642/ => qw/ H18543 /, q/9643/ => qw/ H18551 /, q/9644/ => qw/ filledrect /, q/9650/ => qw/ a76 triagup /, q/9658/ => qw/ triagrt /, q/9660/ => qw/ a77 triagdn /, q/9668/ => qw/ triaglf /, q/9670/ => qw/ a78 /, q/9674/ => qw/ lozenge /, q/9675/ => qw/ circle /, q/9679/ => qw/ H18533 a71 /, q/9687/ => qw/ a81 /, q/9688/ => qw/ invbullet /, q/9689/ => qw/ invcircle /, q/9702/ => qw/ openbullet /, q/9733/ => qw/ a35 /, q/9742/ => qw/ a4 /, q/9755/ => qw/ a11 /, q/9758/ => qw/ a12 /, q/9786/ => qw/ smileface /, q/9787/ => qw/ invsmileface /, q/9788/ => qw/ sun /, q/9792/ => qw/ female /, q/9794/ => qw/ male /, q/9824/ => qw/ a109 spade /, q/9827/ => qw/ a112 club /, q/9829/ => qw/ a110 heart /, q/9830/ => qw/ a111 diamond /, q/9834/ => qw/ musicalnote /, q/9835/ => qw/ musicalnotedbl /, q/9985/ => qw/ a1 /, q/9986/ => qw/ a2 /, q/9987/ => qw/ a202 /, q/9988/ => qw/ a3 /, q/9990/ => qw/ a5 /, q/9991/ => qw/ a119 /, q/9992/ => qw/ a118 /,
		q/9993/ => qw/ a117 /, q/9996/ => qw/ a13 /, q/9997/ => qw/ a14 /, q/9998/ => qw/ a15 /, q/9999/ => qw/ a16 /, q/10000/ => qw/ a105 /, q/10001/ => qw/ a17 /, q/10002/ => qw/ a18 /, q/10003/ => qw/ a19 /, q/10004/ => qw/ a20 /, q/10005/ => qw/ a21 /, q/10006/ => qw/ a22 /, q/10007/ => qw/ a23 /, q/10008/ => qw/ a24 /, q/10009/ => qw/ a25 /, q/10010/ => qw/ a26 /, q/10011/ => qw/ a27 /, q/10012/ => qw/ a28 /, q/10013/ => qw/ a6 /, q/10014/ => qw/ a7 /, q/10015/ => qw/ a8 /, q/10016/ => qw/ a9 /, q/10017/ => qw/ a10 /, q/10018/ => qw/ a29 /, q/10019/ => qw/ a30 /, q/10020/ => qw/ a31 /, q/10021/ => qw/ a32 /, q/10022/ => qw/ a33 /, q/10023/ => qw/ a34 /, q/10025/ => qw/ a36 /, q/10026/ => qw/ a37 /, q/10027/ => qw/ a38 /, q/10028/ => qw/ a39 /, q/10029/ => qw/ a40 /, q/10030/ => qw/ a41 /, q/10031/ => qw/ a42 /, q/10032/ => qw/ a43 /, q/10033/ => qw/ a44 /, q/10034/ => qw/ a45 /, q/10035/ => qw/ a46 /, q/10036/ => qw/ a47 /, q/10037/ => qw/ a48 /, q/10038/ => qw/ a49 /, q/10039/ => qw/ a50 /, q/10040/ => qw/ a51 /,
		q/10041/ => qw/ a52 /, q/10042/ => qw/ a53 /, q/10043/ => qw/ a54 /, q/10044/ => qw/ a55 /, q/10045/ => qw/ a56 /, q/10046/ => qw/ a57 /, q/10047/ => qw/ a58 /, q/10048/ => qw/ a59 /, q/10049/ => qw/ a60 /, q/10050/ => qw/ a61 /, q/10051/ => qw/ a62 /, q/10052/ => qw/ a63 /, q/10053/ => qw/ a64 /, q/10054/ => qw/ a65 /, q/10055/ => qw/ a66 /, q/10056/ => qw/ a67 /, q/10057/ => qw/ a68 /, q/10058/ => qw/ a69 /, q/10059/ => qw/ a70 /, q/10061/ => qw/ a72 /, q/10063/ => qw/ a74 /, q/10064/ => qw/ a203 /, q/10065/ => qw/ a75 /, q/10066/ => qw/ a204 /, q/10070/ => qw/ a79 /, q/10072/ => qw/ a82 /, q/10073/ => qw/ a83 /, q/10074/ => qw/ a84 /, q/10075/ => qw/ a97 /, q/10076/ => qw/ a98 /, q/10077/ => qw/ a99 /, q/10078/ => qw/ a100 /, q/10081/ => qw/ a101 /, q/10082/ => qw/ a102 /, q/10083/ => qw/ a103 /, q/10084/ => qw/ a104 /, q/10085/ => qw/ a106 /, q/10086/ => qw/ a107 /, q/10087/ => qw/ a108 /,
		q/10102/ => qw/ a130 /, q/10103/ => qw/ a131 /, q/10104/ => qw/ a132 /, q/10105/ => qw/ a133 /, q/10106/ => qw/ a134 /, q/10107/ => qw/ a135 /, q/10108/ => qw/ a136 /, q/10109/ => qw/ a137 /, q/10110/ => qw/ a138 /, q/10111/ => qw/ a139 /, q/10112/ => qw/ a140 /, q/10113/ => qw/ a141 /, q/10114/ => qw/ a142 /, q/10115/ => qw/ a143 /, q/10116/ => qw/ a144 /, q/10117/ => qw/ a145 /, q/10118/ => qw/ a146 /, q/10119/ => qw/ a147 /, q/10120/ => qw/ a148 /, q/10121/ => qw/ a149 /, q/10122/ => qw/ a150 /, q/10123/ => qw/ a151 /, q/10124/ => qw/ a152 /, q/10125/ => qw/ a153 /, q/10126/ => qw/ a154 /, q/10127/ => qw/ a155 /, q/10128/ => qw/ a156 /, q/10129/ => qw/ a157 /, q/10130/ => qw/ a158 /, q/10131/ => qw/ a159 /, q/10132/ => qw/ a160 /, q/10136/ => qw/ a196 /, q/10137/ => qw/ a165 /, q/10138/ => qw/ a192 /, q/10139/ => qw/ a166 /, q/10140/ => qw/ a167 /, q/10141/ => qw/ a168 /, q/10142/ => qw/ a169 /, q/10143/ => qw/ a170 /, q/10144/ => qw/ a171 /, q/10145/ => qw/ a172 /, q/10146/ => qw/ a173 /, q/10147/ => qw/ a162 /,
		q/10148/ => qw/ a174 /, q/10149/ => qw/ a175 /, q/10150/ => qw/ a176 /, q/10151/ => qw/ a177 /, q/10152/ => qw/ a178 /, q/10153/ => qw/ a179 /, q/10154/ => qw/ a193 /, q/10155/ => qw/ a180 /, q/10156/ => qw/ a199 /, q/10157/ => qw/ a181 /, q/10158/ => qw/ a200 /, q/10159/ => qw/ a182 /, q/10161/ => qw/ a201 /, q/10162/ => qw/ a183 /, q/10163/ => qw/ a184 /, q/10164/ => qw/ a197 /, q/10165/ => qw/ a185 /, q/10166/ => qw/ a194 /, q/10167/ => qw/ a198 /, q/10168/ => qw/ a186 /, q/10169/ => qw/ a195 /, q/10170/ => qw/ a187 /, q/10171/ => qw/ a188 /, q/10172/ => qw/ a189 /, q/10173/ => qw/ a190 /, q/10174/ => qw/ a191 /, q/63166/ => qw/ dotlessj /, q/63167/ => qw/ LL /, q/63168/ => qw/ ll /, q/63169/ => qw/ Scedilla /, q/63170/ => qw/ scedilla /, q/63171/ => qw/ commaaccent /, q/63172/ => qw/ afii10063 /, q/63173/ => qw/ afii10064 /, q/63174/ => qw/ afii10192 /, q/63175/ => qw/ afii10831 /, q/63176/ => qw/ afii10832 /, q/63177/ => qw/ Acute /, q/63178/ => qw/ Caron /, q/63179/ => qw/ Dieresis /, q/63180/ => qw/ DieresisAcute /,
		q/63181/ => qw/ DieresisGrave /, q/63182/ => qw/ Grave /, q/63183/ => qw/ Hungarumlaut /, q/63184/ => qw/ Macron /, q/63185/ => qw/ cyrBreve /, q/63186/ => qw/ cyrFlex /, q/63187/ => qw/ dblGrave /, q/63188/ => qw/ cyrbreve /, q/63189/ => qw/ cyrflex /, q/63190/ => qw/ dblgrave /, q/63191/ => qw/ dieresisacute /, q/63192/ => qw/ dieresisgrave /, q/63193/ => qw/ copyrightserif /, q/63194/ => qw/ registerserif /, q/63195/ => qw/ trademarkserif /, q/63196/ => qw/ onefitted /, q/63197/ => qw/ rupiah /, q/63198/ => qw/ threequartersemdash /, q/63199/ => qw/ centinferior /, q/63200/ => qw/ centsuperior /, q/63201/ => qw/ commainferior /, q/63202/ => qw/ commasuperior /, q/63203/ => qw/ dollarinferior /, q/63204/ => qw/ dollarsuperior /, q/63205/ => qw/ hypheninferior /, q/63206/ => qw/ hyphensuperior /, q/63207/ => qw/ periodinferior /, q/63208/ => qw/ periodsuperior /, q/63209/ => qw/ asuperior /,
		q/63210/ => qw/ bsuperior /, q/63211/ => qw/ dsuperior /, q/63212/ => qw/ esuperior /, q/63213/ => qw/ isuperior /, q/63214/ => qw/ lsuperior /, q/63215/ => qw/ msuperior /, q/63216/ => qw/ osuperior /, q/63217/ => qw/ rsuperior /, q/63218/ => qw/ ssuperior /, q/63219/ => qw/ tsuperior /, q/63220/ => qw/ Brevesmall /, q/63221/ => qw/ Caronsmall /, q/63222/ => qw/ Circumflexsmall /, q/63223/ => qw/ Dotaccentsmall /, q/63224/ => qw/ Hungarumlautsmall /, q/63225/ => qw/ Lslashsmall /, q/63226/ => qw/ OEsmall /, q/63227/ => qw/ Ogoneksmall /, q/63228/ => qw/ Ringsmall /, q/63229/ => qw/ Scaronsmall /, q/63230/ => qw/ Tildesmall /, q/63231/ => qw/ Zcaronsmall /, q/63265/ => qw/ exclamsmall /, q/63268/ => qw/ dollaroldstyle /, q/63270/ => qw/ ampersandsmall /, q/63280/ => qw/ zerooldstyle /, q/63281/ => qw/ oneoldstyle /, q/63282/ => qw/ twooldstyle /, q/63283/ => qw/ threeoldstyle /,
		q/63284/ => qw/ fouroldstyle /, q/63285/ => qw/ fiveoldstyle /, q/63286/ => qw/ sixoldstyle /, q/63287/ => qw/ sevenoldstyle /, q/63288/ => qw/ eightoldstyle /, q/63289/ => qw/ nineoldstyle /, q/63295/ => qw/ questionsmall /, q/63328/ => qw/ Gravesmall /, q/63329/ => qw/ Asmall /, q/63330/ => qw/ Bsmall /, q/63331/ => qw/ Csmall /, q/63332/ => qw/ Dsmall /, q/63333/ => qw/ Esmall /, q/63334/ => qw/ Fsmall /, q/63335/ => qw/ Gsmall /, q/63336/ => qw/ Hsmall /, q/63337/ => qw/ Ismall /, q/63338/ => qw/ Jsmall /, q/63339/ => qw/ Ksmall /, q/63340/ => qw/ Lsmall /, q/63341/ => qw/ Msmall /, q/63342/ => qw/ Nsmall /, q/63343/ => qw/ Osmall /, q/63344/ => qw/ Psmall /, q/63345/ => qw/ Qsmall /, q/63346/ => qw/ Rsmall /, q/63347/ => qw/ Ssmall /, q/63348/ => qw/ Tsmall /, q/63349/ => qw/ Usmall /, q/63350/ => qw/ Vsmall /, q/63351/ => qw/ Wsmall /, q/63352/ => qw/ Xsmall /, q/63353/ => qw/ Ysmall /, q/63354/ => qw/ Zsmall /, q/63393/ => qw/ exclamdownsmall /, q/63394/ => qw/ centoldstyle /, q/63400/ => qw/ Dieresissmall /, q/63407/ => qw/ Macronsmall /, q/63412/ => qw/ Acutesmall /, q/63416/ => qw/ Cedillasmall /, q/63423/ => qw/ questiondownsmall /, q/63456/ => qw/ Agravesmall /, q/63457/ => qw/ Aacutesmall /, q/63458/ => qw/ Acircumflexsmall /, q/63459/ => qw/ Atildesmall /, q/63460/ => qw/ Adieresissmall /, q/63461/ => qw/ Aringsmall /, q/63462/ => qw/ AEsmall /, q/63463/ => qw/ Ccedillasmall /, q/63464/ => qw/ Egravesmall /, q/63465/ => qw/ Eacutesmall /, q/63466/ => qw/ Ecircumflexsmall /, q/63467/ => qw/ Edieresissmall /,
		q/63468/ => qw/ Igravesmall /, q/63469/ => qw/ Iacutesmall /, q/63470/ => qw/ Icircumflexsmall /, q/63471/ => qw/ Idieresissmall /, q/63472/ => qw/ Ethsmall /, q/63473/ => qw/ Ntildesmall /, q/63474/ => qw/ Ogravesmall /, q/63475/ => qw/ Oacutesmall /, q/63476/ => qw/ Ocircumflexsmall /, q/63477/ => qw/ Otildesmall /, q/63478/ => qw/ Odieresissmall /, q/63480/ => qw/ Oslashsmall /, q/63481/ => qw/ Ugravesmall /, q/63482/ => qw/ Uacutesmall /, q/63483/ => qw/ Ucircumflexsmall /, q/63484/ => qw/ Udieresissmall /, q/63485/ => qw/ Yacutesmall /, q/63486/ => qw/ Thornsmall /, q/63487/ => qw/ Ydieresissmall /, q/63703/ => qw/ a89 /, q/63704/ => qw/ a90 /, q/63705/ => qw/ a93 /, q/63706/ => qw/ a94 /, q/63707/ => qw/ a91 /, q/63708/ => qw/ a92 /, q/63709/ => qw/ a205 /, q/63710/ => qw/ a85 /, q/63711/ => qw/ a206 /, q/63712/ => qw/ a86 /, q/63713/ => qw/ a87 /, q/63714/ => qw/ a88 /, q/63715/ => qw/ a95 /, q/63716/ => qw/ a96 /, q/63717/ => qw/ radicalex /, q/63718/ => qw/ arrowvertex /, q/63719/ => qw/ arrowhorizex /, q/63720/ => qw/ registersans /, q/63721/ => qw/ copyrightsans /, q/63722/ => qw/ trademarksans /, q/63723/ => qw/ parenlefttp /,
		q/63724/ => qw/ parenleftex /, q/63725/ => qw/ parenleftbt /, q/63726/ => qw/ bracketlefttp /, q/63727/ => qw/ bracketleftex /, q/63728/ => qw/ bracketleftbt /, q/63729/ => qw/ bracelefttp /, q/63730/ => qw/ braceleftmid /, q/63731/ => qw/ braceleftbt /, q/63732/ => qw/ braceex /, q/63733/ => qw/ integralex /, q/63734/ => qw/ parenrighttp /, q/63735/ => qw/ parenrightex /, q/63736/ => qw/ parenrightbt /, q/63737/ => qw/ bracketrighttp /, q/63738/ => qw/ bracketrightex /, q/63739/ => qw/ bracketrightbt /, q/63740/ => qw/ bracerighttp /, q/63741/ => qw/ bracerightmid /, q/63742/ => qw/ bracerightbt /, q/64256/ => qw/ ff /, q/64257/ => qw/ fi /, q/64258/ => qw/ fl /, q/64259/ => qw/ ffi /, q/64260/ => qw/ ffl /, q/64287/ => qw/ afii57705 /, q/64298/ => qw/ afii57694 /, q/64299/ => qw/ afii57695 /, q/64309/ => qw/ afii57723 /, q/64331/ => qw/ afii57700 /, q// => qw/ .notdef /,
);

sub genKEY {
	## use Digest::MD5 qw( md5_hex );
	my $key=join('',@_);
	$key=~s/[^a-z0-9]//cgi;	
	my @k=split(//,$key);
	$key=shift @k;
	while(shift @k) {
		$key.=shift(@k);
		$key.=shift(@k);
	}
	## $key=md5_hex($key);
	## $key=uc(substr($key,0,10));
	$key=uc($key);
	
	return($key);
}

sub getDefault {
	my ($this,$parameter,$default)=@_;
	if(grep(/$parameter/i,@Text::PDF::API::parameterlist)) {
		if(defined($this->{'DEFAULT'}{lc($parameter)})) {
			return ($this->{'DEFAULT'}{lc($parameter)});
		} elsif(defined($default)) {
			return ($default);
		} else {
			return undef;
		}
	} else {
		$this->_error('getDefault',"illegal parameter ($parameter)");
		return undef;
	}
}

sub setDefault {
	my ($this,$parameter,$value)=@_;
	if(grep(/$parameter/i,@Text::PDF::API::parameterlist)) {
		$this->{'DEFAULT'}{lc($parameter)}=$value;
	} else {
		$this->_error('setDefault',"illegal parameter ($parameter)");
	}
}
sub _getCurrent {
	my ($this,$parameter)=@_;
	return ($this->{'CURRENT'}{lc($parameter)});
}

sub _setCurrent {
	my ($this,$parameter,$value)=@_;
	$this->{'CURRENT'}{lc($parameter)}=$value;
}

sub _error {	# internal function
	my ($this,$f,$e)=@_;
	print STDERR sprintf("[".localtime()."] Text::PDF::API::%s(%x) : '%s'\n",$f,$this,$e);
}


sub new {
	my $class=shift(@_);
	my %defaults=@_;
	my $this={};
	bless($this);
	$this->{'PDF'} = Text::PDF::File->new;
	$this->{'PAGES'}=();
	$this->{'DEFAULT'}=();
	$this->{'CURRENT'}=();
	$this->{'IMAGES'}=();
	$this->{'STACK'}=();
	$this->setDefault('Compression',1);
	$this->_setCurrent('PageContext',undef);
	$this->_setCurrent('Root',0);
	foreach $parameter (keys(%defaults)) {
		if(grep(/$parameter/i,@Text::PDF::API::parameterlist)) {
			$this->setDefault($parameter,$defaults{$parameter});
		} else {
			$this->_error('new',"illegal parameter ($parameter='".$defaults{$parameter}."')");
		}
	}
	$this->{'PDF'}->{' version'} = $this->getDefault('PdfVersion',3);
	return $this;
}

sub end {
	my $this=shift(@_);
	undef($this);
}

sub saveas {
	my ($this,$file)=@_;
	$this->{'PDF'}->out_file($file);
}



%Text::PDF::API::pagesizes=(
	'a0'		=>	[ 2380	, 3368	],
	'a1'		=>	[ 1684	, 2380	],
	'a2'		=>	[ 1190	, 1684	],
	'a3'		=>	[ 842	, 1190	],
	'a4'		=>	[ 595	, 842	],
	'a5'		=>	[ 421	, 595	],
	'a6'		=>	[ 297	, 421	],
	'letter'	=>	[ 612	, 792	],
	'broadsheet'	=>	[ 1296	, 1584	],
	'ledger'	=>	[ 1224	, 792	],
	'tabloid'	=>	[ 792	, 1224	],
	'legal'		=>	[ 612	, 1008	],
	'executive'	=>	[ 522	, 756	],
	'36x36'		=>	[ 2592	, 2592	],
);

sub newpage {
	my ($this,$width,$height)=@_;
	if(!$this->_getCurrent('Root',0)) {
		$this->_newroot();
	}
	if(!defined($this->_getCurrent('PageContext'))) {
		$this->{'PAGE'} = Text::PDF::Page->new($this->{'PDF'},$this->{'ROOT'});
		push(@{$this->{'PAGES'}},$this->{'PAGE'});
		$this->_setCurrent('PageContext',$#{$pdf->{'PAGES'}});
		if(defined($width) && !defined($height)) {
			if($this->getDefault('pageorientation')=~/^L/i) {
				($height,$width)=@{$Text::PDF::API::pagesizes{$width}};
			} else {
				($width,$height)=@{$Text::PDF::API::pagesizes{$width}};
			}
		} elsif(!defined($width) && !defined($height)) {
			if($this->getDefault('pageorientation')=~/^L/i) {
				($height,$width)=$this->_getDefaultpageWH();
			} else {
				($width,$height)=$this->_getDefaultpageWH();
			}
		} 
		$this->_setMediaBox(0,0,$width,$height);
	} else {
		$this->_error('newpage','called before endpage');
	}
}

sub _getDefaultpageWH {
	my ($this,$size,$w,$h)=@_;
	if($size=$this->getDefault('PageSize')) {
		return(@{$Text::PDF::API::pagesizes{$size}});
	} elsif(($w=$this->getDefault('PageWidth'))&&($h=$this->getDefault('PageHeight'))) {
		return($w,$h);
	} else {
		return(@{$Text::PDF::API::pagesizes{'a4'}});
	}
	
}

sub _setMediaBox {
	my ($this,$x,$y,$width,$height)=@_;
	if(defined($this->_getCurrent('PageContext'))) {
		$this->{'PAGE'}{'MediaBox'}=PDFArray(PDFNum($x),PDFNum($y),PDFNum($width),PDFNum($height));
	} else {
		$this->_error('_setMediaBox','no PageContext defined, skipping');
	}
}

sub _newroot {
	my ($this)=@_;
	if(!$this->_getCurrent('Root')) {
		$this->{'ROOT'} = Text::PDF::Pages->new($this->{'PDF'});
		$this->{'ROOT'}->proc_set(qw( PDF Text ImageB ImageC ImageI ));
		$this->_setCurrent('Root',1);
	} else {
		$this->_error('_newroot','root pages object already created');
	}
}

sub endpage {
	my ($this)=@_;
	if(defined($this->_getCurrent('PageContext'))) {
		if($this->getDefault('compression')==1) {
			$this->{'PAGE'}->{' curstrm'}{'Filter'} = PDFArray(PDFName('FlateDecode'));
		}
		$this->{'PAGE'}=undef;
		$this->_setCurrent('PageContext',undef);
	} else {
		$this->_error('endpage','endpage called before newpage');
	}
}

sub _addtopage {	# internal function
	my ($this,$data)=@_;
	if(defined($this->_getCurrent('PageContext'))) {
		$this->{'PAGE'}->add($data);
	} else {
		$this->_error('_addtopage','no PageContext defined, skipping');
	}
}

sub setFontDir {
	my ($this,$dir)=@_;
	my $lastfd=$this->{'FONTDIR'};
	$this->{'FONTDIR'}=$dir;
	return $lastfd;
}

sub getFontDir {
	my ($this,$dir)=@_;
	return $this->{'FONTDIR'};
}

sub addFontPath {
	my ($this,$dir)=@_;
	if(!$this->{'FONTPATH'}){ $this->{'FONTPATH'}=[];}
	push(@{$this->{'FONTPATH'}},$dir);
}

sub lookUPc2u {
	my ($this,$enc,$char)=@_;
	use Unicode::Map8;
	my $m= Unicode::Map8->new($enc);
	return($m->to_char16($char));
}

sub lookUPu2c {
	my ($this,$enc,$char)=@_;
	use Unicode::Map8;
	my $m= Unicode::Map8->new($enc);
	return($m->to_char8($char));
}

sub lookUPu2n {
	my ($this,$ucode)=@_;
	my (@r);
	@r=(@u2n{$ucode},'.notdef');
	if(wantarray) {
		return @r;
	} else {
		return $r[0] || '.notdef';
	}
}

sub lookUPn2c {
	my ($this,$name)=@_;
}

sub lookUPc2n {
	my ($this,$enc,$char)=@_;
	return(scalar $this->lookUPu2n($this->lookUPc2u($enc,$char)));
}

sub resolveFontFile {
	my $this=shift @_;
	my $file=shift @_;
	my $fontfile=undef;
	if ( -e $file ) {
		$fontfile=$file;
		return $fontfile;
	} else {
		map {
			$fontfile="$_/$file";
			if(-e $fontfile) { return $fontfile; }
		} (
			'.',$this->{'FONTDIR'},@{$this->{'FONTPATH'}},
			map {
				glob("$_/Text/PDF/API/fonts"),
				glob("$_/Text/PDF/fonts"),
				glob("$_/Text/PDF/API/fonts/ttf"),
				glob("$_/Text/PDF/fonts/ttf"),
				glob("$_/Text/PDF/API/fonts/t1"),
				glob("$_/Text/PDF/fonts/t1"),
			} (@INC),
		# last resort looking for files in standard unix/windos locations
			qw( 
				c:/windows/fonts 
				c:/winnt/fonts 
			),
			map {
				glob($_)
			} qw(
				/usr/openwin/lib/locale/*/X11/fonts/TrueType
				/usr/openwin/lib/locale/*/X11/fonts/Type1
				/usr/openwin/lib/locale/*/X11/fonts/Type1/afm
				/usr/openwin/lib/X11/fonts/*/*
				/usr/openwin/lib/X11/fonts/*/*/afm
				/usr/openwin/lib/X11/fonts/*/afm
				/usr/openwin/lib/X11/fonts/*/outline
				/usr/openwin/lib/X11/fonts/*
				/usr/openwin/lib/X11/fonts/*/afm
				/usr/lpp/X11/lib/X11/fonts
				/usr/lpp/X11/lib/X11/fonts/*
				/usr/lib/ps
				/usr/local/share/*/afm
				/usr/local/share/*/fonts
				/usr/local/share/*/fonts/afm
				/usr/share/texmf/fonts/*/*/*
				/usr/share/*/fonts
				/usr/share/fonts/*
				/usr/share/fonts/default/*
				/usr/X11R6/lib/fonts/*
			)
		);
	}
	return undef;
}

sub newFontCore {
	my ($this,$name,$encoding,@glyphs)=@_;
	my ($fontkey,$font,$ug,$fontype,$fontname);

	$fontkey=genKEY($name);

	if(!$this->{'FONTS'}) {
		$this->{'FONTS'}={};
	}

	if(!$this->{'FONTS'}->{$fontkey}) {
		$this->{'FONTS'}->{$fontkey}={};
		$fontype='AC';
		$fontname=$fontype.'x'.$fontkey;
	#	if(grep(/$name/,@Text::PDF::API::CORETYPEFONTS)) {
	#		if($^O eq "MacOS") {
	#			$font=Text::PDF::SFont->new($this->{'PDF'}, $name, $fontname, 2);
	#			$this->{'FONTS'}->{$fontkey}->{'defaultencoding'}=$encoding||'MacRoman';
	#		} elsif($^O eq "MSWin32") {
	#			$font=Text::PDF::SFont->new($this->{'PDF'}, $name, $fontname, 1);
	#			$this->{'FONTS'}->{$fontkey}->{'defaultencoding'}=$encoding||'WinLatin1';
	#		} else {
	#			$font=Text::PDF::SFont->new($this->{'PDF'}, $name, $fontname, 1);
	#			$this->{'FONTS'}->{$fontkey}->{'defaultencoding'}=$encoding||'latin1';
	#		}
	#	} else {
	#		$font=Text::PDF::SFont->new($this->{'PDF'}, $name, $fontname);
	#		$this->{'FONTS'}->{$fontkey}->{'defaultencoding'}=$encoding;
	#	}
	### NEW Text::PDF::AFont code :)
		if($encoding=~/encoding$/i) {
		} elsif($encoding EQ 'latin1') {
		} elsif($encoding EQ 'asis') {
		} elsif($encoding EQ 'custom') {
		} elsif($ug=Unicode::Map8->new($encoding)) {
			undef($ug);
			@glyphs= map {$this->lookUPc2n($encoding,$_);} (0..255);	
			$encoding='WinAnsiEncoding';
		}

		$font=Text::PDF::AFont->newCore(
			$this->{'PDF'}, 
			$name, 
			$fontname,
			$encoding,
			@glyphs
		);
		$this->{'FONTS'}->{$fontkey}={
			'type'	=> $fontype,
			'pdfobj'=> $font,
			'PDFN'	=> $fontname,
		};
		if(!$this->_getCurrent('Root')) {
			$this->_newroot();
		}
		$this->{'ROOT'}->add_font($font);
	} else {
		$fontype=$this->{'FONTS'}->{$fontkey}->{'type'};
		$font=$this->{'FONTS'}->{$fontkey}->{'pdfobj'};
	} 

	#if(grep(/$name/,@Text::PDF::API::CORETYPEFONTS)) {
	#	if(!$font->{'Encoding'}){
	#		$font->{'Encoding'}=PDFDict();
	#		$font->{'Encoding'}->{'Type'}=PDFName('Encoding');
	#		if($^O eq "MacOS") {
	#			$font->{'Encoding'}->{'BaseEncoding'}=PDFName('MacRomanEncoding');
	#		} else {
	#			$font->{'Encoding'}->{'BaseEncoding'}=PDFName('WinAnsiEncoding');
	#		}
	#	}
	#}
	return($fontkey);
}

sub newFontTTF {
	my ($this,$name,$file,$encoding)=@_;
	my ($fontfile,$fontfile2,$fontkey,$ttf,$font,$glyph,$fontype,$fontname,@map);

	$fontkey=genKEY($name);

	if(!$this->{'FONTS'}) {
		$this->{'FONTS'}={};
	}

	if(!$this->{'FONTS'}->{$fontkey}) {
		$this->{'FONTS'}->{$fontkey}={};
		$fontype='TT';
		$fontname=$fontype.'x'.$fontkey;
		$fontfile=$this->resolveFontFile($file);
		die "can not find requested font '$file'" unless($fontfile);
		if($^O eq "MacOS") {
			$this->{'FONTS'}->{$fontkey}->{'defaultencoding'}=$encoding||'MacRoman';
		} elsif($^O eq "MSWin32") {
			$this->{'FONTS'}->{$fontkey}->{'defaultencoding'}=$encoding||'WinLatin1';
		} else {
			$this->{'FONTS'}->{$fontkey}->{'defaultencoding'}=$encoding||'latin1';
		}
		$font=Text::PDF::TTFont0->new($this->{'PDF'}, $fontfile, $fontname);

		$this->{'FONTS'}->{$fontkey}={};
		$this->{'FONTS'}->{$fontkey}={
			'type'	=> $fontype,
			'pdfobj'=> $font,
			'PDFN'	=> $fontname,
		};
		if(!$this->_getCurrent('Root')) {
			$this->_newroot();
		}
		$this->{'ROOT'}->add_font($font);

		$ttf=$font->{' font'};
		$ttf->{'cmap'}->read;
		$ttf->{'hmtx'}->read;
		$ttf->{'post'}->read;
		my $upem = $ttf->{'head'}->read->{'unitsPerEm'};
		if(!$this->{'FONTS'}->{$fontkey}->{'u2g'}) {
			$this->{'FONTS'}->{$fontkey}->{'u2g'}=();
			$this->{'FONTS'}->{$fontkey}->{'u2w'}=();
			@map=$ttf->{'cmap'}->reverse;
			foreach my $x (0..$#map) {
				$this->{'FONTS'}->{$fontkey}->{'u2g'}{$map[$x]}=$x;
				$this->{'FONTS'}->{$fontkey}->{'u2w'}{$map[$x]}=$ttf->{'hmtx'}{'advance'}[$x]/$upem;
			}
		}
	} 
}

sub newFontT1reencode {
	my ($this,$fontkey,$fontype,$encoding,@glyphs)=@_;
	my ($newkey,$font,$fontname,$ug);

	$newkey=$encoding;
	$newkey=~s/[^a-z0-9\-]+//cgi;
	$newkey="$fontkey-$newkey";
	$this->{'FONTS'}->{$newkey}={};
	$fontname=$fontype.'x'.$newkey;

	if($encoding=~/encoding$/i) {
	} elsif($encoding EQ 'latin1') {
	} elsif($encoding EQ 'asis') {
	} elsif($encoding EQ 'custom') {
	} elsif($ug=Unicode::Map8->new($encoding)) {
		undef($ug);
		@glyphs= map {$this->lookUPc2n($encoding,$_);} (0..255);	
		$encoding='WinAnsiEncoding';
	}

	$font=$this->{'FONTS'}->{$fontkey}->{'pdfobj'}->reencode(
		$this->{'PDF'},
		$fontname,
		$encoding,
		@glyphs
	);

	$this->{'FONTS'}->{$newkey}={
		'type'	=> $fontype,
		'pdfobj'=> $font,
		'PDFN'	=> $fontname,
	};

	if(!$this->_getCurrent('Root')) {
		$this->_newroot();
	}
	$this->{'ROOT'}->add_font($font);
}

sub newFontPSreencode {
	my ($this,$fontkey,$encoding,@glyphs)=@_;

	$this->newFontT1reencode($fontkey,'PS',$encoding,@glyphs);
}

sub newFontPS {
	my ($this,$name,$file,$file2,$encoding,@glyphs)=@_;
	my ($fontfile,$fontfile2,$fontkey,$ttf,$font,$ug,$fontype,$fontname,@map);

	$fontkey=genKEY($name);

	if(!$this->{'FONTS'}) {
		$this->{'FONTS'}={};
	}

	if(!$this->{'FONTS'}->{$fontkey}) {
		$this->{'FONTS'}->{$fontkey}={};
		$fontype='PS';
		$fontname=$fontype.'x'.$fontkey;
		$fontfile=$this->resolveFontFile($file) || die "can not find requested font '$file'";
		$fontfile2=$this->resolveFontFile($file2) || die "can not find requested font '$file2'";

		if($encoding=~/encoding$/i) {
		} elsif($encoding EQ 'latin1') {
		} elsif($encoding EQ 'asis') {
		} elsif($encoding EQ 'custom') {
		} elsif($ug=Unicode::Map8->new($encoding)) {
			undef($ug);
			@glyphs= map {$this->lookUPc2n($encoding,$_);} (0..255);	
			$encoding='WinAnsiEncoding';
		}

		$font=Text::PDF::AFont->new(
			$this->{'PDF'}, 
			$fontfile, 
			$fontfile2, 
			$fontname,
			$encoding,
			@glyphs
		);

		$this->{'FONTS'}->{$fontkey}={
			'type'	=> $fontype,
			'pdfobj'=> $font,
			'PDFN'	=> $fontname,
		};

		if(!$this->_getCurrent('Root')) {
			$this->_newroot();
		}
		$this->{'ROOT'}->add_font($font);
	}
	return($fontkey); 
}

sub newFont {
	my ($this,$name,$file,$file2,$encoding);
	my ($fontfile,$fontfile2,$fontkey,$ttf,$font,$glyph,$fontype,$fontname,@map);

	$this=shift @_;
	$name=shift @_;
	$fontkey=genKEY($name);

	if(!$this->{'FONTS'}) {
		$this->{'FONTS'}={};
	}

	if(!$this->{'FONTS'}->{$fontkey}) {
		if(grep(/$name/,@Text::PDF::API::COREFONTS)) {
			$encoding=shift @_;
			$this->newFontCore($name,$encoding);
		} elsif($name=~/\,/) {
			$file=shift @_;
			$encoding=shift @_;
			$this->newFontTTF($name,$file,$encoding);
		} else {
			$file=shift @_;
			$file2=shift @_;
			$encoding=shift @_;
			$this->newFontPS($name,$file,$file2,$encoding);
		}
	} 

	if(!wantarray) {
		return $fontkey;
	} else {
		return ($fontkey);
	}
}

sub getFont {
	my ($this,$name)=@_;
	my $fontkey=genKEY($name);
	if($this->{'FONTS'}->{$fontkey}) {
		return $fontkey;
	} else {
		return undef;
	}
}

sub _getFontpdfname {
	my ($this,$name)=@_;
	my $fontkey=genKEY($name);
	if($this->{'FONTS'}->{$fontkey}) {
		return $this->{'FONTS'}->{$fontkey}->{'type'}.'x'.$fontkey;
	} else {
		return undef;
	}
}

sub addCoreFonts {
	my ($this,%f)=@_;
	foreach my $name (@Text::PDF::API::COREFONTS) {
		$f{$name}=$this->newFont($name);
	}
	return(%f);
}


sub initFontCurrent {
	my ($this)=@_;
	if(!defined($this->{'CURRENT'}{lc('Font')})) {
		$this->{'CURRENT'}{'font'}={
			'Matrix' => [1,0,0,1,0,0],
			'Size' => 1,
		};
	}
}

sub useFont {
	my ($this,$name,$size,$enc)=@_;
	my $fontkey=genKEY($name);
	my $cenc;
	#if() {
		if($enc) {
			$cenc=$enc;
			$cenc=~s/[^a-z0-9\-]+//cgi;
			$cenc="$fontkey-$cenc";
		} else {
			$cenc=$fontkey;
		}
	#}
	
	if(
		($fontkey NE $cenc) &&
		(($this->{'FONTS'}->{$fontkey}{'type'} EQ 'PS') || ($this->{'FONTS'}->{$fontkey}{'type'} EQ 'AC'))
	) {
		if( !$this->{'FONTS'}->{$cenc} ) {
			$this->newFontT1reencode($fontkey,$this->{'FONTS'}->{$fontkey}{'type'},$enc);
		#	$this->newFontPSreencode(
		#		$fontkey,
		#		$enc
		#	);
		}
		$fontkey=$cenc;
	}
	$this->initFontCurrent;
	$this->{'CURRENT'}{'font'}{'Name'}=$name;
	$this->{'CURRENT'}{'font'}{'Key'}=$fontkey;
	$this->{'CURRENT'}{'font'}{'PDFN'}=$this->{'FONTS'}->{$fontkey}{'PDFN'};
	$this->{'CURRENT'}{'font'}{'Size'}=$size;
	$this->{'CURRENT'}{'font'}{'Type'}=$this->{'FONTS'}->{$fontkey}{'type'};
	$this->{'CURRENT'}{'font'}{'Encoding'}=$enc || 'latin1';
}

sub setFontTranslate {
	use Text::PDF::API::Matrix;
	my ($this,$x,$y)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixTranslate'}) {
		$this->{'CURRENT'}{'font'}{'MatrixTranslate'}=Text::PDF::API::Matrix->new(
			[ 1, 0, 0],
			[ 0, 1, 0],
			[$x,$y, 1]
		);
	} else {
		$this->{'CURRENT'}{'font'}{'MatrixTranslate'}->[2][0]=$x;
		$this->{'CURRENT'}{'font'}{'MatrixTranslate'}->[2][1]=$y;
	}
}

sub setFontScale {
	use Text::PDF::API::Matrix;
	my ($this,$x,$y)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixScale'}) {
		$this->{'CURRENT'}{'font'}{'MatrixScale'}=Text::PDF::API::Matrix->new(
			[$x, 0, 0],
			[ 0,$y, 0],
			[ 0, 0, 1]
		);
	} else {
		$this->{'CURRENT'}{'font'}{'MatrixScale'}->[0][0]=$x;
		$this->{'CURRENT'}{'font'}{'MatrixScale'}->[1][1]=$y;
	}
}

sub setFontSkew {
	use Text::PDF::API::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixSkew'}) {
		$this->{'CURRENT'}{'font'}{'MatrixSkew'}=Text::PDF::API::Matrix->new(
			[                1, tan(deg2rad($a)), 0],
			[ tan(deg2rad($b)),                1, 0],
			[                0,                0, 1]
		);
	} else {
		$this->{'CURRENT'}{'font'}{'MatrixSkew'}->[0][0]=tan(deg2rad($a));
		$this->{'CURRENT'}{'font'}{'MatrixSkew'}->[1][1]=tan(deg2rad($b));
	}
}

sub setFontRotation {
	use Text::PDF::API::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initFontCurrent;
	if(!$this->{'CURRENT'}{'font'}{'MatrixRotation'}) {
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}=Text::PDF::API::Matrix->new(
			[ cos(deg2rad($a)), sin(deg2rad($a)), 0],
			[-sin(deg2rad($a)), cos(deg2rad($a)), 0],
			[                0,                0, 1]
		);
	} else {
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}->[0][0]=cos(deg2rad($a));
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}->[0][1]=-sin(deg2rad($a));
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}->[1][0]=sin(deg2rad($a));
		$this->{'CURRENT'}{'font'}{'MatrixRotation'}->[1][1]=cos(deg2rad($a));
	}
}

sub clearFontMatrix {
	my ($this)=@_;
	$this->initFontCurrent;
	foreach my $mx (qw( MatrixTranslate MatrixRotation MatrixScale MatrixSkew 
				CharSpacing WordSpacing TextLeading TextRise TextRendering )) {
		delete($this->{'CURRENT'}{'font'}{$mx});
	}
}

sub calcFontMatrix {
	use Text::PDF::API::Matrix;
	my ($this)=@_;
	my $tm=Text::PDF::API::Matrix->new([1,0,0],[0,1,0],[0,0,1]);
	$this->initFontCurrent;
	foreach my $mx (qw( MatrixSkew MatrixScale MatrixRotation MatrixTranslate )) {
		if(defined($this->{'CURRENT'}{'font'}{$mx})) {
			$tm=$tm->multiply($this->{'CURRENT'}{'font'}{$mx});
		}
	}
	$this->{'CURRENT'}{'font'}{'Matrix'}->[0]=$tm->[0][0];
	$this->{'CURRENT'}{'font'}{'Matrix'}->[1]=$tm->[0][1];
	$this->{'CURRENT'}{'font'}{'Matrix'}->[2]=$tm->[1][0];
	$this->{'CURRENT'}{'font'}{'Matrix'}->[3]=$tm->[1][1];
	$this->{'CURRENT'}{'font'}{'Matrix'}->[4]=$tm->[2][0];
	$this->{'CURRENT'}{'font'}{'Matrix'}->[5]=$tm->[2][1];
}

sub setFontMatrix {
	my ($this,$tm0,$tm1,$tm2,$tm3,$tm4,$tm5)=@_;
	$this->initFontCurrent;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[0]=$tm0;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[1]=$tm1;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[2]=$tm2;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[3]=$tm3;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[4]=$tm4;
	$this->{'CURRENT'}{'font'}{'Matrix'}->[5]=$tm5;
}

sub getFontMatrix {
	my ($this)=@_;
	$this->initFontCurrent;
	return (
		$this->{'CURRENT'}{'font'}{'Matrix'}->[0],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[1],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[2],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[3],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[4],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[5]
	);
}

sub calcTextWidth {
	my ($this,$text)=@_;

	my $k=$this->{'CURRENT'}{'font'}{'Key'};
	my $size=$this->{'CURRENT'}{'font'}{'Size'};
	my $enc=$this->{'CURRENT'}{'font'}{'Encoding'};
	my $font=$this->{'FONTS'}{$k}{'pdfobj'};
	my $type=$this->{'FONTS'}{$k}{'type'};
	my $wm=0;

	$this->calcFontMatrix;

	if($type EQ 'AC') {
		#$wm=$font->width($text)*$size;
		foreach my $c (split(//,$text)) {
			$wm+=$font->{' AFM'}{'wx'}{$font->{' AFM'}{'char'}[ord($c)]}*$size/1000;
		}
	} elsif($type EQ 'PS') {
		foreach my $c (split(//,$text)) {
			$wm+=$font->{' AFM'}{'wx'}{$font->{' AFM'}{'char'}[ord($c)]}*$size/1000;
		}
	} elsif($type EQ 'TT') {
		foreach my $c (split(//,$text)) {
			$wm+=$this->{'FONTS'}{$k}{"u2w"}{$this->lookUPc2u($enc,ord($c))}*$size;
		}
	}
	return $wm;
}
sub setCharSpacing  {
	my $this = shift @_;
	$this->{'CURRENT'}{'font'}{'CharSpacing'} = shift @_;
}
sub setWordSpacing  {
	my $this = shift @_;
	$this->{'CURRENT'}{'font'}{'WordSpacing'} = shift @_;
}
sub setTextLeading  {
	my $this = shift @_;
	$this->{'CURRENT'}{'font'}{'TextLeading'} = shift @_;
}
sub setTextRise  {
	my $this = shift @_;
	$this->{'CURRENT'}{'font'}{'TextRise'} = shift @_;
}
sub setTextRendering  {
	my $this = shift @_;
	$this->{'CURRENT'}{'font'}{'TextRendering'} = shift @_;
}

sub showText {
	my ($this,$text)=@_;
	$this->initFontCurrent;
	my $k=$this->{'CURRENT'}{'font'}{'Key'};
	my $font=$this->{'CURRENT'}{'font'}{'PDFN'};
	my $size=$this->{'CURRENT'}{'font'}{'Size'};
	my $enc=$this->{'CURRENT'}{'font'}{'Encoding'};
	my @tm=@{$this->{'CURRENT'}{'font'}{'Matrix'}};
	
	my $cs=$this->{'CURRENT'}{'font'}{'CharSpacing'} || 0;
	my $ws=$this->{'CURRENT'}{'font'}{'WordSpacing'} || 0;
	my $tl=$this->{'CURRENT'}{'font'}{'TextLeading'} || 0;
	my $ts=$this->{'CURRENT'}{'font'}{'TextRise'} || 0;
	my $tr=$this->{'CURRENT'}{'font'}{'TextRendering'} || 0;

	$this->_addtopage(sprintf("BT %.9f Tc %.9f Tw %.9f TL %.9f Ts %i Tr /$font %.9f Tf %.9f %.9f %.9f %.9f %.9f %.9f Tm <",$cs,$ws,$tl,$ts,$tr,$size,@tm));
	foreach my $c (split(//,$text)) {
		if($this->{'CURRENT'}{'font'}{'Type'} EQ 'AC') {
			$this->_addtopage(sprintf('%02x',unpack('C',$c)));
		} elsif($this->{'CURRENT'}{'font'}{'Type'} EQ 'PS') {
			$this->_addtopage(sprintf('%02x',unpack('C',$c)));
		} else {
			$this->_addtopage(sprintf('%04x',$this->{'FONTS'}{$k}{"u2g"}{$this->lookUPc2u($enc,ord($c))}));
		}
	}
	$this->_addtopage("> Tj ET\n");
}

sub showTextXY {
	my ($this,$x,$y,$text)=@_;
	my ($nx,$ny);
	$this->initFontCurrent;
	$this->calcFontMatrix;
	($nx,$ny)=(
		$this->{'CURRENT'}{'font'}{'Matrix'}->[4],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[5]
	);
	$this->setFontMatrix(
		$this->{'CURRENT'}{'font'}{'Matrix'}->[0],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[1],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[2],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[3],
		$x,$y
	);

	$this->showText($text);

	$this->setFontMatrix(
		$this->{'CURRENT'}{'font'}{'Matrix'}->[0],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[1],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[2],
		$this->{'CURRENT'}{'font'}{'Matrix'}->[3],
		$nx,$ny
	);
}

sub showTextXY_R {
	my ($this,$x,$y,$text)=@_;
	$x-=$this->calcTextWidth($text);
	$this->showTextXY($x,$y,$text);
}

sub showTextXY_C {
	my ($this,$x,$y,$text)=@_;
	$x-=($this->calcTextWidth($text)/2);
	$this->showTextXY($x,$y,$text);
}

sub printText {
	my ($this,$x,$y,$font,$size,$encoding,$text)=@_;
	$this->useFont($font,$size,$encoding);
	$this->showTextXY($x,$y,$text);
}

sub initGfxCurrent {
	my ($this)=@_;
	if(!defined($this->{'CURRENT'}{'gfx'})) {
		$this->{'CURRENT'}{'gfx'}={
			'Matrix' => [1,0,0,1,0,0],
		};
	}
}

sub setGfxTranslate {
	use Text::PDF::API::Matrix;
	my ($this,$x,$y)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixTranslate'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixTranslate'}=Text::PDF::API::Matrix->new(
			[ 1, 0, 0],
			[ 0, 1, 0],
			[$x,$y, 1]
		);
	} else {
		$this->{'CURRENT'}{'gfx'}{'MatrixTranslate'}->[2][0]=$x;
		$this->{'CURRENT'}{'gfx'}{'MatrixTranslate'}->[2][1]=$y;
	}
}

sub setGfxScale {
	use Text::PDF::API::Matrix;
	my ($this,$x,$y)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixScale'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixScale'}=Text::PDF::API::Matrix->new(
			[$x, 0, 0],
			[ 0,$y, 0],
			[ 0, 0, 1]
		);
	} else {
		$this->{'CURRENT'}{'gfx'}{'MatrixScale'}->[0][0]=$x;
		$this->{'CURRENT'}{'gfx'}{'MatrixScale'}->[1][1]=$y;
	}
}

sub setGfxSkew {
	use Text::PDF::API::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixSkew'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixSkew'}=Text::PDF::API::Matrix->new(
			[                1, tan(deg2rad($a)), 0],
			[ tan(deg2rad($b)),                1, 0],
			[                0,                0, 1]
		);
	} else {
		$this->{'CURRENT'}{'gfx'}{'MatrixSkew'}->[0][0]=tan(deg2rad($a));
		$this->{'CURRENT'}{'gfx'}{'MatrixSkew'}->[1][1]=tan(deg2rad($b));
	}
}

sub setGfxRotation {
	use Text::PDF::API::Matrix;
	use Math::Trig;
	my ($this,$a,$b)=@_;
	$this->initGfxCurrent;
	if(!$this->{'CURRENT'}{'gfx'}{'MatrixRotation'}) {
		$this->{'CURRENT'}{'gfx'}{'MatrixRotation'}=Text::PDF::API::Matrix->new(
			[ cos(deg2rad($a)), sin(deg2rad($a)), 0],
			[-sin(deg2rad($a)), cos(deg2rad($a)), 0],
			[                0,                0, 1]
		);
	} else {
		@{$this->{'CURRENT'}{'gfx'}{'MatrixRotation'}->[0]}=(cos(deg2rad($a)),-sin(deg2rad($a)),0);
		@{$this->{'CURRENT'}{'gfx'}{'MatrixRotation'}->[1]}=(sin(deg2rad($a)),cos(deg2rad($a)),0);
	}
}

sub clearGfxMatrix {
	my ($this)=@_;
	$this->initGfxCurrent;
	foreach my $mx (qw( MatrixTranslate MatrixRotation MatrixScale MatrixSkew )) {
		delete($this->{'CURRENT'}{'gfx'}{$mx});
	}
}

sub calcGfxMatrix {
	use Text::PDF::API::Matrix;
	my ($this)=@_;
	my $tm=Text::PDF::API::Matrix->new(
		[1,0,0],
		[0,1,0],
		[0,0,1]
	);
	$this->initGfxCurrent;
	foreach my $mx (qw( MatrixSkew MatrixScale MatrixRotation MatrixTranslate )) {
		if(defined($this->{'CURRENT'}{'gfx'}{$mx})) {
			$tm=$tm->multiply($this->{'CURRENT'}{'gfx'}{$mx});
		}
	}
	@{$this->{'CURRENT'}{'gfx'}{'Matrix'}}=(
		$tm->[0][0],$tm->[0][1],
		$tm->[1][0],$tm->[1][1],
		$tm->[2][0],$tm->[2][1]
	);
	return(@{$this->{'CURRENT'}{'gfx'}{'Matrix'}});
}

sub setGfxMatrix {
	my ($this,@tm)=@_;
	$this->initGfxCurrent;
	@{$this->{'CURRENT'}{'gfx'}{'Matrix'}}=@tm;
	return(@{$this->{'CURRENT'}{'gfx'}{'Matrix'}});
}

sub getGfxMatrix {
	my ($this)=@_;
	$this->initGfxCurrent;
	return(@{$this->{'CURRENT'}{'gfx'}{'Matrix'}});
}


sub useGfxState {
	my ($this)=@_;

	$this->initGfxCurrent;
	my @tm=@{$this->{'CURRENT'}{'gfx'}{'Matrix'}};

	$this->_addtopage(sprintf("%0.6f %0.6f %0.6f %0.6f %0.6f %0.6f cm\n",@tm));
}

sub savePdfState {
	my ($this)=@_;
	$this->_addtopage("q\n");
}

sub restorePdfState {
	my ($this)=@_;
	$this->_addtopage("Q\n");
}

sub saveState {
	my ($this)=@_;
	use Data::Dumper;
	push(@{$this->{'STACK'}},Dumper($this->{'CURRENT'}));
	$this->savePdfState;
}

sub restoreState {
	my ($this)=@_;
	my $cr=pop(@{$this->{'STACK'}});
	$this->{'CURRENT'}=eval($cr);
	$this->restorePdfState;
}

sub useGfxFlatness {
	my ($this,$flatness)=@_;
	$this->_addtopage("$flatness i\n");
}

sub useGfxLineCap {
	my ($this,$linecap)=@_;
	$this->_addtopage("$linecap J\n");
}

sub useGfxLineDash {
	my ($this,@a)=@_;
	$this->_addtopage("[ ".join(' ',@a)." ] 0 d\n");
}

sub useGfxLineJoin {
	my ($this,$linejoin)=@_;
	$this->_addtopage("$linejoin j\n");
}

sub useGfxLineWidth {
	my ($this,$linewidth)=@_;
	$this->_addtopage("$linewidth w\n");
}

sub useGfxMeterlimit {
	my ($this, $limit)=@_;
	$this->_addtopage("$limit M\n");
}

sub setColorFill {
	my ($this,$c,$m,$y,$k)=@_;
	if (!defined($k)) {
		if (!defined($m)) {
			$this->_addtopage("$c g\n");
		} else {
			$this->_addtopage("$c $m $y rg\n");
		}
	} else {
		$this->_addtopage("$c $m $y $k k\n");
	} 
}

sub setColorStroke {
	my ($this,$c,$m,$y,$k)=@_;
	if (!defined($k)) {
		if (!defined($m)) {
			$this->_addtopage("$c G\n");
		} else {
			$this->_addtopage("$c $m $y RG\n");
		}
	} else {
		$this->_addtopage("$c $m $y $k K\n");
	} 
}

sub moveTo {
	my ($this,$x,$y)=@_;
	$this->_addtopage(sprintf("%.9f %.9f m\n",$x,$y));
} 

sub lineTo {
	my $this=shift @_;
	my($x,$y);
	while($x=shift @_) {
		$y=shift @_;
		$this->_addtopage(sprintf("%.9f %.9f l\n",$x,$y));
	}
}

sub curveTo {
	my ($this,$x1,$y1,$x2,$y2,$x3,$y3)=@_;
	$this->_addtopage(sprintf("%.9f %.9f %.9f %.9f %.9f %.9f c\n",$x1,$y1,$x2,$y2,$x3,$y3));
}

sub rect  {
	my ($this,$x,$y,$w,$h)=@_;
	$this->_addtopage(sprintf("%.9f %.9f %.9f %.9f re\n",$x,$y,$w,$h));
}

sub closePath {
	my ($this)=@_;
	$this->_addtopage("h\n");
}

sub endPath{
	my ($this)=@_;
	$this->_addtopage("n\n");
}

sub rectXY {
	my ($this,$x,$y,$x2,$y2)=@_;
	$this->rect($x,$y,($x2-$x),($y2-$y));
}

sub lineXY {
	my ($this,$x1,$y1,$x2,$y2)=@_;
	$this->moveTo($x1,$y1);
	$this->lineTo($x2,$y2);
}

sub ellipsisXYAB {
	my ($this,$x,$y,$a,$b)=@_;
	$this->moveTo($x-$a,$y);
	$this->curveTo($x-$a,$y+($b*4/3),$x+$a,$y+($b*4/3),$x+$a,$y);
	$this->curveTo($x+$a,$y-($b*4/3),$x-$a,$y-($b*4/3),$x-$a,$y);
	$this->closePath;
}

sub circleXYR {
	my ($this,$x,$y,$r)=@_;
	$this->ellipsisXYAB($x,$y,$r,$r);
}

sub stroke {
	my ($this)=@_;
	$this->_addtopage("S\n");
}
sub closestroke {
	my ($this)=@_;
	$this->_addtopage("h S\n");
}
sub fill {
	my ($this)=@_;
	$this->_addtopage("f\n");
}
sub closefill {
	my ($this)=@_;
	$this->_addtopage("h f\n");
}
sub fillNZ {
	my ($this)=@_;
	$this->_addtopage("f*\n");
}
sub fillstroke {
	my ($this)=@_;
	$this->_addtopage("B\n");
}
sub closefillstroke {
	my ($this)=@_;
	$this->_addtopage("b\n");
}
sub fillstrokeNZ {
	my ($this)=@_;
	$this->_addtopage("B*\n");
}
sub closefillstrokeNZ {
	my ($this)=@_;
	$this->_addtopage("b*\n");
}

sub newImage {
	my ($this,$file)=@_;
	my $xo;
	my $key='IMGx'.genKEY($file);

	use Text::PDF::API::Image;
	my ($w,$h,$bpc,$cs,$img)=Text::PDF::API::Image::parseImage($file);

	if(!defined($this->{'IMAGES'}{$key})) {
		$xo=PDFDict();
		$this->{'PDF'}->new_obj($xo);
		$xo->{'Type'}=PDFName('XObject');
		$xo->{'Subtype'}=PDFName('Image');
		$xo->{'Name'}=PDFName($key);
		$xo->{'Width'}=PDFNum($w);
		$xo->{'Height'}=PDFNum($h);
		$xo->{'Filter'}=PDFArray(PDFName('FlateDecode'));
		$xo->{'BitsPerComponent'}=PDFNum($bpc);
		$xo->{'ColorSpace'}=PDFName($cs);
		$xo->{' stream'}=$img;
		$this->{'IMAGES'}{$key}=$xo;
		if(!defined($this->{'ROOT'}->{'Resources'}->{'XObject'})) {
			$this->{'ROOT'}->{'Resources'}->{'XObject'}=PDFDict();
		}
		$this->{'ROOT'}->{'Resources'}->{'XObject'}->{$key}=$xo;
	}
	return ($key,$w,$h);
}

sub rawImage {
	my($this, $name, $w, $h, $type, @imagearray)=@_;
	
	my ($xo,$img,$bpc,$cs);
	my $key='IMGxRAW'.genKEY(sprintf('%s%s-%d-%d',$name,$type,$w,$h));

	if(!defined($this->{'IMAGES'}{$key})) {
		if($type EQ '-rgb'){
			$img=join('',
				map {
					pack('C',$_);
				} @imagearray;
			);
			$cs='DeviceRGB';
			$bpc=8;
		} elsif($type EQ '-RGB') {
			$img=join('',
				map {
					pack('H*',$_);
				} @imagearray;
			);
			$cs='DeviceRGB';
			$bpc=8;
		}
		$xo=PDFDict();
		$this->{'PDF'}->new_obj($xo);
		$xo->{'Type'}=PDFName('XObject');
		$xo->{'Subtype'}=PDFName('Image');
		$xo->{'Name'}=PDFName($key);
		$xo->{'Width'}=PDFNum($w);
		$xo->{'Height'}=PDFNum($h);
		$xo->{'Filter'}=PDFArray(PDFName('FlateDecode'));
		$xo->{'BitsPerComponent'}=PDFNum($bpc);
		$xo->{'ColorSpace'}=PDFName($cs);
		$xo->{' stream'}=$img;
		$this->{'IMAGES'}{$key}=$xo;
		if(!defined($this->{'ROOT'}->{'Resources'}->{'XObject'})) {
			$this->{'ROOT'}->{'Resources'}->{'XObject'}=PDFDict();
		}
		$this->{'ROOT'}->{'Resources'}->{'XObject'}->{$key}=$xo;
	}
	return ($key,$w,$h);
}

sub placeImage {
	my ($this,$key,$x,$y,$sx,$sy)=@_;
	$this->saveState;
	$this->setGfxMatrix($sx,0,0,$sy,$x,$y);
	$this->useGfxState;
	$this->_addtopage("/$key Do\n");
	$this->restoreState;
}

1;

__END__


=pod

=head1 NAME

Text::PDF::API - a wrapper api for the Text::PDF::* modules of Martin Hosken.

=head1 SYNOPSIS

	use Text::PDF::API;

	$pdf = Text::PDF::API->new( %defaults );

	$pdf->end;

=head1 DESCRIPTION

=head2 Base Methods

=over 4

=item $pdf = Text::PDF::API->new [%defaults]

This creates a new pdf-object initializes it with the given defaults and returns it.
See the functions B<getDefault> and B<setDefault> for a list of supported parameters.

=item $pdf->saveas $file 

This saves the pdf-object to a file indicated by B<$file>.

=item $pdf->end

This destroys the pdf-object and frees its memory.

=item $pdf->getDefault $parameter 

This returns the pdf-object default indicated by B<$parameter>.

The current supported defaults are: 

PageSize, valid values:

	'a0'		=>	[ 2380	, 3368	]
	'a1'		=>	[ 1684	, 2380	]
	'a2'		=>	[ 1190	, 1684	]
	'a3'		=>	[ 842	, 1190	]
	'a4'		=>	[ 595	, 842	]
	'a5'		=>	[ 421	, 595	]
	'a6'		=>	[ 297	, 421	]
	'letter'	=>	[ 612	, 792	]
	'broadsheet'	=>	[ 1296	, 1584	]
	'ledger'	=>	[ 1224	, 792	]
	'tabloid'	=>	[ 792	, 1224	]
	'legal'		=>	[ 612	, 1008	]
	'executive'	=>	[ 522	, 756	]
	'36x36'		=>	[ 2592	, 2592	]

PageWidth, valid values:

	0 .. 32535 points (remember default = 72dpi)
	
PageHeight, valid values:

	0 .. 32535 points (remember default = 72dpi)

PageOrientation, valid values:
	
	Landscape, Portrait

Compression

	0, 1 (= off, on)

PDFVersion

	0 .. 3 (corresponding to the adobe acrobat versions up to 4.0)

=item $pdf->setDefault $parameter , $value

This sets the pdf-object defaults (see $pdf->getDefault for details).

=item $pdf->newpage [ $width, $height ] 

=item $pdf->newpage [ $pagesize ] 

This creates a new page in the pdf-object and assigns it to the default page context.
If $width and $height are not given the funtion falls back to any given defaults
(PageSize then PageWidth+PageHeight) and as a last resort to 'A4'.
You can use also specify oonly the Pagesize as given under the defaults.

=item $pdf->endpage

This closes the current page.

=back

=head2 Generic Methods

=over 4

=item $pdf->savePdfState

=item $pdf->restorePdfState

Saves and restores the state of the pdf-document
BUT NOT of the pdf-object.

B<BEWARE:> Don't cross page boundaries with save/restore,
if you really don't know the pdf-specification well enough.

=item $pdf->saveState {currently broken}

=item $pdf->restoreState {currently broken}

Saves and restores the state of the pdf-object
and the underlying document.

B<NOTE:> All states are automagically restored if
you issue a $pdf->endpage.

=back

=head2 Font State Methods

=over 4

=item $pdf->setFontDir $directory

Sets the default font search directory.

=item $directory = $pdf->getFontDir 

Gets the default font search directory.

=item $pdf->addFontPath $directory

Adds a directory to the font search path.

=item $pdf->newFont $fontname, $ttfile

=item $pdf->newFont $fontname, $psffile, $afmfile

=item $pdf->newFont $fontname 

Adds a new font to the pdf-object. Based on the fonts name
either a core, truetype or postscript font is assumed:
TrueType have a ',' between the family and style names whereas
the postscript and core fonts use a '-'.

B<BEWARE:> Postscript fonts other than the core fonts are supported,
BUT the implementation is still somewhere in alpha/beta stage and
may not result in valid pdf-files under certain conditions. 

B<NOTE:> this function is for BACKWARD COMPATIBLITY ONLY (as of version 0.5)
and will be removed sometime before version 1.0.

B<RECOMMENDATION:> Start using the following three functions below.

=item $pdf->newFontCore $fontname [, $encoding [, @glyphs ]]

=item $pdf->newFontTTF $fontname, $ttffile [, $encoding ]

=item $pdf->newFontPS $fontname, $psffile, $afmfile [, $encoding [, @glyphs ]]

Although you can add a font thru the $pdf->newFont function, these three new 
functions are much more stable (newFontPS is alpha-quality) and reliable.

The $encoding is the name of one of the encoding schemes supported by Unicode::Map8, 
'asis' or 'custom'. If you use 'custom' as encoding, you have to supply the @glyphs 
array which should specify 256 glyph-names as defined by the 
"PostScript(R) Language Reference 3rd. Ed. -- Appendix E"

If you do not give $encoding or 'asis', than the afms internal encoding is used.

If you give an unknown $encoding, the encoding defaults to WinAnsiEncoding.

=item $pdf->addCoreFonts 

This is a shortcut to add all pdf-core-fonts to the pdf-object.

=item $pdf->useFont $name, $size [, $encoding ]

This selects the font at the specified size and encoding.
The font must have been loaded with the same $name 
parameter with $pdf->newFont

If you do not give $encoding, than the encoding from $pdf->newFont??? is used.

B<NOTE:> As of version API 0.5 you can specify any encoding supported by Unicode::Map8,
since the fonts are automagically reencoded to use the new encoding if it differs
from that encoding specified at $pdf->newFont???.

=item $pdf->setFontTranslate $tx, $ty

Sets the translation (aka. x,y-offset) in the Font-Transformation-Matrices.

=item $pdf->setFontScale $scalex, $scaley

Sets the scale in the Font-Transformation-Matrices.

=item $pdf->setFontSkew $alfa, $beta

Sets the skew in the Font-Transformation-Matrices specified
in degrees (0..360).

=item $pdf->setFontRotation $alfa

Sets the rotation in the Font-Transformation-Matrices specified
in degrees (0..360) counter-clock-wise from the right horizontal.

=item $pdf->clearFontMatrix

Resets all Font-Transformation-Matrices.

=item $pdf->calcFontMatrix

Calculates the final Transformation-Matrix for use with the *Text* functions.

=item $pdf->setFontMatrix $a, $b, $c, $d, $e, $f

Sets the final Transformation-Matrix directly.

=item ($a, $b, $c, $d, $e, $f)=$pdf->getFontMatrix

Returns the final Transformation-Matrix. Use $pdf->calcFontMatrix 
and then $pdf->getFontMatrix to retrive the combined effects
of Translate, Skew, Scale & Rotate.

=item $pdf->setCharSpacing $spacing

=item $pdf->setWordSpacing $spacing

=item $pdf->setTextLeading $leading

=item $pdf->setTextRise $rise

=item $pdf->setTextRendering $rendering

=back

=head2 Text Methods

=over 4

=item $pdf->showText $text

Displays the $text based on the parameters given by the *Font* functions.

=item $pdf->showTextXY $x, $y, $text

=item $pdf->showTextXY_R $x, $y, $text

=item $pdf->showTextXY_C $x, $y, $text

Like $pdf->showText but overrides the x,y-offsets of the Matrices.
The *_R and *_C variants perform right and center alignment !

=item $pdf->printText $x, $y, $font, $size, $encoding, $text

Like a $pdf->useFont followed by a $pdf->showTextXY.

=item $pdf->calcTextWidth $text

Calculates the width of the text based on the parameters set by useFont.

B<BEWARE:> Does not consider parameters specified by setFont* and *Matrix functions.

=back

=head2 Graphic State Methods

=over 4

=item $pdf->setGfxTranslate $tx, $ty

=item $pdf->setGfxScale $scalex, $scaley

=item $pdf->setGfxSkew $alfa, $beta

=item $pdf->setGfxRotation $alfa

=item $pdf->clearGfxMatrix

=item $pdf->calcGfxMatrix

=item $pdf->setGfxMatrix $a, $b, $c, $d, $e, $f

=item ($a, $b, $c, $d, $e, $f)=$pdf->getGfxMatrix

These functions behave like the the font functions BUT affect
the whole global graphics state.

B<BEWARE:> If you use both the Gfx and Font versions of these functions
the final result for Text would be the combined effects
of both the Gfx and Font parameters.

=item $pdf->useGfxState

Adds the parameters of the functions above to the current graphics state.
To revert to the former parameters use $pdf->savePdfState and $pdf->restorePdfState.

=item $pdf->useGfxFlatness $flatness

=item $pdf->useGfxLineCap $linecap

=item $pdf->useGfxLineDash @dasharray

=item $pdf->useGfxLineJoin $linejoin

=item $pdf->useGfxLineWidth $linewidth

=item $pdf->useGfxMeterlimit $limit

=back

=head2 Color Methods

=over 4

=item $pdf->setColorFill $red, $green, $blue

=item $pdf->setColorFill $cyan, $magenta, $yellow, $black

=item $pdf->setColorFill $gray

=item $pdf->setColorStroke $red, $green, $blue

=item $pdf->setColorStroke $cyan, $magenta, $yellow, $black

=item $pdf->setColorStroke $gray

=back

=head2 Drawing Methods

=over 4

=item $pdf->moveTo $x, $y

=item $pdf->lineTo $x, $y

=item $pdf->curveTo $x1, $y1, $x2, $y2, $x3, $y3

=item $pdf->rect $x, $y, $w, $h

=item $pdf->closePath

=item $pdf->endPath

=item $pdf->rectXY $x1, $y1, $x2, $y2

=item $pdf->lineXY $x1, $y1, $x2, $y2

=item $pdf->ellipsisXYAB $x, $y, $a, $b

=item $pdf->circleXYR $x, $y, $r

=item $pdf->stroke

=item $pdf->closestroke

=item $pdf->fill

=item $pdf->closefill

=item $pdf->fillNZ

=item $pdf->fillstroke

=item $pdf->closefillstroke

=item $pdf->fillstrokeNZ

=item $pdf->closefillstrokeNZ

quot errat demonstrandum

=back

=head2 Bitmap Methods

=over 4

=item ( $key , $width , $height ) = $pdf->newImage $file

Current loading support includes NetPBM images of the
RAW_BITS variation and non-interlaced/non-filtered PNG.
Transperancy/Opacity information is currently ignored
as well as Alpha-Channel information.

=item ( $key , $width , $height ) = $pdf->rawImage $name, $width $height $type @imagearray

This function supports loading of point-arrays for embedding
image information into the pdf. $type must be one of the following:

	'-rgb' ... each element of the array is a color component
			in the range of 0..255
	'-RGB' ... each element of the array is a hex-encoded color pixel
			with two hex-digits per color component  

$name must be a unique name for this image (at least 8 characters long).

=item $pdf->placeImage $key, $x, $y, $scalex, $scaley

=back

=head1 HISTORY

=over 4

=item Version 0.00

GENESIS

=item Version 0.01

inital implementation without documentation

=item Version 0.01_01

you can create pages, still no docs

=item Version 0.01_02 - 0.01_11

various conceptual design stages

=item Version 0.01_12

first public snapshot with some docs
and first implementation of font caching
(released as 0.01_12_snapshot)

=item Version 0.01_14

reimplementaion of font-handling with
unification of core and truetype fonts
under the function "newFont"

=item Version 0.01_15

implementaion of font-encoding for truetypes

=item Version 0.01_16

reimplementaion of font-encoding thru CID
because Acrobat seems to ignore encoding tables 
for TTs when using normal embedding

=item Version 0.01_17

implementaion of printText, useFont, showText & showTextXY

=item Version 0.01_18

implementaion of *FontMatrix functions, 
changes in showText & showTextXY

=item Version 0.01_19

addition of setFontTranslate, Skew, Rotate & Scale
with cleanup in *FontMatrix

=item Version 0.01_20

end of text/font implementation, let it stabilize :)

=item Version 0.02

genesis of the graphical interface
(CTM handling copied from fonts)

=item Version 0.02_01

added text and graphic state functions

=item Version 0.02_02

cleanup/extension of dokumentation, but still not finished

=item Version 0.02_03

proposed implementation of drawing functions (NOT FINISHED)

=item Version 0.02_04

finished implemetation of needed drawing functions

=item Version 0.03

bugfixes in drawing and font functions
first implementation of state functions

=item Version 0.03_01

first implementation of bitmap functions

=item Version 0.03_02

bugfixes in text/font functions

=item Version 0.03_03

added support for loading of PNM(netpbm) and PNG bitmaps

=item Version 0.03_04

added circle and ellipsis drawing functions

=item Version 0.03_05

fixed calcTextWidth to allow the type1 core fonts to be measured too.
added showTextXY_R and _C functions for alignment procedures :)

=item Version 0.04-0.43

rewrite of type1 core-font handling to ease development support for 
other type1 fonts in future releases of Text::PDF and Text::PDF::API.

small bugfixes in calcTextWidth and showTextXY_[RC].

small documentation update

=item Version 0.05 (Oct. 2000)

major rewrite to use Unicode::Map8 instead of the homegrown functions :)
, add another dependency but at least a fast one

=item Versions 0.5_pre??? (Dec. 2000)

major rewrite of font-handling routines stalls the tutorial/exaples collection.
now adobe-type1 fonts (pfb/pfa + afm) and the core-fonts can be used the same way
as truetype with the Unicode::Map8 encodings.

=item Version 0.5 (07-01-2001)

documetaion update and release of the much hacked 0.5_pre??? code :)

=back

=head1 BUGS

MANY! If you find some report them to perl-text-pdf-modules@egroups.com.

=head1 TODO ( in no particular order )

documentation ?

drawing functions ?

more encodings ?

fix encoding for core fonts ?

bitmap import functions (jpeg,xbm,xpm, ...?)

=cut
