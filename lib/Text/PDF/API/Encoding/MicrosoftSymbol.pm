package Text::PDF::API::Encoding::MicrosoftSymbol;

sub new {
	my $class=shift(@_);
	my %defaults=@_;
	my $this={};
	bless($this);
	my ($line,@vals,$data);
	$this->{'e2u'}=();
	$this->{'u2e'}=();
	foreach $line (24..255) {
		$this->{'e2u'}{$line}=0xF000 + $line;
		$this->{'u2e'}{0xF000 + $line}=$line;
	}
	return $this;
}

1;

__END__