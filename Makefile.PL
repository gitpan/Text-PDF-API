#!perl

use ExtUtils::MakeMaker;

require 'version.perl';

$versionfile='version.perl';

print "Current version is: ".$version->{'v_short'}." on a ";

if($^O eq 'MSWin32') {
	use Config;
	print $Config{'archname'}."\n";
} else {
	`cp gif/Makefile.PL.org gif/Makefile.PL`;
	`cp gif/giflib/Makefile.PL.org gif/giflib/Makefile.PL`;
	print `./shtool guessos`."\n";
}
        
WriteMakefile (
	NAME		=>	"Text::PDF::API",
	VERSION		=>	$version->{'v_short'},
	AUTHOR		=>	"areibens\@cpan.org",
	ABSTRACT	=>	"PDF Generation API",
	dist		=>	{
		ZIP		=>	"zip ",
		ZIPFLAGS	=>	" -v -o -r -9 ",
		COMPRESS	=>	"gzip -9 -f ",
	},
	PREREQ_PM	=>	{
					'Compress::Zlib'	=> 1.03,
        				'Font::TTF::Font'	=> 0.22,
				},
);

print "Making html documentation in docs ... ";
`pod2html lib/Text/PDF/API.pm >docs/pdf-api.pm.html`;
if(-f 'docs/pdf-api.pm.html') {print "ok.\n"} else {print "not ok.\n"}

print <<EOT;

If you have either Pod::Parser or perl 5.6 (or higher) installed,
you can generate the PDF-API-FAQ by issuing a:

	make FAQ


Because of incompatible installation changes in this release you need to 
uninstall any previous version first to maintain a working configuration.

This can be done either by:

	make uninstall 

if your perl installation supports simple uninstall, or:

	make uninstall | grep unlink | sed 's/^unlink/rm -f/g' | sh

if you have a unix system.


EOT

sub MY::postamble
{
    my $self = shift;
    return <<"EOT";

new-version: shtool
	./shtool version -l perl -n "Text::PDF::API" -i v $versionfile
	perl Makefile.PL

new-release: shtool
	./shtool version -l perl -n "Text::PDF::API" -i r $versionfile
	perl Makefile.PL

new-level: shtool
	./shtool version -l perl -n "Text::PDF::API" -i l $versionfile
	perl Makefile.PL

FAQ: docs/PDF-API-FAQ install
	perl docs/PDF-API-FAQ


EOT
}

print "anything else ? \n";
exit;

__END__

