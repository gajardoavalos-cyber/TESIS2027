package plecs_io;
# Lectura y escritura del formato de texto de PLECS (.plecs) como arbol.
# Cada nodo es {k=>clave, c=>[hijos]} (bloque), {k, s=>texto} (cadena) o {k, v=>valor}.
use strict; use warnings;
use Exporter 'import';
our @EXPORT = qw(leer escribir clonar attr set_attr param set_param comps buscar
                 schematic quitar_por_nombre rgb ordenar);

sub leer {
  my ($archivo) = @_;
  open my $fh, '<', $archivo or die "No puedo abrir $archivo: $!";
  my @L = map { s/\r?\n$//r } <$fh>;
  close $fh;
  my $i = 0;
  my $arbol = _bloque(\@L, \$i);
  return $arbol;
}

sub _bloque {
  my ($L, $ip) = @_;
  my @items;
  while ($$ip < @$L) {
    my $l = $L->[$$ip];
    if ($l =~ /^\s*\}\s*$/) { $$ip++; return \@items; }
    if ($l =~ /^\s*$/)      { $$ip++; next; }
    if ($l =~ /^\s*(\w+)\s*\{\s*$/) {
      my $k = $1; $$ip++;
      push @items, { k => $k, c => _bloque($L, $ip) };
      next;
    }
    if ($l =~ /^\s*(\w+)\s+(.*?)\s*$/) {
      my ($k, $v) = ($1, $2); $$ip++;
      if ($v =~ /^"/) {
        my $s = $v;
        while ($$ip < @$L && $L->[$$ip] =~ /^[ \t]*"/) { $s .= "\n" . $L->[$$ip]; $$ip++; }
        my @p = ($s =~ /"((?:[^"\x5c]|\x5c.)*)"/g);
        push @items, { k => $k, s => join('', @p) };
      } else {
        # valores no-cadena que siguen en otra linea (base64, listas de senales)
        while ($$ip < @$L && $L->[$$ip] =~ /^[ \t]*"/) { $v .= "\n" . $L->[$$ip]; $$ip++; }
        push @items, { k => $k, v => $v };
      }
      next;
    }
    die "Linea " . ($$ip + 1) . " no reconocida: $l\n";
  }
  return \@items;
}

sub escribir {
  my ($arbol, $archivo) = @_;
  open my $fh, '>', $archivo or die "No puedo escribir $archivo: $!";
  binmode $fh;
  print $fh _emitir($arbol, 0);
  close $fh;
}

sub _pad { my $k = shift; length($k) < 13 ? sprintf('%-13s ', $k) : "$k " }

sub _trozos {   # corta una cadena larga sin separar un escape
  my $s = shift;
  my @t;
  while (length($s) > 72) {
    my $n = 72;
    $n-- while $n > 1 && substr($s, $n - 1, 1) eq "\x5c";
    push @t, substr($s, 0, $n);
    $s = substr($s, $n);
  }
  push @t, $s;
  return @t;
}

sub _emitir {
  my ($items, $ind) = @_;
  my $o = '';
  my $sp = ' ' x $ind;
  for my $it (@$items) {
    if ($it->{c}) {
      $o .= "$sp$it->{k} {\n" . _emitir($it->{c}, $ind + 2) . "$sp}\n";
    } elsif (defined $it->{s}) {
      my @t = _trozos($it->{s});
      $o .= $sp . _pad($it->{k}) . '"' . shift(@t) . "\"\n";
      $o .= "\"$_\"\n" for @t;
    } else {
      $o .= $sp . _pad($it->{k}) . "$it->{v}\n";
    }
  }
  return $o;
}

sub clonar {
  my $x = shift;
  return [ map { clonar($_) } @$x ] if ref $x eq 'ARRAY';
  return $x unless ref $x eq 'HASH';
  my %h = %$x;
  $h{c} = clonar($h{c}) if $h{c};
  return \%h;
}

sub attr {                      # valor de un atributo directo de un bloque
  my ($b, $k) = @_;
  for my $it (@{ $b->{c} }) {
    next if $it->{c} || $it->{k} ne $k;
    return defined $it->{s} ? $it->{s} : $it->{v};
  }
  return undef;
}

sub set_attr {                  # set_attr($b, 'Position', '[1, 2]') ; cadenas con s=>
  my ($b, $k, $val, $es_cadena) = @_;
  for my $it (@{ $b->{c} }) {
    next if $it->{c} || $it->{k} ne $k;
    if ($es_cadena) { delete $it->{v}; $it->{s} = $val } else { delete $it->{s}; $it->{v} = $val }
    return;
  }
  # atributo nuevo: va junto a los demas atributos, antes de Parameter/Terminal/Schematic
  my $nuevo = $es_cadena ? { k => $k, s => $val } : { k => $k, v => $val };
  my $c = $b->{c};
  my $pos = 0;
  $pos++ while $pos < @$c && !$c->[$pos]{c};
  splice @$c, $pos, 0, $nuevo;
}

sub ordenar {                   # orden canonico de PLECS en cada Schematic (recursivo)
  my ($blk) = @_;
  for my $it (@{ $blk->{c} || [] }) { ordenar($it) if $it->{c} }
  return unless $blk->{k} && $blk->{k} eq 'Schematic';
  my %rango = (Component => 1, Connection => 2, Annotation => 3, RectangleAnnotation => 3);
  my $i = 0;
  my @c = map { $_->[1] } sort { $a->[0] <=> $b->[0] || $a->[2] <=> $b->[2] }
          map { [ ($_->{c} ? ($rango{ $_->{k} } // 0) : 0), $_, $i++ ] } @{ $blk->{c} };
  $blk->{c} = \@c;
}

sub _param_nodo {
  my ($comp, $var) = @_;
  for my $it (@{ $comp->{c} }) {
    next unless $it->{c} && $it->{k} eq 'Parameter';
    return $it if (attr($it, 'Variable') // '') eq $var;
  }
  return undef;
}

sub param { my $p = _param_nodo(@_); $p ? attr($p, 'Value') : undef }

sub set_param {
  my ($comp, $var, $val) = @_;
  my $p = _param_nodo($comp, $var) or die "El bloque " . (attr($comp, 'Name') // '?') . " no tiene el parametro $var\n";
  set_attr($p, 'Value', $val, 1);
}

sub schematic {                 # bloque Schematic hijo directo
  my $b = shift;
  for my $it (@{ $b->{c} }) { return $it if $it->{c} && $it->{k} eq 'Schematic' }
  return undef;
}

sub comps {                     # componentes de un Schematic
  my $s = shift;
  return grep { $_->{c} && $_->{k} eq 'Component' } @{ $s->{c} };
}

sub buscar {                    # busca un componente por nombre en todo el arbol
  my ($b, $nombre) = @_;
  for my $it (@{ $b->{c} || [] }) {
    next unless $it->{c};
    return $it if $it->{k} eq 'Component' && (attr($it, 'Name') // '') eq $nombre;
    my $r = buscar($it, $nombre);
    return $r if $r;
  }
  return undef;
}

sub quitar_por_nombre {
  my ($s, $nombre) = @_;
  @{ $s->{c} } = grep { !($_->{c} && $_->{k} eq 'Component' && (attr($_, 'Name') // '') eq $nombre) } @{ $s->{c} };
}

sub rgb {                       # '#2E7D32' -> entero ARGB opaco
  my $h = shift; $h =~ s/^#//;
  return 0xFF000000 + hex($h);
}

1;
