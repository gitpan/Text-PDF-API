                        Text::PDF::API

There seem to be a growing plethora of Perl modules for creating and
manipulating PDF files. This module is a exception, since it provides
a nice API around the Text::PDF::* modules created by Martin Hosken.


WARNING
	
	Sorry but this release of Text::PDF::API requires at least 
	Text::PDF 0.12 	because of the incompatible changes in that 
	version !!!!!


CHANGES FROM VERSIONS 0.04??? TO 0.5

	.  Text::PDF::API now supports Type1 fonts
	.  Font support has been rewritten to support
		one common method of encoding handling
		across all font-formats
	.  bugs and incompatiblities under various platfoms 
		have been fixed or workarounds implemented  
	.  a tutorial and/or examples still have to written :(


FEATURES

	.  Works with more than one PDF file open at once
	.  It presents a nice API to the user
	.  Supports the 14 base PDF Core Fonts 
	.  Supports TrueType fonts via Type0 glyphs (Unicode)
	.  Supports Adobe-Type1 Fonts (eexec-ascii, -binary) 
	.  Supports all Unicode::Map8 encodings
		for Core, Truetype and Type1 fonts
	.  Supports Fontcaching
	.  Supports Embedding of bitmap images


UN-FEATURES (which will one day be fixed)

	.  Documentation is curretly rather sparse 
	.  Adobe-Type1 Font Support requires AFM format files
	.  Bitmap images limited to NetPBM/binary and certain PNG formats
	.  This is beta code in development which works 
	   for my apps. but may not for yours :)


REQUIREMENTS

This module set requires you to have installed the following other perl modules:

	Module		Required for
	------------------------------------------------------
	Text::PDF::AFont - Adobe-Postscript Font Support
		(which is currently included in the Text::PDF::API module set)
	Text::PDF	 - PDF object primitives
	Font::TTF	 - Truetype Font Information
	Compress::Zlib	 - Compression of PDF object streams
	Unicode::Map8	 - Mapping of character code-sets


NOTES

Embedding/Usage for Adobe-Type1 fonts is new and may be buggy.
 
PDF Core Font Support has been rewritten (API v0.5_pre2) and may also be buggy.

If you find bugs in the Text::PDF::AFont module please contact the 
mailing-list or the author of the API, since it is NOT a module 
written by 'Martin Hosken'.

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

There is now a mailing-list available:

Post message:	perl-text-pdf-modules@egroups.com
Subscribe:	perl-text-pdf-modules-subscribe@egroups.com 
Unsubscribe:	perl-text-pdf-modules-unsubscribe@egroups.com 
List owner:	perl-text-pdf-modules-owner@egroups.com 
URL to page:	http://www.egroups.com/group/perl-text-pdf-modules

or you can contact the author: alfredreibenschuh@yahoo.com


COPYRIGHTS & LICENSING

This module is copyrighted by Alfred Reibenschuh and can be used under
perl's "Artistic License" which has been included in this archive.


