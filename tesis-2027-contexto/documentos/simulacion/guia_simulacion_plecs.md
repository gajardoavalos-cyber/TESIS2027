# Guía de simulación PLECS: Micro-red DC con control primario y secundario

Nov 11, 2026 · @Felipe Salvador Gajardo Ávalos

## Qué se entrega y cómo usarlo

El archivo `MicroRed_DC_Validacion.plecs` simula una Micro-red DC residencial de 400 V. Tiene FV, BESS, cargador EV, carga y el IC visto desde su lado DC. Incluye control primario y secundario, y trae dos escenarios listos para el lunes 16.

| Archivo | Para qué sirve |
| --- | --- |
| `MicroRed_DC_Validacion.plecs` | Modelo PLECS, con formato 5.0 igual al de `Convertidor_DC.plecs`. No necesita `PPV.csv`, porque los datos de irradiancia y temperatura van dentro del archivo. |
| `referencia_microred_dc.py` | Modelo de referencia en Python con las mismas ecuaciones, parámetros y PI discretos. Genera las curvas esperadas de esta guía. |
| `verificar_plecs.py` | Verificador estructural del `.plecs`: revisa llaves, conexiones, terminales, Goto/From y variables definidas. |

**Cómo correrlo, paso a paso:**

1. Abre `MicroRed_DC_Validacion.plecs` en PLECS Standalone 5.0.
2. Ve a *Simulation › Simulation Parameters › Initialization*. Al inicio del texto están `Escenario = 1;` y `Mes = 1;`.
3. Con `Escenario = 1` corres la validación dinámica: 3,4 s de tiempo real con siete eventos. Con `Escenario = 2` corres un día comprimido de 24 s, donde 1 s equivale a 1 h.
4. Pulsa *Run* (Ctrl+T). Los tres scopes están a la derecha del nivel superior: *MR a1 vista desde la fase*, *Control primario y secundario* y *FV*.
5. Con doble clic en cualquiera de los seis bloques ves su interior. La sección *Mapa del archivo* recorre cada uno.

**Estructura del archivo:** es la misma disposición de tu lámina de niveles. Arriba está la banda de controladores: `Secundario MR a1`, `Primario DER (droop)` y `Primario IC (g-f)`, más la consigna P\*. Abajo está la planta: `MR a1: PV - BESS - EV - carga` y, fuera de ella, el `IC`, unido al bus DC por los bornes DC+ y DC−. La fase a de la S/E no se modela; el IC es la puerta hacia ella.

**Advertencia honesta:** no pude abrir el archivo en PLECS, porque este entorno no lo tiene. Lo armé copiando la sintaxis de tus dos archivos y pasó el verificador estructural. También corrí los comandos de inicialización en Octave y comparé cada expresión de bloque contra el modelo de referencia. Si PLECS reclama al abrirlo, el mensaje nombrará el bloque; mándamelo y lo corrijo (sección *Limitaciones*).

## Lo que pidió el profesor y dónde se ve en la simulación

La simulación responde al paso que Espina aprobó el 9 de noviembre: validar una Micro-red DC con su primario y su secundario, y dejar lista su conexión a la red. También muestra en el modelo varias ideas de su correo del 10 de noviembre. La tabla dice qué mostrar para cada pedido.

| Lo que pidió | Dónde está en el modelo | Qué mostrar |
| --- | --- | --- |
| Validar una Micro-red DC con primario y secundario (9 nov) | `MR a1`, `Primario DER (droop)` y `Secundario MR a1` | Escenario 1, t = 0,8 a 1,6 s. Solo con primario, el bus queda 4,4 V bajo 400 V y BESS y EV se reparten el escalón. Con el secundario, vuelve a 400 V en ≈ 0,2 s |
| Después, su conexión a la red (9 nov) | El `IC`, fuera de la MR, unido por DC+ y DC−; su lado AC es el paso siguiente | Escenario 1, t = 2,0 y 3,0 s: P\_IC sigue la consigna (importa 3 kW, luego exporta 1 kW) y el bus no se cae |
| El IC es el único que inyecta en la fase; los DER solo ven su bus DC (correo, punto 1) | Solo el `IC` tiene la puerta hacia la fase. Los DER cuelgan del bus y no tienen ninguna señal de la cabecera | Mostrar el nivel superior: la única flecha hacia la fase sale del IC |
| El secundario restaura la tensión y reparte el cambio del IC entre sus DER, sin saber del desbalance (correo, punto 1) | `Secundario MR a1` solo recibe V\_dc y SOC | En t = 2,0 y 3,0 s, el IC cambia y la BESS absorbe la diferencia. dV se ajusta y V\_dc vuelve a 400 V, sin comunicación con el IC |
| El lazo rápido no debe comunicarse con secundarios ni DER (correo, punto 1) | `Primario IC (g-f)` solo recibe P\* y sus propias medidas | Ahí entrará la corrección del lazo rápido: P\_ref = P\* + ΔP. No hay ninguna flecha entre el IC y el secundario |
| El rango de SoC como reserva que asigna el terciario (correo, punto 2) | `SOC_min`, `SOC_max` y `dS` en el secundario | Escenario 2: el recorte FV mantiene el SOC dentro de la banda. Hoy la banda es fija; después la entregará el terciario |
| Cada MR informa al terciario lo que puede ofrecer (correo, punto 3) | Salidas de la MR: P\_IC, SOC, V\_dc y potencias | Ejercicio con `Pic_h` en ceros: sin red, el SOC llega al mínimo de noche. Ese límite es la envolvente que la MR debe informar |
| Lazo rápido por fase (correo, punto 4) | No está en esta simulación | Es el paso siguiente, junto con el lado AC del IC y las tres fases |

**Para el lunes 16, además de la simulación, el correo pide tres cosas:** la diapo de niveles actualizada (qué mide, decide e informa cada nivel), la formulación del terciario (objetivo, envolvente y reserva) y la regla del lazo rápido. Esta simulación respalda la diapo de niveles: el nivel superior del archivo es esa misma diapo, con el primario y el secundario funcionando.

## Ruta de estudio

Son unas dos horas, en este orden, con PLECS abierto al lado:

1. **Arquitectura y Mapa del archivo** (20 min). Abre el archivo y compara el nivel superior con el diagrama de las dos bandas. Entra a cada uno de los seis bloques y ubícalos en la tabla «Dentro de cada bloque».
2. **Qué viaja por cada flecha** (10 min). Recorre una flecha completa: por ejemplo, refs. sale del `Mux` final del secundario y entra al `Demux` del primario DER.
3. **Paso 1 y Paso 3** (30 min). Sigue la cadena i\* → PI de corriente → feedforward → fuente promedio en una fila del `Primario DER (droop)`. Después, por qué la BESS lleva droop sin integrador y por qué el bus tiene 4,7 mF.
4. **Paso 4** (20 min). La restauración con dV y las cuatro rampas de SOC.
5. **Corre el escenario 1** (20 min). Mira el scope *Control primario y secundario* y compáralo con la tabla de eventos del Paso 5 y la figura de referencia. Detén la vista en t = 0,8–1,6 s: es la diapositiva más importante.
6. **Corre el escenario 2** (10 min). Mira el SOC y el recorte FV.
7. **Lo que pidió el profesor y Guion** (15 min). Ensaya la frase de entrada y las respuestas cortas.

Si un resultado no calza con la referencia, revisa primero el escenario elegido y los valores de `Escenario` y `SOC_init` en Initialization. Después, mira la sección *Limitaciones, riesgos al abrir en PLECS*.

## Arquitectura modelada y supuestos

Se modela una sola Micro-red DC, la de una fase, tal como pidió el profesor Espina el 9 de noviembre. Es la primera parte: validar primario y secundario de una Micro-red y luego su conexión a la red. Las tres fases, la cabecera y el lazo rápido vienen después.

&#91;embedded content: Micro-red DC modelada · 5 convertidores, 1 bus, secundario local\]

Solo la BESS fija la tensión. El IC recibe su potencia del terciario, y el secundario se entera de ese cambio únicamente por V\_dc.

Cinco convertidores cuelgan de un mismo bus de 400 V, cada uno con un rol distinto:

| Recurso | Rol en el control primario | Qué sigue |
| --- | --- | --- |
| BESS | **Forma el bus** (grid-forming DC) mediante droop V–I | V₀ + δV − R\_d·i |
| Cargador EV | Sigue su potencia de carga y aporta droop transitorio (opcional, `Modo_EV`) | P\_EV\* + droop |
| FV | Sigue la potencia MPPT (seguidor) | k\_rec·P\_disp |
| Carga activa | Potencia constante según perfil | P\_carga\* |
| IC monofásico | **Grid-following**: inyecta el plan del terciario, como se acordó el 9 nov | P\_IC\* |

**Convención de signos (la misma en todo el modelo):** toda potencia es positiva cuando **entra** al bus DC. Por eso P\_FV > 0 significa que genera y P\_BESS > 0 que descarga. P\_EV < 0 significa que el EV carga y P\_carga < 0 que consume. P\_IC > 0 significa que la red AC entrega energía al bus (importa).

**Supuestos:**

- **Modelo promedio, no conmutado**, en línea con tu estrategia de partir por modelos promedio. Cada convertidor es una fuente de tensión controlada (el promedio de d·V\_in) en serie con R\_l y L. Es la misma planta de `Convertidor_DC.plecs`.
- **La fase de la S/E no se modela.** El IC se modela solo por su lado DC: inyecta en el bus la corriente P\*/V\_dc. P\_IC es la potencia que intercambiaría con la fase a. Eso basta para validar la Micro-red y deja el IC listo como puerta hacia la red.
- **Sin pérdidas de conmutación.** Solo hay pérdidas óhmicas en R\_l y la eficiencia de la BESS, η\_c = η\_d = 0,95.
- **Tensión de batería constante.** El SOC se calcula por balance de energía, sin curva OCV–SOC.
- **El secundario es uno por Micro-red y no ve la cabecera.** Solo mide su V\_dc y el SOC, como se definió en la lámina de niveles.

## Mapa del archivo: bloque por bloque

El nivel superior reproduce la lámina de niveles del 9 de noviembre. Arriba está la banda **CONTROLADORES** (secundario, primario de los DER y primario del IC). Abajo está la **PLANTA**: la Micro-red MR a1 y, fuera de ella, su IC. Las flechas entre bloques son las mismas de la lámina: refs., PWM, v, i, V\_dc y SOC. Con doble clic en un bloque ves su interior. Los nombres en `código` son los de los bloques en PLECS.

&#91;embedded content: Jerarquía del archivo PLECS · 3 niveles\]

### Nivel superior: seis bloques y sus flechas

| Bloque | Banda | Qué hace | Entra (de dónde) | Sale (a dónde) |
| --- | --- | --- | --- | --- |
| `Consigna P* (IC)` | Terciario | Perfil de la potencia que se le pide al IC (`t_ic`, `P_ic`) | Reloj | P\* → `Primario IC (g-f)` y scope |
| `Secundario MR a1` | Controladores | Restaura V\_dc y cuida los límites de SOC | V\_dc, SOC ← planta | refs. → `Primario DER (droop)` |
| `Primario DER (droop)` | Controladores | Calcula i\* de FV, BESS, EV y carga y la impone con su PI de corriente | refs. ← secundario; v, i ← planta | PWM (4 tensiones de mando) → planta |
| `Primario IC (g-f)` | Controladores | Sigue P\*: i\* = P\*/V\_dc, más su PI de corriente | P\* ← consigna; V\_dc, i\_IC ← IC | PWM IC → `IC` |
| `MR a1: PV - BESS - EV - carga` | Planta | Etapas de potencia de los cuatro DER, bus DC y recursos (panel FV, batería, perfiles) | PWM ← primario DER | v, i → primario DER; V\_dc, SOC → secundario; potencias → scope; bornes DC+ y DC− → IC |
| `IC` | Planta | Etapa de potencia del IC, lado DC | PWM IC ← primario IC; bornes DC+ y DC− ← MR | V\_dc, i\_IC → primario IC; P\_IC → scope |

El IC queda fuera de la Micro-red porque es la puerta entre el bus DC y la fase a de la S/E. La fase no se modela: P\_IC es la potencia que el IC intercambiaría con ella (positiva cuando la fase entrega energía a la MR).

### Qué viaja por cada flecha

Cada flecha de señal es un **vector**. Un `Mux` lo arma en el bloque que envía y un `Demux` lo separa en el que recibe, así que el nivel superior queda tan limpio como la lámina.

| Flecha | Contenido (en orden dentro del vector) | Unidades |
| --- | --- | --- |
| refs. | dV, Ib\_lo, Ib\_hi, k\_rec, k\_EV | V, A, A, p.u., p.u. |
| PWM | v\_pv, v\_bat, v\_ev, v\_ld: tensión de mando de cada convertidor (= d·V\_in) | V |
| v, i | V\_dc, i\_pv, i\_bat, i\_ev, i\_ld, P\_disp, P\_EV\*, EV\_c, P\_carga\* | V, A, W, –, W |
| V\_dc, SOC | V\_dc, SOC | V, p.u. |
| P\* | Consigna del IC | W |
| PWM IC | Tensión de mando del IC | V |
| V\_dc, i\_IC | Tensión del bus e i\_IC | V, A |
| bus DC (+) y (−) | Cables (no señales): unen la MR con el IC. El (−) es 0V\_a, flotante | – |

### Dentro de cada bloque

- **`Secundario MR a1`:** `Demux` → `sc_Vdc`, `sc_SOC`. Rama superior: `Secundario ON` → `Mux_e` → `Error V` → `PI secundario` → `Limite dV` → dV. Las cuatro funciones del SOC (`Ib_lo`, `Ib_hi`, `k_rec`, `k_EV`) son las reglas del Paso 4. Un `Mux` final arma las refs.
- **`Primario DER (droop)`:** dos `Demux` (refs. y v, i) y cuatro filas, una por DER. Cada fila hace `From` → `Mux` → `i_ref` → `Error i` → `PI corriente` → `Feedforward` → `Goto pd_v_x`. La ley de cada fila está escrita sobre ella. Un `Mux` final arma el PWM.
- **`Primario IC (g-f)`:** la misma fila de control, con i\* = P\*/V\_dc.
- **`MR a1: PV - BESS - EV - carga`** (versión del 12-nov, dibujada como el recuadro MR de la lámina): arriba corre el **bus DC (+)** y abajo el **bus DC (−)**. De ellos cuelgan cuatro subsistemas, uno por equipo: `PV (boost MPPT)`, `BESS`, `Cargador EV` y `Carga DC`. Cada uno tiene su borne DC+ arriba, su borne DC− abajo, la entrada `v_cmd (PWM)` a la izquierda (un `From pl_v_x`) y sus medidas a la derecha (un `Goto pl_...` por medida). A la derecha del bus están `C_bus`, `R_base` y `Vm_bus` (que publica `pl_Vdc`) y los bornes `DC+ (al IC)` y `DC- (al IC)`. En la franja inferior están el `Demux` del PWM, las potencias P\_x = V·i y los tres `Mux` de salida (v, i al primario; V\_dc, SOC al secundario; potencias al scope).
- **Dentro de cada DER** (doble clic sobre `PV (boost MPPT)`, `BESS`, `Cargador EV` o `Carga DC`): la misma etapa de potencia promedio, `v_cmd (PWM)` → `Fuente promedio` → `Rl` → `L` → `Am` → `DC+`, con retorno de la fuente a `DC-`. `Am` publica la corriente i (positiva hacia el bus). Debajo está el recurso propio de cada equipo: en el PV, el subsistema `Panel FV (G, T)` (salidas i, P\_disp, G, Tc); en la BESS, un `Vm` en sus bornes, P = V·i y el subsistema `Bateria (SOC)` (salidas i, SOC); en el EV, los perfiles `Perfil P_EV` y `EV conectado` (salidas i, P\_EV ref, EV\_c); en la carga, `Perfil P_carga` (salidas i, P\_carga ref). El control no vive aquí: cada DER solo recibe su PWM y entrega medidas, igual que en la lámina.
- **`IC`:** `Fuente promedio IC` → `Rl` → `L` → `Am` → `DC+`, con `Vm` entre `DC+` y `DC-`. La corriente es positiva del IC hacia la MR. Además calcula P\_IC = V·i.

Las etiquetas Goto/From son únicas en todo el archivo. Su prefijo dice dónde nacen: `pl_` (planta), `pv_`, `bt_`, `ev_`, `ld_` (interior de cada DER), `pd_` (primario DER), `pi_` (primario IC), `icp_` (IC), `sc_` (secundario), `top_` (nivel superior). Los scopes las leen desde cualquier nivel.

### Scopes (nivel superior)

| Scope | Eje | Trazas | Qué mirar |
| --- | --- | --- | --- |
| `Scope - MR a1 vista desde la fase` | 1 | P\* consigna, P\_IC | Se superponen: el IC sigue la consigna |
|  | 2 | V\_dc | Vuelve a 400 V con el secundario |
|  | 3 | SOC | Casi plano en el escenario 1; ciclo diario en el escenario 2 |
|  | 4 | P\_FV, P\_BESS, P\_EV, P\_carga | En régimen permanente, su suma más P\_IC ≈ +250 W (la carga base) |
| `Scope - Control primario y secundario` | 1 | V\_dc | Error permanente solo con primario; 400 V con secundario |
|  | 2 | dV | El esfuerzo del secundario: crece cuando la BESS descarga |
|  | 3 | k\_rec, k\_EV | Valen 1, salvo en las bandas de SOC |
|  | 4 | i\_BESS, límite de carga y límite de descarga | i\_BESS siempre queda entre los límites |
| `Scope - FV` | 1 | G | Irradiancia del perfil |
|  | 2 | P\_FV disponible y entregada | Son iguales salvo cuando el secundario recorta |

## Paso 1 — Circuito de potencia (bloque 1 del esquema)

Cada uno de los cinco convertidores reutiliza tu planta de `Convertidor_DC.plecs`: fuente controlada, R\_l = 0,03 Ω, L = 1 mH y amperímetro. Las cinco ramas llegan a un bus común con C\_bus = 4,7 mF y una carga base de 250 W.

**Qué se tomó de tu archivo y qué cambió:**

- **Se conserva** la rama fuente controlada → R\_l → L → amperímetro, con la misma orientación de bloques. Así la corriente medida es positiva hacia el bus, igual que en tu modelo.
- **Se conserva** la sintonía del lazo de corriente: ζ = 0,8 y f\_n = 400 Hz, con Kp\_i = 2ζω\_nL − R\_l = 3,99 y Ki\_i = ω\_n²L = 6317. Usa el mismo PI discreto, trapezoidal, con Ts = 1/15 000 s.
- **Cambia** el lazo externo. En tu convertidor, un PI de tensión fijaba V\_o en una carga aislada. En una Micro-red, cinco convertidores comparten la misma tensión, y cinco PI de tensión peleando por ella no tienen solución única. Por eso solo la BESS (y opcionalmente el EV) regula tensión, y lo hace con droop, sin integrador. El resto sigue potencia.
- **Se agrega** feedforward de V\_dc. La salida del convertidor es v\_k = PI(i\_k\* − i\_k) + V\_dc. Sin él, al partir, el PI debería construir 400 V desde cero y habría un transitorio de corriente enorme.
- **Cambia** la capacidad: de 40 µF a 4,7 mF. La razón está en el recuadro siguiente.

**Ecuaciones del circuito** (k = FV, BESS, EV, carga, IC):

```latex
L\,\frac{di_k}{dt} = v_k - R_l\, i_k - V_{dc}
```

```latex
C_{bus}\,\frac{dV_{dc}}{dt} = \sum_k i_k - \frac{V_{dc}}{R_{base}}
```

> **Por qué 4,7 mF y no 40 µF.** El droop actúa como una conductancia 1/R\_d sobre el condensador, así que el lazo de tensión cruza en ω\_c ≈ 1/(R\_d,eq·C\_bus). Con BESS y EV en droop, R\_d,eq = 0,8 ∥ 1,08 = 0,46 Ω. Con 4,7 mF, ω\_c ≈ 462 rad/s, unas 5,4 veces bajo el lazo de corriente (ω\_n = 2513 rad/s), con margen de fase cercano a 85°. Con 40 µF, ω\_c ≈ 54 000 rad/s queda por encima del lazo de corriente y el sistema se vuelve inestable. Físicamente, 4,7 mF representa la suma de los condensadores de enlace DC de los cinco convertidores, cerca de 1 mF cada uno.

**Cómo leerlo en PLECS:** dentro de `MR a1: PV - BESS - EV - carga` los cuatro equipos son subsistemas colgados entre el bus (+) y el bus (−). Al entrar a cualquiera de ellos ves la rama de potencia `Fuente promedio` → `Rl` → `L` → `Am` → `DC+`. A la derecha del bus están `C_bus`, `R_base` y `Vm_bus`, y los bornes `DC+ (al IC)` y `DC- (al IC)`. La rama del IC es igual y vive en el bloque `IC`, conectado a esos bornes.

## Paso 2 — Modelos FV y BESS depurados (bloque 3 del esquema)

Los dos modelos de `Modelos_ERNC.plecs` funcionaban como idea, pero tenían errores que cambian los resultados. Los modelos corregidos están dentro del bloque de planta `MR a1: PV - BESS - EV - carga`: `Panel FV (G, T)` vive dentro del subsistema `PV (boost MPPT)` y `Bateria (SOC)` dentro del subsistema `BESS`. El modelo eólico (WT) quedó fuera, porque tu Micro-red no lo incluye.

### Modelo FV

El modelo calcula la potencia disponible con MPPT ideal, a partir de la irradiancia y la temperatura horarias del CSV. Para 16 módulos Risen RS6F-200M en 2 strings de 8, eso da 3,28 kWp, con V\_mp del string ≈ 329 V.

```latex
T_c = T_a + \frac{NOCT-20}{800}\,G
```

```latex
P_{disp} = N_p\,I_{mp}\,\frac{G}{G_n}\,\big(1+\alpha_I\,(T_c-25)\big)\cdot N_s\,V_{mp}\,\big(1+\beta_V\,(T_c-25)\big)
```

| # | En el original | Problema | Corrección |
| --- | --- | --- | --- |
| 1 | `Tcv = 0.05/100` sobre la tensión y `Tci = -0.32/100` sobre la corriente | **Coeficientes intercambiados.** En módulos Risen, la corriente sube 0,05 %/°C y la tensión baja 0,32 %/°C. Con el original, la tensión subía con el calor. | α\_I = +0,05 %/°C sobre la corriente y β\_V = −0,32 %/°C sobre la tensión. |
| 2 | `Isc + Tci*(T-Tn)` | **Coeficiente relativo sumado como absoluto.** Se restaban 0,0032 A/°C, un efecto casi nulo, y se perdía la caída real por temperatura. | Forma relativa: I·(1 + α·ΔT). |
| 3 | Se usaba la temperatura ambiente | **La celda está más caliente que el aire.** Al mediodía de enero, T\_a = 28,9 °C, pero T\_c ≈ 61 °C. | Modelo NOCT, con NOCT = 45 °C. Al mediodía, la potencia baja ≈ 10 % respecto de STC. |
| 4 | `linspace(0, 24*3600, 24)*eqv` | **Eje de tiempo estirado.** Pone 24 puntos con paso de 24/23 h, así que la hora 23 cae en la 24 y el mediodía se corre 30 min. | Paso exacto: t = (0:23)·T\_h, con la hora 24 igual a la hora 0 para cerrar el día. |
| 5 | `dlmread('PPV.csv', …)` | Depende de que el CSV esté en la carpeta de trabajo. | Los 24×4 datos van dentro de la inicialización, en la matriz `PPV`. `Mes` elige enero o julio. |

### Modelo BESS (SOC)

El SOC se integra con la potencia que el convertidor de la BESS entrega realmente al bus, P\_bat = V\_dc·i\_bat. Se incluyen las eficiencias y un factor κ de compresión de tiempo, ambos explícitos.

```latex
\frac{dSOC}{dt} = -\,\kappa\,\frac{P_{celda}}{3600\,E_{bat}},\qquad P_{celda}=\begin{cases}P_{bat}/\eta_d & P_{bat}>0\\ P_{bat}\,\eta_c & P_{bat}<0\end{cases}
```

| # | En el original | Problema | Corrección |
| --- | --- | --- | --- |
| 6a | Ganancia «Ah→As» = 2 | Solo vale con la compresión de 48 s por día (1 h = 2 s), y eso no estaba dicho. Con tiempo real debería ser 3600. | Factor κ explícito: κ = 1 en tiempo real (escenario 1) y κ = 3600 con 1 s = 1 h (escenario 2). |
| 6b | Se integra y después se satura | **Windup.** Si el SOC llega a 1 y la batería sigue cargando, el integrador sigue creciendo por dentro. Al descargar, el SOC queda pegado en 1 hasta deshacer ese exceso. | Integrador con límites \[0, 1\] sobre el propio SOC. |
| 6c | Entrada constante de −7800 W y `SOC_init = 0` | No estaba acoplado al circuito y partía vacía. | La entrada es P\_bat medida. SOC\_init = 0,60 (esc. 1) o 0,50 (esc. 2). |
| 6d | 30 en paralelo × 6,5 Ah × 360 V = 70 kWh | Es grande para una vivienda y no calza con tu escenario previo (20 kWh). | 9 en paralelo: 58,5 Ah × 360 V = 21,1 kWh, con límite de 5 kW. |
| 6e | Sin eficiencia | El ciclo cerraba sin pérdidas. | η\_c = η\_d = 0,95, con un rendimiento de ciclo de ≈ 90 %. |

Los coeficientes del punto 1 son los típicos de las hojas de datos Risen ([ej. 1](https://www.scribd.com/document/548903136/data-sheet-Risen-P320-340), [ej. 2](https://www.scribd.com/document/503020253/DataSheet-Modulos)). No pude abrir la hoja del RS6F-200M que cita tu archivo, así que conviene confirmar α, β y NOCT en ella.

## Paso 3 — Control primario (bloque 2 del esquema)

El primario reacciona en milisegundos y sin comunicación. Cada convertidor calcula una referencia de corriente i\* con medidas locales, y un lazo PI de corriente la impone. Solo la BESS fija la tensión del bus. Lo hace con droop V–I, que se comporta como una fuente de V₀ + δV detrás de una resistencia virtual R\_d.

**Dónde está en PLECS:** en el bloque `Primario DER (droop)`, una fila por recurso: `From` → `Mux` → `i_ref` → `Error i` → `PI corriente` → `Feedforward` → `Goto pd_v_x`. La ley está escrita sobre cada fila. El IC tiene la misma fila en `Primario IC (g-f)`.

| Recurso | Referencia de corriente i\* | Parámetros |
| --- | --- | --- |
| BESS | sat\[ (V₀ + δV − V\_dc)/R\_d,b ; I\_b,lo , I\_b,hi \] | R\_d,b = ΔV\_max/I\_max = 10 V / 12,5 A = 0,8 Ω |
| EV | EV\_c · sat\[ −k\_EV·P\_EV\*/V\_dc + Modo\_EV·(V₀ − V\_dc)/R\_d,ev ; −I\_ev,max , Modo\_EV·I\_V2G \] | R\_d,ev = 10 V / 9,25 A = 1,08 Ω; I\_ev,max = 10 A; I\_V2G = 0 (sin V2G) |
| FV | k\_rec · P\_disp / V\_dc | k\_rec viene del secundario (recorte) |
| Carga activa | −P\_carga\* / V\_dc | carga de potencia constante |
| IC | P\_IC\* / V\_dc | plan del terciario (acá, un perfil) |

**Por qué droop sin integrador.** Si cada recurso tuviera un PI de tensión hacia 400 V, todos los integradores querrían imponer la misma tensión y el reparto quedaría indeterminado. Con droop, el equilibrio es único:

```latex
V_{dc} = V_0 + \delta V - R_{d,b}\, i_{bat}
```

Cuanto más entrega la BESS, más baja la tensión. Ese error permanente es el precio del primario y lo corrige el secundario (Paso 4).

**Reparto entre BESS y EV.** Con `Modo_EV = 1`, el EV también aporta droop. Ante un desequilibrio, ambos se reparten el cambio en proporción a 1/R\_d, es decir, a su potencia nominal. En el escenario 1, al conectar el EV, la BESS sube 2,1 kW y el EV reduce su carga 1,6 kW. La razón 2,1/1,6 ≈ 1,3 coincide con R\_d,ev/R\_d,b = 1,35.

**Decisión de diseño (defendible ante el profesor).** El droop del EV se centra en V₀, no en V₀ + δV. Así, el EV ayuda solo en el transitorio: cuando el secundario restaura 400 V, su término de droop vale cero y vuelve a cargar a lo pedido. La BESS asume el desequilibrio en régimen permanente y el usuario del EV recibe su energía. Si se suma δV también al EV, el reparto proporcional se mantiene en régimen permanente, a costa de cargar menos el auto. Es un cambio de una línea en `i_ref_ev`.

**Límites de la BESS.** I\_b,lo e I\_b,hi no son constantes: los calcula el secundario según el SOC (Paso 4). Cerca de SOC\_min, la BESS deja de poder descargar; cerca de SOC\_max, deja de poder cargar.

**Carga de potencia constante.** Una CPL tiene resistencia incremental negativa, −V²/P ≈ −22 Ω a 7,4 kW. Frente a la conductancia del droop (1/0,46 Ω ≈ 2,2 S) es despreciable, así que no desestabiliza el bus.

## Paso 4 — Control secundario (subsistema *Control secundario*)

El secundario hace dos cosas, en una escala unas 15 veces más lenta que el primario. Primero, devuelve el bus a 400 V. Segundo, cuida los límites de SOC de la BESS, actuando sobre FV, EV y la propia BESS. Solo mide su V\_dc y el SOC. No ve la cabecera ni a otras Micro-redes, como pide el correo de Espina del 10 de noviembre.

### (a) Restauración de tensión

```latex
\delta V = \mathrm{sat}_{\pm 25\,V}\Big[K_{p,s}\,e + K_{i,s}\!\int e\,dt\Big],\qquad e = \mathrm{sec\_on}\cdot(V_0 - V_{dc})
```

Como el primario es mucho más rápido, el secundario ve un bus que ya cumple V\_dc ≈ V₀ + δV − R\_d·i. Reemplazando eso en el integrador queda un sistema de primer orden:

```latex
\tau_s \approx \frac{1+K_{p,s}}{K_{i,s}} = \frac{1{,}2}{20} = 60\ \text{ms}
```

El primario cruza en 1/ω\_c ≈ 2–4 ms, así que la separación de escalas es de al menos 15 veces. Por eso no se pelean. Con el EV también en droop, δV mueve el bus solo en la fracción R\_d,ev/(R\_d,b + R\_d,ev) = 0,57, y τ\_s sube a ≈ 100 ms. En el escenario 1, el 90 % de la restauración tarda 0,22 s. La corrección δV se suma solo a la referencia de la BESS, que asume el desequilibrio en régimen permanente. La señal `sec_on` permite mostrar el sistema primero solo con primario y después activar el secundario.

**Lectura física para el profesor:** cuando el IC cambia su potencia por el plan del terciario, la Micro-red no se entera por comunicación. Se entera porque su V\_dc se mueve. El primario de la BESS absorbe el cambio y el secundario restaura la tensión. Es exactamente lo que pide el correo: el secundario redistribuye el cambio de potencia del IC entre sus DER sin saber del desbalance.

### (b) Gestión de límites de SOC

Cuatro rampas continuas de ancho dS = 0,03 se ordenan para que **siempre haya alguien sosteniendo el bus**. Primero actúa el recurso flexible (FV o EV) y solo después se limita la BESS:

| Señal | Ley | Actúa entre | Efecto |
| --- | --- | --- | --- |
| k\_rec (recorte FV) | sat₀¹\[(SOC\_max − dS − SOC)/dS\] | SOC 0,84 → 0,87 | La FV deja de entregar todo su MPPT |
| I\_b,lo (máx. carga) | −I\_max · sat₀¹\[(SOC\_max − SOC)/dS\] | SOC 0,87 → 0,90 | La BESS deja de poder cargar |
| k\_EV (reduce EV) | sat₀¹\[(SOC − SOC\_min − dS)/dS\] | SOC 0,16 → 0,13 | El EV reduce su carga |
| I\_b,hi (máx. descarga) | I\_max · sat₀¹\[(SOC − SOC\_min)/dS\] | SOC 0,13 → 0,10 | La BESS deja de poder descargar |

En PLECS, sat₀¹(x) se escribe sin condicionales, como 0,5·(|x| − |x−1| + 1). Las rampas son continuas, así que no hay conmutaciones ni chattering. Cuando el SOC llega a la banda, el sistema encuentra solo un punto de equilibrio. En el escenario 2 se ve el SOC detenido en ≈ 0,85 entre las 13 y las 17 h, con la FV recortada a lo justo.

**Vínculo con el terciario.** Acá, SOC\_min y SOC\_max son fijos. En la tesis, el terciario asignará ese rango a cada Micro-red y a cada intervalo, como la reserva que luego usa el lazo rápido. Para pasar a eso, SOC\_min y SOC\_max solo tienen que convertirse en entradas del subsistema.

## Paso 5 — Escenarios y resultados esperados

El escenario 1 valida la dinámica: primario, secundario y conexión del IC, en 3,4 s de tiempo real. El escenario 2 valida la integración con los perfiles FV reales y la gestión de SOC en un día comprimido. Las curvas de abajo vienen del modelo de referencia en Python, **no de PLECS**. Son lo que PLECS debería mostrar, y sirven para contrastar.

### Escenario 1 — validación dinámica (`Escenario = 1`)

Condiciones iniciales: Micro-red aislada (P\_IC = 0), G = 800 W/m² (FV ≈ 2,45 kW), carga 1,5 kW + 250 W, SOC = 0,60 y secundario apagado.

| t \[s\] | Evento | Qué demuestra | Resultado esperado |
| --- | --- | --- | --- |
| 0,0 | Partida en isla | Primario estable desde el inicio | V\_dc = 401,4 V: la BESS carga 0,69 kW, así que el droop sube la tensión |
| 0,4 | Carga 1,5 → 2,25 kW | Droop: la BESS absorbe el escalón | V\_dc = 399,9 V (BESS ≈ 0) |
| 0,8 | EV conecta (3,7 kW) | **Reparto primario BESS/EV y error permanente** | V\_dc cae a 395,6 V; BESS +2,16 kW; EV carga solo 2,1 kW |
| 1,2 | Secundario ON | **Restauración** | V\_dc vuelve a 400 V en ≈ 0,2 s; el EV vuelve a 3,7 kW; la BESS sube a 3,7 kW; δV = 7,4 V |
| 1,6 | Nube: G 800 → 500 W/m² | Perturbación de generación | FV 2,45 → 1,57 kW; caída de 0,9 V; BESS 4,6 kW, cerca de su límite de 5 kW |
| 2,0 | IC importa 3 kW (plan) | **Conexión a la red, IC grid-following** | Pico de +3,9 V; la BESS baja a 1,6 kW; el bus vuelve a 400 V |
| 2,6 | EV se desconecta | Rechazo de carga | Pico de +5,4 V; la BESS pasa a cargar 2,1 kW |
| 3,0 | IC exporta 1 kW | Inversión del flujo en el IC | Valle de −5,9 V; la BESS descarga 1,9 kW |

En todo el escenario, V\_dc se mantiene entre 394,1 y 405,4 V, es decir, dentro de ±1,5 %.

**Qué mirar en PLECS:** el scope *Control primario y secundario* (V\_dc, dV, factores y corriente de la BESS) y el scope *MR a1 vista desde la fase* (consigna frente a P\_IC, V\_dc, SOC y potencias). El SOC casi no se mueve, porque κ = 1 y 3,4 s de operación real no alcanzan.

### Escenario 2 — día comprimido de enero (`Escenario = 2`)

Un día de 24 h dura 24 s (κ = 3600, así que 1 s = 1 h). Como el SOC evoluciona 3600 veces más rápido con las mismas potencias, se ve la gestión de energía. Al mismo tiempo, la electrónica sigue en milisegundos, muy por debajo de 1 s, y no se distorsiona.

- **FV:** irradiancia y temperatura horarias de enero desde `PPV.csv`, interpoladas linealmente.
- **Carga:** perfil residencial **supuesto** (no medido) de 0,32 a 1,76 kW, con punta a las 20 h, más 250 W base. En total son ≈ 22 kWh/día.
- **EV:** conectado de 19 a 23 h a 3,7 kW (14,8 kWh).
- **Plan del IC (sustituto del terciario, escalones horarios):** importa 1 kW de 0 a 7 h, exporta 1 kW de 11 a 16 h, importa 3,5 kW de 19 a 23 h y 1 kW a las 23 h.
- **Secundario** activo todo el día; SOC inicial = 0,50.

**Resultado esperado:** V\_dc se mantiene entre 398,1 y 402,2 V todo el día. El SOC sube de 0,50 a 0,85 con el sol. Entre las 13 y las 17 h el recorte FV lo detiene en la banda, y se recortan 2,65 kWh de 23,7 kWh disponibles. Después baja con la punta y el EV hasta 0,42. La red entrega 22,0 kWh y recibe 5,0 kWh.

**Qué mirar en PLECS:** en el scope *Control primario y secundario*, k\_rec bajando de 1 entre las 13 y las 17 h. En el scope *FV*, la diferencia entre P\_FV disponible y entregada.

**Ejercicio sugerido para mostrar los límites:** pon `Pic_h` en ceros (Micro-red siempre aislada) y corre de nuevo. El SOC llegará a SOC\_min de noche. Sin respaldo de la red, la carga no servida hace caer el bus, y esa es justamente la información que la Micro-red deberá reportar al terciario como envolvente de lo que puede ofrecer.

Figuras de resultados esperados (modelo de referencia en Python, no PLECS):

&#91;image: Escenario 1: tensión del bus, potencias y corrección del secundario ante siete eventos\]

En el escenario 1, el bus queda 4,4 V bajo 400 V solo con primario (t = 0,8–1,2 s). El secundario lo restaura, y cada evento posterior se corrige en menos de 0,3 s.

&#91;image: Detalle: error permanente del primario y restauración del secundario\]

&#91;image: Escenario 2: día comprimido de enero, con SOC, potencias y recorte FV\]

En el escenario 2, el recorte FV detiene el SOC en 0,85 entre las 13 y las 17 h, y el bus nunca sale de 398–402 V.

## Guion para la reunión del lunes 16

Son unos 8 minutos con el modelo abierto. La idea central es una sola: **la Micro-red sostiene su bus sola, y el IC puede seguir cualquier plan del terciario sin que el secundario sepa de él.**

**Frase de entrada:** «Profesor, armé la primera parte que acordamos: una Micro-red DC con su primario y su secundario, y su conexión a la red a través del IC como grid-following. Es un modelo promedio, para validar el control antes de pasar a conmutado o a tiempo real.»

1. **Arquitectura (30 s).** Muestra el nivel superior: es su lámina. Arriba están el secundario y los primarios; abajo, la MR a1 y su IC unidos por el bus DC. «La BESS forma el bus con droop. FV, EV, carga e IC siguen potencia.»
2. **Modelos (1 min).** Abre *Panel FV (G, T)* y *Bateria (SOC)*. Menciona las correcciones a los modelos del curso: coeficientes de temperatura, NOCT, eje de tiempo, windup del SOC y el factor κ explícito.
3. **Primario (2 min).** Corre el escenario 1 y detén la vista en t = 0,8–1,2 s. «Al conectar el EV, BESS y EV se reparten el escalón según 1/R\_d, y queda un error de 4,4 V. Ese es el precio del droop.»
4. **Secundario (2 min).** Continúa en t = 1,2 s. «El secundario solo mide su V\_dc. Restaura 400 V en 0,2 s, el EV vuelve a lo pedido y la BESS asume el desequilibrio.» Luego muestra t = 2,0 y 3,0 s: «el IC cambia su potencia y la Micro-red lo absorbe sin comunicación. Es lo que usted planteó para el lazo rápido: el IC es el único que actúa sobre la fase.»
5. **Día completo (2 min).** Corre el escenario 2. «Con κ = 3600 veo el SOC en un día. Cuando llega a la banda superior, el secundario recorta FV y no deja que la BESS se sature.»
6. **Cierre (30 s).** «El siguiente paso es modelar el lado AC del IC monofásico con una impedancia de alimentador. Después, tres Micro-redes, una por fase, para cerrar el lazo rápido en la cabecera.»

**Preguntas probables y respuestas cortas:**

- *«¿Por qué la BESS y no el IC forma el bus DC?»* Porque acordamos IC grid-following. Si el IC formara el bus, la potencia hacia la fase la decidiría la Micro-red y no el terciario ni el lazo rápido.
- *«¿Por qué 4,7 mF?»* Para que el lazo de tensión del droop (≈ 460 rad/s) quede unas 5 veces bajo el lazo de corriente (2513 rad/s). Representa la suma de los enlaces DC de los cinco convertidores.
- *«¿Qué pasa si la BESS se queda sin energía en isla?»* El secundario primero reduce el EV y después limita la BESS. Si aún falta energía, el bus cae, porque no hay deslastre de carga. Eso define la envolvente que la Micro-red debe informar al terciario.
- *«¿La compresión de tiempo no distorsiona?»* Distorsiona la contabilidad de energía de los transitorios, que pesan 3600 veces más en el SOC. Por eso la dinámica se evalúa en el escenario 1 (κ = 1) y el escenario 2 solo sirve para ver la gestión de energía.
- *«¿Y el EV como V2G?»* Está previsto: basta con poner `Iev_v2g` > 0. Lo dejé en cero para validar primero el caso base.

## Limitaciones, riesgos al abrir en PLECS y siguientes pasos

El riesgo principal es que PLECS reclame por la sintaxis de algún bloque, porque el archivo no se abrió en PLECS. La lógica de control y los números sí están verificados contra el modelo de referencia. Pruébalo antes del lunes, para tener tiempo de corregirlo.

### Si PLECS reclama al abrir o al correr

| Síntoma | Causa probable | Arreglo rápido |
| --- | --- | --- |
| Error en `TimeSpan` / *Stop time* | PLECS no acepta la variable `Tsim` en ese campo | Escribe 3.4 (escenario 1) o 24 (escenario 2) en *Simulation Parameters* |
| Error de parámetro en Function, Lookup1D, Integrator o Subsystem | Esos bloques los copié de tu archivo 4.9 dentro de un archivo 5.0 | Abre el bloque que nombra el error y vuelve a escribir el parámetro, o mándame el mensaje |
| Error en una expresión con `abs` | El bloque Fcn de tu versión no acepta esa función | Mándame el mensaje: se reemplaza por un bloque *Saturation* |
| Un scope se abre raro o vacío | La configuración visual guardada se copió de tus scopes | Bórralo, inserta un Scope nuevo con el mismo número de ejes y reconecta |
| El escenario 2 tarda | Paso variable con controles muestreados a 15 kHz: ≈ 360 000 muestras | Es normal (debería tardar alrededor de un minuto). Si molesta, sube Ts a 1/10 000 |
| «Uncaught PLECS Exception: cannot determine the start point of connection segment» al mover bloques o cables | Falla interna de PLECS al redibujar una conexión cuyo primer o último quiebre queda encima de un borne, porque se forma un tramo de largo cero. En las versiones anteriores, varios quiebres quedaban a 20–40 px del centro de fuentes, condensadores y sumadores, justo donde PLECS pone el borne | Usa el archivo nuevo. Ningún quiebre queda a menos de 45 px del bloque al que llega o del que sale, no hay señales bifurcadas y todos los tramos son horizontales o verticales. El verificador revisa las tres cosas. Si vuelve a aparecer, guárdalo con otro nombre, reinicia PLECS (lo pide el propio mensaje) e instala la actualización que ofrece la barra inferior. Para mover un bloque, arrástralo sin tomar los cables |

### Limitaciones del modelo (decirlas antes de que las pregunten)

- Es un modelo promedio: no hay rizado de conmutación ni pérdidas de semiconductores.
- El IC solo tiene su lado DC: no hay lado AC, PLL ni red de la S/E. Su potencia es un perfil, no la salida del terciario.
- La BESS tiene tensión constante, sin curva OCV–SOC ni resistencia interna.
- El EV solo tiene una ventana de conexión y una potencia. No se lleva la cuenta de su energía requerida (E\_req) ni de su SOC.
- No hay deslastre de carga. Si la energía no alcanza, el bus colapsa, y eso se interpreta como energía no servida.
- Solo hay una Micro-red: todavía no hay desbalance entre fases que medir.

### Siguientes pasos sugeridos

1. **Lado AC del IC.** Agregar el lado AC del IC (inversor monofásico promedio con PLL, control PR a 50 Hz y filtro LCL) y conectarlo a la fase a de la S/E, cumpliendo el balance P\_ac = P\_dc.
2. **Micro-red como subsistema replicable.** Enmascarar todo este modelo como un bloque «Micro-red» con parámetros (E\_bat, kWp, perfiles) y replicarlo en a, b y c sobre un alimentador 3φ-4H.
3. **Medición en cabecera y lazo rápido por fase.** Igualar las tres potencias de fase usando solo los IC, como pidió Espina el 10 nov.
4. **Terciario.** Reemplazar los perfiles `Pic_h` por el plan optimizado y convertir SOC\_min/SOC\_max en la reserva asignada.
5. **Tiempo real.** Para una RT Box hace falta paso fijo discreto. Hay que reemplazar el integrador continuo del SOC por uno discreto y fijar el solver en *Discrete*.

## Parámetros y referencias

Todos los parámetros están en *Simulation › Simulation Parameters › Initialization*, con los mismos nombres que se usan aquí.

| Grupo | Variable | Valor | Origen |
| --- | --- | --- | --- |
| Bus | `V0`, `C_bus`, `P_base` | 400 V, 4,7 mF, 250 W | V₀ de tu convertidor; C por estabilidad |
| Convertidores | `L`, `Rl` | 1 mH, 0,03 Ω | `Convertidor_DC.plecs` |
| Lazo de corriente | `e_i`, `f_i`, `Kp_i`, `Ki_i`, `Ts` | 0,8, 400 Hz, 3,99, 6317, 1/15 000 s | `Convertidor_DC.plecs` |
| FV | `Imp`, `Vmp`, `Np`, `Ns` | 4,99 A, 41,1 V, 2, 8 (3,28 kWp) | `Modelos_ERNC.plecs` |
| FV | `alpha_I`, `beta_V`, `NOCT` | +0,05 %/°C, −0,32 %/°C, 45 °C | Corregidos (Paso 2) |
| BESS | `cell_cap`, `n_parallel`, `pack_V`, `E_bat` | 6,5 Ah, 9, 360 V, 21,1 kWh | `Modelos_ERNC.plecs` (n ajustado) |
| BESS | `Pb_max`, `dV_max`, `Rd_b`, `eta_c`, `eta_d` | 5 kW, 10 V, 0,8 Ω, 0,95, 0,95 | Escenario previo de tu tesis |
| EV | `P_ev_nom`, `Iev_max`, `Rd_ev`, `Modo_EV`, `Iev_v2g` | 3,7 kW, 10 A, 1,08 Ω, 1, 0 A | Carga monofásica de 16 A |
| Secundario | `Kp_s`, `Ki_s`, `dVsec_max` | 0,2, 20, 25 V | τ ≈ 60–100 ms |
| SOC | `SOC_min`, `SOC_max`, `dS` | 0,10, 0,90, 0,03 | Banda de la tesis |
| Escenario 1 | `kappa`, `SOC_init`, `Tsim` | 1, 0,60, 3,4 s | Tiempo real |
| Escenario 2 | `kappa`, `SOC_init`, `Tsim` | 3600, 0,50, 24 s | 1 s = 1 h |

**Referencias base para defender el control (de memoria, sin enlace: verifica los datos bibliográficos antes de citarlas):**

1. J. M. Guerrero, J. C. Vásquez, J. Matas, L. G. de Vicuña, M. Castilla, «Hierarchical control of droop-controlled AC and DC microgrids — A general approach toward standardization», *IEEE Trans. Ind. Electron.*, vol. 58, n.º 1, 2011. Es la base del droop V–I y del secundario por δV.
2. T. Dragičević, X. Lu, J. C. Vásquez, J. M. Guerrero, «DC microgrids — Part I: A review of control strategies and stabilization techniques», *IEEE Trans. Power Electron.*, vol. 31, n.º 7, 2016. Trata la estabilidad con cargas de potencia constante y la separación de escalas.
3. Lineamiento de la tesis: el secundario por Micro-red y el IC grid-following siguen lo acordado con E. Espina (reunión del 9 nov y correo del 10 nov de 2026).

**Fuentes consultadas para los coeficientes FV:** [Risen RSM72-6 (hoja de datos)](https://www.scribd.com/document/548903136/data-sheet-Risen-P320-340) y [Risen, hoja de datos módulos 2018](https://www.scribd.com/document/503020253/DataSheet-Modulos).
