use ExtUtils::MakeMaker;

@scripts = grep {-f } glob("scripts/*.*");

WriteMakefile (
        NAME => "Text::PDF::API",
        VERSION_FROM => "lib/Text/PDF/API.pm",
        EXE_FILES => \@scripts,
        AUTHOR => "areibens\@cpan.org",
        ABSTRACT => "PDF Generation API",
        PREREQ_PM => {
		'Compress::Zlib' => 1.03,
        	'Font::TTF::Font' => 0.16,
        	'Font::AFM' => 1.18,
        	'Text::PDF::File' => 0.09,
        },
	dist => {
		ZIP => 'zip -9'
	},
    );
    
