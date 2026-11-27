#!/usr/bin/perl
# verificar_formato.pl - compara el orden de atributos de cada bloque con el de archivos que PLECS ya abrio
#   perl verificar_formato.pl ../Red_3F_MR_por_fase.plecs
use strict; use warnings;
use FindBin; use lib $FindBin::Bin;
use plecs_io;

my $f = shift or die "uso: perl verificar_formato.pl archivo.plecs\n";
my @ref = ("$FindBin::Bin/../MicroRed_ACDC_IC.plecs", "$FindBin::Bin/../Parte 2.plecs", "$FindBin::Bin/../Parte 1.1.plecs");

my %orden;    # tipo -> {clave -> posicion}
sub claves { my $c = shift; my %v; grep { !$v{$_}++ } map { $_->{k} } @{ $c->{c} } }
sub aprender {
  my $b = shift;
  for my $it (@{ $b->{c} || [] }) {
    next unless $it->{c};
    if ($it->{k} eq 'Component') {
      my $t = attr($it, 'Type'); my @k = claves($it);
      for my $i (0 .. $#k) { $orden{$t}{ $k[$i] } //= $i }
    }
    aprender($it);
  }
}
aprender(leer($_)->[0]) for @ref;

my @err;
sub revisar {
  my ($b, $ruta) = @_;
  my $prev = 0; my %r = (Component => 1, Connection => 2, Annotation => 3, RectangleAnnotation => 3);
  if ($b->{k} eq 'Schematic') {
    for my $it (grep { $_->{c} } @{ $b->{c} }) {
      my $x = $r{ $it->{k} } // 0;
      push @err, "$ruta: $it->{k} despues de un elemento de orden mayor" if $x < $prev;
      $prev = $x if $x > $prev;
    }
  }
  for my $it (grep { $_->{c} } @{ $b->{c} }) {
    if ($it->{k} eq 'Component') {
      my $t = attr($it, 'Type'); my $n = attr($it, 'Name');
      my @k = claves($it);
      if (!$orden{$t}) { push @err, "$ruta/$n: tipo $t no aparece en los archivos de referencia" }
      else {
        my $p = -1;
        for my $k (@k) {
          my $o = $orden{$t}{$k};
          if (!defined $o) { push @err, "$ruta/$n ($t): atributo '$k' que nunca aparece en ese tipo"; next }
          push @err, "$ruta/$n ($t): '$k' fuera de orden" if $o < $p;
          $p = $o;
        }
        my $seen = 0;
        for my $x (@{ $it->{c} }) { if ($x->{c}) { $seen = 1 } elsif ($seen) { push @err, "$ruta/$n: atributo '$x->{k}' despues de un bloque" } }
      }
    }
    revisar($it, $ruta . ($it->{k} eq 'Component' ? '/' . attr($it, 'Name') : ''));
  }
}
revisar(leer($f)->[0], '');
my %u; @err = grep { !$u{$_}++ } @err;
print "== formato de $f\n", (@err ? map { "  - $_\n" } @err : "  sin diferencias con los archivos de referencia\n");
