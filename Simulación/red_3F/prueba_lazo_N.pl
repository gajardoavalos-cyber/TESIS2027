#!/usr/bin/perl
# prueba_lazo_N.pl - igual que prueba_lazo.pl pero con N MR por fase y reparto water-filling.
#   perl prueba_lazo_N.pl 0.60 0.35     (SOC inicial de la 1a y 2a MR de cada fase)
use strict; use warnings; use List::Util qw(min max sum);
my @soc0 = @ARGV ? @ARGV : (0.60, 0.35);
my $N = @soc0;
sub llenar { my ($d,$f,$b)=@_; my ($lo,$hi)=(0,0); $hi=max($hi,1+$_) for @$b;
  for (1..60){ my $m=($lo+$hi)/2; my $s=0; $s+=min($f->[$_],$m*$f->[$_]/(1+$b->[$_])) for 0..$#$f; if($s<$d){$lo=$m}else{$hi=$m} }
  return [ map { min($f->[$_],$hi*$f->[$_]/(1+$b->[$_])) } 0..$#$f ]; }
my ($Ts,$Kp,$Ki,$ton)=(1e-3,0.5,5,1.0); my %Pnog=(a=>3000,b=>1500,c=>800);
my ($Pbmax,$Picmax,$Ebat,$eta,$smin,$smax,$Th)=(5000,5000,21060,0.95,0.10,0.90,4);
my @F=qw(a b c); my (%Pic,%dP,%Fu,%Fd,%X,%buf,%sum); my $idx=0;
for my $f (@F){ $X{$f}=0; $buf{$f}=[(0)x20]; $sum{$f}=0; for my $k (0..$N-1){ $Pic{$f}[$k]=0; $dP{$f}[$k]=0; $Fu{$f}[$k]=0; $Fd{$f}[$k]=0 } }
printf "%5s |%7s %7s %7s |%s\n",'t','P_h,a','P_h,b','P_h,c', join('', map { my $f=$_; map { sprintf "%7s", "dP_$f".($_+1) } 0..$N-1 } @F);
for my $n (0..3400){ my $t=$n*$Ts;
  my $plan_a1 = $t>=3.0 ? -1000 : $t>=2.0 ? 3000 : 0;
  my %Ph; $Ph{$_}=$sum{$_}/20 for @F;
  for my $f (@F){ my $e=$Ph{$f}-sum(values %Ph)/3; my $act=$t>=$ton; my $fu=sum(@{$Fu{$f}}); my $fd=sum(@{$Fd{$f}});
    my $dp=$act? max(-$fd,min($fu,$Kp*$e+$X{$f})):0;
    $dP{$f} = $dp>0 ? llenar($dp,$Fu{$f},[(0)x$N]) : $dp<0 ? [ map {-$_} @{llenar(-$dp,$Fd{$f},[(0)x$N])} ] : [(0)x$N];
    if($act){ $X{$f}=max(-$fd,min($fu,$X{$f}+$Ki*$Ts*$e)) } else { $X{$f}=0 } }
  printf "%5.1f |%7.0f %7.0f %7.0f |%s\n",$t,@Ph{@F}, join('', map { my $f=$_; map { sprintf "%7.0f",$dP{$f}[$_] } 0..$N-1 } @F) if $n%200==0 && $n>=800 || $n==3400;
  for my $f (@F){ my $p=$Pnog{$f};
    for my $k (0..$N-1){ my $plan = ($f eq 'a' && $k==0) ? $plan_a1 : 0; my $d=$dP{$f}[$k];
      $Pic{$f}[$k] += ($plan-$d-$Pic{$f}[$k])*$Ts/0.010; $p += $Pic{$f}[$k];
      my $pb=-$Pic{$f}[$k]-250; my $pbp=$pb-$d; my $inp=-$Pic{$f}[$k]-$d; my $s=$soc0[$k];
      $Fu{$f}[$k]=max(0,min($Pbmax-$pbp,$Picmax-$inp,($s-$smin)*$Ebat*$eta/$Th));
      $Fd{$f}[$k]=max(0,min($Pbmax+$pbp,$Picmax+$inp,($smax-$s)*$Ebat/$eta/$Th)); }
    $sum{$f}+=$p-$buf{$f}[$idx]; $buf{$f}[$idx]=$p; }
  $idx=($idx+1)%20; }
printf "F_up por MR: %s W | F_dn por MR: %s W\n", join(' / ', map { sprintf '%.0f',$Fu{a}[$_] } 0..$N-1), join(' / ', map { sprintf '%.0f',$Fd{c}[$_] } 0..$N-1);
