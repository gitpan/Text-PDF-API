                        Text::PDF::API

There seem to be a growing plethora of Perl modules for creating and
manipulating PDF files. This module is a exception, since it provides
a nice API around the Text::PDF::* modules created by Martin Hosken.

WARNING
	
	Sorry but this release of Text::PDF::API requires at least 
	Text::PDF 0.12 	because of the incompatible changes in that 
	version !!!!!


FEATURES

	.  Works with more than one PDF file open at once
	.  It presents a nice API to the user
	.  Supports the 14 base PDF Fonts 
	.  Supports TrueType fonts with 8bit encodings 
	.  Supports TrueType CID fonts via Type0 glyphs (Unicode)
	.  Supports Fontcaching
	.  Supports Embedding of bitmap images


UN-FEATURES (which will one day be fixed)

	.  Documentation is curretly rather sparse or entirely lacking 
	.  PDF Base Font encoding is hardwired based on platform 
	.  No support for Type1 or Type3 fonts other than the core fonts
	.  Bitmap images limited to NetPBM/binary and certain PNG formats
	.  This is alpha code in development which works 
	   for my apps. but may not for yours :)


REQUIREMENTS

This module set requires you to have installed the following other perl modules:

	Module		Required for
	-----------------------------------------------
	Text::PDF	- PDF object primitives
	Font::TTF	- Truetype Font Information
	Compress::Zlib	- Compression of PDF object streams
	Digest::MD5	- Font/Image caching
	Math::Matrix	- Font/Gfx Transformations


INSTALLATION

Installation is as per the standard module installation approach:

	perl Makefile.PL
	make
	make install


CONTACT

There is now a mailing-list available:

Post message:	perl-text-pdf-api@egroups.com
Subscribe:	perl-text-pdf-api-subscribe@egroups.com 
Unsubscribe:	perl-text-pdf-api-unsubscribe@egroups.com 
List owner:	perl-text-pdf-api-owner@egroups.com 
URL to page:	http://www.egroups.com/group/perl-text-pdf-api

or you can contact the author: alfredreibenschuh@yahoo.com


COPYRIGHTS & LICENSING

This module is copyrighted by Alfred Reibenschuh and can be used under
perl's "Artistic License" which has been included in this archive.
