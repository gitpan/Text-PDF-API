use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'		=> 'Text::PDF::API::GIF',
    'VERSION_FROM'	=> 'GIF.pm',
    'MYEXTLIB'  => 'giflib/libgif$(LIB_EXT)',

    'dist'      	=> {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
	            	'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'},
);

sub MY::postamble {

    $postamble .= <<'END';

$(MYEXTLIB): giflib/Makefile
	cd giflib && $(MAKE) all 

html: GIF.pm
	pod2html GIF.pm
END

    $postamble;
}

