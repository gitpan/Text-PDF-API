
use ExtUtils::MakeMaker;

@scripts = grep {-f } glob("scripts/*.*");
@theselibs = grep {-f } glob("lib/Text/PDF/*.pm");
push(@theselibs,grep {-f } glob("lib/Text/PDF/API/*.pm"));


WriteMakefile (
	NAME		=>	"Text::PDF::API",
	VERSION_FROM	=>	"lib/Text/PDF/API.pm",
	EXE_FILES	=>	\@scripts,
	AUTHOR		=>	"areibens\@cpan.org",
	ABSTRACT	=>	"PDF Generation API",
	PREREQ_PM	=>	{
					'Compress::Zlib'	=> 1.03,
        				'Font::TTF::Font'	=> 0.16,
        				'Text::PDF::File'	=> 0.09,
        				'Digest::MD5'		=> 2.09,
					'Math::Matrix'		=> 0,
				},
	dist		=>	{
				#	COMPRESS	=>	'bzip2 -9',
					ZIP		=>	'zip -9',
				},
);
        

`pod2html lib/Text/PDF/API.pm >docs/pdf-api.pm.html`;

exit;

__END__
