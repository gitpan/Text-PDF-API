package Text::PDF::API::Encoding::AdobeSymbol;

sub new {
	my $class=shift(@_);
	my %defaults=@_;
	my $this={};
	bless($this);
	my ($line,@vals,$data);
	$this->{'e2u'}=();
	$this->{'u2e'}=();
	seek(DATA,0,0);
	while($line=<DATA>) {
		($data)=split(/\#+/,$line);
		if(!$data){next;}
		@vals=split(/\s+/,$data);
		$this->{'e2u'}{hex($vals[1])}=hex($vals[0]);
		$this->{'u2e'}{hex($vals[0])}=hex($vals[1]);
	}
	return $this;
}

1;

__DATA__
#
#  Name:             Adobe Symbol Encoding to Unicode
#  Unicode version:  2.0
#  Table version:    0.2
#  Date:             30 March 1999
#  
#  Copyright (c) 1991-1999 Unicode, Inc. All Rights reserved.
#  
#  This file is provided as-is by Unicode, Inc. (The Unicode Consortium). No
#  claims are made as to fitness for any particular purpose. No warranties of
#  any kind are expressed or implied. The recipient agrees to determine
#  applicability of information provided. If this file has been provided on
#  magnetic media by Unicode, Inc., the sole remedy for any claim will be
#  exchange of defective media within 90 days of receipt.
#  
#  Format: 4 tab-delimited fields:
#
#    (1) The Unicode value (in hexadecimal)
#    (2) The Symbol Encoding code point (in hexadecimal)
#    (3) # Unicode name
#    (4) # PostScript character name
#  
#  Contact <unicode-inc@unicode.org> with any questions or comments.
#
0020	20	# SPACE	# space
0021	21	# EXCLAMATION MARK	# exclam
2200	22	# FOR ALL	# universal
0023	23	# NUMBER SIGN	# numbersign
2203	24	# THERE EXISTS	# existential
0025	25	# PERCENT SIGN	# percent
0026	26	# AMPERSAND	# ampersand
220B	27	# CONTAINS AS MEMBER	# suchthat
0028	28	# LEFT PARENTHESIS	# parenleft
0029	29	# RIGHT PARENTHESIS	# parenright
2217	2A	# ASTERISK OPERATOR	# asteriskmath
002B	2B	# PLUS SIGN	# plus
002C	2C	# COMMA	# comma
2212	2D	# MINUS SIGN	# minus
002E	2E	# FULL STOP	# period
002F	2F	# SOLIDUS	# slash
0030	30	# DIGIT ZERO	# zero
0031	31	# DIGIT ONE	# one
0032	32	# DIGIT TWO	# two
0033	33	# DIGIT THREE	# three
0034	34	# DIGIT FOUR	# four
0035	35	# DIGIT FIVE	# five
0036	36	# DIGIT SIX	# six
0037	37	# DIGIT SEVEN	# seven
0038	38	# DIGIT EIGHT	# eight
0039	39	# DIGIT NINE	# nine
003A	3A	# COLON	# colon
003B	3B	# SEMICOLON	# semicolon
003C	3C	# LESS-THAN SIGN	# less
003D	3D	# EQUALS SIGN	# equal
003E	3E	# GREATER-THAN SIGN	# greater
003F	3F	# QUESTION MARK	# question
2245	40	# APPROXIMATELY EQUAL TO	# congruent
0391	41	# GREEK CAPITAL LETTER ALPHA	# Alpha
0392	42	# GREEK CAPITAL LETTER BETA	# Beta
03A7	43	# GREEK CAPITAL LETTER CHI	# Chi
0394	44	# GREEK CAPITAL LETTER DELTA	# Delta
0395	45	# GREEK CAPITAL LETTER EPSILON	# Epsilon
03A6	46	# GREEK CAPITAL LETTER PHI	# Phi
0393	47	# GREEK CAPITAL LETTER GAMMA	# Gamma
0397	48	# GREEK CAPITAL LETTER ETA	# Eta
0399	49	# GREEK CAPITAL LETTER IOTA	# Iota
03D1	4A	# GREEK THETA SYMBOL	# theta1
039A	4B	# GREEK CAPITAL LETTER KAPPA	# Kappa
039B	4C	# GREEK CAPITAL LETTER LAMDA	# Lambda
039C	4D	# GREEK CAPITAL LETTER MU	# Mu
039D	4E	# GREEK CAPITAL LETTER NU	# Nu
039F	4F	# GREEK CAPITAL LETTER OMICRON	# Omicron
03A0	50	# GREEK CAPITAL LETTER PI	# Pi
0398	51	# GREEK CAPITAL LETTER THETA	# Theta
03A1	52	# GREEK CAPITAL LETTER RHO	# Rho
03A3	53	# GREEK CAPITAL LETTER SIGMA	# Sigma
03A4	54	# GREEK CAPITAL LETTER TAU	# Tau
03A5	55	# GREEK CAPITAL LETTER UPSILON	# Upsilon
03C2	56	# GREEK SMALL LETTER FINAL SIGMA	# sigma1
03A9	57	# GREEK CAPITAL LETTER OMEGA	# Omega
2126	57	# OHM SIGN	# Omega
039E	58	# GREEK CAPITAL LETTER XI	# Xi
03A8	59	# GREEK CAPITAL LETTER PSI	# Psi
0396	5A	# GREEK CAPITAL LETTER ZETA	# Zeta
005B	5B	# LEFT SQUARE BRACKET	# bracketleft
2234	5C	# THEREFORE	# therefore
005D	5D	# RIGHT SQUARE BRACKET	# bracketright
22A5	5E	# UP TACK	# perpendicular
005F	5F	# LOW LINE	# underscore
F8E5	60	# RADICAL EXTENDER	# radicalex (CUS)
03B1	61	# GREEK SMALL LETTER ALPHA	# alpha
03B2	62	# GREEK SMALL LETTER BETA	# beta
03C7	63	# GREEK SMALL LETTER CHI	# chi
03B4	64	# GREEK SMALL LETTER DELTA	# delta
03B5	65	# GREEK SMALL LETTER EPSILON	# epsilon
03C6	66	# GREEK SMALL LETTER PHI	# phi
03B3	67	# GREEK SMALL LETTER GAMMA	# gamma
03B7	68	# GREEK SMALL LETTER ETA	# eta
03B9	69	# GREEK SMALL LETTER IOTA	# iota
03D5	6A	# GREEK PHI SYMBOL	# phi1
03BA	6B	# GREEK SMALL LETTER KAPPA	# kappa
03BB	6C	# GREEK SMALL LETTER LAMDA	# lambda
03BC	6D	# GREEK SMALL LETTER MU	# mu
03BD	6E	# GREEK SMALL LETTER NU	# nu
03BF	6F	# GREEK SMALL LETTER OMICRON	# omicron
03C0	70	# GREEK SMALL LETTER PI	# pi
03B8	71	# GREEK SMALL LETTER THETA	# theta
03C1	72	# GREEK SMALL LETTER RHO	# rho
03C3	73	# GREEK SMALL LETTER SIGMA	# sigma
03C4	74	# GREEK SMALL LETTER TAU	# tau
03C5	75	# GREEK SMALL LETTER UPSILON	# upsilon
03D6	76	# GREEK PI SYMBOL	# omega1
03C9	77	# GREEK SMALL LETTER OMEGA	# omega
03BE	78	# GREEK SMALL LETTER XI	# xi
03C8	79	# GREEK SMALL LETTER PSI	# psi
03B6	7A	# GREEK SMALL LETTER ZETA	# zeta
007B	7B	# LEFT CURLY BRACKET	# braceleft
007C	7C	# VERTICAL LINE	# bar
007D	7D	# RIGHT CURLY BRACKET	# braceright
223C	7E	# TILDE OPERATOR	# similar
20AC	A0	# EURO SIGN	# Euro
03D2	A1	# GREEK UPSILON WITH HOOK SYMBOL	# Upsilon1
2032	A2	# PRIME	# minute
2264	A3	# LESS-THAN OR EQUAL TO	# lessequal
2044	A4	# FRACTION SLASH	# fraction
221E	A5	# INFINITY	# infinity
0192	A6	# LATIN SMALL LETTER F WITH HOOK	# florin
2663	A7	# BLACK CLUB SUIT	# club
2666	A8	# BLACK DIAMOND SUIT	# diamond
2665	A9	# BLACK HEART SUIT	# heart
2660	AA	# BLACK SPADE SUIT	# spade
2194	AB	# LEFT RIGHT ARROW	# arrowboth
2190	AC	# LEFTWARDS ARROW	# arrowleft
2191	AD	# UPWARDS ARROW	# arrowup
2192	AE	# RIGHTWARDS ARROW	# arrowright
2193	AF	# DOWNWARDS ARROW	# arrowdown
00B0	B0	# DEGREE SIGN	# degree
00B1	B1	# PLUS-MINUS SIGN	# plusminus
2033	B2	# DOUBLE PRIME	# second
2265	B3	# GREATER-THAN OR EQUAL TO	# greaterequal
00D7	B4	# MULTIPLICATION SIGN	# multiply
221D	B5	# PROPORTIONAL TO	# proportional
2202	B6	# PARTIAL DIFFERENTIAL	# partialdiff
2022	B7	# BULLET	# bullet
00F7	B8	# DIVISION SIGN	# divide
2260	B9	# NOT EQUAL TO	# notequal
2261	BA	# IDENTICAL TO	# equivalence
2248	BB	# ALMOST EQUAL TO	# approxequal
2026	BC	# HORIZONTAL ELLIPSIS	# ellipsis
F8E6	BD	# VERTICAL ARROW EXTENDER	# arrowvertex (CUS)
F8E7	BE	# HORIZONTAL ARROW EXTENDER	# arrowhorizex (CUS)
21B5	BF	# DOWNWARDS ARROW WITH CORNER LEFTWARDS	# carriagereturn
2135	C0	# ALEF SYMBOL	# aleph
2111	C1	# BLACK-LETTER CAPITAL I	# Ifraktur
211C	C2	# BLACK-LETTER CAPITAL R	# Rfraktur
2118	C3	# SCRIPT CAPITAL P	# weierstrass
2297	C4	# CIRCLED TIMES	# circlemultiply
2295	C5	# CIRCLED PLUS	# circleplus
2205	C6	# EMPTY SET	# emptyset
2229	C7	# INTERSECTION	# intersection
222A	C8	# UNION	# union
2283	C9	# SUPERSET OF	# propersuperset
2287	CA	# SUPERSET OF OR EQUAL TO	# reflexsuperset
2284	CB	# NOT A SUBSET OF	# notsubset
2282	CC	# SUBSET OF	# propersubset
2286	CD	# SUBSET OF OR EQUAL TO	# reflexsubset
2208	CE	# ELEMENT OF	# element
2209	CF	# NOT AN ELEMENT OF	# notelement
2220	D0	# ANGLE	# angle
2207	D1	# NABLA	# gradient
F6DA	D2	# REGISTERED SIGN SERIF	# registerserif (CUS)
F6D9	D3	# COPYRIGHT SIGN SERIF	# copyrightserif (CUS)
F6DB	D4	# TRADE MARK SIGN SERIF	# trademarkserif (CUS)
220F	D5	# N-ARY PRODUCT	# product
221A	D6	# SQUARE ROOT	# radical
22C5	D7	# DOT OPERATOR	# dotmath
00AC	D8	# NOT SIGN	# logicalnot
2227	D9	# LOGICAL AND	# logicaland
2228	DA	# LOGICAL OR	# logicalor
21D4	DB	# LEFT RIGHT DOUBLE ARROW	# arrowdblboth
21D0	DC	# LEFTWARDS DOUBLE ARROW	# arrowdblleft
21D1	DD	# UPWARDS DOUBLE ARROW	# arrowdblup
21D2	DE	# RIGHTWARDS DOUBLE ARROW	# arrowdblright
21D3	DF	# DOWNWARDS DOUBLE ARROW	# arrowdbldown
25CA	E0	# LOZENGE	# lozenge
2329	E1	# LEFT-POINTING ANGLE BRACKET	# angleleft
F8E8	E2	# REGISTERED SIGN SANS SERIF	# registersans (CUS)
F8E9	E3	# COPYRIGHT SIGN SANS SERIF	# copyrightsans (CUS)
F8EA	E4	# TRADE MARK SIGN SANS SERIF	# trademarksans (CUS)
2211	E5	# N-ARY SUMMATION	# summation
F8EB	E6	# LEFT PAREN TOP	# parenlefttp (CUS)
F8EC	E7	# LEFT PAREN EXTENDER	# parenleftex (CUS)
F8ED	E8	# LEFT PAREN BOTTOM	# parenleftbt (CUS)
F8EE	E9	# LEFT SQUARE BRACKET TOP	# bracketlefttp (CUS)
F8EF	EA	# LEFT SQUARE BRACKET EXTENDER	# bracketleftex (CUS)
F8F0	EB	# LEFT SQUARE BRACKET BOTTOM	# bracketleftbt (CUS)
F8F1	EC	# LEFT CURLY BRACKET TOP	# bracelefttp (CUS)
F8F2	ED	# LEFT CURLY BRACKET MID	# braceleftmid (CUS)
F8F3	EE	# LEFT CURLY BRACKET BOTTOM	# braceleftbt (CUS)
F8F4	EF	# CURLY BRACKET EXTENDER	# braceex (CUS)
232A	F1	# RIGHT-POINTING ANGLE BRACKET	# angleright
222B	F2	# INTEGRAL	# integral
2320	F3	# TOP HALF INTEGRAL	# integraltp
F8F5	F4	# INTEGRAL EXTENDER	# integralex (CUS)
2321	F5	# BOTTOM HALF INTEGRAL	# integralbt
F8F6	F6	# RIGHT PAREN TOP	# parenrighttp (CUS)
F8F7	F7	# RIGHT PAREN EXTENDER	# parenrightex (CUS)
F8F8	F8	# RIGHT PAREN BOTTOM	# parenrightbt (CUS)
F8F9	F9	# RIGHT SQUARE BRACKET TOP	# bracketrighttp (CUS)
F8FA	FA	# RIGHT SQUARE BRACKET EXTENDER	# bracketrightex (CUS)
F8FB	FB	# RIGHT SQUARE BRACKET BOTTOM	# bracketrightbt (CUS)
F8FC	FC	# RIGHT CURLY BRACKET TOP	# bracerighttp (CUS)
F8FD	FD	# RIGHT CURLY BRACKET MID	# bracerightmid (CUS)
F8FE	FE	# RIGHT CURLY BRACKET BOTTOM	# bracerightbt (CUS)