# Red 3F-4H con Micro-redes por fase

`../Red_3F_MR_por_fase.plecs` es el modelo nuevo: S/E de 0,4 kV, alimentador BT de 4 hilos, una carga monofásica no gestionada por fase y una Micro-red (MR a1, b1, c1) colgada de cada fase a través de su IC. Encima corre el lazo rápido: PI por fase más el reparto de la opción C.

No lo he abierto en PLECS (no está instalado en este PC). Pasó el verificador estructural y la lógica del lazo se probó aparte (sección 5).

## 1. Cómo está ordenado

| Nivel | Qué hay | Color del recuadro |
|---|---|---|
| Superior | S/E, medición en cabecera (i_h), alimentador R-L por fase y neutro, bloques `Fase a/b/c`, `Lazo rapido`, `Medidas` y dos scopes | gris azulado: red · verde: lazo rápido |
| `Fase a` | barra de la fase y neutro, carga no gestionada `R_nog_a`, voltímetro del PCC y las MR de la fase | — |
| `MR a1` | tu MR de `MicroRed_ACDC_IC.plecs` sin cambios de control, más tres agregados (abajo) | naranjo: plan · verde: envolvente |
| `Lazo rapido` | medición P_h por fase (promedio de un ciclo) y un C-Script por fase: PI + reparto | gris: medición · verde: PI y reparto |

Lo que cambió dentro de cada MR respecto de tu archivo:

1. **La red de 50 Hz salió del IC.** La fuente `Red fase a` y la tierra interna se reemplazaron por los bornes `L` y `N`, que llegan a la fase de la S/E. La tierra queda solo en la S/E.
2. **Entrada `dP_k`.** El primario del IC recibe `P*_IC = P* − ΔP_k`. ΔP_k > 0 significa que la MR inyecta más a la fase. Ojo con el signo: en tu archivo P_IC > 0 es importar.
3. **Bloque `Envolvente F_k`.** Calcula F↑ y F↓ = min(Π, W/Θ) con el SOC, P_bat, P_IC y ΔP_k de la propia MR, y los publica con los tags `a1_Fup` y `a1_Fdn`. Tiene un paso de retardo (Ts_lr) para que no forme un lazo algebraico con el reparto.

Todos los tags de la MR llevan el prefijo de su id (`a1_pl_SOC`, `b1_top_Pic`, etc.). Las anotaciones se reescribieron más cortas y por nivel, con el código de colores de la tesis.

## 2. Parámetros nuevos (Initialization, secciones 10 a 13)

| Variable | Valor | Para qué |
|---|---|---|
| `R_lin`, `L_lin`, `R_neu`, `L_neu` | 0,064 Ω · 0,05 mH | ~200 m de Al 95 mm² |
| `P_nog_a/b/c` | 3000 / 1500 / 800 W | desbalance base |
| `Lazo_ON`, `t_lr_on` | 1 · 1,0 s | activa el lazo rápido |
| `Kp_lr`, `Ki_lr`, `Ts_lr` | 0,5 · 5 · 1 ms | τ ≈ 0,3 s, para que quepa en 3,4 s de tiempo real |
| `Theta_h`, `P_ic_max` | 4 h · 5 kW | potencia firme de cada MR |
| `P_ic_a1`, `t_ic_a1`, `SOC_init_a1`, `beta_a1`… | copia del escenario | perfiles propios de cada MR |

Por defecto solo `MR a1` sigue el plan del escenario 1 (importa 3 kW a los 2,0 s y exporta 1 kW a los 3,0 s). `MR b1` y `MR c1` parten con plan nulo, así que el desbalance inicial viene solo de las cargas no gestionadas.

## 3. Cómo validarlo (orden sugerido)

1. **Sin lazo (`Lazo_ON = 0`).** Cada IC debe seguir su plan y en el scope `Cabecera` debe verse P_h ≈ P_nog + P_IC por fase: 3000 / 1500 / 800 W antes de los 2,0 s y 6000 W en la fase a después. Dentro de cada MR, el scope `Scope - IC lado DC y AC` debe dar P_ac ≈ P_dc.
2. **Con lazo (`Lazo_ON = 1`).** Desde t = 1,0 s las tres P_h deben juntarse cerca de 1770 W (la media), con ΔP_a > 0 y ΔP_b, ΔP_c < 0.
3. **Saturación.** A los 2,0 s la fase a pide más de lo que MR a1 puede dar en 4 h. ΔP_a debe quedar plano en F↑ (u_a = 1) sin que el integrador se dispare. Al volver a −1 kW, a los 3,0 s, sale de saturación sin sobrepaso grande.
4. **Más MR por fase y opción 4.** Ver sección 4.

## 4. Agregar Micro-redes

Desde Git Bash, en esta carpeta:

```
perl generar_red.pl                 # a1 b1 c1
perl generar_red.pl a1 a2 b1 c1     # dos MR en la fase a
perl verificar.pl ../Red_3F_MR_por_fase.plecs
```

- El reparto ya es la opción C completa para N MR: water-filling con cotas F_k y pesos F_k/(1+β_k), por bisección. Con una MR por fase se reduce a saturar ΔP_φ.
- Los β de cada MR son `beta_a1`, `beta_a2`… en la sección 13. Con β = 0 el reparto es la opción B.
- **La plantilla es `MicroRed_ACDC_IC.plecs`.** Si cambias la MR, cámbiala ahí y vuelve a generar. Los cambios hechos a mano en las copias `MR xy` del archivo generado se pierden al regenerar. Los perfiles y β propios se editan en Initialization del archivo generado; si quieres conservarlos entre regeneraciones, dímelo y los paso a un archivo aparte.

## 5. Qué está comprobado y qué no

**Comprobado aquí:**
- Al leer y reescribir tu archivo, el generador no cambia nada de su contenido; solo puede cortar las líneas largas en otro punto.
- `verificar.pl`:
  - todas las conexiones apuntan a bloques y terminales existentes;
  - ninguna entrada queda sin conectar ni con dos fuentes;
  - cada From tiene un único Goto;
  - los índices de puertos calzan con los terminales de cada subsistema;
  - no hay variables sin definir.
- `prueba_lazo.pl` reproduce en Perl la aritmética de los C-Script con una planta simplificada (IC de primer orden con τ = 10 ms):
  - el water-filling da 1071 / 214 / 214 W para el ejemplo del documento;
  - el lazo lleva 3000 / 1500 / 800 W a ≈ 1790 / 1760 / 1750 W en 1 s;
  - la fase a satura en F↑ = 2,5 kW.

**No comprobado (lo primero que hay que mirar al abrirlo):**
1. **API de los C-Script.** Uso `ParamRealData(0,j)`, `CurrentTime`, `DiscState(i)` e `InputSignal(0,i)`. Los parámetros van como un solo vector `[...]`. Si PLECS reclama al compilar, el mensaje dirá la línea.
2. **`PeriodicAverage` de tu IC.** El verificador marca que en tu archivo la señal entra por el terminal 2 de `Promedio 1 ciclo (P)` y `(Q)`. Si tu archivo ya corría, ignóralo. Si no, ahí está el error, y no lo toqué. El lazo rápido no usa ese bloque: P_h se calcula con su propio C-Script.
3. **Rectángulos de color.** Usé el formato `RectangleAnnotation` de tu archivo, solo con borde (sin relleno). Si el color no aparece, es cosmético.
4. **Geometría.** Las posiciones de terminales de Mux, Scope y Demux las deduje de tus archivos. Si un cable queda en diagonal, es solo dibujo: la conexión está bien.

## 6. Archivos de esta carpeta

| Archivo | Qué hace |
|---|---|
| `generar_red.pl` | arma el modelo a partir de la plantilla |
| `plecs_io.pm` | lee y escribe el formato .plecs |
| `verificar.pl` | revisión estructural de cualquier .plecs |
| `verificar_formato.pl` | compara el orden de bloques y atributos con tus archivos que PLECS ya abrió |
| `prueba_lazo.pl` | prueba de la lógica del lazo fuera de PLECS |
| `vista.pl` + `dibujar_vista.ps1` | dibujo aproximado de un nivel del esquema en PNG, para revisar el orden sin PLECS |

## 7. Día completo (escenario 2)

En *Simulation › Simulation Parameters › Initialization*, cambia `Escenario = 1;` por `Escenario = 2;`. No hay que tocar nada más: `TimeSpan` ya vale `Tsim`, que pasa a ser 24 s.

- **Compresión:** 1 s simulado = 1 h. Solo se comprime la energía (κ = 3600 en el SOC). La red de 50 Hz, el PR y el lazo rápido siguen en tiempo real.
- **Por qué no 86 400 s reales:** el modelo tiene 50 Hz y controles a 15 kHz, así que un día real son unos 1300 millones de pasos de control.
- **Qué cambia en el escenario 2:**
  - La carga no gestionada sigue el perfil horario del hogar: ×2,0 en la fase a, ×1,0 en la b y ×0,5 en la c. Las puntas son de 3,5 / 1,8 / 0,9 kW a las 20 h.
  - MR a1 sigue el plan `Pic_h`.
  - El SOC se mueve, así que F_k cambia durante el día.
- **Antes de mirar el lazo, revisa el signo de la carga variable:** con `Lazo_ON = 0`, P_h,a tiene que **subir** en la punta de 19–22 h. Si baja, pon `s_carga = -1`.
- **Tiempo de cómputo:** tarda unas 7 veces lo que el escenario 1, porque son 24 s contra 3,4 s.
- **Lectura del lazo:** con `Ki_lr = 5`, la constante τ ≈ 0,3 s equivale a 18 min del día. Si quieres que se vea como instantáneo a escala diaria, usa `Ki_lr = 15` (τ ≈ 0,1 s).
- **Dinámica:** los transitorios pesan 3600 veces más en el SOC. Evalúa la dinámica en el escenario 1 y usa el 2 para la energía.

## 8. Dos MR por fase

`../Red_3F_2MR_por_fase.plecs` se genera con:

```
perl generar_red.pl -o ../Red_3F_2MR_por_fase.plecs a1 a2 b1 b2 c1 c2
```

La segunda MR de cada fase parte con 0,25 menos de SOC (0,35 en el escenario 1), así que tiene otra F_k y el reparto se nota: F↑ = 2,5 / 1,25 kW y F↓ = 1,66 / 3,05 kW. Las cifras esperadas salen de `perl prueba_lazo_N.pl 0.60 0.35`.

## 9. Respaldo de red (opción b) y otros ajustes del 27-nov

- **Consigna del IC:** P*_IC = sat(P* − ΔP_k + P_resp), limitada a ±P_ic_max.
  - P_resp sube en rampa de 0 a `P_resp_max` cuando el SOC baja de SOC_min + 2dS (0,16) a SOC_min + dS (0,13).
  - El IC importa antes de que el secundario corte la descarga de la BESS (0,13 → 0,10), así el bus nunca se queda sin quien lo forme.
  - Desactivar con `Respaldo_ON = 0`.
- **P_IC del scope y de la envolvente:** ahora es la potencia AC promediada en un ciclo (`icp_Pac`), sin la banda de 100 Hz.
- **SOC inicial de la segunda MR de cada fase:** −0,25 en el escenario 1 y −0,10 en el escenario 2 (`dSOC_2`).
- **Eje V_dc** del scope `Micro-redes`: fijo en 380–420 V.

## 10. Agregar o quitar MR por fase

**No copies y pegues bloques MR en PLECS.** Una MR no es autocontenida:
- Sus ~90 tags llevan el prefijo de su id (`a1_…`): una copia repite tags y PLECS da error.
- El lazo de cada fase tiene anchos fijos: el Mux de entrada, el C-Script (NumInputs, NumOutputs, Parameters con N y los β), el Demux y los Goto de ΔP_k.
- Medidas, scopes y la inicialización (perfiles, `SOC_init_xy`, `beta_xy`) dependen de la lista de MR.

Se hace regenerando, desde Git Bash en esta carpeta:

```
perl generar_red.pl -o ../Red_3F_prueba.plecs a1 a2 a3 b1 c1 c2
```

- Cada fase necesita al menos una MR.
- Los ids son fase + número (a1, a2, …). Pueden saltarse números: `a1 a3` es válido.
- Después, en Initialization del archivo nuevo, ajusta los parámetros propios (`P_ic_xy`, `SOC_init_xy`, `beta_xy`).

## 11. Plantilla de dibujo (tu orden de la MR)

`plantilla_dibujo.plecs` es tu `Red_3F_MR_por_fase.plecs` tal como lo guardaste el 27-nov a las 16:57, con la MR a1 y la Fase a reordenadas a mano.

Si ese archivo existe, el generador lo usa solo:
- **Todas las MR** se copian desde tu MR a1: bloques, posiciones, tamaños, scopes, anotaciones y cables. Solo cambian el id, los tags y las variables propias.
- **Las fases con una sola MR** se copian desde tu Fase a, cambiando la letra de la fase.
- **Las fases con dos o más MR** usan la disposición del generador para la barra y las cargas, porque tu dibujo es para una MR. Las MR adentro sí son tu dibujo.

Para cambiar el orden:
1. Edita la MR a1 o la Fase a en PLECS.
2. Guarda el archivo.
3. Cópialo sobre `plantilla_dibujo.plecs`.
4. Vuelve a generar.

Otra opción es indicar el archivo con `-p`: `perl generar_red.pl -p ../otro.plecs …`.

Antes de regenerar sobre tu archivo quedó un respaldo: `../Red_3F_MR_por_fase_respaldo_1702.plecs`.
