                        Text::PDF::API

There seem to be a growing plethora of Perl modules for creating and
manipulating PDF files. This module is a exception, since it provides
a nice API around the Text::PDF::* modules created by Martin Hosken.


WARNING
	
	Sorry but this release of Text::PDF::API requires at least 
	Text::PDF 0.12 	because of the incompatible changes in that 
	version !!!!!


CHANGES IN VERSIONS 0.699.x (Development Branch)

	.  added experimental support of utf8-strings
	.  adobe-like handling of glyph-encoding of type1-fonts
	.  jpeg is now a native supported bitmap-format 
	.  a tutorial and/or examples still have to written :(
	.  bugfixing


FEATURES

	.  Works with more than one PDF file open at once
	.  It presents a semi-object-oriented API to the user
	.  Supports the 14 base PDF Core Fonts 
	.  Supports TrueType fonts 
	.  Supports Adobe-Type1 Fonts (pfb/pfa/afm) 
	.  Supports native Embedding of bitmap images (jpeg,ppm,png)
	.  Supports Embedding of bitmap images via plugins (gif,bmp,ppm)


UN-FEATURES (which will one day be fixed)

	.  Documentation is currently rather sparse
	.  This is beta code in development which works 
	   for my apps. but may not for yours :)


REQUIREMENTS

This module set requires you to have installed the following other perl modules:

	Module		Required for
	------------------------------------------------------
	Text::PDF	 - PDF object primitives
	Font::TTF	 - Truetype Font Information
	Compress::Zlib	 - Compression of PDF object streams

If you want to embed images via plugins you might want to look for the following modules:

	Text::PDF::API::GIF Text::PDF::API::PPM Text::PDF::API::BMP


NOTES

Embedding of images via plugins is new and may be buggy !
BMP embedding currently works only on little-endian architectures :((

For Type1 font support to work correctly you have to have a postscript font file,
either binary (pfb) or ascii (pfa) format and an adobe font metrics file (afm).

Sorry NO pfm files possible BUT you can create afm files from your pfa/pfb files
with the 'type1afm' utility of the 't1lib'-package available from :

	ftp://ftp.neuroinformatik.ruhr-uni-bochum.de/pub/software/t1lib/
	ftp://sunsite.unc.edu/pub/Linux/libs/graphics/

This requires you to have a working c-compiler installed !

Windows users can download a win32 port (already compiled) from : 
	
	http://penguin.at0.net/~fredo/files/pfb2afm-mingw32.zip

If you can't use any of the above utilities you can try to use the psf2afm.pl
utility provided in the scripts subdirectory which MAY BE ABLE to create
a working afm file for use with Text::PDF::API/AFont ONLY !!!


Thanks.


INSTALLATION

Installation is as per the standard module installation approach:

	perl Makefile.PL
	make
	make install


CONTACT

There is a mailing-list available:

Post message:	perl-text-pdf-modules@yahoogroups.com
Subscribe:	perl-text-pdf-modules-subscribe@yahoogroups.com
Unsubscribe:	perl-text-pdf-modules-unsubscribe@yahoogroups.com
List owner:	perl-text-pdf-modules-owner@yahoogroups.com
URL to page:	http://groups.yahoo.com/group/perl-text-pdf-modules


COPYRIGHTS & LICENSING

This module is copyrighted by Alfred Reibenschuh and can be used under
perl's "Artistic License" which has been included in this archive.
