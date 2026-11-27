#!/usr/bin/perl
# verificar.pl - revision estructural de un .plecs (no reemplaza abrirlo en PLECS)
#   perl verificar.pl ../Red_3F_MR_por_fase.plecs
use strict; use warnings;
use FindBin; use lib $FindBin::Bin;
use plecs_io;

my $f = shift or die "uso: perl verificar.pl archivo.plecs\n";
my $arb = leer($f);
my $P = $arb->[0];
my (@err, @avi);
my (%goto, %from);

# terminales por tipo: [numero de terminales, terminales de entrada de senal]
sub nterm {
  my ($c) = @_;
  my $t = attr($c, 'Type');
  my %fijo = (Resistor => 2, Inductor => 2, Capacitor => 2, Ammeter => 3, Voltmeter => 3, VoltageSource => 3,
              CurrentSource => 3, ACVoltageSource => 2, Ground => 1, Goto => 1, From => 1, Port => 1, Input => 1,
              Output => 1, Clock => 1, Function => 2, PeriodicAverage => 2, Lookup1D => 2, Sum => 3, Saturation => 2,
              DiscreteTransferFunction => 2, Integrator => 2, Delay => 2, CScript => 2, Gain => 2, Constant => 1);
  return $fijo{$t} if $fijo{$t};
  return param($c, 'Width') + 1 if $t eq 'SignalMux' || $t eq 'SignalDemux';
  return attr($c, 'Axes') if $t eq 'Scope';
  return scalar grep { $_->{c} && $_->{k} eq 'Terminal' } @{ $c->{c} } if $t eq 'Subsystem';
  return undef;
}
sub entradas {             # terminales que reciben senal (no pueden tener dos fuentes)
  my ($c) = @_;
  my $t = attr($c, 'Type');
  my %e = (Goto => [1], Output => [1], Function => [1], PeriodicAverage => [1], Lookup1D => [1], Sum => [2, 3],
           Saturation => [1], DiscreteTransferFunction => [1], CScript => [1], VoltageSource => [3], CurrentSource => [3]);
  return @{ $e{$t} } if $e{$t};
  return 2 .. param($c, 'Width') + 1 if $t eq 'SignalMux';
  return 1 if $t eq 'SignalDemux';
  return 1 .. attr($c, 'Axes') if $t eq 'Scope';
  if ($t eq 'Subsystem') {
    my @T = grep { $_->{c} && $_->{k} eq 'Terminal' } @{ $c->{c} };
    return grep { attr($T[$_ - 1], 'Type') eq 'Input' } 1 .. @T;
  }
  return ();
}

sub destinos {             # lista de [componente, terminal] de una conexion (con ramas)
  my ($x) = @_;
  my @d;
  my $dc = attr($x, 'DstComponent');
  push @d, [$dc, attr($x, 'DstTerminal')] if defined $dc;
  push @d, destinos($_) for grep { $_->{c} && $_->{k} eq 'Branch' } @{ $x->{c} };
  return @d;
}

sub revisar {
  my ($sch, $ruta) = @_;
  my %c; my %usado;
  for my $comp (comps($sch)) {
    my $n = attr($comp, 'Name');
    push @avi, "$ruta: nombre con barra '$n'" if $n =~ m{/};
    push @err, "$ruta: nombre repetido '$n'" if $c{$n};
    $c{$n} = $comp;
    my $t = attr($comp, 'Type');
    if ($t eq 'Goto') { push @{ $goto{ param($comp, 'Tag') } }, "$ruta/$n" }
    if ($t eq 'From') { push @{ $from{ param($comp, 'Tag') } }, "$ruta/$n" }
    if ($t eq 'Subsystem') {
      my $s = schematic($comp);
      my @T = grep { $_->{c} && $_->{k} eq 'Terminal' } @{ $comp->{c} };
      my %idx;
      for my $p (comps($s)) {
        my $pt = attr($p, 'Type');
        next unless $pt =~ /^(Port|Input|Output)$/;
        my $i = param($p, 'Index');
        push @err, "$ruta/$n: indice $i repetido" if $idx{$i}++;
        my $tt = $T[$i - 1] ? attr($T[$i - 1], 'Type') : 'nada';
        push @err, "$ruta/$n: el puerto '" . attr($p, 'Name') . "' (indice $i, $pt) no calza con el terminal ($tt)" if $tt ne $pt;
      }
      push @err, "$ruta/$n: " . scalar(@T) . " terminales y " . scalar(keys %idx) . " puertos" if @T != keys %idx;
      revisar($s, "$ruta/$n");
    }
  }
  for my $x (grep { $_->{c} && $_->{k} eq 'Connection' } @{ $sch->{c} }) {
    my $tipo = attr($x, 'Type');
    my @ext = ([attr($x, 'SrcComponent'), attr($x, 'SrcTerminal')], destinos($x));
    for my $e (@ext) {
      my ($nm, $tr) = @$e;
      my $comp = $c{$nm};
      unless ($comp) { push @err, "$ruta: conexion a bloque inexistente '$nm'"; next }
      my $nt = nterm($comp);
      push @avi, "$ruta: no conozco los terminales de " . attr($comp, 'Type') unless defined $nt;
      push @err, "$ruta: '$nm' no tiene terminal $tr (tiene $nt)" if defined $nt && ($tr < 1 || $tr > $nt);
      $usado{"$nm#$tr"}++;
    }
    if ($tipo eq 'Signal') {
      for my $d (destinos($x)) {
        my $comp = $c{ $d->[0] } or next;
        my %ent = map { $_ => 1 } entradas($comp);
        push @err, "$ruta: la senal llega a '$d->[0]' por el terminal $d->[1], que no es entrada" if %ent && !$ent{ $d->[1] };
      }
    }
  }
  for my $comp (values %c) {
    my $n = attr($comp, 'Name');
    for my $i (entradas($comp)) {
      my $k = $usado{"$n#$i"} // 0;
      push @err, "$ruta: entrada $i de '$n' sin conectar" if $k == 0;
      push @err, "$ruta: entrada $i de '$n' con $k fuentes" if $k > 1;
    }
  }
}

revisar(schematic($P), '');

for my $t (sort keys %from) {
  my $g = $goto{$t} ? scalar @{ $goto{$t} } : 0;
  push @err, "tag '$t': $g Goto para " . join(', ', @{ $from{$t} }) if $g != 1;
}
for my $t (sort keys %goto) {
  push @err, "tag '$t' con " . @{ $goto{$t} } . " Goto: @{ $goto{$t} }" if @{ $goto{$t} } > 1;
  push @avi, "tag '$t' sin From (solo se escribe)" unless $from{$t};
}

# variables usadas en parametros vs definidas en la inicializacion
my $ini = attr($P, 'InitializationCommands');
$ini =~ s/\\n/\n/g;
my %def;
for my $l (split /\n/, $ini) { $l =~ s/%.*//; $def{$1} = 1 while $l =~ /\b([A-Za-z_]\w*)\s*=(?!=)/g }
$def{$_} = 1 for qw(pi inf u sin cos sqrt abs exp min max round tan ones zeros i j);
my %faltan;
sub valores {
  my ($x) = @_;
  for my $it (@{ $x->{c} }) {
    if ($it->{c}) {
      if ($it->{k} eq 'Parameter') {
        my $var = attr($it, 'Variable') // '';
        next if $var =~ /^(Tag|Declarations|StartFcn|OutputFcn|UpdateFcn|DerivativeFcn|TerminateFcn|CustomMessage|DialogGeometry|.*Fcn)$/;
        my $v = attr($it, 'Value') // '';
        next if $v =~ /^\|/;
        while ($v =~ /(?<![\w.])([A-Za-z_]\w*)/g) { $faltan{$1}++ unless $def{$1} }
      } else { valores($it) }
    }
  }
}
valores(schematic($P));

print "== $f\n";
print "ERRORES (" . scalar(@err) . "):\n", map { "  - $_\n" } @err;
my %u; @avi = grep { !$u{$_}++ } @avi;
print "AVISOS (" . scalar(@avi) . "):\n", map { "  - $_\n" } @avi;
print "VARIABLES SIN DEFINIR: ", (join(', ', sort keys %faltan) || 'ninguna'), "\n";
