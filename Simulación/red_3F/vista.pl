#!/usr/bin/perl
# vista.pl - exporta un esquema del .plecs como lista de figuras para dibujar_vista.ps1
#   perl vista.pl archivo.plecs "Fase a/MR a1" > vista.txt
use strict; use warnings;
use FindBin; use lib $FindBin::Bin;
use plecs_io;

my ($f, $ruta) = @ARGV;
my $s = schematic(leer($f)->[0]);
for my $p (grep { length } split m{/}, $ruta // '') {
  my $c = (grep { attr($_, 'Name') eq $p } comps($s))[0] or die "No existe $p\n";
  $s = schematic($c);
}
sub xy { my $t = shift; $t =~ /\[\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)/; ($1, $2) }
my %pos; my %term;
for my $c (comps($s)) {
  my $n = attr($c, 'Name'); my ($x, $y) = xy(attr($c, 'Position'));
  $pos{$n} = [$x, $y];
  my ($x1, $y1, $x2, $y2) = (-15, -12, 15, 12);
  if (my $fr = attr($c, 'Frame')) { ($x1, $y1, $x2, $y2) = $fr =~ /(-?[\d.]+)/g }
  my $t = attr($c, 'Type'); my $d = attr($c, 'Direction') // 'up';
  if ($t =~ /^(Resistor|Inductor|Capacitor|Ammeter|Voltmeter|VoltageSource|ACVoltageSource|CurrentSource)$/) {
    my $fl = (attr($c, 'Flipped') // 'off') eq 'on';
    my %v = (up => [0, -1], down => [0, 1], left => [-1, 0], right => [1, 0]);
    my $u = $v{$d}; $u = [-$u->[0], -$u->[1]] if $fl && ($d eq 'down' || $d eq 'up');
    $term{$n}{1} = [$x + 25 * $u->[0], $y + 25 * $u->[1]];
    $term{$n}{2} = [$x - 25 * $u->[0], $y - 25 * $u->[1]];
    ($x1, $y1, $x2, $y2) = $u->[0] ? (-20, -8, 20, 8) : (-8, -20, 8, 20);
  }
  if ($t eq 'Subsystem') {
    my $i = 0;
    for my $T (grep { $_->{c} && $_->{k} eq 'Terminal' } @{ $c->{c} }) {
      $i++; my ($tx, $ty) = xy(attr($T, 'Position')); $term{$n}{$i} = [$x + $tx, $y + $ty];
    }
  }
  print "BOX\t", $x + $x1, "\t", $y + $y1, "\t", $x + $x2, "\t", $y + $y2, "\t$t\t$n\n";
}
sub punto { my ($n, $t) = @_; $term{$n}{$t} // $pos{$n} // [0, 0] }
sub rama {
  my ($x, $desde) = @_;
  my @p = ($desde);
  if (my $pt = attr($x, 'Points')) { $pt =~ s/[\[\]]//g; push @p, map { [split /\s*,\s*/] } split /\s*;\s*/, $pt }
  my $dc = attr($x, 'DstComponent');
  push @p, punto($dc, attr($x, 'DstTerminal')) if defined $dc;
  return ([@p]) if defined $dc;
  my @r = ([@p]);
  push @r, rama($_, $p[-1]) for grep { $_->{c} && $_->{k} eq 'Branch' } @{ $x->{c} };
  return @r;
}
for my $x (grep { $_->{c} && $_->{k} eq 'Connection' } @{ $s->{c} }) {
  my $t = attr($x, 'Type');
  my $ini = punto(attr($x, 'SrcComponent'), attr($x, 'SrcTerminal'));
  my @lineas = rama($x, $ini);
  for my $l (@lineas) { next if @$l < 2; print "LINE\t$t\t", join(' ', map { "$_->[0],$_->[1]" } @$l), "\n" }
}
for my $a (grep { $_->{c} && $_->{k} eq 'Annotation' } @{ $s->{c} }) {
  my ($x, $y) = xy(attr($a, 'Position')); my $t = attr($a, 'Name');
  my ($col) = $t =~ /color:(#[0-9A-Fa-f]{6})/; $col //= '#37474F';
  $t =~ s/\\n/ /g; $t =~ s{</p>}{ | }g; $t =~ s/<[^>]+>//g; $t =~ s/&[a-z]+;/~/g; $t =~ s/\s*\|\s*$//;
  print "TEXT\t$x\t$y\t$col\t$t\n";
}
for my $a (grep { $_->{c} && $_->{k} eq 'RectangleAnnotation' } @{ $s->{c} }) {
  my ($x, $y) = xy(attr($a, 'Position'));
  printf "RECT\t%s\t%s\t%s\t%s\t%s\n", $x, $y, attr($a, 'Width'), attr($a, 'Height'), attr($a, 'PenColor');
}
