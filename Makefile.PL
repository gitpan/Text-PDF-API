#!perl

use ExtUtils::MakeMaker;


WriteMakefile (
	NAME		=>	"Text::PDF::API",
	VERSION_FROM	=>	"lib/Text/PDF/API.pm",
	AUTHOR		=>	"areibens\@cpan.org",
	ABSTRACT	=>	"PDF Generation API",
	PREREQ_PM	=>	{
					'Compress::Zlib'	=> 1.03,
        				'Font::TTF::Font'	=> 0.16,
        				'Text::PDF::File'	=> 0.12,
				},
);
        

`pod2html lib/Text/PDF/API.pm >docs/pdf-api.pm.html`;

exit;

__END__
