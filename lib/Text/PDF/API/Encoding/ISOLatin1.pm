package Text::PDF::API::Encoding::ISOLatin1;

sub new {
	my $class=shift(@_);
	my %defaults=@_;
	my $this={};
	bless($this);
	my ($line,@vals,$data);
	seek(DATA,0,0);
	$this->{'e2u'}=();
	$this->{'e2n'}=();
	$this->{'u2e'}=();
	$this->{'u2n'}=();
	$this->{'n2e'}=();
	$this->{'n2u'}=();
	while($data=<DATA>){
		@vals=split(/\s+/,$data);
		$this->{'e2u'}{hex($vals[1])}=hex($vals[0]);
		$this->{'u2e'}{hex($vals[0])}=hex($vals[1]);
		if($vals[2]) {
			$this->{'u2n'}{hex($vals[0])}=$vals[2];
			$this->{'e2n'}{hex($vals[1])}=$vals[2];
			$this->{'n2u'}{$vals[2]}=hex($vals[0]);
			$this->{'n2e'}{$vals[2]}=hex($vals[1]);
		}
	}
	return $this;
}

1;

__DATA__
0020	20	space
0021	21	exclam
0022	22	quotedbl
0023	23	numbersign
0024	24	dollar
0025	25	percent
0026	26	ampersand
0027	27	quotesingle
0028	28	parenleft
0029	29	parenright
002a	2a	asterisk
002b	2b	plus
002c	2c	comma
002d	2d	hyphen
002e	2e	period
002f	2f	slash
0030	30	zero
0031	31	one
0032	32	two
0033	33	three
0034	34	four
0035	35	five
0036	36	six
0037	37	seven
0038	38	eight
0039	39	nine
003a	3a	colon
003b	3b	semicolon
003c	3c	less
003d	3d	equal
003e	3e	greater
003f	3f	question
0040	40	at
0041	41	A
0042	42	B
0043	43	C
0044	44	D
0045	45	E
0046	46	F
0047	47	G
0048	48	H
0049	49	I
004a	4a	J
004b	4b	K
004c	4c	L
004d	4d	M
004e	4e	N
004f	4f	O
0050	50	P
0051	51	Q
0052	52	R
0053	53	S
0054	54	T
0055	55	U
0056	56	V
0057	57	W
0058	58	X
0059	59	Y
005a	5a	Z
005b	5b	bracketleft
005c	5c	backslash
005d	5d	bracketright
005e	5e	asciicircum
005f	5f	underscore
0060	60	grave
0061	61	a
0062	62	b
0063	63	c
0064	64	d
0065	65	e
0066	66	f
0067	67	g
0068	68	h
0069	69	i
006a	6a	j
006b	6b	k
006c	6c	l
006d	6d	m
006e	6e	n
006f	6f	o
0070	70	p
0071	71	q
0072	72	r
0073	73	s
0074	74	t
0075	75	u
0076	76	v
0077	77	w
0078	78	x
0079	79	y
007a	7a	z
007b	7b	braceleft
007c	7c	bar
007d	7d	braceright
007e	7e	asciitilde
007f	7f
0080	80
0081	81
0082	82
0083	83
0084	84
0085	85
0086	86
0087	87
0088	88
0089	89
008a	8a
008b	8b
008c	8c
008d	8d
008e	8e
008f	8f
0090	90	dotlessi
0091	91	grave
0092	92	acute 
0093	93	circumflex 
0094	94	tilde 
0095	95	macron 
0096	96	breve 
0097	97	dotaccent 
0098	98	dieresis
0099	99
009a	9a	ring
009b	9b	cedilla
009c	9c
009d	9d	hungarumlaut 
009e	9e	ogonek 
009f	9f	caron
00a0	a0	space
00a1	a1	exclamdown
00a2	a2	cent
00a3	a3	sterling
00a4	a4	currency
00a5	a5	yen
00a6	a6	brokenbar
00a7	a7	section
00a8	a8	dieresis
00a9	a9	copyright
00aa	aa	ordfeminine
00ab	ab	guillemotleft
00ac	ac	logicalnot
00ad	ad	hyphen
00ae	ae	registered
00af	af	macron
00b0	b0	degree
00b1	b1	plusminus
00b2	b2	twosuperior
00b3	b3	threesuperior
00b4	b4	acute
00b5	b5	mu
00b6	b6	paragraph
00b7	b7	periodcentered
00b8	b8	cedilla
00b9	b9	onesuperior
00ba	ba	ordmasculine
00bb	bb	guillemotright
00bc	bc	onequarter
00bd	bd	onehalf
00be	be	threequarters
00bf	bf	questiondown
00c0	c0	Agrave
00c1	c1	Aacute
00c2	c2	Acircumflex
00c3	c3	Atilde
00c4	c4	Adieresis
00c5	c5	Aring
00c6	c6	AE
00c7	c7	Ccedilla
00c8	c8	Egrave
00c9	c9	Eacute
00ca	ca	Ecircumflex
00cb	cb	Edieresis
00cc	cc	Igrave
00cd	cd	Iacute
00ce	ce	Icircumflex
00cf	cf	Idieresis
00d0	d0	Eth
00d1	d1	Ntilde
00d2	d2	Ograve
00d3	d3	Oacute
00d4	d4	Ocircumflex
00d5	d5	Otilde
00d6	d6	Odieresis
00d7	d7	multiply
00d8	d8	Oslash
00d9	d9	Ugrave
00da	da	Uacute
00db	db	Ucircumflex
00dc	dc	Udieresis
00dd	dd	Yacute
00de	de	Thorn
00df	df	germandbls
00e0	e0	agrave
00e1	e1	aacute
00e2	e2	acircumflex
00e3	e3	atilde
00e4	e4	adieresis
00e5	e5	aring
00e6	e6	ae
00e7	e7	ccedilla
00e8	e8	egrave
00e9	e9	eacute
00ea	ea	ecircumflex
00eb	eb	edieresis
00ec	ec	igrave
00ed	ed	iacute
00ee	ee	icircumflex
00ef	ef	idieresis
00f0	f0	eth
00f1	f1	ntilde
00f2	f2	ograve
00f3	f3	oacute
00f4	f4	ocircumflex
00f5	f5	otilde
00f6	f6	odieresis
00f7	f7	divide
00f8	f8	oslash
00f9	f9	ugrave
00fa	fa	uacute
00fb	fb	ucircumflex
00fc	fc	udieresis
00fd	fd	yacute
00fe	fe	thorn
00ff	ff	ydieresis