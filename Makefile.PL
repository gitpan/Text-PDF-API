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

print <<EOT;

hi!

if you want to run the testing-scripts by entering:

	make test

you should have installed the following additional modules:

	Data::DumpXML
	MIME::Base64
        XML::Parser
        Array::RefElem
	Digest::MD5
	
else you can just issue

	make all install

for installation ...

have a nice day

-- Alfred Reibenschuh
EOT

exit;

__END__
