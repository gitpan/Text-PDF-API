use ExtUtils::MakeMaker;
$Verbose = 1;
WriteMakefile(
	'NAME'     =>   'libgif',
        'LINKTYPE'  => 'static',
        'SKIP'      => [qw(dynamic test)],
	'H'         => [qw( getarg.h gif_hash.h gif_lib.h gif_lib_private.h)],
        'C'         => [qw( dev2gif.c dgif_lib.c egif_lib.c getarg.c gif_err.c gif_font.c gif_hash.c gifalloc.c qprintf.c quantize.c)],
        'OBJECT'    => q[$(O_FILES)],
        'clean'    =>   {'FILES' => 'libgif$(LIB_EXT)'}
);

sub MY::post_constants {
    <<'END'
INST_STATIC = libgif$(LIB_EXT)
END
    ;
}

sub MY::top_targets {
    my $top_targets =<<'END';
all    ::    static

static ::    libgif$(LIB_EXT)

config ::

test :	

END
    ;
    $top_targets;
}

