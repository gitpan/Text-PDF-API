#!perl

use ExtUtils::MakeMaker;

require 'version.perl';

$versionfile='version.perl';
WriteMakefile (
	NAME		=>	"Text::PDF::API",
	VERSION		=>	$version->{'v_short'},
	AUTHOR		=>	"areibens\@cpan.org",
	ABSTRACT	=>	"PDF Generation API",
	PREREQ_PM	=>	{
					'Compress::Zlib'	=> 1.03,
        				'Font::TTF::Font'	=> 0.22,
        				'Text::PDF::File'	=> 0.12,
				},
);

print "Current version is: ".$version->{'v_short'}." on a ".`./shtool guessos`."\n";
        

`pod2html lib/Text/PDF/API.pm >docs/pdf-api.pm.html`;


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

EOT
}

exit;

__END__

