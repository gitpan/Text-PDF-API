package Text::PDF::API::Encoding::Generic;

sub new {
	my $class=shift(@_);
	my %defaults=@_;
	my $this={};
	bless($this);
	$this->{'e2u'}=();
	$this->{'u2e'}=();
	foreach my $c (keys(%defaults)) {
		$this->{'e2u'}{$c}=$defaults{$c};
		$this->{'u2e'}{$defaults{$c}}=$c;
	}
	return $this;
}

sub add {
	my $this=shift(@_);
	my %defaults=@_;
	foreach my $c (keys(%defaults)) {
		$this->{'e2u'}{$c}=$defaults{$c};
		$this->{'u2e'}{$defaults{$c}}=$c;
	}
}

1;

__END__