#!/usr/bin/perl
#
# perl continent_sizes.pl ../LT36/save/a.sav
#

use strict;
use warnings;

my @map; # 2d array, each element is a character from the .sav
my $line = 0;

while (<>) {
	if (/^t\d\d\d\d="(.*)"$/) {
		my $tmp = $1;
		$tmp =~ s/[:\+]/ /g;
		#$tmp =~ s/a/_/g;
		$tmp =~ s/[a-z]/X/g;
		$map[$line++] = [split(//, $tmp)];
	}
}

my $w = @{$map[0]};
my $h = @map;
my %land; # hash of tiles that are land, keys: "$y $x", values: 1

for (my $y = 0; $y < $h; $y++) {
	for (my $x = 0; $x < $w; $x++) {
		$land{"$y $x"} = 1 if $map[$y][$x] !~ /[ _]/;
	}
}

my @tmp;

sub wrap {
	my ($y, $x) = @_;

	$x -= $w if $x >= $w;
	$y -= $h if $y >= $h;
	$x += $w if $x < 0;
	$y += $h if $y < 0;

	return [$y, $x];
}

# move a tile from %land to @tmp
sub process {
	my ($y, $x) = @_;
	($y, $x) = @{wrap($y, $x)};

	my $key = "$y $x";
	if ($land{$key}) {
		delete $land{$key};
		push @tmp, [$y, $x];
	}
}

my $continent_id = 0;
my %result;

while (keys %land) {
	my $tile = (keys %land)[0];
	my ($y, $x) = $tile =~ /^(\d+) (\d+)$/;
	process($y, $x);

	while (@tmp) {
		($y, $x) = @{pop @tmp};
		$result{$continent_id}++;

		process($y + 1, $x);
		process($y - 1, $x);
		process($y, $x + 1);
		process($y, $x - 1);
		process($y + 1, $x + 1);
		process($y - 1, $x - 1);
		process($y + 1, $x - 1);
		process($y - 1, $x + 1);
	}
	$continent_id++;
}

my $total = keys %result;
print "$total landmasses on map\n";
for (sort {$b <=> $a} values %result) {
	last if $_ < 10;
	print "$_\n";
}
