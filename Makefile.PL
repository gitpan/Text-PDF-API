#!perl

use ExtUtils::MakeMaker;

@scripts = grep { -f } glob("scripts/*.pl*");

WriteMakefile (
	NAME		=>	"Text::PDF::API",
	VERSION_FROM	=>	"lib/Text/PDF/API.pm",
	EXE_FILES	=>	\@scripts,
	AUTHOR		=>	"areibens\@cpan.org",
	ABSTRACT	=>	"PDF Generation API",
	PREREQ_PM	=>	{
					'Compress::Zlib'	=> 1.03,
        				'Font::TTF::Font'	=> 0.16,
        				'Text::PDF::File'	=> 0.12,
        				'Digest::MD5'		=> 2.09,
				},
	dist		=>	{
				#	COMPRESS	=>	'bzip2 -9',
					ZIP		=>	'zip -9',
				},
);
        

`pod2html lib/Text/PDF/API.pm >docs/pdf-api.pm.html`;

sub locateUM8 {
	map {
		if(-e "$_/Unicode/Map8/maps/aliases") {return("$_/Unicode/Map8/maps");}
	} @INC;
}

if($um8dir=locateUM8()) {
	print "found Unicode::Map8 aliases file in '$um8dir' ...\n";
	print "writing 'Microsoft-Dingbats' encoding table ... ";
	open(OUTF,qq|>$um8dir/Microsoft-Dingbats.bin|);
	binmode(OUTF);
	print OUTF pack('CCCC',0xff,0xfe,0,1);
	foreach $c (0..255) {
		print OUTF pack('CCCC',0,$c,0xf0,$c);
	}
	close(OUTF);
	print "finished\n";
	print "updating aliases file ...";
	open(OUTF,qq|$um8dir/aliases|);
	@lines=<OUTF>;
	close(OUTF);
	open(OUTF,qq|>$um8dir/aliases|);
	foreach $line (@lines) {
		if($line=~/^Microsoft\-Dingbats\s/){
			print " was previously installed ... ";
		} else {
			print OUTF $line;
		}
	}
	print OUTF "Microsoft-Dingbats microsoftdingbats MsDingbats msdingbats\n";
	close(OUTF);
	print "finished\n";
} else {
	print "could not locate Unicode::Map8 aliases file in '\@INC'.\n"
} 
exit;

__END__
