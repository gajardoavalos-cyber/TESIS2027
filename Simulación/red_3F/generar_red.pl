#!/usr/bin/perl
# =============================================================================
#  generar_red.pl  -  Alimentador BT 3F-4H con Micro-redes DC por fase
#
#  Toma la MR validada (MicroRed_ACDC_IC.plecs), la encapsula como subsistema
#  "MR xy" y arma alrededor la S/E, el alimentador, los nodos de fase y el lazo
#  rapido (PI por fase + reparto opcion C).
#
#  Uso (desde Git Bash, en la carpeta red_3F):
#     perl generar_red.pl                    -> a1 b1 c1 (una MR por fase)
#     perl generar_red.pl a1 a2 b1 c1        -> dos MR en la fase a
#  Salida: ../Red_3F_MR_por_fase.plecs
#
#  Para cambiar la MR, edita MicroRed_ACDC_IC.plecs (la plantilla) y vuelve a
#  generar. No edites a mano las copias MR xy del archivo generado: se pisan.
# =============================================================================
use strict; use warnings;
use FindBin; use lib $FindBin::Bin;
use plecs_io;

my $BASE = "$FindBin::Bin/../MicroRed_ACDC_IC.plecs";
my $OUT = "$FindBin::Bin/../Red_3F_MR_por_fase.plecs";
my $CSCR = "$FindBin::Bin/../Parte 2.plecs";        # solo como plantilla del bloque C-Script

our $PLANTILLA;
$PLANTILLA = "$FindBin::Bin/plantilla_dibujo.plecs" if -e "$FindBin::Bin/plantilla_dibujo.plecs";   # tu dibujo, si existe
sub ruta { my $r = shift; $r =~ m{^(/|[A-Za-z]:)} ? $r : "$FindBin::Bin/$r" }
while (@ARGV >= 2 && $ARGV[0] =~ /^-[op]$/) {
  my $o = shift; my $v = ruta(shift);
  if ($o eq q(-o)) { $OUT = $v } else { $PLANTILLA = $v }
}
my @IDS = @ARGV ? @ARGV : qw(a1 b1 c1);
for (@IDS) { die "Id de MR invalido: $_ (usa fase + numero, p. ej. a2)\n" unless /^[abc]\d+$/ }
my @FASES = qw(a b c);
my %MR_DE; push @{ $MR_DE{ substr($_, 0, 1) } }, $_ for @IDS;
for my $f (@FASES) { die "La fase $f no tiene ninguna MR\n" unless $MR_DE{$f} }

# Variables que pasan a ser propias de cada MR (perfiles y estado inicial)
my @VAR_MR = qw(P_ic t_ic P_ld t_ld P_ev t_ev EV_c SOC_init);

# Colores por nivel (codigo de colores de la tesis)
my %COL = (terc => '#E77500', lazo => '#2E7D32', sec => '#009688', prim => '#1F5FAF',
           red => '#455A64', gris => '#78909C');

# -----------------------------------------------------------------------------
my $ARB  = leer($BASE);
my $PLECS = $ARB->[0];
my $TOP  = schematic($PLECS);
my $CS_TPL = do {
  my $a = leer($CSCR);
  buscar($a->[0], 'Filtro primer orden1') or die "No encontre la plantilla C-Script\n";
};

my %TPL;
for my $n ('p_ac = v_g i_ac', 'Promedio 1 ciclo (P)', 'R_f', 'L_f', 'Am_ac', 'Vm_g',
           'Red fase a (50 Hz)', 'Neutro', 'DC+', 'v_inv* (del primario IC)',
           'Fuente i_dc (balance P)', 'Consigna P* (IC)', 'G_ic_vcmd', 'F_idc_cmd', 'Mux_e', 'Demux_in', 'pv_Error i', 'Clock_plan',
           'Secundario MR a1', 'MR a1 vista desde la fase') {
  $TPL{$n} = clonar(buscar($PLECS, $n) or die "Falta la plantilla '$n' en la MR base\n");
}
$TPL{cscript} = clonar($CS_TPL);

# ------------------------------- utilidades ----------------------------------
sub P { '[' . join('; ', map { "$_->[0], $_->[1]" } @_) . ']' }

sub nuevo {
  my ($tpl, %o) = @_;
  my $c = clonar($TPL{$tpl});
  set_attr($c, 'Name', $o{name}, 1);
  set_attr($c, 'Position', "[$o{x}, $o{y}]");
  set_attr($c, 'Direction', $o{dir} // 'right');
  set_attr($c, 'Flipped', $o{flip} // 'off');
  set_attr($c, 'Show', $o{show}) if $o{show};
  set_attr($c, 'LabelPosition', $o{lab}) if $o{lab};
  set_attr($c, 'Frame', $o{frame}) if $o{frame};
  set_param($c, $_, $o{p}{$_}) for keys %{ $o{p} || {} };
  return $c;
}

sub goto_ { my ($nm, $tag, $x, $y) = @_;
  nuevo('G_ic_vcmd', name => $nm, x => $x, y => $y, show => 'off', p => { Tag => $tag }) }
sub from_ { my ($nm, $tag, $x, $y) = @_;
  nuevo('F_idc_cmd', name => $nm, x => $x, y => $y, show => 'off', p => { Tag => $tag }) }
sub mux_  { my ($nm, $n, $x, $y) = @_; my $h = 10 * $n;
  nuevo('Mux_e', name => $nm, x => $x, y => $y, show => 'off', frame => "[-2, -$h; 7, $h]", p => { Width => $n }) }
sub demux_ { my ($nm, $n, $x, $y) = @_; my $h = 10 * $n;
  nuevo('Demux_in', name => $nm, x => $x, y => $y, show => 'off', frame => "[-7, -$h; 2, $h]", p => { Width => $n }) }
sub fcn_  { my ($nm, $expr, $x, $y, $w) = @_; $w //= 55;
  nuevo('p_ac = v_g i_ac', name => $nm, x => $x, y => $y, frame => "[-$w, -12; $w, 12]", p => { 'f(u)' => $expr }) }
sub muxin { my ($n, $i) = @_; -10 * $n + 10 + 20 * $i }     # y relativo de la entrada i (0..n-1)

# Conexiones. Arbol: {pts=>[[x,y],...], dst=>[nombre, terminal]} o {pts=>..., br=>[arbol, arbol]}
sub conn {
  my ($tipo, $src, $st, $arbol) = @_;
  my @c = ({ k => 'Type', v => $tipo }, { k => 'SrcComponent', s => $src }, { k => 'SrcTerminal', v => $st });
  push @c, _rama($arbol);
  return { k => 'Connection', c => \@c };
}
sub _rama {
  my $t = shift; my @c;
  push @c, { k => 'Points', v => P(@{ $t->{pts} }) } if $t->{pts} && @{ $t->{pts} };
  if ($t->{dst}) {
    push @c, { k => 'DstComponent', s => $t->{dst}[0] }, { k => 'DstTerminal', v => $t->{dst}[1] };
  } else {
    push @c, { k => 'Branch', c => [ _rama($_) ] } for @{ $t->{br} };
  }
  return @c;
}
sub sig  { my ($s, $st, $d, $dt, @p) = @_; conn('Signal', $s, $st, { pts => \@p, dst => [$d, $dt] }) }
sub cab  { my ($s, $st, $d, $dt, @p) = @_; conn('Wire',   $s, $st, { pts => \@p, dst => [$d, $dt] }) }

# Barra horizontal en y: nodos [x, nombre, terminal] colgados en vertical de la barra
sub barra {
  my ($src, $st, $y, @nodos) = @_;
  @nodos = sort { $a->[0] <=> $b->[0] } @nodos;
  my $arbol = _barra($y, @nodos);
  return conn('Wire', $src, $st, $arbol);
}
sub _barra {
  my ($y, $n, @resto) = @_;
  return { pts => [[$n->[0], $y]], dst => [$n->[1], $n->[2]] } unless @resto;
  return { pts => [[$n->[0], $y]], br => [ { dst => [$n->[1], $n->[2]] }, _barra_sin_pt($y, @resto) ] };
}
sub _barra_sin_pt { my ($y, @r) = @_; _barra($y, @r) }

# Anotaciones
sub esc_html { my $t = shift; $t }   # el texto ya viene con entidades HTML
sub titulo { my ($txt, $col, $pt) = @_; $pt //= 10;
  '<p><span style=\" font-size:' . $pt . 'pt; font-weight:600; color:' . $col . ';\">' . $txt . '</span></p>' }
sub linea { my ($txt, $col) = @_; $col //= '#37474F';
  '<p><span style=\" font-size:8pt; color:' . $col . ';\">' . $txt . '</span></p>' }
sub nota { my ($x, $y, @p) = @_;
  { k => 'Annotation', c => [ { k => 'Name', s => '<html><body>' . join('', @p) . '</body></html>' },
                               { k => 'Position', v => "[$x, $y]" } ] } }
sub zona {
  my ($x1, $y1, $x2, $y2, $col) = @_;
  { k => 'RectangleAnnotation', c => [
      { k => 'Position', v => '[' . (($x1 + $x2) / 2) . ', ' . (($y1 + $y2) / 2) . ']' },
      { k => 'Width', v => $x2 - $x1 }, { k => 'Height', v => $y2 - $y1 },
      { k => 'CornerRadius', v => 4 }, { k => 'Thickness', v => 2 },
      { k => 'PenColor', v => rgb($col) }, { k => 'PenAlpha', v => 1 },
      { k => 'BrushColor', v => 0 }, { k => 'BrushAlpha', v => 0 } ] }
}

sub subsistema {           # subsistema vacio con terminales [tipo, [x,y], dir]
  my ($nombre, $x, $y, $frame, $terms, $items) = @_;
  my $s = clonar($TPL{'Secundario MR a1'});
  set_attr($s, 'Name', $nombre, 1);
  set_attr($s, 'Position', "[$x, $y]");
  set_attr($s, 'Frame', $frame);
  my @c = grep { !($_->{c} && ($_->{k} eq 'Terminal' || $_->{k} eq 'Schematic')) } @{ $s->{c} };
  for my $t (@$terms) {
    push @c, { k => 'Terminal', c => [ { k => 'Type', v => $t->[0] }, { k => 'Position', v => "[$t->[1][0], $t->[1][1]]" },
                                       { k => 'Direction', v => $t->[2] } ] };
  }
  push @c, { k => 'Schematic', c => [
      { k => 'Location', v => '[0, 26; 1536, 800]' }, { k => 'ZoomFactor', v => '0.8' },
      { k => 'SliderPosition', v => '[0, 0]' }, { k => 'ShowBrowser', v => 'off' },
      { k => 'BrowserWidth', v => '100' }, @$items ] };
  $s->{c} = \@c;
  return $s;
}

sub scope_ {               # ejes: [titulo, [[etiqueta, tag], ...]]
  my ($nombre, $xs, $ys, @ejes) = @_;
  my $n = @ejes;
  my $sc = clonar($TPL{'MR a1 vista desde la fase'});
  set_attr($sc, 'Name', $nombre, 1);
  set_attr($sc, 'Position', "[$xs, $ys]");
  my $h = 5 * $n + 10;
  set_attr($sc, 'Frame', "[-15, -$h; 15, $h]");
  set_attr($sc, 'Axes', $n, 1);
  my @c;
  for my $it (@{ $sc->{c} }) {
    next if !$it->{c} && $it->{k} =~ /^(State|SavedViews|HeaderState|PlotPalettes)$/;
    next if $it->{c} && $it->{k} eq 'Axis';
    if ($it->{c} && $it->{k} eq 'Fourier') {
      my @f = grep { !($_->{c} && $_->{k} eq 'Axis') } @{ $it->{c} };
      for my $e (@ejes) {
        push @f, { k => 'Axis', c => [ { k => 'Name', s => '' }, { k => 'AutoScale', v => 1 }, { k => 'MinValue', v => 0 },
          { k => 'MaxValue', v => 1 }, { k => 'Signals', v => '{' . join(', ', map { "\"$_->[0]\"" } @{ $e->[1] }) . '}' },
          { k => 'Untangle', v => 0 }, { k => 'KeepBaseline', v => 'off' }, { k => 'BaselineValue', v => 0 } ] };
      }
      push @c, { k => 'Fourier', c => \@f };
      next;
    }
    push @c, $it;
    if (!$it->{c} && $it->{k} eq 'ShowLegend') {
      for my $e (@ejes) {
        my ($mn, $mx) = $e->[3] ? @{ $e->[3] } : (0, 1);
        push @c, { k => 'Axis', c => [ { k => 'Name', s => $e->[0] }, { k => 'AutoScale', v => ($e->[3] ? 0 : 1) },
          { k => 'MinValue', v => $mn }, { k => 'MaxValue', v => $mx }, { k => 'Signals', v => '{' . join(', ', map { "\"$_->[0]\"" } @{ $e->[1] }) . '}' },
          { k => 'SignalTypes', v => '[ ]' }, { k => 'Untangle', v => 0 }, { k => 'KeepBaseline', v => 'off' },
          { k => 'BaselineValue', v => 0 } ] };
      }
    }
  }
  $sc->{c} = \@c;
  # Cada eje llega como un vector (Goto armado en el subsistema Medidas): un From por eje
  my @items = ($sc);
  for my $k (0 .. $n - 1) {
    my $yc  = $ys + 30 * ($k - ($n - 1) / 2);
    my $yin = $ys - 5 * ($n - 1) + 10 * $k;
    my $fn  = "F_${nombre}_$k";
    push @items, from_($fn, $ejes[$k][2], $xs - 110, $yc);
    my $xb = $yc < $yin ? $xs - 45 - 10 * $k : $xs - 45 - 10 * ($n - 1 - $k);
    push @items, abs($yc - $yin) < 0.5 ? sig($fn, 1, $nombre, $k + 1)
                                       : sig($fn, 1, $nombre, $k + 1, [$xb, $yc], [$xb, $yin]);
  }
  return @items;
}

sub medidas {              # arma los vectores que leen los scopes
  my (@grupos) = @_;       # [tag vector, [[etiqueta, tag], ...]]
  my @items; my $y = 80;
  for my $g (@grupos) {
    my ($tv, $s) = @$g; my $m = @$s;
    my $yc = $y + 10 * $m;
    push @items, mux_("Mux_$tv", $m, 200, $yc), goto_("G_$tv", $tv, 280, $yc), sig("Mux_$tv", 1, "G_$tv", 1),
      nota(390, $yc, linea($tv));
    for my $i (0 .. $m - 1) {
      push @items, from_("F_${tv}_$i", $s->[$i][1], 130, $yc + muxin($m, $i)), sig("F_${tv}_$i", 1, "Mux_$tv", $i + 2);
    }
    $y += 20 * $m + 40;
  }
  unshift @items, nota(250, 40, titulo('Vectores para los scopes', $COL{gris}, 10));
  return subsistema('Medidas', 1070, 430, '[-40, -20; 40, 20]', [], \@items);
}

# -----------------------------------------------------------------------------
#  1. La MR encapsulada (una copia por id)
# -----------------------------------------------------------------------------
sub texto_plano { my $t = shift; $t =~ s/\\n/ /g; $t =~ s/<[^>]+>//g; $t =~ s/^\s+|\s+$//g; $t }

sub reescribir_nota {      # devuelve html nuevo, '' para borrar, undef para dejar igual
  my ($t, $id) = @_;
  return titulo('Secundario', $COL{sec}) . linea('mide solo V_dc y SOC de su MR')           if $t =~ /^SECUNDARIO DE LA MR/;
  return linea('dV = PI(V0 &minus; V_dc) &middot; l&iacute;mites de SOC con rampas de ancho dS') if $t =~ /^\(a\) Restauracion/;
  return titulo('Primario de los DER', $COL{prim}) . linea('cada convertidor impone su corriente con un PI') if $t =~ /^PRIMARIO DE LOS DER/;
  return titulo('Primario del IC', $COL{prim})
       . linea('grid-following, Q_ref = 0 &middot; SOGI-PLL &rarr; &theta;, V')
       . linea('i_ac* = (2 P*/V) sin &theta; &middot; PR 50 Hz + feedforward de v_g')
       . linea('No regula V_dc: lo fija la BESS')                                            if $t =~ /^Primario del IC/;
  return ''                                                                                 if $t =~ /^MEDIDAS QUE SALEN/;
  return linea('<b>Bus DC (+)</b>')                                                          if $t =~ /^BUS DC \(\+\)/;
  return linea('<b>Bus DC (&minus;)</b> &middot; 0V flotante, no se une al neutro')          if $t =~ /^BUS DC \(-\)/;
  return linea('<b>Salidas de la planta</b>')                                                if $t =~ /^SALIDAS de la planta/;
  return titulo('IC monof&aacute;sico', $COL{prim})
       . linea('AC: v_inv &ndash; R_f &ndash; L_f &ndash; bornes L, N (fase de la S/E)')
       . linea('DC: i_dc = v_inv i_ac / V_dc &middot; i_ac &gt; 0 de la red al IC')
       . linea('DC&minus; no se une al neutro')                                              if $t =~ /^IC monofasico, modelo promedio/;
  return titulo("MR $id", '#263238', 12) . linea('Micro-red DC residencial + IC monof&aacute;sico &middot; plantilla: MicroRed_ACDC_IC.plecs')
                                                                                            if $t =~ /^VALIDACION DE UNA MICRO-RED/;
  return titulo('Plan P*', $COL{terc}) . linea('perfil fijo en lugar del terciario')       if $t =~ /^TERCIARIO/;
  return titulo('Control', $COL{gris})                                                       if $t =~ /^CONTROLADORES/;
  return titulo('Planta', $COL{gris})                                                        if $t =~ /^PLANTA/;
  return ''                                                                                 if $t =~ /^P\* \(consigna\)$/ || $t =~ /^Scope - /;
  return undef;
}

sub recorrer {             # aplica renombres a todo el arbol de una MR
  my ($items, $id) = @_;
  my @out;
  for my $it (@$items) {
    if ($it->{c}) {
      if ($it->{k} eq 'Annotation') {
        my $nombre = attr($it, 'Name');
        my $nuevo = reescribir_nota(texto_plano($nombre), $id);
        next if defined $nuevo && $nuevo eq '';
        if (defined $nuevo) { set_attr($it, 'Name', "<html><body>$nuevo</body></html>", 1) }
        else { (my $s = $nombre) =~ s/MR a1/MR $id/g; set_attr($it, 'Name', $s, 1) }
        push @out, $it; next;
      }
      if ($it->{k} eq 'RectangleAnnotation') { set_attr($it, 'PenColor', rgb($COL{gris})); push @out, $it; next }
      if ($it->{k} eq 'Component') {
        my $tipo = attr($it, 'Type');
        if ($tipo eq 'Goto' || $tipo eq 'From') { set_param($it, 'Tag', "${id}_" . param($it, 'Tag')) }
      }
      $it->{c} = recorrer($it->{c}, $id);
      push @out, $it; next;
    }
    if (defined $it->{s}) {
      if ($it->{k} =~ /^(Name|SrcComponent|DstComponent)$/) { $it->{s} =~ s/MR a1/MR $id/g }
      if ($it->{k} eq 'Value') { for my $v (@VAR_MR) { $it->{s} =~ s/\b\Q$v\E\b/${v}_$id/g } }
    }
    push @out, $it;
  }
  return \@out;
}

sub ajustar_ic {           # la red de 50 Hz sale del IC por los bornes L y N
  my ($ic) = @_;
  my $s = schematic($ic);
  my $fuente = buscar($ic, 'Red fase a (50 Hz)') or die "No encontre la red interna del IC\n";
  quitar_por_nombre($s, 'Red fase a (50 Hz)');
  quitar_por_nombre($s, 'Neutro');
  push @{ $s->{c} },
    nuevo('DC+', name => 'L', x => 910, y => 175, dir => 'up', show => 'on', lab => 'east', p => { Index => 6 }),
    nuevo('DC+', name => 'N', x => 910, y => 285, dir => 'up', show => 'on', lab => 'east', p => { Index => 7 });
  # conexiones que tocaban la fuente o la tierra
  @{ $s->{c} } = grep {
    !($_->{c} && $_->{k} eq 'Connection' && _toca($_, 'Red fase a (50 Hz)', 'Neutro'))
  } @{ $s->{c} };
  push @{ $s->{c} },
    conn('Wire', 'Am_ac', 1, { pts => [[910, 120]], br => [ { dst => ['L', 1] }, { pts => [[1045, 120]], dst => ['Vm_g', 1] } ] }),
    conn('Wire', 'N', 1, { pts => [[910, 230]], br => [ { pts => [[600, 230]], dst => ['Fuente promedio v_inv', 2] },
                                                       { pts => [[1045, 230]], dst => ['Vm_g', 2] } ] });
  # terminales nuevos en el marco del IC
  my @c = @{ $ic->{c} };
  my ($ult) = grep { $c[$_]{c} && $c[$_]{k} eq 'Terminal' } reverse 0 .. $#c;
  splice @c, $ult + 1, 0,
    { k => 'Terminal', c => [ { k => 'Type', v => 'Port' }, { k => 'Position', v => '[100, -40]' }, { k => 'Direction', v => 'right' } ] },
    { k => 'Terminal', c => [ { k => 'Type', v => 'Port' }, { k => 'Position', v => '[100, -10]' }, { k => 'Direction', v => 'right' } ] };
  $ic->{c} = \@c;
}
sub _toca {
  my ($x, @nombres) = @_;
  for my $it (@{ $x->{c} }) {
    if ($it->{c}) { return 1 if _toca($it, @nombres) }
    elsif (defined $it->{s} && $it->{k} =~ /^(SrcComponent|DstComponent)$/) { return 1 if grep { $it->{s} eq $_ } @nombres }
  }
  return 0;
}

my $CS_ENV = <<'C';
#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define MAX(a,b) ((a) > (b) ? (a) : (b))
/* Parametros: [Pb_max, P_ic_max, E_bat, eta_d, eta_c, SOC_min, SOC_max, Theta_h] */
#define PBMAX  ParamRealData(0,0)
#define PICMAX ParamRealData(0,1)
#define EBAT   ParamRealData(0,2)
#define ETAD   ParamRealData(0,3)
#define ETAC   ParamRealData(0,4)
#define SOCMIN ParamRealData(0,5)
#define SOCMAX ParamRealData(0,6)
#define THETA  ParamRealData(0,7)
/* Entradas: SOC, P_bat (>0 descarga), P_IC (>0 importa, prom. 1 ciclo), dP_k (>0 inyecta) */
#define SOC  InputSignal(0,0)
#define PBAT InputSignal(0,1)
#define PIC  InputSignal(0,2)
#define DPK  InputSignal(0,3)
#define FUP   DiscState(0)
#define FDN   DiscState(1)
C
my $CS_ENV_UPD = <<'C';
{
  double pb_plan  = PBAT - DPK;          /* BESS sin la correccion del lazo */
  double iny_plan = -PIC - DPK;          /* inyeccion del IC en el plan    */
  double pi_up = MIN(PBMAX - pb_plan, PICMAX - iny_plan);
  double pi_dn = MIN(PBMAX + pb_plan, PICMAX + iny_plan);
  double w_up  = (SOC - SOCMIN) * EBAT * ETAD;      /* Wh disponibles para inyectar */
  double w_dn  = (SOCMAX - SOC) * EBAT / ETAC;      /* Wh disponibles para absorber */
  FUP = MAX(0.0, MIN(pi_up, w_up / THETA));
  FDN = MAX(0.0, MIN(pi_dn, w_dn / THETA));
}
C

sub cscript {
  my (%o) = @_;
  my $c = clonar($TPL{cscript});
  set_attr($c, 'Name', $o{name}, 1);
  set_attr($c, 'Show', 'on');
  set_attr($c, 'Position', "[$o{x}, $o{y}]");
  set_attr($c, 'Direction', 'up');      # tamano por defecto: en los archivos de referencia nunca lleva Frame
  my $nl = sub { my $t = shift; $t =~ s/\x5c/\x5c\x5c/g; $t =~ s/"/\x5c"/g; $t =~ s/\n/\x5cn/g; $t };
  my %p = (NumInputs => "[$o{nin}]", NumOutputs => "[$o{nout}]", NumContStates => '0',
           NumDiscStates => $o{nd}, NumZCSignals => '0', DirectFeedthrough => $o{df}, Ts => $o{ts},
           Parameters => $o{par}, Declarations => $nl->($o{decl}), StartFcn => $nl->($o{start}),
           OutputFcn => $nl->($o{out}), UpdateFcn => $nl->($o{upd}), DialogGeometry => '');
  set_param($c, $_, $p{$_}) for keys %p;
  return $c;
}

sub mr_encapsulada {
  my ($id) = @_;
  my @items = grep { $_->{c} && $_->{k} =~ /^(Component|Connection|Annotation|RectangleAnnotation)$/ } @{ clonar($TOP->{c}) };
  @items = @{ recorrer(\@items, $id) };
  my %sch = (c => \@items);
  ajustar_ic(buscar(\%sch, 'IC'));

  # Consigna del IC: plan - correccion del lazo + respaldo de red, limitada a +-P_ic_max
  #   u[1] = dP_k, u[2] = P*, u[3] = SOC.  sat01(x) = 0.5(|x| - |x-1| + 1), sin condicionales
  my $kr = '(Respaldo_ON*0.5*(abs((SOC_min + 2*dS - u[3])/dS) - abs((SOC_min + 2*dS - u[3])/dS - 1) + 1))';
  my $yr = "(u[2] - u[1] + P_resp_max*$kr)";
  my $expr = "0.5*(abs($yr + P_ic_max) - abs($yr - P_ic_max))";
  @items = grep { !($_->{c} && $_->{k} eq 'Connection' && (attr($_, 'SrcComponent') // '') eq 'Consigna P* (IC)') } @items;
  push @items,
    mux_('Mux_Pref', 3, 690, 205),
    fcn_('P*_IC', $expr, 790, 205, 55),
    nuevo('v_inv* (del primario IC)', name => 'dP_k', x => 500, y => 120, show => 'on', p => { Index => 3 }),
    from_('F_resp_SOC', "${id}_pl_SOC", 600, 250),
    nuevo('DC+', name => 'L', x => 870, y => 725, dir => 'left', show => 'on', p => { Index => 1 }),
    nuevo('DC+', name => 'N', x => 870, y => 755, dir => 'left', show => 'on', p => { Index => 2 }),
    sig('dP_k', 1, 'Mux_Pref', 2, [660, 120], [660, 185]),
    sig('Consigna P* (IC)', 2, 'Mux_Pref', 3),
    sig('F_resp_SOC', 1, 'Mux_Pref', 4, [665, 250], [665, 225]),
    sig('Mux_Pref', 1, 'P*_IC', 1),
    sig('P*_IC', 2, 'Primario IC (g-f)', 1, [880, 205], [880, 265], [640, 265]),
    cab('IC', 6, 'L', 1),
    cab('IC', 7, 'N', 1),
    nota(800, 150, linea('<b>P*_IC = sat(P* &minus; &Delta;P_k + P_resp)</b>', $COL{lazo}),
         linea('&Delta;P_k &gt; 0: inyectar m&aacute;s', $COL{lazo}),
         linea('P_resp: respaldo de red si SOC &lt; SOC_min + 2dS', $COL{terc})),
    nota(905, 700, linea('<b>a la fase</b>', $COL{red}));

  # Envolvente que el IC informa al lazo rapido (F_up, F_dn)
  my $y0 = 1000;
  my @tags = ("${id}_pl_SOC", "${id}_pl_P_bat", "${id}_icp_Pac", "${id}_dP");   # P_IC promediada en un ciclo
  push @items, mux_('Mux_env', 4, 230, $y0);
  for my $i (0 .. 3) {
    push @items, from_("F_env_$i", $tags[$i], 160, $y0 + muxin(4, $i)), sig("F_env_$i", 1, 'Mux_env', $i + 2);
  }
  push @items,
    cscript(name => 'Envolvente F_k', x => 340, y => $y0, nin => 4, nout => 2, nd => 2, df => 0, ts => 'Ts_lr',
            par => '[Pb_max, P_ic_max, E_bat, eta_d, eta_c, SOC_min, SOC_max, Theta_h]',
            decl => $CS_ENV, start => "FUP = 0.0; FDN = 0.0;", out => "OutputSignal(0,0) = FUP;\nOutputSignal(0,1) = FDN;",
            upd => $CS_ENV_UPD),
    demux_('Demux_env', 2, 440, $y0),
    goto_('G_env_up', "${id}_Fup", 540, $y0 - 25), goto_('G_env_dn', "${id}_Fdn", 540, $y0 + 25),
    sig('Mux_env', 1, 'Envolvente F_k', 1), sig('Envolvente F_k', 2, 'Demux_env', 1),
    sig('Demux_env', 2, 'G_env_up', 1, [490, $y0 - 10], [490, $y0 - 25]),
    sig('Demux_env', 3, 'G_env_dn', 1, [490, $y0 + 10], [490, $y0 + 25]),
    zona(70, 925, 640, 1075, $COL{lazo}),
    nota(355, 945, titulo('Envolvente que informa el IC', $COL{lazo}, 9),
         linea('F_k = min(&Pi;_k, W_k/&Theta;), hacia arriba y hacia abajo')),
    nota(585, 975, linea('F&uarr;_k')), nota(585, 1025, linea('F&darr;_k'));

  return parchar_mr(subsistema("MR $id", 0, 0, '[-50, -40; 50, 40]',
                    [ ['Port', [0, -40], 'up'], ['Port', [0, 40], 'down'], ['Input', [-50, 0], 'left'] ], \@items), $id);
}

# Lleva una MR encapsulada (generada o tomada de la plantilla de dibujo) a la version funcional actual,
# sin mover lo que ya esta dibujado: envolvente con 3 salidas, respaldo de red y P_IC promediada.
sub parchar_mr {           # ajustes funcionales que no mueven el dibujo
  my ($w, $id) = @_;
  my $f2 = buscar($w, 'F_env_2');
  set_param($f2, 'Tag', "${id}_icp_Pac") if $f2;   # P_IC promediada en un ciclo
  ordenar($w);
  return $w;
}

# ---------------- plantilla de dibujo (-p archivo.plecs) ----------------
my ($PL_MR, $PL_ID, $PL_FASE, $PL_F);
if ($PLANTILLA) {
  my $p = leer($PLANTILLA)->[0];
  for my $f (qw(a b c)) {
    my $F = buscar($p, "Fase $f") or next;
    my @m = grep { attr($_, 'Name') =~ /^MR (\w+)$/ } comps(schematic($F));
    next unless @m;
    ($PL_MR) = @m; ($PL_ID) = attr($PL_MR, 'Name') =~ /^MR (\w+)$/;
    ($PL_FASE, $PL_F) = (@m == 1 ? $F : undef, $f);
    last;
  }
  die "La plantilla $PLANTILLA no tiene ninguna MR dentro de un bloque Fase\n" unless $PL_MR;
  print "Plantilla de dibujo: MR $PL_ID", ($PL_FASE ? " y Fase $PL_F" : ''), " de $PLANTILLA\n";
}

sub renombrar {            # cambia id de MR (y opcionalmente fase) en nombres, tags y parametros
  my ($x, $de, $a, $fde, $fa, $dentro_mr) = @_;
  for my $it (@{ $x->{c} || [] }) {
    if ($it->{c}) {
      my $es_mr = $it->{k} eq 'Component' && (attr($it, 'Name') // '') =~ /^MR \w+$/;
      renombrar($it, $de, $a, $fde, $fa, $dentro_mr || $es_mr);
      next;
    }
    next unless defined $it->{s} || ($it->{k} eq 'Signals');
    my $r = \(defined $it->{s} ? $it->{s} : $it->{v});
    $$r =~ s/\bMR $de\b/MR $a/g;
    $$r =~ s/\b${de}_/${a}_/g;
    $$r =~ s/_${de}\b/_${a}/g;
    if (defined $fde && !$dentro_mr) {
      $$r =~ s/_${fde}_/_${fa}_/g;
      $$r =~ s/_${fde}\b/_${fa}/g;
      $$r =~ s/\b(gestionada|carga|Fase|fase) ${fde}\b/$1 $fa/g;
    }
  }
}

sub fase_desde_plantilla {  # copia el bloque Fase de la plantilla (fase con una sola MR)
  my ($f, $x, $y, $id) = @_;
  my $F = clonar($PL_FASE);
  renombrar($F, $PL_ID, $id, $PL_F, $f, 0);
  set_attr($F, 'Name', "Fase $f", 1);
  set_attr($F, 'Position', "[$x, $y]");
  my $s = schematic($F);
  for my $i (0 .. $#{ $s->{c} }) {
    my $c = $s->{c}[$i];
    next unless $c->{c} && $c->{k} eq 'Component' && (attr($c, 'Name') // '') eq "MR $id";
    my $n = mr_desde_plantilla($id);
    set_attr($n, 'Position', attr($c, 'Position'));
    $s->{c}[$i] = $n;
  }
  for my $c (comps($s)) {
    next unless attr($c, 'Type') eq 'From' && param($c, 'Tag') eq "${id}_dP";
    set_param($c, 'Tag', "${id}_dP");
  }
  return $F;
}

sub mr_desde_plantilla {
  my ($id) = @_;
  my $w = clonar($PL_MR);
  renombrar($w, $PL_ID, $id, undef, undef, 1);
  set_attr($w, 'Name', "MR $id", 1);
  return parchar_mr($w, $id);
}

# -----------------------------------------------------------------------------
#  2. Nodo de cada fase: carga no gestionada + MR de la fase
# -----------------------------------------------------------------------------
sub nodo_fase {
  my ($f, $x, $y) = @_;
  my @ids = @{ $MR_DE{$f} };
  return fase_desde_plantilla($f, $x, $y, $ids[0]) if $PL_FASE && @ids == 1;
  my ($yb, $yn) = (150, 450);
  my @items = (
    nuevo('DC+', name => 'L', x => 60, y => $yb, dir => 'right', show => 'on', p => { Index => 1 }),
    nuevo('DC+', name => 'N', x => 60, y => $yn, dir => 'right', show => 'on', p => { Index => 2 }),
    nuevo('R_f', name => "Carga no gestionada $f", x => 220, y => 300, dir => 'up', lab => 'east', p => { R => "R_nog_$f" }),
    nuevo('Vm_g', name => "Vm_pcc_$f", x => 300, y => 300, dir => 'up', show => 'off'),
    goto_("G_pcc_$f", "pcc_v_$f", 355, 300),
    sig("Vm_pcc_$f", 3, "G_pcc_$f", 1),
    # parte variable de la carga no gestionada (perfil diario); en el escenario 1 vale cero
    nuevo('Fuente i_dc (balance P)', name => "Perfil carga $f", x => 470, y => 300, dir => 'down', show => 'on', lab => 'east'),
    from_("F_nog_$f", "nog_i_$f", 415, 300),
    sig("F_nog_$f", 1, "Perfil carga $f", 3),
    nuevo('Clock_plan', name => "Reloj_nog_$f", x => 200, y => 535, show => 'off'),
    nuevo('Consigna P* (IC)', name => "dP_nog_$f(t)", x => 280, y => 535, show => 'on',
          p => { x => 't_nog', 'f(x)' => "Pnog_${f}_v - P_nog_$f" }),
    nuevo('Clock_plan', name => "Reloj_nog2_$f", x => 280, y => 575, show => 'off'),
    mux_("Mux_nog_$f", 2, 370, 555),
    fcn_("i = -s_carga dP sqrt2/V sin", "-s_carga*sqrt(2)*u[1]/Vg_rms*sin(2*pi*f_g*u[2] + phi_$f)", 490, 555, 75),
    goto_("G_nog_$f", "nog_i_$f", 620, 555),
    sig("Reloj_nog_$f", 1, "dP_nog_$f(t)", 1),
    sig("dP_nog_$f(t)", 2, "Mux_nog_$f", 2, [330, 535], [330, 545]),
    sig("Reloj_nog2_$f", 1, "Mux_nog_$f", 3, [330, 575], [330, 565]),
    sig("Mux_nog_$f", 1, "i = -s_carga dP sqrt2/V sin", 1),
    sig("i = -s_carga dP sqrt2/V sin", 2, "G_nog_$f", 1),
    nota(420, 505, linea('<b>perfil diario de la carga no gestionada</b> (cero en el escenario 1)')),
  );
  my @arriba = ([220, "Carga no gestionada $f", 1], [300, "Vm_pcc_$f", 1], [470, "Perfil carga $f", 2]);
  my @abajo  = ([220, "Carga no gestionada $f", 2], [300, "Vm_pcc_$f", 2], [470, "Perfil carga $f", 1]);
  my $xm = 660;
  for my $id (@ids) {
    my $mr = $PL_MR ? mr_desde_plantilla($id) : mr_encapsulada($id);
    set_attr($mr, 'Position', "[$xm, 300]");
    push @items, $mr, from_("F_dP_$id", "${id}_dP", $xm - 110, 300), sig("F_dP_$id", 1, "MR $id", 3),
      nota($xm, 380, linea("&Delta;P_$id desde el lazo r&aacute;pido", $COL{lazo}));
    push @arriba, [$xm, "MR $id", 1];
    push @abajo,  [$xm, "MR $id", 2];
    $xm += 260;
  }
  push @items, barra('L', 1, $yb, @arriba), barra('N', 1, $yn, @abajo),
    nota(140, 135, linea("<b>fase $f</b>", $COL{red})), nota(140, 465, linea('<b>neutro</b>', $COL{red})),
    nota(220, 365, linea("P_nog_$f (fija)")),
    nota(($xm - 260 + 380) / 2, 60, titulo("Fase $f &middot; nodo PCC", $COL{red}, 11),
         linea('carga monof&aacute;sica no gestionada y Micro-redes de la fase'));
  return subsistema("Fase $f", $x, $y, '[-60, -50; 60, 50]',
                    [ ['Port', [-60, 0], 'left'], ['Port', [60, 0], 'right'] ], \@items);
}

# -----------------------------------------------------------------------------
#  3. Lazo rapido: medicion en cabecera, PI de fase y reparto (opcion C)
# -----------------------------------------------------------------------------
my $CS_LR = <<'C';
#define MIN(a,b) ((a) < (b) ? (a) : (b))
/* Parametros: [fase (0,1,2), N, Kp_lr, Ki_lr, Ts_lr, t_lr_on, Lazo_ON, beta_1..beta_N] */
#define FASE  ((int)ParamRealData(0,0))
#define NMR   ((int)ParamRealData(0,1))
#define KP    ParamRealData(0,2)
#define KI    ParamRealData(0,3)
#define TS    ParamRealData(0,4)
#define TON   ParamRealData(0,5)
#define LON   ParamRealData(0,6)
#define BETA(i) ParamRealData(0,7+(i))
/* Entradas: P_h,a  P_h,b  P_h,c  F_up(1..N)  F_dn(1..N) */
#define PH(i)  InputSignal(0,(i))
#define FUP(i) InputSignal(0,3+(i))
#define FDN(i) InputSignal(0,3+NMR+(i))
/* Salidas: dP_k(1..N)  e_phi  dP_phi  lambda_phi  u_phi */
#define X      DiscState(0)
#define ACTIVO (LON > 0.5 && CurrentTime >= TON)

/* water-filling: reparte d >= 0 entre n MR con cotas f[i] y pesos f[i]/(1+b[i]).
   Devuelve lambda (precio de la fase). C puro: no usa macros de PLECS.        */
static double llenar(double d, int n, const double *f, const double *b, double *out)
{
  int i, it;
  double lo = 0.0, hi = 0.0, mid, s;
  for (i = 0; i < n; i++) if (1.0 + b[i] > hi) hi = 1.0 + b[i];
  for (it = 0; it < 60; it++) {
    mid = 0.5 * (lo + hi); s = 0.0;
    for (i = 0; i < n; i++) s += MIN(f[i], mid * f[i] / (1.0 + b[i]));
    if (s < d) lo = mid; else hi = mid;
  }
  for (i = 0; i < n; i++) out[i] = MIN(f[i], hi * f[i] / (1.0 + b[i]));
  return hi;
}
C
my $CS_LR_OUT = <<'C';
{
  int i, n = NMR;
  double e, fu = 0.0, fd = 0.0, v, dp, lam = 0.0, u = 0.0;
  double rep[64], vup[64], vdn[64], b[64];
  if (n > 64) n = 64;
  e = PH(FASE) - (PH(0) + PH(1) + PH(2)) / 3.0;
  for (i = 0; i < n; i++) {
    vup[i] = FUP(i); vdn[i] = FDN(i); b[i] = BETA(i); rep[i] = 0.0;
    fu += vup[i]; fd += vdn[i];
  }
  v  = ACTIVO ? KP * e + X : 0.0;
  dp = v; if (dp > fu) dp = fu; if (dp < -fd) dp = -fd;
  if (dp > 0.0 && fu > 0.0)      { lam =  llenar( dp, n, vup, b, rep); u = dp / fu; }
  else if (dp < 0.0 && fd > 0.0) { lam = -llenar(-dp, n, vdn, b, rep); u = dp / fd; for (i = 0; i < n; i++) rep[i] = -rep[i]; }
  for (i = 0; i < n; i++) OutputSignal(0,i) = rep[i];
  OutputSignal(0,n)   = e;
  OutputSignal(0,n+1) = dp;
  OutputSignal(0,n+2) = lam;
  OutputSignal(0,n+3) = u;
}
C
my $CS_LR_UPD = <<'C';
{
  int i, n = NMR;
  double e, fu = 0.0, fd = 0.0;
  if (!ACTIVO) { X = 0.0; }
  else {
    e = PH(FASE) - (PH(0) + PH(1) + PH(2)) / 3.0;
    for (i = 0; i < n; i++) { fu += FUP(i); fd += FDN(i); }
    X += KI * TS * e;                       /* integrador con anti-windup por recorte */
    if (X > fu) X = fu;
    if (X < -fd) X = -fd;
  }
}
C

my $CS_PH = <<'C';
/* Potencia activa de cabecera: promedio movil de v*i sobre un ciclo de 50 Hz.
   Con Ts_lr = 1 ms son 20 muestras: anula exacto el termino de 100 Hz.      */
/* Parametros: [f_g, Ts_lr]   Entradas: v_h, i_h   Estados: buffer, suma, indice */
#define NCALC ((int)(1.0 / (ParamRealData(0,0) * ParamRealData(0,1)) + 0.5))
#define NPROM (NCALC > 200 ? 200 : (NCALC < 1 ? 1 : NCALC))
#define SUMA  DiscState(200)
#define IDX   DiscState(201)
C
my $CS_PH_INI = "{ int i; for (i = 0; i < 202; i++) DiscState(i) = 0.0; }";
my $CS_PH_UPD = <<'C';
{
  int k = (int)IDX;
  double p = InputSignal(0,0) * InputSignal(0,1);
  SUMA += p - DiscState(k);
  DiscState(k) = p;
  k++; if (k >= NPROM) k = 0;
  IDX = k;
}
C

sub lazo_rapido {
  my @items;
  my %fi = (a => 0, b => 1, c => 2);
  my $nmax = 0; for (@FASES) { $nmax = @{ $MR_DE{$_} } if @{ $MR_DE{$_} } > $nmax }
  my $dy = 20 * (3 + 2 * $nmax) + 80; $dy = 240 if $dy < 240;
  for my $f (@FASES) {
    my $k = $fi{$f};
    my $y0 = 170 + $dy * $k;
    # Medicion en cabecera: p_h = v_h i_h promediada en un ciclo
    push @items,
      nuevo('Clock_plan', name => "Reloj_$f", x => 60, y => $y0 - 30, show => 'off'),
      fcn_("v_h,$f (fuente ideal)", "Vg_pk*sin(2*pi*f_g*u[1] + phi_$f)", 200, $y0 - 30, 70),
      from_("F_ih_$f", "cab_i_$f", 200, $y0 + 30),
      mux_("Mux_p_$f", 2, 320, $y0),
      cscript(name => "P_h,$f = prom. 1 ciclo de v i", x => 450, y => $y0, frame => '[-55, -20; 55, 20]',
              nin => 2, nout => 1, nd => 202, df => 0, ts => 'Ts_lr', par => '[f_g, Ts_lr]',
              decl => $CS_PH, start => $CS_PH_INI, out => 'OutputSignal(0,0) = SUMA / NPROM;', upd => $CS_PH_UPD),
      goto_("G_Ph_$f", "lr_Ph_$f", 600, $y0),
      sig("Reloj_$f", 1, "v_h,$f (fuente ideal)", 1),
      sig("v_h,$f (fuente ideal)", 2, "Mux_p_$f", 2, [285, $y0 - 30], [285, $y0 - 10]),
      sig("F_ih_$f", 1, "Mux_p_$f", 3, [285, $y0 + 30], [285, $y0 + 10]),
      sig("Mux_p_$f", 1, "P_h,$f = prom. 1 ciclo de v i", 1),
      sig("P_h,$f = prom. 1 ciclo de v i", 2, "G_Ph_$f", 1);
    # PI de fase + reparto
    my @ids = @{ $MR_DE{$f} }; my $n = @ids;
    my @ent = ('lr_Ph_a', 'lr_Ph_b', 'lr_Ph_c', (map { "${_}_Fup" } @ids), (map { "${_}_Fdn" } @ids));
    my @sal = ((map { "${_}_dP" } @ids), "lr_e_$f", "lr_dP_$f", "lr_lam_$f", "lr_u_$f");
    my $nin = @ent; my $nout = @sal;
    push @items, mux_("Mux_lr_$f", $nin, 870, $y0);
    for my $i (0 .. $nin - 1) {
      push @items, from_("F_lr_${f}_$i", $ent[$i], 800, $y0 + muxin($nin, $i)), sig("F_lr_${f}_$i", 1, "Mux_lr_$f", $i + 2);
    }
    my $beta = join(', ', map { "beta_$_" } @ids);
    push @items,
      cscript(name => "Fase $f: PI + reparto", x => 990, y => $y0, frame => '[-60, -25; 60, 25]',
              nin => $nin, nout => $nout, nd => 1, df => 1, ts => 'Ts_lr',
              par => "[$k, $n, Kp_lr, Ki_lr, Ts_lr, t_lr_on, Lazo_ON, $beta]",
              decl => $CS_LR, start => 'X = 0.0;', out => $CS_LR_OUT, upd => $CS_LR_UPD),
      demux_("Demux_lr_$f", $nout, 1110, $y0),
      sig("Mux_lr_$f", 1, "Fase $f: PI + reparto", 1),
      sig("Fase $f: PI + reparto", 2, "Demux_lr_$f", 1);
    for my $j (0 .. $nout - 1) {
      push @items, goto_("G_lr_${f}_$j", $sal[$j], 1180, $y0 + muxin($nout, $j)), sig("Demux_lr_$f", $j + 2, "G_lr_${f}_$j", 1);
    }
  }
  my $yf = 170 + $dy * 2 + $dy / 2;
  push @items,
    zona(30, 60, 680, $yf, $COL{red}), zona(720, 60, 1260, $yf, $COL{lazo}),
    nota(355, 85, titulo('Medici&oacute;n en cabecera', $COL{red}, 11),
         linea('P_h,&phi; = promedio de v_h &middot; i_h en un ciclo')),
    nota(990, 85, titulo('PI de fase y reparto (opci&oacute;n C)', $COL{lazo}, 11),
         linea('e_&phi; = P_h,&phi; &minus; (P_h,a + P_h,b + P_h,c)/3'),
         linea('&Delta;P_&phi; = PI(e_&phi;), limitado a [&minus;F&darr;_&phi;, F&uarr;_&phi;]'),
         linea('&Delta;P_k = sat(&lambda;_&phi; F_k/(1+&beta;_k)), &Sigma;&Delta;P_k = &Delta;P_&phi;')),
    nota(1180, $yf - 20, linea('salidas por fase: &Delta;P_k, e, &Delta;P_&phi;, &lambda;, u'));
  return subsistema('Lazo rapido', 1110, 250, '[-90, -45; 90, 45]', [], \@items);
}

# -----------------------------------------------------------------------------
#  4. Nivel superior: S/E, alimentador, fases, lazo rapido y scopes
# -----------------------------------------------------------------------------
my %yl = (a => 200, b => 260, c => 320);         # lineas de fase
my %xs = (a => 120, b => 170, c => 220);         # fuentes de la S/E
my %yf = (a => 200, b => 360, c => 520);         # bloques de fase
my %ph = (a => '0', b => '-2*pi/3', c => '2*pi/3');
my $yN = 640;
my @top;

push @top, nuevo('Neutro', name => 'Tierra SE', x => 70, y => 700, dir => 'up', show => 'off');
for my $f (@FASES) {
  my ($x, $y) = ($xs{$f}, $yl{$f});
  push @top,
    nuevo('Red fase a (50 Hz)', name => "v_$f", x => $x, y => 480, dir => 'up', show => 'on', lab => 'west',
          p => { V => 'Vg_pk', w => '2*pi*f_g', phi => "phi_$f" }),
    nuevo('Am_ac', name => "i_h,$f", x => 300, y => $y, dir => 'left', show => 'off'),
    nuevo('R_f', name => "R_lin_$f", x => 390, y => $y, dir => 'right', show => 'off', p => { R => 'R_lin' }),
    nuevo('L_f', name => "L_lin_$f", x => 470, y => $y, dir => 'right', show => 'off', p => { L => 'L_lin' }),
    goto_("G_ih_$f", "cab_i_$f", 345, $y - 30),
    nodo_fase($f, 760, $yf{$f}),
    cab("v_$f", 1, "i_h,$f", 1, [$x, $y]),
    cab("i_h,$f", 2, "R_lin_$f", 2),
    cab("R_lin_$f", 1, "L_lin_$f", 2),
    sig("i_h,$f", 3, "G_ih_$f", 1, [300, $y - 30]);
}
push @top,
  cab('L_lin_a', 1, 'Fase a', 1),
  cab('L_lin_b', 1, 'Fase b', 1, [640, 260], [640, 360]),
  cab('L_lin_c', 1, 'Fase c', 1, [600, 320], [600, 520]),
  nuevo('R_f', name => 'R_neu', x => 390, y => $yN, dir => 'right', show => 'off', p => { R => 'R_neu' }),
  nuevo('L_f', name => 'L_neu', x => 470, y => $yN, dir => 'right', show => 'off', p => { L => 'L_neu' }),
  conn('Wire', 'Tierra SE', 1, { pts => [[70, $yN]], br => [
        { pts => [[120, $yN]], br => [ { dst => ['v_a', 2] },
          { pts => [[170, $yN]], br => [ { dst => ['v_b', 2] },
            { pts => [[220, $yN]], br => [ { dst => ['v_c', 2] }, { dst => ['R_neu', 2] } ] } ] } ] } ] }),
  cab('R_neu', 1, 'L_neu', 2),
  conn('Wire', 'L_neu', 1, { pts => [[900, $yN], [900, 520]], br => [ { dst => ['Fase c', 2] },
        { pts => [[900, 360]], br => [ { dst => ['Fase b', 2] }, { pts => [[900, 200]], dst => ['Fase a', 2] } ] } ] }),
  lazo_rapido();

# Scopes del nivel superior: cada eje es un vector armado en "Medidas"
my @ej_cab = (
  ['P_h por fase [W]',             [ map { ["P_h,$_", "lr_Ph_$_"] } @FASES ], 'vec_Ph'],
  ['e_phi [W]',                    [ map { ["e_$_",   "lr_e_$_"]  } @FASES ], 'vec_e'],
  ['Delta P_phi [W] (>0 inyecta)', [ map { ["dP_$_",  "lr_dP_$_"] } @FASES ], 'vec_dPphi'],
  ['u_phi = Delta P_phi / F_phi',  [ map { ["u_$_",   "lr_u_$_"]  } @FASES ], 'vec_u'],
  ['lambda_phi (precio de la fase)', [ map { ["lambda_$_", "lr_lam_$_"] } @FASES ], 'vec_lam']);
my @ej_mr = (
  ['P_IC [W] (>0 importa, prom. 1 ciclo)', [ map { ["MR $_", "${_}_icp_Pac"] } @IDS ], 'vec_Pic'],
  ['Delta P_k [W]',         [ map { ["MR $_", "${_}_dP"] } @IDS ],      'vec_dPk'],
  ['SOC [p.u.]',            [ map { ["MR $_", "${_}_pl_SOC"] } @IDS ],  'vec_SOC'],
  ['V_dc [V]',              [ map { ["MR $_", "${_}_pl_Vdc"] } @IDS ],  'vec_Vdc', [380, 420]],
  ['F_up [W]',              [ map { ["MR $_", "${_}_Fup"] } @IDS ],     'vec_Fup']);
push @top, medidas(map { [$_->[2], $_->[1]] } @ej_cab, @ej_mr),
  scope_('Cabecera', 1240, 530, @ej_cab),
  scope_('Micro-redes', 1240, 700, @ej_mr);

my $mrs = join(', ', map { "MR $_" } @IDS);
push @top,
  zona(40, 140, 260, 720, $COL{red}), zona(270, 140, 560, 720, $COL{red}),
  zona(580, 130, 940, 720, $COL{red}), zona(990, 170, 1300, 340, $COL{lazo}), zona(990, 370, 1300, 800, $COL{gris}),
  nota(520, 40, titulo('Alimentador BT 3F-4H con Micro-redes DC por fase', '#263238', 14),
       linea("$mrs &middot; modelo promedio &middot; generado con red_3F/generar_red.pl")),
  nota(150, 120, titulo('S/E 0,4 kV', $COL{red})),
  nota(415, 120, titulo('Cabecera y alimentador', $COL{red}), linea('i_h medida en la salida de la S/E')),
  nota(760, 110, titulo('Nodos de fase (PCC)', $COL{red}), linea('doble clic: carga y MR de la fase')),
  nota(150, 660, linea('<b>neutro</b>', $COL{red})),
  nota(1145, 150, titulo('Lazo r&aacute;pido', $COL{lazo}), linea('lee i_h &middot; escribe &Delta;P_k en cada IC')),
  nota(1145, 320, linea('par&aacute;metros: Lazo_ON, t_lr_on, Kp_lr, Ki_lr, beta_xy', $COL{lazo})),
  nota(1145, 385, titulo('Resultados', $COL{gris})),
  nota(470, 750, linea('Signos: P_h &gt; 0 la S/E entrega &middot; P_IC &gt; 0 el IC importa &middot; &Delta;P &gt; 0 la MR inyecta m&aacute;s'));

# -----------------------------------------------------------------------------
#  5. Comandos de inicializacion y escritura
# -----------------------------------------------------------------------------
my $ini = attr($PLECS, 'InitializationCommands');
my @extra = (
  '', '',
  '%% ---------- 10. RED TRIFASICA 4 HILOS: S/E Y ALIMENTADOR -------------',
  'phi_a = 0; phi_b = -2*pi/3; phi_c = 2*pi/3;   % secuencia positiva [rad]',
  'R_lin = 0.064;  L_lin = 0.05e-3;    % por fase: ~200 m de Al 95 mm2 [Ohm, H]',
  'R_neu = 0.064;  L_neu = 0.05e-3;    % neutro, misma seccion',
  '',
  '%% ---------- 11. CARGAS MONOFASICAS NO GESTIONADAS (desbalance base) ----',
  '%% Parte fija (resistencia R_nog) + parte variable (fuente de corriente Perfil carga).',
  'if Escenario == 1',
  '  P_nog_a = 3000; P_nog_b = 1500; P_nog_c = 800;   % constantes [W]',
  '  t_nog = [0 1e6];',
  '  Pnog_a_v = [P_nog_a P_nog_a]; Pnog_b_v = [P_nog_b P_nog_b]; Pnog_c_v = [P_nog_c P_nog_c];',
  'else',
  '  k_nog = [2.0 1.0 0.5];            % la fase a es la mas cargada todo el dia',
  '  aux = [Pld_h; Pld_h]; perfil_nog = [aux(:)\' Pld_h(end)];   % mismo perfil horario del hogar',
  '  t_nog = t_z;',
  '  Pnog_a_v = k_nog(1)*perfil_nog; Pnog_b_v = k_nog(2)*perfil_nog; Pnog_c_v = k_nog(3)*perfil_nog;',
  '  P_nog_a = min(Pnog_a_v); P_nog_b = min(Pnog_b_v); P_nog_c = min(Pnog_c_v);   % parte fija = minimo',
  'end',
  'R_nog_a = Vg_rms^2/P_nog_a; R_nog_b = Vg_rms^2/P_nog_b; R_nog_c = Vg_rms^2/P_nog_c;',
  's_carga = 1;      % signo de la fuente Perfil carga: si con Lazo_ON = 0 la punta de la tarde BAJA P_h, poner -1',
  '',
  '%% ---------- 12. LAZO RAPIDO POR FASE (PI + reparto opcion C) ----------',
  'Lazo_ON = 1;      % 0: IC siguen solo su plan P*',
  't_lr_on = 1.0;    % instante en que se activa [s]',
  'Ts_lr   = 1e-3;   % muestreo del lazo y de la envolvente [s]',
  'Kp_lr = 0.5;  Ki_lr = 5;   % tau ~ (1+Kp)/Ki = 0.3 s (validacion en tiempo real)',
  'Theta_h  = 4;     % duracion que debe sostener la potencia firme [h]',
  'P_ic_max = 5000;  % potencia nominal de cada IC [W]',
  '',
  '%% Respaldo de red (opcion b): si el SOC entra en [SOC_min + dS, SOC_min + 2dS] el IC importa',
  '%% en rampa hasta P_resp_max. Asi la BESS no pierde el bus y el SOC se detiene en la banda.',
  'Respaldo_ON = 1;  P_resp_max = P_ic_max;',
  '',
  '%% ---------- 13. PARAMETROS PROPIOS DE CADA MR ------------------------',
  '%% Por defecto copian el escenario. Solo la primera MR sigue el plan P*;',
  '%% las demas parten con plan nulo para que el desbalance venga de la red.',
);
push @extra, '%% La segunda MR de cada fase parte con menos SOC: asi F_k difiere y el reparto se nota.',
  'dSOC_2 = 0.25; if Escenario == 2, dSOC_2 = 0.10; end   % en el dia completo parte en 0.40 y llega a la manana';
my $primera = 1;
for my $id (@IDS) {
  my $plan = $primera ? 'P_ic' : '0*P_ic'; $primera = 0;
  my $soc = $id =~ /1$/ ? 'SOC_init' : 'SOC_init - dSOC_2';
  push @extra, "P_ic_$id = $plan;  t_ic_$id = t_ic;  P_ld_$id = P_ld;  t_ld_$id = t_ld;",
               "P_ev_$id = P_ev;  t_ev_$id = t_ev;  EV_c_$id = EV_c;  SOC_init_$id = $soc;  beta_$id = 0;";
}
die "Comillas dobles en la inicializacion: usa comillas simples\n" if grep { /"/ } @extra;
$ini .= join('\n', @extra) . '\n';
set_attr($PLECS, 'InitializationCommands', $ini, 1);
my $nombre_mod = $OUT; $nombre_mod =~ s{^.*[\x2F\x5C]}{}; $nombre_mod =~ s{\.plecs$}{};
set_attr($PLECS, 'Name', $nombre_mod, 1);

my @cab = grep { !($_->{c} && $_->{k} =~ /^(Component|Connection|Annotation|RectangleAnnotation)$/) } @{ $TOP->{c} };
$TOP->{c} = [ @cab, @top ];
ordenar($_) for @$ARB;
escribir($ARB, $OUT);
print "Escrito $OUT con ", scalar(@IDS), " MR: @IDS\n";
