# Pauta pedagógica: la arquitectura de control en diagramas de bloques

**Material:** `control_bloques_9nov.pdf` (6 láminas, estilo de Rocabert et al. 2012, Figs. 10 y 11)  
**Reunión:** lunes 9 de noviembre de 2026  
**Lo que pidió el profesor:** una sola lámina con los niveles de control, indicando **qué mide, qué decide y a quién envía** cada uno; más el caso simple; y marcar lo que no esté claro.

---

## 0. Qué presentar el lunes

- **La lámina 3 ("Niveles de control: vista general") es la candidata a ser "la lámina única"**: muestra los cuatro niveles anidados, con sus entradas (flechas que llegan), lo que deciden (bloques) y a quién envían (flechas que salen), y los puntos abiertos marcados en rojo.
- Llevar como respaldo la **tabla** (`lamina_niveles_control_9nov.pdf`, lámina 1) y el **caso simple** (lámina 2 del mismo archivo).
- Las láminas 4, 5 y 6 de este archivo son para **entender** y para responder si el profesor pregunta "¿y cómo funciona por dentro?".
- **Recomendación:** enviarle al profesor la lámina 3 y el caso simple antes del lunes, como él ofreció.

---

## 1. Cómo se lee un diagrama de bloques (lámina 2)

Un diagrama de bloques es un **mapa de quién le pasa información a quién**. Cuatro piezas:

| Símbolo | Qué es | Cómo leerlo |
|---|---|---|
| **Rectángulo** | Un bloque que decide o calcula | "Aquí alguien toma una decisión con lo que le llega" |
| **Círculo con Σ o +** | Un sumador | "Aquí se juntan señales: se suman o restan según el signo" |
| **Triángulo** | Una ganancia $k$ | "La señal se multiplica por $k$" |
| **Nube** | Una fuente externa | "Información que viene de afuera del sistema: pronósticos, tarifa" |

Y las flechas, por color:

- **Naranjo**: lo que manda el **terciario** (cada 15 min).
- **Verde punteado**: lo que manda el **lazo rápido** (segundos).
- **Teal**: lo que manda el **secundario** de cada micro-red.
- **Gris punteado**: **mediciones** que suben.
- **Negro grueso**: **potencia**, el circuito eléctrico real.

**Regla de oro:** para un nivel cualquiera, lo que **mide** son las flechas que le **llegan**, lo que **decide** está en su **bloque**, y a quién **envía** es donde **terminan** sus flechas de salida. Es exactamente lo que pidió el profesor.

---

## 2. La vista general, paso a paso (lámina 3)

### 2.1 Las regiones anidadas

Igual que en la Fig. 11 de Rocabert, cada color de fondo es el **alcance** de un nivel:

- **Amarillo claro (exterior): terciario.** Ve todo el alimentador y planifica.
- **Amarillo fuerte: lazo rápido.** Actúa sobre todo el alimentador, pero en segundos.
- **Azul (con copias apiladas detrás): cada micro-red DC.** Las copias indican que hay $N_a+N_b+N_c$ micro-redes iguales en estructura. **Todo lo que está dentro del azul es local de esa micro-red**: sus recursos (FV, BESS, EV), su barra DC, su IC y su secundario.
- **Línea vertical negra a la derecha:** el alimentador BT 3φ-4W, con el medidor **M** en la cabecera, junto a la subestación.

### 2.2 Recorrido nivel por nivel

| Nivel | Mide (flechas que llegan) | Decide (bloque) | Envía a (flechas que salen) |
|---|---|---|---|
| **Terciario** | Pronósticos y tarifa (nube), $S_{h,\phi}$ de la cabecera, SoC de cada micro-red | Optimización con ventana $H$ | Al **IC**: plan $P^*_{\mathrm{IC},k}$, $Q^*_{\mathrm{IC},k}$. Al **secundario**: rango de SoC$_k$ |
| **Lazo rápido** | $I_0$, $I_2$ medidos en la cabecera | Corrección para reducir el desbalance **medido** | Al sumador del **IC**: $\Delta P_k$, $\Delta Q_k$ (camino por definir, punto 4) |
| **Secundario MR $k$** | $V_{dc,k}$ y SoC de sus recursos; rango de SoC$_k$ | Reparto entre sus DER y restauración de $V_{dc}$ | A los **convertidores de sus DER** (referencias). Hacia arriba: SoC$_k$ |
| **Primario** | Variables locales ($v$, $i$, $V_{dc}$) y su referencia | Control del convertidor (droop en los DER; corriente en el IC) | A su propio convertidor (PWM) |

### 2.3 El detalle que hay que entender bien: el sumador del IC

Abajo a la derecha hay un **círculo Σ** al que llegan dos flechas:

$$P_{ref,k}=\underbrace{P^*_{\mathrm{IC},k}}_{\text{terciario: el plan}}+\underbrace{\Delta P_k}_{\text{lazo rápido: la corrección}}$$

Es el mismo truco de Rocabert (Fig. 11), donde se suman $P^*_{III}$, $P^*_{II}$ y $P^*_{I}$. En palabras: **"el plan dice cuánto inyectar; la corrección ajusta ese plan según lo que realmente se mide"**.

### 2.4 Una confusión que conviene evitar

En Rocabert (y en la tesis del profesor Espina), el **secundario** es un nivel de **toda la micro-red AC** que restaura frecuencia y tensión. **En esta tesis el secundario es otra cosa:** vive **dentro** de cada micro-red DC y solo coordina sus propios recursos (aclaración 1 del profesor). Lo que en Rocabert sería "la corrección que viene de arriba en segundos", aquí es el **lazo rápido**. Si el profesor pregunta, decirlo así:

> "Usé el estilo de la Fig. 11 de Rocabert, pero los nombres no calzan uno a uno: mi lazo rápido ocupa el lugar de su secundario, y mi secundario es interno a cada micro-red DC."

---

## 3. Dentro de una micro-red (lámina 4)

Esta lámina tiene el estilo de la Fig. 10 de Rocabert: arriba el **circuito de potencia** y abajo, en celeste, el **control**.

### 3.1 La intuición física: un estanque de agua

- La **barra DC** es un **estanque** y $V_{dc}$ es el **nivel del agua**.
- El **IC** es un **grifo de salida**: saca del estanque exactamente la potencia que le ordenan ($P_{ref}$), ni más ni menos. Es un **seguidor de corriente** (grid-following): no le importa el nivel del estanque.
- Los **DER** (BESS, FV, EV) son **llaves de entrada con resorte** (droop): si el nivel baja, se abren solas y meten más agua. Eso es ser **grid-supporting** en el lado DC (punto 6 del correo).
- El **secundario** es el **operador** que mira el nivel: si quedó bajo la marca, ajusta las llaves para devolverlo ($\delta_B$), y decide **qué estanque de reserva aporta más** según cuánta agua (SoC) le queda a cada uno.

### 3.2 La ecuación del droop de la BESS, en palabras

$$V_{ref,B}=V^*_{dc}+\delta_B-k_d\,P_B$$

- $V^*_{dc}$: el nivel nominal ("la marca").
- $-k_d P_B$: **mientras más potencia entrega la BESS, más baja su referencia de tensión**. Así varias BESS en la misma barra se reparten la carga sin hablarse: es el **primario**.
- $+\delta_B$: el **desplazamiento** que pone el **secundario** para corregir el nivel y repartir según SoC.

**Por qué hace falta el secundario:** con droop solo, la tensión DC queda **un poco bajo la marca** cuando hay carga (por el término $-k_dP_B$) y el reparto depende solo de $k_d$, no del SoC. El secundario corrige ambas cosas.

### 3.3 El control del IC, en palabras

1. El **sumador Σ** de la derecha arma $P_{ref}$ y $Q_{ref}$ (plan + corrección).
2. El **PLL** mide la tensión de la red y entrega su ángulo $\theta$, para inyectar en fase con la red.
3. El bloque **referencia de corriente** convierte $P_{ref}$, $Q_{ref}$ y $\theta$ en la corriente que hay que inyectar, $i^*$.
4. El **lazo PR** compara $i^*$ con la corriente medida $i$ y corrige con PWM.

**Punto 5 (por aclarar):** si el IC también fuera grid-supporting en el lado AC, habría además un droop $P$–$f$ o $Q$–$V$ sumado a $P_{ref}$, $Q_{ref}$. Por eso aparece "¿droop AC?".

### 3.4 Cómo se conecta todo

Cuando el IC saca más potencia (porque subió $P_{ref}$), **baja $V_{dc}$**; las BESS lo notan **solas** por droop y aportan; luego el secundario **restaura** $V_{dc}$ y reparte por SoC. **El secundario nunca necesitó saber qué pasó en la cabecera**: se enteró por su propio $V_{dc}$. Eso es justamente lo que pidió el profesor (aclaración 1).

---

## 4. Lazo rápido y terciario en detalle (lámina 5)

### 4.1 Lazo rápido: seis pasos en cadena

1. **Medir** las corrientes y tensiones de fase en la cabecera.
2. **Fortescue**: calcular $I_0$ (neutro) e $I_2$ (secuencia negativa).
3. **Comparar con cero**: el error es "cuánto desbalance hay".
4. **Controlador** (por ejemplo un PI; por definir, punto 4): decide cuánta corrección total aplicar.
5. **Asignar** esa corrección entre las micro-redes (por definir, punto 4). Usa **$Q$ primero** porque no gasta energía (Resultado 2).
6. **Limitar** cada $\Delta P_k$ para que el SoC no salga de su rango.

**Idea clave (aclaración 3):** el lazo rápido **no sigue el plan**, porque el plan también puede venir desbalanceado: cierra el lazo sobre la **medición**.

### 4.2 Terciario: entrada, decisión y salida

- **Entra:** pronósticos y tarifa (nube), SoC de BESS y EV, y medición de cabecera.
- **Decide:** optimización con ventana $H$ (punto 1), minimizando compra de energía y desbalance entre fases (punto 2).
- **Sale:** el **plan** (cuánto inyectar) y el **rango** de SoC (cuánta energía puede usar cada micro-red, punto 3).

**Analogía:** el terciario es el **presupuesto del mes** (cuánto gastar y cuánto guardar); el lazo rápido es **pagar los imprevistos del día** sin pasarse del presupuesto (el rango).

---

## 5. Historia de una perturbación (lámina 6)

Es la mejor forma de explicar todo junto. Con números:

0. **$t=0$:** un cliente de la fase $a$ enciende 3 kW. Solo la fase $a$ cambia, así que la corriente de neutro sube en $3000/230\approx13$ A.
1. **Milisegundos:** los IC siguen su consigna; todavía nadie corrigió. La red absorbe el cambio.
2. **Segundos:** el lazo rápido mide $I_0$ más alto y envía $\Delta P_k>0$ a las micro-redes de la fase $a$ (y quizás $\Delta P<0$, es decir cargar, a las de $b$ y $c$).
3. **Milisegundos a segundos:** el IC de cada micro-red de $a$ saca más potencia; baja su $V_{dc}$; las BESS responden por droop; el secundario restaura $V_{dc}$ y reparte según SoC.
4. **Próximo intervalo:** el terciario ve el SoC más bajo y el nuevo pronóstico, y replanifica el plan y el rango.

**Moraleja:** cada nivel reacciona **a lo que está en su conjunto de entradas** y **a su propio ritmo**. El rango de SoC evita que el lazo rápido gaste la energía que el terciario reservó para más tarde (el caso simple muestra por qué eso importa).

---

## 6. Confusiones típicas (para no caer)

| Confusión | Lo correcto |
|---|---|
| "El secundario coordina las micro-redes de una fase" | No: el secundario es **uno por micro-red** y solo coordina sus DER |
| "El lazo rápido sigue el plan del terciario" | No: reduce el desbalance **medido**; el plan puede venir desbalanceado |
| "El rango de SoC reparte según el tamaño de la batería" | No: **acota la energía** del intervalo y deja **margen** para corregir |
| "Grid-supporting = grid-forming" | No: grid-supporting **apoya** la tensión con droop, pero no la impone solo |
| "El IC regula $V_{dc}$" | En esta arquitectura no: el IC sigue potencia; $V_{dc}$ lo sostienen los DER por droop y lo restaura el secundario |

## 7. Preguntas probables y respuestas cortas

- **"¿Por qué el IC no regula la tensión DC?"** Porque la consigna de potencia del IC viene de arriba (plan + corrección). Si además regulara $V_{dc}$, tendría dos objetivos para una sola variable. Con DER grid-supporting, $V_{dc}$ se sostiene dentro de la micro-red.
- **"¿Qué pasa si la BESS ya está en el límite de su rango?"** El limitador del lazo rápido le asigna $\Delta P_k=0$ (o solo $\Delta Q_k$), y el secundario no la deja descargar más. La corrección la toman otras micro-redes o queda sin corregir, como en el caso simple.
- **"¿Por qué el lazo rápido usa $Q$ primero?"** Porque $Q$ no consume energía de la batería (Resultado 2); solo usa capacidad del inversor.
- **"¿Cómo se diferencia de la Fig. 11 de Rocabert?"** Ver la sección 2.4.

---

## 8. Bibliografía para este tema

1. **Rocabert, Luna, Blaabjerg, Rodríguez (2012)**, "Control of Power Converters in AC Microgrids", *IEEE Trans. Power Electronics*, 27(11), 4734–4749. **Fuente de las Figs. 10 y 11.** Leer la sección de clasificación (grid-forming, grid-feeding, grid-supporting) y la de control jerárquico. [DOI](https://doi.org/10.1109/TPEL.2012.2199334)
2. **Guerrero, Vásquez, Matas, de Vicuña, Castilla (2011)**, "Hierarchical Control of Droop-Controlled AC and DC Microgrids", *IEEE Trans. Industrial Electronics*, 58(1), 158–172. El origen del esquema primario–secundario–terciario, con la versión **DC** (droop $V$–$P$ y restauración de $V_{dc}$): la base de la lámina 4.
3. **Dragičević, Lu, Vásquez, Guerrero (2016)**, "DC Microgrids—Part I", *IEEE Trans. Power Electronics*, 31(7). Primario y secundario en micro-redes DC. 🔓 [PDF, Aalborg](https://vbn.aau.dk/ws/files/218830588/Paper1_final.pdf)
4. **Mexis, Todeschini, Zhou (2022)**, *IEEE Trans. Energy Conversion*, 37(4). Controlador superior que mide en el transformador y fija $P$, $Q$ de inversores monofásicos: lo más cercano al **lazo rápido**. 🔓 [PDF, Swansea](https://cronfa.swansea.ac.uk/Record/cronfa61052/Download/61052__25368__35dfd823984a46369995096bae02a94a.pdf)
5. **Elkazaz et al. (2020)**, *Applied Energy*. MPC cada 15 min más controlador en tiempo real que sigue un perfil de energía: lo más cercano a **plan + rango de SoC**. 🔓 [Repositorio U. de Nottingham](https://nottingham-repository.worktribe.com/file/4481580/1/A%20Hierarchical%20Two-Stage%20Energy%20Management%20for%20a%20Home%20Microgrid%20Using%20Model%20Predictive%20and%20Real-Time%20Controllers)
6. **Tesis doctoral del profesor Espina**, sec. 2.6.2 y referencias [E116]–[E131]: secundario DC con balance de SoC (la versión rigurosa de la lámina 4).
