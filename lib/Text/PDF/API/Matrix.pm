#                              -*- Mode: Perl -*- 
# Matrix.pm -- 
# ITIID           : $ITI$ $Header $__Header$
# Author          : Ulrich Pfeifer
# Created On      : Tue Oct 24 18:34:08 1995
# Last Modified By: Ulrich Pfeifer
# Last Modified On: Wed Jul 10 20:12:18 1996
# Language        : Perl
# Update Count    : 143
# Status          : Unknown, Use with caution!
# 
# (C) Copyright 1995, Universität Dortmund, all rights reserved.
# 
# $Locker: pfeifer $
# $Log: Matrix.pm,v $
# Revision 0.2  1996/07/10 17:48:14  pfeifer
# Fixes from Mike Beachy <beachy@chem.columbia.edu>
#
# Revision 0.1  1995/10/25  09:48:39  pfeifer
# Initial revision
#
# modified for use by Text::PDF::API by alfred reibenschuh 2000-11-07
# documentation deleted !

package Text::PDF::API::Matrix;

$VERSION = 0.2;

sub version {
    return "Text::PDF::API::Matrix $VERSION";
}

sub new {
    my $type = shift;
    my $self = [];
    my $len = scalar(@{$_[0]});
    for (@_) {
        return undef if scalar(@{$_}) != $len;
        push(@{$self}, [@{$_}]);
    }
    bless $self, $type;
}

sub concat {
    my $self = shift;
    my $other = shift;
    my $result = new Text::PDF::API::Matrix (@{$self});
    
    return undef if scalar(@{$self}) != scalar(@{$other});
    for $i (0 .. $#{$self}) {	
	push @{$result->[$i]}, @{$other->[$i]};
    }
    $result;
}

sub transpose {
    my $self = shift;
    my @result;
    my $m;

    for $col (@{$self->[0]}) {
        push @result, [];
    }
    for $row (@{$self}) {
        $m=0;
        for $col (@{$row}) {
            push(@{$result[$m++]}, $col);
        }
    }
    new Math::Matrix (@result);
}

sub vekpro {
    my($a, $b) = @_;
    my $result=0;

    for $i (0 .. $#{$a}) {
        $result += $a->[$i] * $b->[$i];
    }
    $result;
}
                  
sub multiply {
    my $self  = shift;
    my $other = shift->transpose;
    my @result;
    my $m;
    
    return undef if $#{$self->[0]} != $#{$other->[0]};
    for $row (@{$self}) {
        my $rescol = [];
	for $col (@{$other}) {
            push(@{$rescol}, vekpro($row,$col));
        }
        push(@result, $rescol);
    }
    new Math::Matrix (@result);
}

$eps = 0.000001;

sub solve {
    my $m    = new Text::PDF::API::Matrix (@{$_[0]});
    my $mr   = $#{$m};
    my $mc   = $#{$m->[0]};
    my $f;
    my $try;

    return undef if $mc <= $mr;
    ROW: for($i = 0; $i <= $mr; $i++) {
	$try=$i;
	# make diagonal element nonzero if possible
	while (abs($m->[$i]->[$i]) < $eps) {
	    last ROW if $try++ > $mr;
	    my $row = splice(@{$m},$i,1);
	    push(@{$m}, $row);
	}

	# normalize row
	$f = $m->[$i]->[$i];
	for($k = 0; $k <= $mc; $k++) {
            $m->[$i]->[$k] /= $f;
	}
	# subtract multiple of designated row from other rows
        for($j = 0; $j <= $mr; $j++) {
	    next if $i == $j;
            $f = $m->[$j]->[$i];
            for($k = 0; $k <= $mc; $k++) {
                $m->[$j]->[$k] -= $m->[$i]->[$k] * $f;
            }
        }
    }
# Answer is in augmented column    
    transpose new Text::PDF::API::Matrix @{$m->transpose}[$mr+1 .. $mc];
}

sub print {
    my $self = shift;
    
    print @_ if scalar(@_);
    for $row (@{$self}) {
        for $col (@{$row}) {
            printf "%10.5f ", $col;
        }
        print "\n";
    }
}

1;
