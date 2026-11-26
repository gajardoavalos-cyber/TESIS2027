# Lazo rápido, opción C: reparto por costo marginal, paso a paso

**Preparado:** 26-nov-2026. **Estado:** propuesta para la reunión del lunes 30-nov. No la valida aún el profesor. Las cifras de la sección 9 salen de una integración numérica simple (paso de 1 min, sin pérdidas), no de PLECS.
**Responde a:** acuerdo 1 de la reunión del 25-nov: definir con precisión la matemática del lazo rápido, justificando cada variable.
**Decisión de Felipe (26-nov):** se adopta la **opción C** del documento `lazo_rapido_opciones_B_C.md`, en su versión **acotada por la potencia firme de B** (sección 1.3 explica por qué esa es "la" C).
**Se apoya en:** `documento_formulacion_terciario_lazo_rapido.md` (23-nov), del que se mantienen la notación, la medición $e_\phi$, el PI con anti-windup y la convención de signos.

---

## Índice

0. La ley en una página
1. ¿Conversa C con lo ya acordado? (verificación punto por punto)
2. Mapa de variables: qué es cada una y por qué está
3. Paso 1. Qué mide el lazo y cuánto corrige la fase (sin cambios)
4. Paso 2. Qué informa cada Micro-red: la potencia firme
5. Paso 3. Planteamiento del reparto como un problema de optimización
6. Paso 4. Resolución: condiciones KKT y *water-filling*
7. Paso 5. Propiedades demostradas
8. Paso 6. Cómo elegir $\beta_k$ y $\Theta$
9. Paso 7. Ejemplo numérico (fase $a$ del 23-nov)
10. Paso 8. Implementación en PLECS
11. Paso 9. Qué se informa hacia arriba (terciario futuro)
12. Paso 10. Extensión distribuida por consenso (donde entra la línea de Espina)
13. Decisiones a validar con el profesor
14. Preguntas probables y respuestas
15. Referencias

---

## 0. La ley en una página

En cada fase $\phi\in\lbrace a,b,c\rbrace$, con $\mathcal N_\phi$ el conjunto de Micro-redes (MR) conectadas a esa fase:

```math
\begin{aligned}
&\textbf{(1) Medición (23-nov):} && e_\phi=P_{h,\phi}-\tfrac13\textstyle\sum_{\psi}P_{h,\psi}\\
&\textbf{(2) Potencia firme de cada MR:} && F_k=\min\!\Big(\Pi_k,\ \dfrac{W_k(\Theta)}{\Theta}\Big),\qquad F_\phi=\textstyle\sum_{k\in\mathcal N_\phi}F_k\\
&\textbf{(3) PI saturado (23-nov, banda nueva):} && \Delta P_\phi=\mathrm{sat}_{[-F^{\downarrow}_\phi,\,F^{\uparrow}_\phi]}\big(K_p e_\phi+x\big)\\
&\textbf{(4) Reparto óptimo:} && \min_{\Delta P_k}\ \sum_{k}\tfrac12\,\dfrac{1+\beta_k}{F_k}\,\Delta P_k^2\quad\text{s.a.}\quad\sum_k\Delta P_k=\Delta P_\phi,\ \ |\Delta P_k|\le F_k\\
&\textbf{(5) Solución:} && \Delta P_k=\mathrm{sat}_{[-F^{\downarrow}_k,\,F^{\uparrow}_k]}\!\Big(\lambda_\phi\,\dfrac{F_k}{1+\beta_k}\Big),\quad \lambda_\phi\ \text{tal que}\ \textstyle\sum_k\Delta P_k=\Delta P_\phi\\
&\textbf{(6) Referencia al IC (23-nov):} && P_{\mathrm{ref},k}=P^{\ast}_k+\Delta P_k,\qquad Q_{\mathrm{ref},k}=0
\end{aligned}
```

**En una frase:** el PI decide **cuánto** corrige la fase; la optimización decide **quién** lo entrega, cobrando a cada MR un precio que sube cuando le queda poca potencia firme y cuando su uso molesta ($\beta_k$). El precio común resultante, $\lambda_\phi$, es la información que la fase entrega hacia arriba.

Si todas las MR tienen $\beta_k=0$, la ley (5) se reduce a $\Delta P_k=(F_k/F_\phi)\,\Delta P_\phi$ (la opción B) y $\lambda_\phi=\Delta P_\phi/F_\phi$ es el indicador de uso del margen del 23-nov.

---

## 1. ¿Conversa C con lo ya acordado? (verificación punto por punto)

### 1.1 Con los acuerdos del 25-nov

| Acuerdo | ¿C lo cumple? | Cómo | Ojo |
|---|---|---|---|
| 1. Matemática precisa, cada variable justificada | **Sí** | Cada variable tiene unidad y origen físico (sección 2). $c_k$ no es arbitrario: sale de $F_k$, y el problema equivale a **igualar la utilización** de las MR (sección 5.3). | La única variable "de diseño" sin origen físico directo es $\beta_k$. Por eso se propone $\beta_k=0$ como caso base y $\beta_k>0$ solo con un motivo declarado (sección 8). |
| 2. Validar la simulación con el lazo rápido funcionando | **Sí** | Es un bloque por fase: un PI (el mismo del 23-nov) más un *water-filling* de 3 MR que se resuelve por bisección en microsegundos (sección 10). | Hay que comprobar en PLECS que el PI responde igual que con α fijo (sección 7.1). |
| 3. Terciario como trabajo futuro | **Sí** | C no necesita ningún dato del terciario: usa solo la envolvente de cada MR. Deja listas dos interfaces para el terciario futuro: $F_\phi$ y $\lambda_\phi$ (sección 11). | C optimiza **en el instante**, no en el tiempo. No debe convertirse en un mini-terciario (no hay horizonte ni pronóstico dentro del lazo). |

### 1.2 Con las disposiciones anteriores

| Disposición | Origen | ¿Se mantiene con C? |
|---|---|---|
| El lazo rápido actúa **solo sobre los IC**, por fase; no habla con secundarios ni DER | correo 10-nov | **Sí.** C recibe de cada IC tres números por dirección ($\Pi_k$, $W_k$, $\beta_k$) y le devuelve uno ($\Delta P_k$). El IC los conoce por la envolvente que calcula el secundario de su MR. |
| Cada MR informa una **envolvente** (P mín/máx, E mín/máx) por medio de su IC | correo 10-nov | **Sí, y es la entrada de C.** No se pide información nueva, salvo $\beta_k$ (un número fijo, opcional). |
| Lazo **por fase**: igualar las potencias por fase en cabecera, no anular I₂ e I₀ directamente | correo 10-nov, resultado R1 | **Sí.** $e_\phi$ no cambia. |
| IC **grid-following**, $Q_{\mathrm{ref}}=0$ | reunión 9-nov | **Sí.** C solo cambia $P_{\mathrm{ref},k}$. |
| Medición $e_\phi=P_{h,\phi}-\bar P_h$, con $\sum_\phi e_\phi=0$ | 23-nov §4 | **Sí, sin cambios.** |
| Estructura $P_{\mathrm{ref},k}=P^{\ast}_k+\alpha_k\Delta P_\phi$, con $\sum\alpha_k=1$ | 23-nov §5 | **Sí.** El α efectivo de C es $\alpha_k=\Delta P_k/\Delta P_\phi$ y siempre suma 1 (sección 7.1). Lo que cambia es que α deja de ser fijo. |
| PI con anti-windup por retrocálculo; planta de ganancia uno; $K_p=K_iT_{\mathrm{IC}}$, $1/K_i$ de 5 a 10 s | 23-nov §13 | **Sí.** La sintonía no cambia (sección 7.1). Solo cambia de dónde sale la banda de saturación: de $F_\phi$ en vez de $b_\phi\pm R^{\varepsilon}_\phi$. |
| Indicador $u_\phi\in[-1,1]$ de uso del margen | 23-nov §13 | **Sí.** Con $\beta=0$, $\lambda_\phi=u_\phi$. Con $\beta>0$ se reportan los dos (sección 7.5). |
| Separación de roles: terciario = energía en el tiempo; lazo = balance en el instante | correo 10-nov | **Sí.** C reparte en el instante; la energía entra solo como cota ($F_k$). |
| No volver a la ley de SoC con τ | CLAUDE.md | **Sí.** $\Theta$ no es una constante de tiempo de un lazo de SoC; es la duración que la MR debe poder sostener (sección 8.2). |
| $\alpha_k=E_k/\sum E_j$ fijo | 23-nov §6, decisión D2 | **Se reemplaza** (decisión N1). Era fijo solo para que el LP del terciario no fuera bilineal; sin terciario ese motivo desaparece, y con C el terciario futuro tampoco lo necesita (sección 11). |
| Banda del PI $[b_\phi-R^{\varepsilon\downarrow}_\phi,\ b_\phi+R^{\varepsilon\uparrow}_\phi]$ y referencia $e_\phi\to\rho_\phi$ | 23-nov D14, D15 | **Se ajustan** mientras no haya terciario: banda $[-F^{\downarrow}_\phi,F^{\uparrow}_\phi]$ y referencia $e_\phi\to0$. |

**Conclusión de la verificación:** C es compatible con todo lo acordado. Reemplaza una sola decisión (D2) y ajusta dos (D14, D15) por una razón que el propio acuerdo 3 genera. No contradice el correo del 10-nov en ningún punto.

### 1.3 Una condición para que la compatibilidad se sostenga

C **debe** llevar las cotas $|\Delta P_k|\le F_k$. Sin ellas, el problema sigue siendo un despacho óptimo, pero ya no garantiza que ninguna MR se vacíe ni supere la potencia de su IC: solo garantiza optimalidad del costo. Con ellas, C hereda los teoremas de energía de B (sección 7.3). Por eso, en este documento, **"opción C" significa siempre C acotada por la potencia firme**. No hay que elegir entre B y C: B es el caso $\beta=0$ de C.

### 1.4 Por qué C es donde Espina puede aportar más

- El reparto por **costo incremental igual** ($c_k\Delta P_k=\lambda$) es exactamente el principio del despacho económico distribuido que usa su línea de trabajo: su tesis doctoral incluye una estrategia de control secundario que minimiza el costo de operación de la Micro-red híbrida completa [E2], y el algoritmo de consenso de costo incremental [C1] es la herramienta estándar para distribuirlo.
- La extensión natural de C (sección 12) es que **los IC de una fase acuerden $\lambda_\phi$ por consenso**, sin que la cabecera conozca los costos individuales. Eso extiende su contribución doctoral (el IC como agente de consenso [E1]) de un IC a varios IC por fase.

---

## 2. Mapa de variables: qué es cada una y por qué está

Tipo: **M** = medida, **E** = estimada por la MR (envolvente), **D** = de diseño, **C** = calculada por el lazo.

| Símbolo | Qué es | Unidad | Tipo | Por qué está (justificación) |
|---|---|---|---|---|
| $P_{h,\phi}$ | potencia activa de la fase $\phi$ en la cabecera | kW | M | es lo único que el lazo puede medir del desbalance (correo 10-nov) |
| $e_\phi$ | desviación de la fase respecto del promedio | kW | C | igualar potencias por fase ⇔ anular I₂ e I₀ (R1) |
| $\Delta P_\phi$ | corrección total que pide el PI a la fase | kW | C | salida del PI; es lo que la fase entera debe entregar |
| $P^{\ast}_k$ | punto de operación nominal del IC $k$ | kW | E | sin terciario lo fija la propia MR (0 o su intercambio programado) |
| $\Pi^{\uparrow}_k=P^{\max}_k-P^{\ast}_k$ | holgura de potencia para inyectar más | kW | E | límite del IC y de los DER: no se le puede pedir más potencia que esta |
| $\Pi^{\downarrow}_k=P^{\ast}_k-P^{\min}_k$ | holgura para absorber más | kW | E | ídem, en sentido contrario |
| $W^{\uparrow}_k(\Theta)$ | energía adicional que la MR puede entregar en $[t,t+\Theta]$ sin salir de su banda de SoC | kWh | E | límite de energía; sale de la envolvente (23-nov §11) |
| $W^{\downarrow}_k(\Theta)$ | energía adicional que puede absorber | kWh | E | ídem |
| $\Theta$ | duración que la fase debe poder sostener la corrección | h | D | convierte energía en potencia sostenible (sección 8.2) |
| $F_k=\min(\Pi_k,\,W_k/\Theta)$ | **potencia firme**: la que la MR puede sostener durante $\Theta$ | kW | C | es la cota que garantiza potencia **y** energía a la vez (teoremas 1 y 2) |
| $F_\phi=\sum_kF_k$ | potencia firme de la fase | kW | C | banda de saturación del PI; información para el terciario |
| $\beta_k\ge0$ | recargo por usar la MR $k$ | adim. | D | expresa preferencias que la física no ve (EV de un cliente, degradación) |
| $c_k=(1+\beta_k)/F_k$ | costo de pedir potencia a la MR $k$ | 1/kW | C | escasez ($1/F_k$) por recargo ($1+\beta_k$); sección 5.3 |
| $u_k=\Delta P_k/F_k$ | utilización de la potencia firme de la MR $k$ | adim. | C | qué fracción de lo que puede dar está dando |
| $\lambda_\phi$ | precio sombra del balance en la fase | adim. | C | multiplicador de Lagrange de $\sum_k\Delta P_k=\Delta P_\phi$; cuánto cuesta un kW más de corrección |
| $\alpha_k=\Delta P_k/\Delta P_\phi$ | factor de participación efectivo | adim. | C | conecta con la política afín del 23-nov |
| $T_\alpha$ | período de actualización de $F_k$ y $c_k$ | s | D | separación de escalas con el PI (sección 10) |

Convención de signo (23-nov): $\Delta P_\phi>0$ significa que los IC de la fase **inyectan** más (descargan). Para $\Delta P_\phi>0$ se usan las magnitudes $\uparrow$ ($F^{\uparrow}_k$, $\beta^{\uparrow}_k$); para $\Delta P_\phi<0$, las $\downarrow$. Para no recargar, de aquí en adelante se escribe el caso $\uparrow$ sin flecha.

---

## 3. Paso 1. Qué mide el lazo y cuánto corrige la fase (sin cambios)

Esto es idéntico al 23-nov §13; se repite para que el documento se lea solo.

**Medición.** En cada período $T_s\approx1$ s:

```math
e_\phi=P_{h,\phi}-\bar P_h,\qquad \bar P_h=\tfrac13\big(P_{h,a}+P_{h,b}+P_{h,c}\big),\qquad \sum_\phi e_\phi=0 .
```

**Planta vista por el PI.** Si $d_\phi$ es el desbalance sin corregir, la cabecera ve $e_\phi=d_\phi-\sum_{k\in\mathcal N_\phi}\Delta P_k$. Si la suma de lo que entregan los IC es exactamente lo que pidió el PI, $\sum_k\Delta P_k=\Delta P_\phi$, entonces

```math
e_\phi=d_\phi-\Delta P_\phi ,
```

una planta de **ganancia uno** (más la dinámica rápida del IC, $T_{\mathrm{IC}}$). La sintonía por cancelación polo-cero del 23-nov, $K_p=K_iT_{\mathrm{IC}}$ con $1/K_i$ de 5 a 10 s, sigue valiendo.

**PI con anti-windup (23-nov §13.6):**

```math
v=K_p\,e_\phi+x,\qquad \Delta P_\phi=\min\!\big(\max(v,\,-F^{\downarrow}_\phi),\,F^{\uparrow}_\phi\big),\qquad x\leftarrow x+K_iT_s\,e_\phi+K_{aw}(\Delta P_\phi-v).
```

Lo único nuevo es la banda: antes la fijaba el terciario ($b_\phi\pm R^{\varepsilon}_\phi$); ahora la fija la potencia firme de la fase. **Esa banda es lo que hace que el problema del paso 3 siempre tenga solución** (sección 7.2).

> **En simple.** El PI es el "jefe de fase": mira la cabecera y dice "esta fase tiene que entregar 1,5 kW más". No sabe ni le importa quién los entrega. Solo sabe que, entre todos, no pueden prometer más que $F_\phi$.

---

## 4. Paso 2. Qué informa cada Micro-red: la potencia firme

### 4.1 Las dos holguras

Cada MR ya calcula su envolvente para el terciario (correo 10-nov; 23-nov §11). De ella salen dos cifras por dirección:

```math
\Pi_k(t)=P^{\max}_k(t)-P^{\ast}_k(t)\quad[\mathrm{kW}],
```

```math
W_k(t;\Theta)=\underbrace{E_{B,k}(t)-E^{\min}_{B,k}}_{\text{energía sobre el mínimo}}+\int_t^{t+\Theta}\big(\hat P_{\mathrm{net},k}-P^{\ast}_k\big)\,d\tau-z\,\sigma_{E,k}(\Theta)\quad[\mathrm{kWh}].
```

El primer término es lo que la batería (BESS + EV disponible) tiene sobre su mínimo. El segundo es lo que la MR gana o pierde por su propio balance previsto (FV menos cargas) mientras sostiene $P^{\ast}_k$. El tercero es el colchón por el error de su propio pronóstico (23-nov §11; esto responde la pregunta del 10-nov sobre qué pasa si una MR se equivoca: el colchón reduce $W_k$ y, con él, lo que se le pide).

### 4.2 De energía a potencia sostenible

Una MR con mucha potencia y poca energía (IC grande, batería casi vacía) puede entregar mucho, pero poco rato. Una con mucha energía y un IC chico puede entregar poco, pero mucho rato. Para comparar ambas en la misma unidad se pregunta: **¿qué potencia constante puedes sostener durante $\Theta$ horas?**

```math
F_k=\min\!\Big(\Pi_k,\ \frac{W_k(\Theta)}{\Theta}\Big)\quad[\mathrm{kW}].
```

Si la responde la potencia ($F_k=\Pi_k$), la MR está **limitada por su IC**. Si la responde la energía ($F_k=W_k/\Theta$), está **limitada por su batería**. Esta es la única cifra que el lazo necesita de cada MR para garantizar que no se vacía ni se sobrecarga.

**Ejemplo (fase $a$, $\Theta=4$ h):** MR1 con 10 kWh y 3 kW → $\min(3,\,2{,}5)=2{,}5$ kW (energía). MR2 con 2 kWh y 3 kW → $0{,}5$ kW (energía). MR3 con 4 kWh y 0,5 kW → $\min(0{,}5,\,1)=0{,}5$ kW (potencia). Fase: $F_a=3{,}5$ kW.

---

## 5. Paso 3. Planteamiento del reparto como un problema de optimización

### 5.1 El problema

Dado el $\Delta P_\phi$ que pide el PI, cada $T_s$ se resuelve, por fase:

```math
\boxed{\ \min_{\Delta P_k}\ J=\sum_{k\in\mathcal N_\phi}\tfrac12\,c_k\,\Delta P_k^{2}\qquad\text{s.a.}\qquad\sum_{k\in\mathcal N_\phi}\Delta P_k=\Delta P_\phi,\qquad -F^{\downarrow}_k\le\Delta P_k\le F^{\uparrow}_k\ }
```

con $c_k=(1+\beta_k)/F_k$.

Tres piezas, tres preguntas:
- **Restricción de igualdad:** entre todas deben entregar lo que pidió el PI. Garantiza que la planta del PI siga teniendo ganancia uno (paso 1).
- **Cotas:** nadie entrega más que su potencia firme. Garantizan potencia y energía (sección 7.3).
- **Objetivo:** entre todos los repartos que cumplen lo anterior, cuál se prefiere. Es lo único que hay que justificar, y se hace en las secciones 5.2 y 5.3.

### 5.2 Por qué un costo cuadrático

| Alternativa | Qué pasa | Veredicto |
|---|---|---|
| Costo lineal $\sum c_k\Delta P_k$ | Orden de mérito: se usa la más barata hasta saturarla, luego la siguiente. El reparto salta cuando una satura y la solución no es única si dos costos empatan. | Se descarta: saltos de referencia a los IC. |
| Costo cuadrático $\sum\tfrac12c_k\Delta P_k^2$ | Estrictamente convexo: solución **única**, **continua** y **monótona** en $\Delta P_\phi$ (sección 7.4). | **Se adopta.** |
| Costo general convexo $\sum f_k(\Delta P_k)$ | Mismas propiedades, sin solución cerrada. | Innecesario para la tesis. |

Además, el costo cuadrático tiene dos lecturas físicas (son motivaciones, no derivaciones exactas):
1. Las pérdidas $I^2R$ del IC y de la batería crecen aproximadamente con el cuadrado de la potencia;
2. el desgaste de una batería crece con la tasa de carga o descarga (C-rate).
Y una lectura de diseño: es la forma estándar del despacho económico por costo incremental [C1, E2], lo que conecta directamente con la línea de Espina.

### 5.3 Por qué $c_k=(1+\beta_k)/F_k$: el objetivo iguala la utilización

Reemplazando $c_k$ y la utilización $u_k=\Delta P_k/F_k$:

```math
J=\sum_k\tfrac12\,\frac{1+\beta_k}{F_k}\,\Delta P_k^2=\sum_k\tfrac12\,(1+\beta_k)\,F_k\,u_k^{2}.
```

**Lectura:** C minimiza la suma de las utilizaciones al cuadrado, ponderadas por el tamaño de cada MR y por su recargo. Sin recargos, el óptimo es que **todas las MR usen la misma fracción de su potencia firme** (se demuestra en 6.1: $u_k=\lambda_\phi$ para todas). Eso es lo justo en el sentido físico correcto: ninguna MR se acerca a su límite antes que las demás.

Con recargo, la MR $k$ queda con una utilización $1+\beta_k$ veces menor que las sin recargo: $\beta_k=1$ significa "úsala a la mitad de su ritmo relativo".

**Por qué no otras elecciones:**
- $c_k$ constante (igual para todas): reparte en partes iguales en kW, ignora el tamaño y el estado. Vacía primero a la MR más chica.
- $c_k=1/E_k$: es el α fijo del 23-nov ($E_k/\sum E$). Ignora el SoC y la potencia del IC. En el ejemplo vacía a la MR2 (sección 9).
- $c_k$ en \$/kWh² por degradación: requiere datos de cada batería que hoy no se tienen. Queda como trabajo futuro, y cabe en $\beta_k$.

> **En simple.** Cada MR cobra por cada kW que se le pide. Cobra más si le queda poco que dar ($1/F_k$) y si usarla molesta ($1+\beta_k$). El lazo compra la corrección al menor costo total.

---

## 6. Paso 4. Resolución: condiciones KKT y *water-filling*

### 6.1 Sin cotas activas

Lagrangiano:

```math
\mathcal L=\sum_k\tfrac12\,c_k\,\Delta P_k^2-\lambda_\phi\Big(\sum_k\Delta P_k-\Delta P_\phi\Big).
```

Condición de primer orden para cada $k$:

```math
\frac{\partial\mathcal L}{\partial\Delta P_k}=c_k\,\Delta P_k-\lambda_\phi=0\quad\Longrightarrow\quad \Delta P_k=\frac{\lambda_\phi}{c_k}=\lambda_\phi\,\frac{F_k}{1+\beta_k}.
```

Sumando sobre $k$ y usando la restricción:

```math
\Delta P_\phi=\lambda_\phi\sum_j\frac{1}{c_j}\quad\Longrightarrow\quad \lambda_\phi=\frac{\Delta P_\phi}{G_\phi},\qquad G_\phi:=\sum_j\frac{F_j}{1+\beta_j}\ [\mathrm{kW}].
```

Por lo tanto:

```math
\boxed{\ \alpha_k=\frac{\Delta P_k}{\Delta P_\phi}=\frac{F_k/(1+\beta_k)}{\sum_jF_j/(1+\beta_j)}\ }
```

**Lectura de la condición $c_k\Delta P_k=\lambda_\phi$:** en el óptimo, todas las MR tienen el **mismo costo marginal** (lo que cuesta el último kW que entregan). Si una tuviera un costo marginal menor, convendría pedirle un poco más y pedirle un poco menos a otra. Es el principio de igual costo incremental del despacho económico clásico.

Con $\beta_k=0$ para todas: $G_\phi=F_\phi$, $\alpha_k=F_k/F_\phi$ (opción B) y $\lambda_\phi=\Delta P_\phi/F_\phi=u_\phi$.

### 6.2 Con cotas activas: *water-filling*

Las condiciones KKT completas (con multiplicadores $\mu^{+}_k,\mu^{-}_k\ge0$ para las cotas) dan:

```math
\Delta P_k(\lambda_\phi)=\min\!\Big(F^{\uparrow}_k,\ \max\!\big(-F^{\downarrow}_k,\ \lambda_\phi/c_k\big)\Big),\qquad \text{con }\lambda_\phi\text{ tal que }\ \sum_k\Delta P_k(\lambda_\phi)=\Delta P_\phi .
```

Cada MR entrega $\lambda_\phi/c_k$ hasta que llega a su cota, y ahí se queda. La MR $k$ satura cuando $\lambda_\phi$ alcanza su **precio de saturación**

```math
\bar\lambda_k=c_k\,F_k=1+\beta_k .
```

**Observación importante:** el precio de saturación no depende de $F_k$, solo del recargo. Todas las MR sin recargo saturan **a la vez**, en $\lambda_\phi=1$. Las MR con recargo $\beta_k$ siguen aportando hasta $\lambda_\phi=1+\beta_k$. Esto da una lectura directa del precio:

| $\lambda_\phi$ | Qué está pasando en la fase |
|---|---|
| $0$ | sin corrección |
| $0<\lambda_\phi<1$ | todas aportan; ninguna saturada |
| $\lambda_\phi=1$ | las MR sin recargo llegan a su potencia firme |
| $1<\lambda_\phi\le1+\beta_{\max}$ | **se está usando la reserva "cara"** (MR con recargo) |
| $\Delta P_\phi=F_\phi$ | todas saturadas; el PI está en su límite |

### 6.3 Cómo se calcula $\lambda_\phi$

La función $g(\lambda)=\sum_k\Delta P_k(\lambda)$ es continua, no decreciente y lineal por tramos, con quiebres en los $\bar\lambda_k$. Dos formas:

- **Bisección** en $[0,\ \max_k\bar\lambda_k]$: 30 iteraciones dan un error de $10^{-9}$ relativo. Con 3 a 5 MR por fase es trivial en un C-Script.
- **Exacta por tramos:** ordenar los $\bar\lambda_k$; en el tramo donde está la solución, las MR saturadas aportan su $F_k$ y el resto $\lambda/c_k$, así que

```math
\lambda_\phi=\frac{\Delta P_\phi-\sum_{k\in\mathcal S}F_k}{\sum_{k\notin\mathcal S}1/c_k},\qquad \mathcal S=\text{MR saturadas}.
```

---

## 7. Paso 5. Propiedades demostradas

### 7.1 El PI no se entera (conservación)

**Proposición 1.** Si $|\Delta P_\phi|\le F_\phi$, la solución cumple $\sum_k\Delta P_k=\Delta P_\phi$ exactamente, para cualquier $\beta_k$, $F_k$ y $\Delta P_\phi$. Por lo tanto el α efectivo suma 1 y la planta vista por el PI es $e_\phi=d_\phi-\Delta P_\phi$.

*Demostración.* Es la restricción de igualdad del problema, que es factible (7.2). ∎

**Consecuencia:** aunque el reparto de C es no lineal en $\Delta P_\phi$ (por la saturación de cada MR), la suma es lineal y la sintonía del 23-nov no cambia. Lo que importa para el PI es la suma, no la forma del reparto. **Supuesto a validar en PLECS:** los IC de una fase tienen dinámicas $T_{\mathrm{IC}}$ parecidas; si no, al cambiar el reparto cambia levemente la constante de tiempo equivalente (efecto de segundo orden porque $T_{\mathrm{IC}}\ll1/K_i$).

### 7.2 Siempre hay solución, y es única

**Proposición 2.** El conjunto factible es no vacío si y solo si $-F^{\downarrow}_\phi\le\Delta P_\phi\le F^{\uparrow}_\phi$. La banda del PI (paso 1) garantiza esa condición. Como $c_k>0$, el objetivo es estrictamente convexo y el mínimo es **único**.

*Demostración.* La suma de cajas $\prod_k[-F^{\downarrow}_k,F^{\uparrow}_k]$ proyectada por $\sum_k$ es exactamente $[-F^{\downarrow}_\phi,F^{\uparrow}_\phi]$. Función estrictamente convexa sobre un convexo compacto no vacío tiene un único minimizador. ∎

**Caso borde:** si una MR tiene $F_k=0$ (sin energía o IC en su límite), $c_k\to\infty$ y su cota es cero: simplemente no participa. En la implementación se usa $F_k\leftarrow\max(F_k,\varepsilon)$ para no dividir por cero.

### 7.3 Ninguna MR se vacía ni se sobrecarga (heredado de B)

Como $|\Delta P_k|\le F_k\le\Pi_k$ y $F_k\le W_k/\Theta$, valen los teoremas de B (`lazo_rapido_opciones_B_C.md` §4.2–4.3):

**Teorema 1 (Θ fijo, ventana fija).** Si en $[t_0,t_0+\Theta]$ se mantiene $F_k$ en su valor inicial, la energía entregada es $\int\Delta P_k\,dt\le F_k\Theta\le W_k$. ∎

**Teorema 2 (Θ fijo, recalculado continuamente).** $\dot W_k=-\Delta P_k\ge-F_k\ge-W_k/\Theta$, así que $W_k(t)\ge W_k(t_0)\,e^{-(t-t_0)/\Theta}>0$. **Ninguna MR llega a vaciarse.** ∎

Lo que demuestran los teoremas solo usa la cota $|\Delta P_k|\le F_k$, no la forma del reparto. Por eso **C conserva las garantías de B con cualquier $\beta_k$**. Es la razón técnica de la condición de la sección 1.3.

### 7.4 Continuidad y monotonía

**Proposición 3.** $\Delta P_k$ es una función **continua y no decreciente** de $\Delta P_\phi$, para cada $k$.

*Demostración.* Cada $\Delta P_k(\lambda)$ es continua y no decreciente en $\lambda$, así que $g(\lambda)=\sum_k\Delta P_k(\lambda)$ también lo es, y es estrictamente creciente mientras alguna MR no esté saturada. Su inversa $\lambda_\phi(\Delta P_\phi)$ es continua y no decreciente en $[0,F_\phi]$, y la composición $\Delta P_k(\lambda_\phi(\Delta P_\phi))$ también. ∎

**Significado práctico:** si el PI pide un poco más, ninguna MR entrega menos, y ninguna referencia de IC salta. Esto es lo que el orden de mérito estricto (costo lineal) no garantiza.

### 7.5 El precio y el indicador del 23-nov

- Con $\beta_k=0$ para todas: $\lambda_\phi=\Delta P_\phi/F_\phi=u_\phi$ (mientras nadie sature, es decir, en todo $[0,F_\phi]$).
- Con recargos: $\lambda_\phi\ge u_\phi$ cuando hay MR con recargo, y $\lambda_\phi$ puede pasar de 1. Por eso se reportan los dos:
  - $u_\phi=\Delta P_\phi/F_\phi\in[-1,1]$: **cuánto margen queda** (física);
  - $\lambda_\phi$: **cuánto cuesta el margen que queda** (preferencia).

### 7.6 Cambio de dirección

Cuando $\Delta P_\phi$ cruza cero, se pasa de las magnitudes $\uparrow$ a las $\downarrow$. Como $\Delta P_k(0)=0$ en ambos casos, $P_{\mathrm{ref},k}$ es continua.

---

## 8. Paso 6. Cómo elegir $\beta_k$ y $\Theta$

### 8.1 $\beta_k$: el único parámetro de preferencia

**Regla de diseño:** $\beta_k=0$ salvo que exista un motivo declarable. Cada $\beta_k>0$ debe tener una frase que lo justifique.

| Situación | Propuesta | Motivo |
|---|---|---|
| Caso base (validar la simulación) | $\beta_k=0$ para todas | sin preferencias: C = B |
| MR cuya energía es mayoritariamente el EV de un cliente | $\beta^{\uparrow}_k=1$ a $3$ (inyectar desde el EV) | no descargar el auto del cliente salvo que haga falta |
| La misma MR, absorbiendo | $\beta^{\downarrow}_k=0$ | cargar el EV no le molesta al cliente (si quiere cargar) |
| MR con batería más degradada | $\beta_k$ proporcional al costo relativo de degradación | trabajo futuro; requiere datos |
| MR lejos de la cabecera (más pérdidas) | $\beta_k$ pequeño, del orden de las pérdidas relativas | segundo orden en BT; se puede omitir |

**Quién lo fija:** la propia MR, que lo informa por su IC junto con su envolvente (un número fijo por dirección). Así se respeta el correo del 10-nov: el lazo no conoce la composición interna de la MR; solo sabe que "esta MR prefiere no aportar".

**Interpretación cuantitativa:** con $\beta_k=1$, la MR aporta la mitad de lo que aportaría sin recargo, a igualdad de $F_k$, mientras ninguna sature. Con $\beta_k=3$, un cuarto.

### 8.2 $\Theta$: la duración que se quiere sostener

$\Theta$ convierte energía en potencia sostenible. No es una constante de tiempo de un lazo de SoC (eso está descartado): es una **duración de compromiso**.

| Criterio | Elección | Qué se obtiene |
|---|---|---|
| Evento típico de desbalance (clientes monofásicos al atardecer) | $\Theta=4$ h fijo | teorema 2: nadie se vacía; conservador si el evento dura más |
| Se conoce cuándo termina el evento (perfil conocido; el profesor dijo que basta un perfil conocido más un error controlado) | $\Theta(t)=\max(t_{\mathrm{fin}}-t,\ \Theta_{\min})$ | usa toda la energía hasta $t_{\mathrm{fin}}$ sin vaciar a nadie antes |
| Horizonte del terciario futuro | $\Theta=H=12$ h | coherente con el LP del 23-nov |

**Propuesta para la simulación:** $\Theta=4$ h fijo como caso base y $\Theta=t_{\mathrm{fin}}-t$ como variante; $\Theta_{\min}=15$ min.

---

## 9. Paso 7. Ejemplo numérico (fase $a$ del 23-nov)

**Datos del 23-nov:** fase $a$ con 3 MR, $E=10/10/5$ kWh, desbalance previsible de 1,5 kW durante 4 h (18–22 h).
**Supuestos declarados** (los mismos de `lazo_rapido_opciones_B_C.md` §8): $W^{\uparrow}=10/2/4$ kWh a las 18:00; $\Pi^{\uparrow}=3/3/0{,}5$ kW; $P^{\ast}_k=0$; la MR3 tiene recargo $\beta_3=1$ (su energía es mayormente un EV); integración con paso de 1 min, sin pérdidas.

### 9.1 Reparto en un instante (Θ = 4 h; $F=2{,}5/0{,}5/0{,}5$ kW, $F_a=3{,}5$ kW)

$c=(1+\beta)/F=0{,}4/2{,}0/4{,}0$ y precios de saturación $\bar\lambda=1/1/2$. Resultado del *water-filling* para distintos pedidos del PI:

| $\Delta P_a$ [kW] | $\lambda_a$ | $\Delta P_1$ | $\Delta P_2$ | $\Delta P_3$ | Qué pasa |
|---|---|---|---|---|---|
| 0,50 | 0,154 | 0,385 | 0,077 | 0,038 | todas aportan; la MR3, a la mitad de su ritmo relativo |
| 1,50 | 0,462 | 1,154 | 0,231 | 0,115 | caso del ejemplo; $u_1=u_2=0{,}46$, $u_3=0{,}23$ |
| 2,87 | 0,883 | 2,208 | 0,442 | 0,221 | previsible + margen del 23-nov ($b+R$) |
| 3,25 | 1,000 | 2,500 | 0,500 | 0,250 | MR1 y MR2 llegan a su potencia firme |
| 3,40 | 1,600 | 2,500 | 0,500 | 0,400 | solo la MR3 sigue subiendo: se usa la reserva "cara" |
| 3,50 | 2,000 | 2,500 | 0,500 | 0,500 | todas saturadas; el PI está en su límite $F_a$ |

Comparación en $\Delta P_a=1{,}5$ kW: α fijo del 23-nov 0,60/0,60/0,30 kW; B 1,07/0,21/0,21 kW; C 1,15/0,23/0,12 kW.

### 9.2 Evolución integrada

| Caso | Energía final MR1/MR2/MR3, evento de 4 h [kWh] | Evento de 8 h [kWh] | ¿Alguna se vacía? | Desbalance no corregido en 8 h [kWh] |
|---|---|---|---|---|
| α fijo (23-nov) | 7,33 / **0,00** / 2,67 | 3,33 / **0,00** / 0,67 | **MR2 a las 21:20** | 0 |
| B = C con $\beta=0$, $\Theta=4$ h | 5,88 / 1,18 / 2,94 | 2,46 / 0,49 / 1,34 | no | 0,30 |
| B = C con $\beta=0$, $\Theta=t_{\mathrm{fin}}-t$ | 6,01 / 0,67 / 3,32 | 2,09 / 0,29 / 1,63 | no | 0 |
| **C, $\beta_3=1$, $\Theta=4$ h** | 5,50 / 1,10 / 3,40 | 2,09 / 0,42 / 1,86 | no | 0,38 |
| **C, $\beta_3=1$, $\Theta=t_{\mathrm{fin}}-t$** | 5,75 / 0,62 / 3,63 | 1,23 / 0,19 / 2,58 | no | **0** |
| C, $\beta_3=3$, $\Theta=4$ h | 5,27 / 1,05 / 3,68 | – | no | – |
| C, $\beta_3=3$, $\Theta=t_{\mathrm{fin}}-t$ | 5,60 / 0,59 / 3,81 | – | no | – |

### 9.3 Lectura

1. **C nunca vacía a ninguna MR** y respeta $\Pi_3=0{,}5$ kW en todo momento, con cualquier $\beta_3$ (teoremas 1 y 2).
2. **El recargo protege a la MR3:** termina el evento de 4 h con 3,40 kWh ($\beta_3=1$) o 3,68 kWh ($\beta_3=3$), contra 2,94 kWh sin recargo. La diferencia la paga sobre todo la MR1, que es la que más energía tiene.
3. **Con $\Theta=t_{\mathrm{fin}}-t$, C corrige todo el evento de 8 h** sin vaciar a nadie, y la MR3 (el EV) termina con 2,58 kWh, contra 1,63 kWh sin recargo. Es la mejor combinación del ejemplo.
4. **Con $\Theta$ fijo, C es algo más conservadora que B** en el evento largo (0,38 contra 0,30 kWh sin corregir): proteger a la MR3 tiene un costo en capacidad cuando la energía se acaba. Es el precio honesto de la preferencia.
5. **El precio inicial informa la escasez:** $\lambda_a=0{,}46$ con $\Theta=4$ h; si la fase tuviera que sostener 8 h, el precio inicial sube a 0,86. La misma corrección "cuesta" casi el doble cuando el compromiso es más largo.

---

## 10. Paso 8. Implementación en PLECS

### 10.1 Dos escalas de tiempo

| Qué | Cada cuánto | Por qué |
|---|---|---|
| Cada IC informa $\Pi_k$, $W_k(\Theta)$, $\beta_k$; se calculan $F_k$, $c_k$, $F_\phi$ y se filtran con un paso bajo $\tau_\alpha$ | $T_\alpha\approx$ 30–60 s | la energía cambia lento; evita que el reparto "tiemble" |
| PI de fase y *water-filling* | $T_s\approx$ 1 s | el reparto es no lineal en $\Delta P_\phi$ cuando alguna MR satura, así que se recalcula con cada $\Delta P_\phi$ |
| Terciario (futuro) | 15 min | no interviene |

### 10.2 Algoritmo por fase

```text
Cada T_alpha:
    para cada k: F_k = max( min(Pi_k, W_k/Theta), eps )      # ambas direcciones
                 c_k = (1 + beta_k) / F_k
    F_phi = suma(F_k);   filtrar F_k, c_k, F_phi con tau_alpha

Cada T_s:
    1. medir P_h,a  P_h,b  P_h,c;   e = P_h,phi - (P_h,a + P_h,b + P_h,c)/3
    2. v  = Kp*e + x
    3. dP = min( max(v, -F_phi_dn), F_phi_up )
    4. x  = x + Ki*Ts*e + Kaw*(dP - v)
    5. si dP >= 0 usar (F_up, c_up), si no (F_dn, c_dn)
       lambda por biseccion en [0, max(c_k*F_k)]  (30 iteraciones):
           dP_k(lambda) = sat( lambda/c_k , [-F_dn_k, F_up_k] )
           ajustar lambda hasta que suma(dP_k) = dP
    6. enviar P_ref,k = P*_k + dP_k  a cada IC_k   (Q_ref,k = 0)
    7. registrar lambda_phi, u_phi = dP/F_phi, alpha_k = dP_k/dP
```

En PLECS: un **C-Script por fase** con entradas $P_{h,a},P_{h,b},P_{h,c}$ y los vectores $\Pi_k$, $W_k$, $\beta_k$; salidas $P_{\mathrm{ref},k}$, $\lambda_\phi$, $u_\phi$, $F_\phi$. El paso 5 es un lazo `for` de 30 iteraciones sobre 3 MR: costo despreciable, incluso en tiempo real.

### 10.3 Qué tiene que mostrar la simulación (acuerdo 2)

1. **Desacople:** el mismo escalón de desbalance con α fijo y con C; las respuestas de $e_a(t)$ deben superponerse (proposición 1).
2. **Garantías:** SoC de cada MR dentro de su banda y $|\Delta P_k|\le\Pi_k$ en todo momento (sección 7.3).
3. **Efecto del recargo:** con $\beta_3=0$ y $\beta_3=1$, la MR3 aporta menos y las demás compensan sin superar sus cotas.
4. **Saturación ordenada:** al acercar $\Delta P_a$ a $F_a$, las MR sin recargo saturan primero ($\lambda_a=1$) y el precio sube después (tabla 9.1).
5. **Sin saltos:** las referencias $P_{\mathrm{ref},k}$ son continuas (proposición 3).

Escenario: el del 23-nov §14 (escalón de 1,5 kW durante 4 h más error AR(1) con $\sigma=0{,}5$ kW, $a=0{,}8$), con compresión de tiempo κ para que la simulación sea viable.

---

## 11. Paso 9. Qué se informa hacia arriba (terciario futuro)

Aunque el terciario quede como trabajo futuro (acuerdo 3), C deja definida su interfaz. Cada fase entrega:

| Cifra | Qué dice | Uso en un terciario futuro |
|---|---|---|
| $F_\phi(\Theta)$, para $\Theta\in\lbrace1,2,4,8,12\rbrace$ h | "la fase puede sostener X kW durante Θ horas" | batería equivalente por fase: restricción (b) por fase, $b_\phi+R^{\varepsilon}_\phi\le F_\phi$ |
| $\sum_kW_k$ | energía disponible de la fase | restricción (c) por fase |
| $\lambda_\phi$ | cuánto cuesta corregir en esa fase | señal de precio para un terciario de optimización o de mercado |
| $u_\phi$ | cuánto margen queda | igual que el $u_\phi$ del 23-nov |

**Por qué desaparece la bilinealidad del 23-nov:** el terciario ya no decide cuánto aporta cada MR dentro de una fase; planifica **una batería equivalente por fase**, y el lazo garantiza que lo planificado se puede repartir (teoremas 1 y 2: desagregación realizable [B1, B3]). En el LP no aparece ningún α.

**Por qué los precios no cambian quién corrige entre fases:** $\Delta P_\phi$ lo fija el PI de cada fase según su propio $e_\phi$, y $\sum_\phi e_\phi=0$. El precio $\lambda_\phi$ solo informa; no mueve corrección de una fase a otra (eso sería decisión de un terciario).

---

## 12. Paso 10. Extensión distribuida por consenso (donde entra la línea de Espina)

### 12.1 Por qué distribuir

En la tesis base, C se calcula **centralizada por fase** en la cabecera: es lo más simple de validar y cumple el acuerdo 2. Distribuirla tiene sentido si:
- no se quiere que la cabecera conozca los recargos y la composición de cada MR (privacidad de los clientes con EV);
- se quiere tolerancia a la falla del nodo central de la fase, o *plug-and-play* de nuevas MR.

### 12.2 Una formulación posible (consenso de costo incremental)

Los IC de la fase forman un grafo de comunicación con matriz de pesos doblemente estocástica $D=[d_{kj}]$. La cabecera solo envía $\Delta P_\phi$ a un IC (o a todos). Cada IC $k$ mantiene una estimación de precio $\lambda_k$ y una estimación del desajuste global $y_k$:

```math
\begin{aligned}
\lambda_k[m+1]&=\sum_jd_{kj}\,\lambda_j[m]+\eta\,y_k[m]\\
\Delta P_k[m+1]&=\mathrm{sat}_{[-F^{\downarrow}_k,F^{\uparrow}_k]}\big(\lambda_k[m+1]/c_k\big)\\
y_k[m+1]&=\sum_jd_{kj}\,y_j[m]-\big(\Delta P_k[m+1]-\Delta P_k[m]\big)
\end{aligned}
```

con $\sum_ky_k[0]=\Delta P_\phi-\sum_k\Delta P_k[0]$. Como $D$ es doblemente estocástica, $\sum_ky_k$ es siempre el desajuste entre lo pedido y lo entregado; cuando converge, todos los $\lambda_k$ son iguales a $\lambda_\phi$ y el desajuste es cero. Es la estructura de los algoritmos de consenso de costo incremental [C1, C5], que convergen si el grafo es conexo y $\eta$ es suficientemente pequeño.

### 12.3 Lo que hay que resolver con el profesor (verdad cruda)

1. **Escalas de tiempo:** $\Delta P_\phi$ cambia cada $T_s\approx1$ s. El consenso debe converger bastante más rápido (decenas de iteraciones por segundo), o bien se rediseña a dos escalas: el consenso acuerda lentamente los agregados ($G_\phi=\sum_jF_j/(1+\beta_j)$, $F_\phi$) por promedio dinámico, y cada IC calcula localmente $\Delta P_k=\Delta P_\phi\,F_k/((1+\beta_k)G_\phi)$, que es exacto mientras nadie sature.
2. **Comunicación entre IC:** el correo del 10-nov no la descarta (prohíbe hablar con secundarios y DER, no entre IC), pero es una decisión de arquitectura nueva.
3. **Interacción con el PI:** hay que demostrar que el error transitorio del consenso ($\sum_k\Delta P_k\neq\Delta P_\phi$ mientras converge) no desestabiliza el PI de fase. Es una perturbación acotada que el integrador absorbe, pero hay que probarlo.

Este es el punto donde la experiencia de Espina en consenso con IC como agentes [E1, E2] y en estrategias distribuidas [C2] aporta directamente, y donde la tesis puede tener un aporte propio: **consenso de costo incremental entre varios IC monofásicos de una misma fase, acoplado a un PI de balance en cabecera.**

**Propuesta:** C centralizada por fase para validar (acuerdos 1 y 2); la versión distribuida como segunda etapa, si el profesor la considera parte del alcance.

---

## 13. Decisiones a validar con el profesor

Actualiza la tabla N1–N8 de `lazo_rapido_opciones_B_C.md` con la elección de C.

| # | Decisión | Propuesta | Reemplaza |
|---|---|---|---|
| N1 | Criterio de reparto | **C acotada:** $\min\sum\tfrac12c_k\Delta P_k^2$, $c_k=(1+\beta_k)/F_k$, $\lvert\Delta P_k\rvert\le F_k$ | D2 ($E_k/\sum E$) |
| N2 | Naturaleza del lazo | PI de fase (sin cambios) + reparto óptimo; α efectivo variable con el estado; $T_\alpha$ de 30–60 s | D1 (afín con α constante) |
| N3 | Banda del PI sin terciario | $[-F^{\downarrow}_\phi,\ F^{\uparrow}_\phi]$ | D14 |
| N4 | Referencia del PI sin terciario | $e_\phi\to0$ | D15 |
| N5 | Duración objetivo | $\Theta=4$ h fijo; variante $\Theta=t_{\mathrm{fin}}-t$ | nuevo |
| N6 | Información hacia el terciario futuro | $F_\phi(\Theta)$, $\sum W_k$, $\lambda_\phi$, $u_\phi$ por fase | (b), (c) por MR pasan a ser por fase |
| N7 | Recargo | $\beta_k=0$ en el caso base; $\beta^{\uparrow}_k=1$ para MR con energía mayoritariamente EV; lo declara la MR | nuevo |
| N8 | Cálculo | centralizado por fase; consenso entre IC como segunda etapa | nuevo |
| N9 | Costo | cuadrático (único, continuo, monótono); se descarta el orden de mérito lineal | nuevo |

---

## 14. Preguntas probables y respuestas

1. **"¿Por qué C y no B?"** C contiene a B: con $\beta=0$ son idénticas. C agrega la posibilidad de expresar preferencias (el EV del cliente) y entrega un precio por fase. Las garantías de energía son las mismas porque C conserva las cotas de B.
2. **"¿De dónde sale $c_k$? ¿No es arbitrario?"** No: $c_k=(1+\beta_k)/F_k$ hace que el objetivo sea $\sum\tfrac12(1+\beta_k)F_ku_k^2$, es decir, igualar la utilización de la potencia firme. Sin recargos, todas las MR usan la misma fracción de lo que pueden dar.
3. **"¿Por qué cuadrático?"** Porque da una solución única, continua y monótona; uno lineal da orden de mérito con saltos. Además aproxima pérdidas y desgaste, y es la forma estándar del despacho por costo incremental.
4. **"Si el reparto es no lineal, ¿no cambia la dinámica del PI?"** No. Lo que ve el PI es la suma, y la suma es siempre exactamente $\Delta P_\phi$ (proposición 1).
5. **"¿Qué significa $\lambda_\phi$?"** Cuánto cuesta el último kW de corrección en esa fase. Bajo 1, hay margen barato; sobre 1, se está usando la reserva que las MR prefieren no dar. Con $\beta=0$ es el $u_\phi$ del 23-nov.
6. **"¿Quién fija $\beta_k$?"** La MR, por su IC, junto con su envolvente. El lazo no conoce su composición interna (correo 10-nov).
7. **"¿Hace falta consenso?"** No para la tesis base: el PI está en la cabecera y ya recibe información de los IC. El consenso es la extensión para no centralizar los costos (sección 12).
8. **"¿Y si una MR se equivoca en su pronóstico?"** El colchón $z\sigma_{E,k}$ reduce su $W_k$ y, con él, su $F_k$: se le pide menos. Si el error igual se materializa, $F_k$ se recalcula cada $T_\alpha$ y el teorema 2 la protege.
9. **"¿No es esto un terciario disfrazado?"** No. C optimiza solo en el instante, sin horizonte ni pronóstico. La energía entra solo como cota ($F_k$). Decidir cuánta energía guarda cada MR para mañana sigue siendo del terciario.

---

## 15. Referencias

✔ = título, revista, volumen y DOI confirmados en línea (26-nov-2026). ⚠ = falta confirmar algún dato.

**Línea de Espina**
- [E1] ✔ E. Espina, R. Cárdenas-Dobson, J. W. Simpson-Porco, D. Sáez, M. Kazerani, "A consensus-based secondary control strategy for hybrid AC/DC microgrids with experimental validation," *IEEE Trans. Power Electron.*, vol. 36, no. 5, pp. 5971–5984, 2021, doi:10.1109/TPEL.2020.3031539.
- [E2] ✔ E. Espina González, *Distributed Secondary Control of Hybrid ac/dc Microgrids*, tesis doctoral, University of Waterloo, 2021. UWSpace, handle 10012/17668. Incluye una estrategia distribuida que minimiza el costo de operación de la Micro-red híbrida.
- [C2] ✔ E. Espina, J. Llanos, C. Burgos-Mellado, R. Cárdenas-Dobson, M. Martínez-Gómez, D. Sáez, "Distributed control strategies for microgrids: an overview," *IEEE Access*, vol. 8, pp. 193412–193448, 2020, doi:10.1109/ACCESS.2020.3032378.

**Despacho por costo incremental y consenso**
- [C1] ✔ Z. Zhang, M.-Y. Chow, "Convergence analysis of the incremental cost consensus algorithm under different communication network topologies in a smart grid," *IEEE Trans. Power Syst.*, vol. 27, no. 4, pp. 1761–1768, 2012, doi:10.1109/TPWRS.2012.2188912.
- [C5] ⚠ S. Yang, S. Tan, J.-X. Xu, "Consensus based approach for economic dispatch problem in a smart grid," *IEEE Trans. Power Syst.*, vol. 28, no. 4, pp. 4416–4426, 2013. Introduce la estimación distribuida del desajuste ($y_k$ en la sección 12.2). No se verificó en línea en esta sesión.
- [C3] ✔ K. Lu, S. Dong, Y. Song, "A distributed economic power dispatch strategy considering state of charge for microgrids," *IEEE Access*, 2025 (IEEE Xplore doc. 10963348).
- [C4] ✔ "A distributed AGC power sharing strategy considering BESS participation factors," *Electric Power Systems Research*, vol. 217, art. 109117, 2023. ⚠ Falta confirmar los autores.

**Optimización (KKT y water-filling)**
- [O1] S. Boyd, L. Vandenberghe, *Convex Optimization*. Cambridge University Press, 2004, §5.5 (condiciones KKT) y ejemplo 5.2 (*water-filling*).

**Política afín y desagregación realizable (heredadas de B)**
- [1] ✔ J. Warrington, P. J. Goulart, S. Mariéthoz, M. Morari, "Policy-based reserves for power systems," *IEEE Trans. Power Syst.*, vol. 28, no. 4, pp. 4427–4437, 2013, doi:10.1109/TPWRS.2013.2269804.
- [B1] ✔ H. Hao, B. M. Sanandaji, K. Poolla, T. L. Vincent, "Aggregate flexibility of thermostatically controlled loads," *IEEE Trans. Power Syst.*, vol. 30, no. 1, pp. 189–198, 2015, doi:10.1109/TPWRS.2014.2328865.
- [B3] ⚠ M. Elsaadany, M. R. Almassalkhi, "Making aggregations reliable: realizability guarantees for battery fleets with heterogeneous power and energy limits," arXiv:2606.01562, 2026. Preprint.

**Documentos propios con los que conversa este**
- `documento_formulacion_terciario_lazo_rapido.md` (23-nov): notación, §4 medición, §11 envolvente, §13 PI, tabla D1–D20.
- `lazo_rapido_opciones_B_C.md` (26-nov): comparación B/C, teoremas 1 y 2, ejemplo base.
- `diseno_alfa_variable_lazo_rapido.md` (26-nov): las tres opciones originales A, B, C.
