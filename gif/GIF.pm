package Text::PDF::API::GIF;

use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS);

$VERSION='0.1';

require Exporter;

@EXPORT_OK = qw( readGIF );


require DynaLoader;
@ISA = qw( DynaLoader );

sub readGIF {
	return(readGIF_internal(@_));
}

bootstrap Text::PDF::API::GIF;

1;

__END__
