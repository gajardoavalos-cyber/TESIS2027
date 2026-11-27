param([string]$Entrada, [string]$Salida, [double]$Escala = 1.0)
# Dibuja la lista de figuras de vista.pl en un PNG (solo para revisar el orden del esquema)
Add-Type -AssemblyName System.Drawing
$lin = Get-Content -Encoding UTF8 $Entrada
$maxX = 400; $maxY = 300
foreach ($l in $lin) {
  $c = $l -split "`t"
  if ($c[0] -eq 'BOX') { $maxX = [Math]::Max($maxX, [double]$c[3]); $maxY = [Math]::Max($maxY, [double]$c[4]) }
  if ($c[0] -eq 'RECT') { $maxX = [Math]::Max($maxX, [double]$c[1] + [double]$c[3] / 2); $maxY = [Math]::Max($maxY, [double]$c[2] + [double]$c[4] / 2) }
  if ($c[0] -eq 'TEXT') { $maxX = [Math]::Max($maxX, [double]$c[1] + 150); $maxY = [Math]::Max($maxY, [double]$c[2] + 20) }
}
$W = [int](($maxX + 60) * $Escala); $H = [int](($maxY + 60) * $Escala)
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.ScaleTransform($Escala, $Escala)
$g.Clear([System.Drawing.Color]::White)
$fuente = New-Object System.Drawing.Font 'Segoe UI', 7
$fuenteT = New-Object System.Drawing.Font 'Segoe UI', 8
$penCaja = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(90, 90, 90)), 1
$penSig = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(30, 90, 200)), 1
$penCab = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(20, 20, 20)), 1.6
$br = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(70, 70, 70))
foreach ($l in $lin) {
  $c = $l -split "`t"
  switch ($c[0]) {
    'RECT' {
      $col = [System.Drawing.Color]::FromArgb([int]([int64]$c[5] -band 0xFFFFFF) -bor 0xFF000000)
      $p = New-Object System.Drawing.Pen $col, 2
      $g.DrawRectangle($p, [float]([double]$c[1] - [double]$c[3] / 2), [float]([double]$c[2] - [double]$c[4] / 2), [float]$c[3], [float]$c[4])
    }
    'BOX' {
      $x1 = [double]$c[1]; $y1 = [double]$c[2]; $x2 = [double]$c[3]; $y2 = [double]$c[4]
      $g.DrawRectangle($penCaja, [float]$x1, [float]$y1, [float]($x2 - $x1), [float]($y2 - $y1))
      $nom = $c[6]; if ($nom.Length -gt 26) { $nom = $nom.Substring(0, 26) }
      if ($c[5] -notin @('Goto', 'From', 'SignalMux', 'SignalDemux')) { $g.DrawString($nom, $fuente, $br, [float]$x1, [float]($y2 + 1)) }
      else { $g.DrawString($nom.Substring(0, [Math]::Min(12, $nom.Length)), $fuente, $br, [float]$x1, [float]($y1 - 10)) }
    }
    'LINE' {
      $pts = $c[2] -split ' ' | ForEach-Object { $q = $_ -split ','; New-Object System.Drawing.PointF ([float]$q[0]), ([float]$q[1]) }
      $pen = if ($c[1] -eq 'Wire') { $penCab } else { $penSig }
      if ($pts.Count -ge 2) { $g.DrawLines($pen, [System.Drawing.PointF[]]$pts) }
    }
    'TEXT' {
      $col = [System.Drawing.ColorTranslator]::FromHtml($c[3])
      $b = New-Object System.Drawing.SolidBrush $col
      $t = $c[4]; $sz = $g.MeasureString($t, $fuenteT)
      $g.DrawString($t, $fuenteT, $b, [float]([double]$c[1] - $sz.Width / 2), [float]([double]$c[2] - $sz.Height / 2))
    }
  }
}
$bmp.Save($Salida, [System.Drawing.Imaging.ImageFormat]::Png)
"ok $Salida ${W}x${H}"
