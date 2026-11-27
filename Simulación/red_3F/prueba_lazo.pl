#!/usr/bin/perl
# prueba_lazo.pl - prueba fuera de PLECS de la logica de los C-Script (misma aritmetica).
# Planta simplificada: P_h,phi = P_nog,phi + P_IC,k ; el IC sigue su referencia con tau = 10 ms.
use strict; use warnings;
use List::Util qw(min max sum);

# --- 1. water-filling (copia de llenar) ---
sub llenar {
  my ($d, $f, $b) = @_; my $n = @$f;
  my ($lo, $hi) = (0, 0);
  for my $i (0 .. $n - 1) { $hi = 1 + $b->[$i] if 1 + $b->[$i] > $hi }
  for (1 .. 60) {
    my $mid = 0.5 * ($lo + $hi); my $s = 0;
    $s += min($f->[$_], $mid * $f->[$_] / (1 + $b->[$_])) for 0 .. $n - 1;
    if ($s < $d) { $lo = $mid } else { $hi = $mid }
  }
  return ($hi, [ map { min($f->[$_], $hi * $f->[$_] / (1 + $b->[$_])) } 0 .. $n - 1 ]);
}
print "== water-filling, ejemplo del documento (F = 2.5/0.5/0.5 kW, dP = 1.5 kW)\n";
for my $b ([0, 0, 0], [0, 0, 1]) {
  my ($l, $r) = llenar(1500, [2500, 500, 500], $b);
  printf "  beta = (%s): dP_k = %s  suma = %.1f  lambda = %.4f\n", join(',', @$b), join(' / ', map { sprintf '%.1f', $_ } @$r), sum(@$r), $l;
}
my ($l, $r) = llenar(3400, [2500, 500, 500], [0, 0, 1]);
printf "  dP = 3.4 kW (cerca de F_phi = 3.5): %s  suma = %.1f  lambda = %.3f\n", join(' / ', map { sprintf '%.1f', $_ } @$r), sum(@$r), $l;

# --- 2. lazo cerrado con una MR por fase ---
my ($Ts, $Kp, $Ki, $ton) = (1e-3, 0.5, 5, 1.0);
my %Pnog = (a => 3000, b => 1500, c => 800);
my ($Pbmax, $Picmax, $Ebat, $eta, $socmin, $socmax, $Th) = (5000, 5000, 21060, 0.95, 0.10, 0.90, 4);
my @F = qw(a b c);
my %plan = map { $_ => 0 } @F; my %Pic = map { $_ => 0 } @F;    # P_IC > 0 importa
my %X = map { $_ => 0 } @F; my %dPk = map { $_ => 0 } @F;
my %buf = map { $_ => [ (0) x 20 ] } @F; my %sum = map { $_ => 0 } @F; my $idx = 0;
my %Fu = map { $_ => 0 } @F; my %Fd = map { $_ => 0 } @F;
my $soc = 0.60;
printf "\n== lazo cerrado (Kp = %.1f, Ki = %.0f, activo desde t = %.1f s)\n", $Kp, $Ki, $ton;
printf "%6s | %7s %7s %7s | %7s %7s %7s | %6s %6s %6s\n", 't [s]', 'P_h,a', 'P_h,b', 'P_h,c', 'dP_a', 'dP_b', 'dP_c', 'u_a', 'u_b', 'u_c';
for my $n (0 .. 3400) {
  my $t = $n * $Ts;
  $plan{a} = $t >= 3.0 ? -1000 : $t >= 2.0 ? 3000 : 0;
  my %Ph; $Ph{$_} = $sum{$_} / 20 for @F;                 # salida del promedio movil (sin paso directo)
  my %u;
  for my $f (@F) {
    my $e = $Ph{$f} - ($Ph{a} + $Ph{b} + $Ph{c}) / 3;
    my $act = $t >= $ton;
    my $v = $act ? $Kp * $e + $X{$f} : 0;
    my $dp = max(-$Fd{$f}, min($Fu{$f}, $v));
    $dPk{$f} = $dp;                                         # una MR por fase: reparto = saturacion
    $u{$f} = $dp > 0 ? ($Fu{$f} ? $dp / $Fu{$f} : 0) : ($Fd{$f} ? $dp / $Fd{$f} : 0);
    if ($act) { $X{$f} += $Ki * $Ts * $e; $X{$f} = max(-$Fd{$f}, min($Fu{$f}, $X{$f})) } else { $X{$f} = 0 }
  }
  if ($n % 200 == 0 || $n == 3400) {
    printf "%6.2f | %7.0f %7.0f %7.0f | %7.0f %7.0f %7.0f | %6.2f %6.2f %6.2f\n", $t, @Ph{@F}, @dPk{@F}, @u{@F};
  }
  # planta: IC con primer orden, y envolvente (un paso de retardo, como en el C-Script)
  for my $f (@F) {
    my $ref = $plan{$f} - $dPk{$f};
    $Pic{$f} += ($ref - $Pic{$f}) * $Ts / 0.010;
    my $pb = -$Pic{$f} - 250;                              # la BESS cubre lo que exporta el IC (carga base 250 W)
    my $pb_plan = $pb - $dPk{$f}; my $iny_plan = -$Pic{$f} - $dPk{$f};
    $Fu{$f} = max(0, min(min($Pbmax - $pb_plan, $Picmax - $iny_plan), ($soc - $socmin) * $Ebat * $eta / $Th));
    $Fd{$f} = max(0, min(min($Pbmax + $pb_plan, $Picmax + $iny_plan), ($socmax - $soc) * $Ebat / $eta / $Th));
    my $p = $Pnog{$f} + $Pic{$f};
    $sum{$f} += $p - $buf{$f}[$idx]; $buf{$f}[$idx] = $p;
  }
  $idx = ($idx + 1) % 20;
}
printf "\nF_up = %.0f W, F_dn = %.0f W por MR (SOC = %.2f, Theta = %d h)\n", $Fu{a}, $Fd{a}, $soc, $Th;
