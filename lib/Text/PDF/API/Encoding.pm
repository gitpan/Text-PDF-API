package Text::PDF::API::Encoding;

# use strict;

sub canon {
	my ($line)=@_;
	$line=~s/[^a-z0-9]+//gi;
	return lc($line);
}

sub new {
	my $class=shift(@_);
	my $this={};
	bless($this);
	$this->{'_ALIAS'}={};
	%{$this->{'_ALIAS'}}=(
		canon('Adobe')			=>	'AdobeStandard'		,		
		canon('AdobeStandard')		=>	'AdobeStandard'		,		
		canon('AdobeSymbol')		=>	'AdobeSymbol'		,		
		canon('ZapfDingbats')		=>	'AdobeZapfDingbats'	,	
		canon('AdobeZapfDingbats')	=>	'AdobeZapfDingbats'	,	
		canon('ISO-Latin-1')		=>	'ISOLatin1'		,
		canon('ISO-8859-1')		=>	'ISOLatin1'		,
		canon('Latin1')			=>	'ISOLatin1'		,
		canon('L1')			=>	'ISOLatin1'		,
		canon('MicrosoftAnsi')		=>	'MicrosoftAnsi',
		canon('WinAnsi')		=>	'MicrosoftAnsi',
		canon('MsCP1250')		=>	'MicrosoftAnsi',
		canon('CP1250')			=>	'MicrosoftAnsi',
		canon('MS-Latin-1')		=>	'MicrosoftAnsi',
		canon('MicrosoftSymbol')	=>	'MicrosoftSymbol',
		canon('WinSymbol')		=>	'MicrosoftSymbol',
		canon('MS-Symbol')		=>	'MicrosoftSymbol',
		canon('Symbol')			=>	'MicrosoftSymbol',
		canon('Mac')			=>	'MacRoman',
		canon('MacRoman')		=>	'MacRoman',
		canon('Mac-Latin-1')		=>	'MacRoman',
	);
	return $this;
}

sub addalias {
	my $this=shift(@_);
	my ($benc,$enc)=@_;
	if(!$this->{'_ALIAS'}) {
		$this->{'_ALIAS'}=();
	}
	$this->{'_ALIAS'}{$enc}=$benc;
}

sub add {
	my $this=shift(@_);
	my @encs=@_;
	my ($benc,$x,@ret)=();
	foreach my $enc (@encs) {
		$enc=~s/[^a-z0-9]+//gi;
		$enc=lc($enc);
		if($benc=$this->{'_ALIAS'}{$enc}) {
			if(!$this->{$benc}) {
				eval("
					use Text::PDF::API::Encoding::$benc;
					\$this->{\$benc}=Text::PDF::API::Encoding::$benc->new;
				");
				push(@ret,$benc);
			} else {
				push(@ret,$benc);
			}
		} else {
			print STDERR "";
			push(@ret,undef);
		}
	}
	return @ret;
}

sub newEncoding {
	use Text::PDF::API::Encoding::Generic;
	my $this=shift(@_);
	my ($benc,$map)=@_;
	$this->{'_ALIAS'}{canon($benc)}=$benc;
	if(ref($map) EQ 'HASH') {
		$this->{$benc}=Text::PDF::API::Encoding::Generic->new(%$map);
	} elsif ($this->{$this->{'_ALIAS'}{canon($map)}}) {
		$this->{$benc}=Text::PDF::API::Encoding::Generic->new(%{$this->{$this->{'_ALIAS'}{canon($map)}}{'e2u'}});
	} else {
		$this->{$benc}=Text::PDF::API::Encoding::Generic->new();
	} 
}

sub addEncoding {
	my $this=shift(@_);
	my ($benc,%map)=@_;
	if((ref($map) EQ 'HASH') && (ref($this->{canon($benc)}) EQ 'Text::PDF::API::Encoding::Generic')) {
		$this->{$benc}->add(%$map);
	} else {
	} 
}

sub lookUp {
	my ($this,$enc,$code)=@_;
	if(!$this->{$this->{'_ALIAS'}{canon($enc)}}) {
		die "cannot add encoding named '$enc', either unsupported or unknown" unless $this->add($enc);
	}
	return $this->{$this->{'_ALIAS'}{canon($enc)}}{'e2u'}{$code};
}

1;

__DATA__
