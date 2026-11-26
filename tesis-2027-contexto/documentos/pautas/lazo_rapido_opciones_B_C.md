# Lazo rápido con factor de participación variable: opciones B y C

**Preparado:** 26-nov-2026. **Estado:** propuesta. No está validada por el profesor y solo se simuló numéricamente un caso simple (sección 8).
**Responde a:** acuerdo 1 de la reunión del 25-nov ("definir con precisión la matemática del lazo rápido y sus variables, justificando su uso en el problema").
**Se apoya en:** `documento_formulacion_terciario_lazo_rapido.md` (23-nov), cuya notación, secciones 4, 11, 13 y tabla de decisiones D1–D20 se mantienen. Esta pauta **reemplaza solo la decisión D2** (cómo se elige α_k) y ajusta las que dependen de ella (D1, D14, D15, D16). El documento general con las tres opciones es `diseno_alfa_variable_lazo_rapido.md`.

---

## Índice

0. Cómo conversa esto con lo presentado antes
1. Qué cambia con el acuerdo 3 (terciario como trabajo futuro)
2. Notación nueva y choques que se evitan
3. Punto de partida común a B y C
4. Opción B: reparto por potencia firme (potencia–energía)
5. Opción C: reparto por costo marginal (despacho óptimo dentro de la fase)
6. Opción adicional: C acotada por B (una sola implementación)
7. Cómo encajan con el terciario futuro (la pregunta del reparto)
8. Ejemplo numérico: fase a del 23-nov, integrado minuto a minuto
9. Comparación y criterio de elección
10. Escenario de simulación propuesto
11. Decisiones a validar con el profesor
12. Preguntas probables y respuestas
13. Referencias (verificadas el 26-nov-2026)

---

## 0. Cómo conversa esto con lo presentado antes

| Presentación | Qué se dijo | Qué pasa ahora |
|---|---|---|
| 9-nov | Lazo rápido por fase, solo sobre los IC; grid-following | **Se mantiene.** |
| 10-nov (correo) | Terciario = energía, lazo = balance; cada MR informa su **envolvente** (P mín/máx, E mín/máx) por medio de su IC | **Se aprovecha:** B y C calculan α_k **con esa misma envolvente**. No se pide ninguna información nueva a las MR. |
| 16-nov (v2) | Lo previsible es energía (ŷ_k) y el error es margen (r_k) | Se mantiene como estructura del terciario futuro (sección 7). |
| 23-nov §4 | $e_\phi=P_{h,\phi}-\bar P_h$, $\sum_\phi e_\phi=0$ | **Se mantiene sin cambios.** |
| 23-nov §5 | Política afín: $P_{\mathrm{IC},k}=P^{\ast}_k+\alpha_k\Delta P_\phi$ | **Se mantiene la forma.** α_k pasa de constante a **variable con el estado** (sección 3.3). |
| 23-nov §6 | $\alpha_k=E_k/\sum_jE_j$, fijo, para que el LP no sea bilineal | **Se reemplaza** (D2). El problema de la bilinealidad se resuelve de otra forma (sección 7). |
| 23-nov §11 | Cada MR calcula $P^{\min/\max}_k(t)$ y $W^{\min/\max}_k(t)$ | **Es la entrada de B y C.** |
| 23-nov §13 | PI con anti-windup por retrocálculo; planta de ganancia uno; $1/K_i$ de 5 a 10 s | **Se mantiene.** Solo cambia de dónde salen los límites de saturación (sección 4.4). |
| 23-nov §13 | Indicador $u_\phi=(\Delta P_\phi-b_\phi)/R^{\varepsilon}_\phi$ | Reaparece de forma natural: en C es el **precio sombra** $\lambda_\phi$ (sección 5.4). |

---

## 1. Qué cambia con el acuerdo 3 (terciario como trabajo futuro)

Sin terciario no existen $b_\phi$, $\rho_\phi$, $R^{\varepsilon}_\phi$ ni $Z_\phi$, porque todos los fijaba el LP. En consecuencia:

1. **El PI corrige todo el desbalance**, previsible y error, con referencia $e_\phi\to 0$ (D15 con $\rho_\phi=0$).
2. **$P^{\ast}_k$ deja de ser un plan del terciario**: es el punto de operación nominal que fija la propia MR, por ejemplo 0 o su intercambio programado. Lo informa con su envolvente.
3. **Los límites del PI ya no vienen del terciario** ($b_\phi\pm R^{\varepsilon}_\phi$). Hay que obtenerlos de la disponibilidad real de las MR de la fase. **Esa es la función nueva de α_k.**
4. Por lo tanto, α_k tiene que hacer **dos cosas a la vez**: repartir $\Delta P_\phi$ entre los IC y **resumir la disponibilidad de la fase** en una o dos cifras que el terciario futuro pueda usar.

> **En simple.** Antes el terciario le decía al lazo "tienes este presupuesto". Ahora el lazo tiene que averiguar su presupuesto preguntándole a cada Micro-red cuánto puede dar, y repartir el trabajo de acuerdo con eso. Cuando el terciario exista, el lazo le entrega ese mismo resumen ya hecho.

---

## 2. Notación nueva y choques que se evitan

En la formulación del 23-nov, $T$ es el número de tramos del horizonte, $H$ el horizonte del terciario, $S_\phi$ la inyección total de los IC de una fase y $n$ el número de tramos acumulados. Para no chocar con esos símbolos:

| Símbolo | Qué es | Unidad | Tipo | De dónde sale |
|---|---|---|---|---|
| $\Theta$ | **duración objetivo**: cuánto tiempo se quiere poder sostener la corrección | h | D | sección 4.5 |
| $\Pi^{\uparrow}_k(t)=P^{\max}_k(t)-P^{\ast}_k(t)$ | holgura de **potencia** para inyectar más | kW | E | envolvente 23-nov §11 |
| $\Pi^{\downarrow}_k(t)=P^{\ast}_k(t)-P^{\min}_k(t)$ | holgura de potencia para absorber más | kW | E | envolvente |
| $W^{\uparrow}_k(t;\Theta)$ | **energía** adicional que el IC puede entregar en $[t,t+\Theta]$ sin salir de la banda de SoC | kWh | E | envolvente: $W^{\max}_k$ menos lo comprometido por $P^{\ast}_k$ |
| $W^{\downarrow}_k(t;\Theta)$ | energía adicional que puede absorber en $[t,t+\Theta]$ | kWh | E | envolvente: lo comprometido menos $W^{\min}_k$ |
| $F^{\uparrow}_k$, $F^{\downarrow}_k$ | **potencia firme**: la que la MR puede sostener durante $\Theta$ | kW | E | sección 4.1 |
| $F^{\uparrow}_\phi=\sum_{k\in\mathcal N_\phi}F^{\uparrow}_k$ | potencia firme de la fase | kW | E | – |
| $c_k$ | costo de pedirle potencia a la MR $k$ (opción C) | adim. | D/E | sección 5.3 |
| $\lambda_\phi$ | precio sombra del balance en la fase $\phi$ (opción C) | adim. | E | sección 5.2 |
| $\beta_k$ | recargo por usar la MR $k$ (EV del cliente, degradación) | adim. | D | sección 5.3 |

Con las definiciones del 23-nov §11, y con $E_{B,k}$ la energía almacenada:

```math
W^{\uparrow}_k(t;\Theta)=\underbrace{E_{B,k}(t)-E^{\min}_{B,k}}_{\text{lo que tiene sobre el mínimo}}+\int_t^{t+\Theta}\big(\hat P_{\mathrm{net},k}-P^{\ast}_k\big)\,d\tau-z\,\sigma_{E,k}(\Theta)
```

```math
W^{\downarrow}_k(t;\Theta)=\underbrace{E^{\max}_{B,k}-E_{B,k}(t)}_{\text{lo que le cabe}}-\int_t^{t+\Theta}\big(\hat P_{\mathrm{net},k}-P^{\ast}_k\big)\,d\tau-z\,\sigma_{E,k}(\Theta)
```

El último término es el colchón por el error propio de la MR, igual que en el 23-nov §11. **La MR ya calcula todo esto para su envolvente.** Lo único nuevo es evaluarlo sobre una ventana $\Theta$ que se mueve con el tiempo.

Convención de signo: la del 23-nov, $\Delta P_\phi>0$ significa que los IC de la fase inyectan más (descargan). Se usan las magnitudes $\uparrow$ si $\Delta P_\phi>0$ y las $\downarrow$ si $\Delta P_\phi<0$. Para aliviar la escritura, de aquí en adelante se escribe el caso $\uparrow$; el caso $\downarrow$ es simétrico.

---

## 3. Punto de partida común a B y C

### 3.1 Estructura

```math
P_{\mathrm{ref},k}=P^{\ast}_k+\alpha_k(t)\,\Delta P_\phi,\qquad \alpha_k(t)\ge 0,\quad\sum_{k\in\mathcal N_\phi}\alpha_k(t)=1
```

### 3.2 El PI no se entera de que α varía

Del 23-nov §13.4, cada fase ve la planta $e_\phi=d_\phi-\sum_k\Delta P_k$. Como $\sum_k\alpha_k=1$:

```math
\sum_{k\in\mathcal N_\phi}\alpha_k(t)\,\Delta P_\phi=\Delta P_\phi\quad\Rightarrow\quad e_\phi=d_\phi-\Delta P_\phi
```

**La planta sigue teniendo ganancia uno, sea cual sea α(t).** La sintonía por cancelación polo-cero ($K_p=K_iT_{\mathrm{IC}}$, $1/K_i$ de 5 a 10 s) **no cambia**.

Supuesto a validar en PLECS: los IC de una fase tienen constantes $T_{\mathrm{IC}}$ parecidas. Si fueran muy distintas, al cambiar α se movería la constante de tiempo equivalente, aunque el efecto sería de segundo orden porque $T_{\mathrm{IC}}\ll 1/K_i$.

### 3.3 Qué cambia respecto de la política afín del 23-nov

En Warrington et al. [1], el factor de participación es una **constante decidida de antemano**. Aquí α_k depende del estado (SoC y envolvente), así que **el lazo ya no es afín en sentido estricto**. Es afín en $\Delta P_\phi$ **en cada instante**, con una ganancia programada por el estado (*gain scheduling*). Esto se puede defender por **separación de escalas**:

- α_k se recalcula cada $T_\alpha\approx$ 30–60 s, y además se filtra con un paso bajo de constante $\tau_\alpha$;
- el PI actúa con $1/K_i\approx$ 5–10 s;
- el terciario futuro actuaría cada 15 min.

Mirado desde el PI, α es una constante. Mirado desde el terciario, es una **regla conocida**: el terciario no necesita saber el valor de α para predecir qué va a pasar, porque conoce la regla (sección 7).

### 3.4 Continuidad al cambiar de dirección

Cuando $\Delta P_\phi$ cruza 0, α salta entre su versión $\uparrow$ y su versión $\downarrow$. Pero $\alpha_k\Delta P_\phi=0$ en ese punto, así que $P_{\mathrm{ref},k}$ es continua.

---

## 4. Opción B: reparto por potencia firme (potencia–energía)

### 4.1 Ley

```math
F^{\uparrow}_k(t)=\min\!\Big(\Pi^{\uparrow}_k(t),\ \frac{W^{\uparrow}_k(t;\Theta)}{\Theta}\Big),\qquad
\alpha^{\uparrow}_k(t)=\frac{F^{\uparrow}_k(t)}{F^{\uparrow}_\phi(t)},\qquad F^{\uparrow}_\phi=\sum_{j\in\mathcal N_\phi}F^{\uparrow}_j
```

$F_k$ es la **potencia que la MR $k$ puede sostener durante $\Theta$ horas**: lo que permite su IC ($\Pi_k$) o lo que alcanza su energía repartida en $\Theta$ ($W_k/\Theta$), lo que sea menor.

### 4.2 Teorema 1 (garantía con Θ fijo)

**Enunciado.** Si durante $[t_0,t_0+\Theta]$ se cumple $0\le\Delta P_\phi(t)\le F^{\uparrow}_\phi(t_0)$ y los $F_k$ se mantienen en su valor de $t_0$, entonces ninguna MR supera su potencia ni sale de su banda de SoC en ese intervalo.

**Demostración.**
- Potencia: $\Delta P_k=\dfrac{F_k}{F_\phi}\Delta P_\phi\le F_k\le\Pi_k$.
- Energía: $\displaystyle\int_{t_0}^{t_0+\Theta}\Delta P_k\,dt\le F_k\,\Theta\le\frac{W_k}{\Theta}\,\Theta=W_k$. ∎

### 4.3 Teorema 2 (Θ rodante: aterrizaje suave)

**Enunciado.** Si $F_k$ se recalcula continuamente con $\Theta$ fijo y $|\Delta P_\phi|\le F_\phi$ en todo momento, la energía disponible de cada MR cumple

```math
W_k(t)\ \ge\ W_k(t_0)\,e^{-(t-t_0)/\Theta}\ >\ 0 .
```

**Ninguna MR llega a vaciarse.**

**Demostración.** $\dfrac{dW_k}{dt}=-\Delta P_k\ge-F_k\ge-\dfrac{W_k}{\Theta}$. Por comparación con la ecuación $\dot y=-y/\Theta$ se obtiene la cota. ∎

**Consecuencia física.** A medida que la energía baja, $F_\phi$ baja, y con ella el límite del PI (sección 4.4). La fase **pierde capacidad gradualmente**, nunca de golpe. Con α fijo (23-nov), en cambio, una MR se vacía en un instante preciso y la fase pierde su aporte de una vez (sección 8).

**Costo honesto.** Con $\Theta$ fijo y rodante, B es **conservadora**: nunca usa toda la energía y puede dejar desbalance sin corregir aunque todavía quede energía (en la sección 8, 0,30 kWh en un evento de 8 h). Si se quiere usar toda la energía hasta un instante final conocido, se usa $\Theta(t)=t_{\mathrm{fin}}-t$ (sección 4.5).

### 4.4 Límites del PI: la banda sale de B

Reemplaza a D14 mientras no haya terciario:

```math
\Delta P_\phi=\mathrm{sat}_{[-F^{\downarrow}_\phi,\ F^{\uparrow}_\phi]}(v),\qquad v=K_p\,e_\phi+x
```

El anti-windup por retrocálculo del 23-nov §13.6 se mantiene igual: $x\leftarrow x+K_iT_s\,e_\phi+K_{aw}(\Delta P_\phi-v)$. Como $F_\phi$ varía lentamente, la banda se mueve sin saltos y no hace falta el ajuste *bumpless* por cambio de $b_\phi$.

### 4.5 Cómo elegir Θ

| Criterio | Θ | Qué se obtiene |
|---|---|---|
| Duración del evento típico de desbalance (clientes monofásicos al atardecer) | fijo, p. ej. 4 h | Teorema 2: nunca vacía; conservador |
| Instante en que termina el evento | $\Theta(t)=\max(t_{\mathrm{fin}}-t,\ \Theta_{\min})$ | usa toda la energía hasta $t_{\mathrm{fin}}$, sin vaciar antes |
| Horizonte del terciario futuro | $\Theta=H=12$ h | coherente con el LP del 23-nov |

$\Theta_{\min}$ (por ejemplo 15 min $=\Delta t$) evita dividir por cero al final. **Propuesta:** $\Theta=4$ h fijo como caso base, y $\Theta(t)=t_{\mathrm{fin}}-t$ como variante a comparar.

### 4.6 Qué información entrega hacia arriba

Cada $T_\alpha$, el lazo de cada fase dispone de:

- $F^{\uparrow}_\phi(\Theta)$ y $F^{\downarrow}_\phi(\Theta)$: **"la fase $a$ puede sostener 3,5 kW de corrección durante 4 h"**;
- la curva $\Theta\mapsto F_\phi(\Theta)$ para $\Theta\in\{1,2,4,8,12\}$ h: una **envolvente potencia–duración por fase**;
- la utilización $u_\phi=\Delta P_\phi/F_\phi\in[-1,1]$, que tiene el mismo significado que el $u_\phi$ del 23-nov: 0 en reposo y 1 con el margen agotado.

### 4.7 Implementación (cada $T_s\approx1$ s, por fase)

```math
\begin{aligned}
&\text{Cada }T_\alpha\text{ (30–60 s): cada IC}_k\text{ informa }\Pi^{\uparrow\downarrow}_k,\ W^{\uparrow\downarrow}_k(\Theta);\ \text{se calculan }F_k,\ F_\phi,\ \alpha_k\ \text{y se filtran con }\tau_\alpha\\
&\text{1. medir }P_{h,a},P_{h,b},P_{h,c};\quad e_\phi=P_{h,\phi}-\tfrac13\textstyle\sum_\psi P_{h,\psi}\\
&\text{2. }v=K_p\,e_\phi+x\\
&\text{3. }\Delta P_\phi=\min\!\big(\max(v,-F^{\downarrow}_\phi),\ F^{\uparrow}_\phi\big)\\
&\text{4. }x\leftarrow x+K_iT_s\,e_\phi+K_{aw}(\Delta P_\phi-v)\\
&\text{5. enviar }\Delta P_k=\alpha^{\mathrm{sgn}(\Delta P_\phi)}_k\,\Delta P_\phi\ \text{a cada IC}_k\\
&\text{6. (monitoreo) }u_\phi=\Delta P_\phi/F^{\mathrm{sgn}}_\phi
\end{aligned}
```

**Sigue siendo la separación del 10-nov.** El lazo no le habla a los DER. Recibe del IC dos números por dirección ($\Pi_k$, $W_k$), que el IC ya conoce por la envolvente que calcula su secundario.

### 4.8 Explicación pedagógica

Un equipo de corredores (las MR) debe mantener entre todos una velocidad durante una carrera de $\Theta$ horas.

- No es justo pedirle a cada uno **lo mismo**, ni algo proporcional a su **tamaño** (eso es $\alpha=E_k/\sum E$).
- A cada uno se le pregunta: **"¿qué velocidad puedes mantener durante toda la carrera?"**. Un velocista (IC grande, poca batería) puede ir muy rápido, pero por poco rato: su respuesta la limita la energía, $W_k/\Theta$. Un fondista (IC chico, mucha batería) aguanta mucho, pero no corre rápido: su respuesta la limita la potencia, $\Pi_k$.
- La **suma** de las respuestas, $F_\phi$, es lo máximo que el equipo puede **prometer** para toda la carrera.
- Cada uno aporta según lo que prometió. Así nadie se agota antes que el resto, y si el equipo va más lento de lo pedido, se nota de a poco y no con un corredor que cae de golpe.

Lo que el equipo le dice al entrenador (el terciario futuro) es esa promesa: **"podemos sostener 3,5 kW durante 4 h"**.

### 4.9 Qué valida la simulación

1. El PI no cambia su respuesta cuando α varía (sección 3.2): comparar los escalones de $e_\phi$ con α fijo y con α de B.
2. Ninguna MR sale de su banda de SoC ni supera $\Pi_k$ (teoremas 1 y 2).
3. Con $\Theta$ fijo, la capacidad de la fase decae de forma suave; con $\Theta=t_{\mathrm{fin}}-t$, se usa toda la energía sin vaciar ninguna MR antes de $t_{\mathrm{fin}}$.
4. La potencia firme informada coincide con la que la fase sostiene realmente.

---

## 5. Opción C: reparto por costo marginal (despacho óptimo dentro de la fase)

### 5.1 Ley

Cada $T_\alpha$ se resuelve, por fase, un despacho económico instantáneo:

```math
\min_{\Delta P_k}\ \sum_{k\in\mathcal N_\phi}\tfrac12\,c_k\,\Delta P_k^{2}\qquad\text{s.a.}\qquad\sum_{k\in\mathcal N_\phi}\Delta P_k=\Delta P_\phi,\qquad -\bar F^{\downarrow}_k\le\Delta P_k\le\bar F^{\uparrow}_k
```

$c_k>0$ es el costo de pedirle potencia a la MR $k$, y $\bar F_k$ son sus cotas (sección 6).

### 5.2 Solución (condiciones KKT)

El lagrangiano es $\mathcal L=\sum_k\tfrac12c_k\Delta P_k^2-\lambda_\phi(\sum_k\Delta P_k-\Delta P_\phi)$. **Sin cotas activas:**

```math
\frac{\partial\mathcal L}{\partial\Delta P_k}=c_k\Delta P_k-\lambda_\phi=0\ \Rightarrow\ \Delta P_k=\frac{\lambda_\phi}{c_k},\qquad \lambda_\phi=\frac{\Delta P_\phi}{\sum_j1/c_j},\qquad \boxed{\alpha_k=\frac{1/c_k}{\sum_j1/c_j}}
```

**Con cotas activas (water-filling):**

```math
\Delta P_k=\min\!\Big(\bar F^{\uparrow}_k,\ \max\!\big(-\bar F^{\downarrow}_k,\ \lambda_\phi/c_k\big)\Big),\qquad \text{con }\lambda_\phi\text{ tal que }\sum_k\Delta P_k=\Delta P_\phi
```

La suma es monótona en $\lambda_\phi$, así que $\lambda_\phi$ se encuentra por bisección (unas 30 iteraciones) u ordenando los cocientes $c_k\bar F_k$. Las MR saturadas quedan en su cota y las demás **igualan su costo marginal** $c_k\Delta P_k=\lambda_\phi$.

### 5.3 Cómo se codifica la energía y la prioridad en $c_k$

**Recomendación:**

```math
c_k=\frac{1+\beta_k}{F_k}
```

- $1/F_k$ es el término de **escasez**: a menor potencia firme, más caro. Tiende a infinito cuando la MR se queda sin energía o sin potencia.
- $\beta_k\ge0$ es el **recargo**:
  - prioridad del usuario si la MR es casi toda EV (no se quiere usar el auto del cliente salvo que haga falta);
  - degradación relativa de su batería;
  - pérdidas, si la MR está lejos de la cabecera.

**Resultado clave:** con $\beta_k=0$ para todas, $\alpha_k=F_k/\sum_jF_j$. **C reproduce exactamente B.** B es el caso particular de C en el que todas las MR tienen la misma prioridad.

Otras elecciones posibles (menos recomendadas):
- $c_k=\gamma/(E_kh_k^{\,n})$ recupera la opción A del documento general;
- $c_k$ como costo de degradación en \$/kWh² exige datos de la batería que hoy no están.

### 5.4 El precio sombra es el uso del margen

Con $\beta_k=0$:

```math
\lambda_\phi=\frac{\Delta P_\phi}{\sum_j1/c_j}=\frac{\Delta P_\phi}{\sum_jF_j}=\frac{\Delta P_\phi}{F_\phi}=u_\phi
```

**El precio sombra es exactamente el indicador $u_\phi$ del 23-nov.** Tiene la misma interpretación, uso del margen de la fase entre 0 y 1, y ahora además el sentido económico de **lo que cuesta un kW más de corrección en esa fase**. Si $\lambda_a\gg\lambda_b$, el balance "sale caro" en la fase $a$. Es una sola cifra por fase, comparable entre fases, útil para un terciario futuro de optimización o de mercado.

### 5.5 ¿Hace falta consenso? (vínculo con la línea de Espina)

**Respuesta honesta:** en la arquitectura actual el PI de cada fase está en la cabecera y ya recibe información de los IC, así que **C se puede calcular centralizado por fase** y no necesita consenso.

El consenso de costo incremental [C1] sería útil si se quiere que **los IC calculen $\lambda_\phi$ entre ellos**, sin que la cabecera conozca los costos individuales (por ejemplo, por privacidad de los clientes con EV). Cada IC iteraría:

```math
\lambda_k[m+1]=\sum_{j}a_{kj}\,\lambda_j[m]+\eta\,\big(\Delta P^{\mathrm{asig}}_k-\Delta P_k[m]\big)
```

y converge a un $\lambda_\phi$ común si el grafo de comunicación tiene un árbol de expansión [C1].

Esto extiende la contribución doctoral de Espina (el IC como agente de consenso) [C2]. **Pero agrega una dinámica más que validar**, que debe converger más rápido que $T_\alpha$. **Propuesta:** C centralizada por fase en la tesis, y el consenso como extensión.

### 5.6 Explicación pedagógica

Es un **mercado** dentro de la fase. El lazo necesita "comprar" $\Delta P_\phi$ kW de corrección, y cada MR pone un **precio** por cada kW:

- el precio **sube cuando a la MR le queda poca potencia firme**, porque no quiere quedarse sin batería;
- una MR que es casi solo el EV de un cliente cobra un **recargo**, porque usar ese auto molesta más.

El lazo compra primero a las más baratas, y a medida que compra más a una, su precio sube. Al final **todas cobran lo mismo por el último kW**: ese precio común es $\lambda_\phi$. Si nadie tiene recargos, el mercado reparte exactamente como en B, y el precio es simplemente "qué fracción del margen se está usando".

Lo que la fase le dice al terciario futuro es el precio: **"aquí balancear cuesta 0,43; en la fase b, 0,10"**.

### 5.7 Qué valida la simulación

Lo mismo que B, y además:
1. que con $\beta_3>0$ la MR con recargo aporta menos y las demás compensan sin superar sus cotas;
2. que el water-filling respeta las cotas cuando $\Delta P_\phi$ se acerca a $F_\phi$;
3. que $\lambda_\phi$ ordena correctamente las fases según su escasez.

---

## 6. Opción adicional: C acotada por B (una sola implementación)

En C, si se usa $c_k=(1+\beta_k)/F_k$ **y** las cotas $\bar F_k=F_k$ de B:

- **El conjunto de lo posible lo fija B.** Cada MR nunca entrega más que su potencia firme, así que los teoremas 1 y 2 **siguen valiendo**, porque solo usan $|\Delta P_k|\le F_k$.
- **La preferencia dentro de ese conjunto la fija C.** El recargo $\beta_k$ decide quién aporta primero.
- **La capacidad de la fase no cambia:** sigue siendo $F_\phi=\sum F_k$. Cuando $\Delta P_\phi\to F_\phi$ todas saturan, tengan o no recargo.
- Con $\beta_k=0$ es B, y con $\beta_k>0$ es C. **Es un solo bloque en PLECS con un parámetro.**

> **En simple.** B dice **cuánto puede dar cada uno**. C dice **a quién le pido primero**. Juntas, nunca le pido a nadie más de lo que puede dar, y entre los que pueden, prefiero a los que menos molesta.

Otras alternativas que **se descartan** para la tesis:
- **Orden de mérito estricto** (primero BESS, después EV): es el límite de C con $\beta\to\infty$. Produce saltos de α cuando una MR satura.
- **MPC dentro de la fase:** optimizaría el reparto sobre una ventana futura. Le quita al terciario el trabajo que le corresponde y es demasiado pesado para el lazo rápido.

---

## 7. Cómo encajan con el terciario futuro (la pregunta del reparto)

En el 23-nov (§6.1) el problema era el siguiente: si el terciario elige cuánto aporta cada MR y el lazo reparte de otra manera, lo planificado no es lo que ocurre. La solución fue fijar α, y optimizarlo habría hecho el LP bilineal.

**Con B o C la pregunta cambia de nivel.** El terciario futuro ya no tiene que repartir entre las MR de una fase: le basta **una batería equivalente por fase**, con potencia $F_\phi$ y energía $\sum_kW_k$. Las restricciones (b) y (c) del 23-nov pasan de ser por MR a ser **por fase**:

```math
\text{(b}_\phi\text{)}\quad b_\phi(t)+R^{\varepsilon\uparrow}_\phi(t)\le F^{\uparrow}_\phi(t),\qquad
\text{(c}_\phi\text{)}\quad \sum_{s\le t}b_\phi(s)\Delta t+Z^{\uparrow}_\phi(t)\le\sum_{k\in\mathcal N_\phi}W^{\uparrow}_k(t)
```

(y las simétricas hacia abajo). Ya **no aparece ningún α en el LP**: la bilinealidad desaparece y el LP es más pequeño (una variable por fase en vez de una por MR).

**¿Por qué es legítimo?** Porque el lazo garantiza que lo que la fase promete se puede repartir entre sus MR: los teoremas 1 y 2 dicen que si la fase pide $\le F_\phi$, ninguna MR se sale de sus límites. En la literatura esto se llama **desagregación realizable** de un modelo de batería agregado [B1, B3]. El modelo agregado es una **aproximación interior** (conservadora) del conjunto real, que es justamente lo que garantiza que el plan se pueda cumplir.

**El reparto queda así:** el terciario decide **entre fases y en el tiempo** (energía), y el lazo decide **dentro de la fase y en el instante** (con α). Es la misma separación de roles del 10-nov, llevada al reparto.

---

## 8. Ejemplo numérico: fase a del 23-nov, integrado minuto a minuto

**Datos del 23-nov:** fase $a$ con 3 MR, $E=10/10/5$ kWh, desbalance previsible de 1,5 kW durante 4 h (18–22 h), $R^{\varepsilon}=1{,}37$ kW.

**Supuestos agregados** (no son datos medidos; se declaran):
- energía disponible a las 18:00: $W^{\uparrow}=10/2/4$ kWh. La MR1 está llena, la MR2 al 20 % de su banda y la MR3 al 80 %;
- holgura de potencia: $\Pi^{\uparrow}=3/3/0{,}5$ kW (la MR3 tiene un IC pequeño);
- $P^{\ast}_k=0$, sin FV de noche y con la carga propia ya descontada de la envolvente;
- se integró con paso de 1 min, sin pérdidas.

### 8.1 Reparto inicial con $\Delta P_a=1{,}5$ kW

| | MR1 | MR2 | MR3 | Fase |
|---|---|---|---|---|
| $W^{\uparrow}/\Theta$ con $\Theta=4$ h | 2,5 | 0,5 | 1,0 | – |
| $\Pi^{\uparrow}$ | 3,0 | 3,0 | 0,5 | – |
| $F^{\uparrow}$ | **2,5** (energía) | **0,5** (energía) | **0,5** (potencia) | **3,5 kW** |
| α fijo 23-nov ($E_k/\sum E$) | 0,400 | 0,400 | 0,200 | – |
| α B ($F_k/F_\phi$) | 0,714 | 0,143 | 0,143 | – |
| α C, $\beta_3=1$ | 0,769 | 0,154 | 0,077 | – |
| $\Delta P_k$ α fijo [kW] | 0,60 | 0,60 | 0,30 | 1,5 |
| $\Delta P_k$ B [kW] | 1,07 | 0,21 | 0,21 | 1,5 |
| $\Delta P_k$ C [kW] | 1,15 | 0,23 | 0,12 | 1,5 |

- **Indicador:** $u_a=\lambda_a=1{,}5/3{,}5=0{,}43$ en B. En C, $\lambda_a=1{,}5/3{,}25=0{,}46$.
- **Con el margen del 23-nov:** $b+R=2{,}87\le F_a=3{,}5$ kW, así que la fase cubre lo previsible y el error. En B, a 2,87 kW: $\Delta P_k=2{,}05/0{,}41/0{,}41\le F_k$. ✓

### 8.2 Evolución integrada (evento de 4 h y de 8 h)

| Caso | Energía final MR1/MR2/MR3 [kWh] | ¿Alguna se vacía? | Desbalance no corregido [kWh] | $F_a$ al final [kW] |
|---|---|---|---|---|
| α fijo, 4 h | 7,33 / **0,00** / 2,67 | **MR2 a las 3,33 h (21:20)** | 0 | 2,33 |
| B, $\Theta=4$ h fijo, 4 h | 5,88 / 1,18 / 2,94 | no | 0 | 2,26 |
| B, $\Theta=t_{\mathrm{fin}}-t$, 4 h | 6,01 / 0,67 / 3,32 | no | 0 | – |
| C ($\beta_3=1$), $\Theta=4$ h, 4 h | 5,50 / 1,10 / 3,40 | no | 0 | 2,15 |
| α fijo, 8 h | 3,33 / **0,00** / 0,67 | **MR2 a las 3,33 h** | 0 | – |
| B, $\Theta=4$ h fijo, 8 h | 2,46 / 0,49 / 1,34 | no | **0,30** | 1,07 |
| B, $\Theta=t_{\mathrm{fin}}-t$, 8 h | 2,09 / 0,29 / 1,63 | no | 0 | – |
| C ($\beta_3=1$), $\Theta=4$ h, 8 h | 2,09 / 0,42 / 1,86 | no | 0,38 | 1,09 |

### 8.3 Lectura

1. **α fijo vacía a la MR2 a las 21:20.** Es la misma historia que el "20:40" del 16-nov, ahora dentro de la fase. Desde ese momento la MR2 no tiene margen para el error ni para sus propias cargas. La fase sigue corrigiendo porque las otras dos compensan, pero una MR quedó en cero.
2. **B y C nunca vacían a nadie** y respetan $\Pi_3=0{,}5$ kW en todo momento.
3. **B con $\Theta$ fijo es conservadora:** en 8 h deja 0,30 kWh sin corregir aunque todavía quedan 4,3 kWh. Es el precio del teorema 2: guarda energía por si el evento se alarga.
4. **B con $\Theta=t_{\mathrm{fin}}-t$ corrige todo** (como α fijo) **sin vaciar a nadie.** Si se conoce el fin del evento, es la mejor de las tres.
5. **C desplaza el esfuerzo:** la MR3 (con recargo) termina con 3,40 kWh en vez de 2,94. Lo paga la MR1.

---

## 9. Comparación y criterio de elección

| Criterio | B | C | C acotada por B |
|---|---|---|---|
| Entrada que necesita | $\Pi_k$, $W_k$ (envolvente del 10-nov) | lo mismo más $\beta_k$ | lo mismo más $\beta_k$ |
| Parámetros nuevos | $\Theta$ | $\Theta$, $\beta_k$ | $\Theta$, $\beta_k$ |
| Garantía demostrable | teoremas 1 y 2 | solo optimalidad (sin las cotas de B, no garantiza energía) | teoremas 1 y 2 más optimalidad |
| Qué informa hacia arriba | $F_\phi(\Theta)$: potencia firme | $\lambda_\phi$: precio | ambos |
| Efecto sobre el PI | ninguno (Σα = 1); la banda sale de $F_\phi$ | ninguno; la misma banda | ninguno |
| Encaje con el terciario futuro | batería equivalente por fase; el LP sin α | precio por fase | ambos |
| Justificación ante el profesor (acuerdo 1) | **fácil**: cada variable tiene sentido físico (kW, kWh, h) | media: hay que justificar $\beta_k$ | media |
| Vínculo con Espina | envolvente del 10-nov | consenso de su doctorado (si se distribuye) | ambos |
| Riesgo para la próxima semana | **bajo** | medio | bajo si $\beta=0$ |

**Criterio sugerido para decidir:**
- Si lo prioritario es **cumplir el acuerdo 1** (cada variable justificada) y **validar la simulación** (acuerdo 2) en una semana: **B**.
- Si quieres que la tesis tenga un **aporte de reparto con preferencias** (EV del cliente, degradación) y una **señal económica** para el terciario: **C acotada por B**. Se implementa como B con un parámetro extra, así que no cuesta más simularla.
- C sin las cotas de B: **no se recomienda**, porque pierde la garantía de energía.

---

## 10. Escenario de simulación propuesto

Es el mismo escenario del 23-nov, para que todo converse: fase $a$ con 3 MR y los datos de la sección 8, en el modelo promedio de PLECS.

1. **Escalón de 1,5 kW durante 4 h**, más un error aleatorio con $\sigma=0{,}5$ kW y $a=0{,}8$ (del 23-nov §14). Para que la simulación sea viable, se usa compresión de tiempo: escalar las energías por $1/\kappa$ (pendiente 8 del CLAUDE.md).
2. **Casos:** α fijo (línea base); B con $\Theta=4$ h; B con $\Theta=t_{\mathrm{fin}}-t$; C acotada con $\beta_3=1$.
3. **Métricas:**
   - $e_a(t)$ (que el PI siga igual);
   - SoC de cada MR;
   - $\min_t W_k$;
   - energía no corregida $\int|e_a|\,dt$;
   - $F_a(t)$ y $u_a(t)$;
   - instante de la primera saturación.
4. **Prueba de desacople:** el mismo escalón con α fijo y con α de B. Las respuestas de $e_a$ deben superponerse (sección 3.2).

---

## 11. Decisiones a validar con el profesor

| # | Decisión | Propuesta | Reemplaza |
|---|---|---|---|
| N1 | Criterio de reparto | B: $\alpha_k=F_k/F_\phi$ (o C acotada) | D2 ($E_k/\sum E$) |
| N2 | Naturaleza del lazo | afín en $\Delta P_\phi$ con ganancia programada por estado; $T_\alpha$ de 30–60 s, filtrada | D1 (afín con α constante) |
| N3 | Banda del PI sin terciario | $[-F^{\downarrow}_\phi,\ F^{\uparrow}_\phi]$ | D14 ($b_\phi\pm R$) |
| N4 | Referencia del PI sin terciario | $e_\phi\to0$ | D15 ($e_\phi\to\rho_\phi$) |
| N5 | Duración objetivo | $\Theta=4$ h fijo; variante $t_{\mathrm{fin}}-t$ | nuevo |
| N6 | Información hacia el terciario futuro | $F_\phi(\Theta)$ y $\sum W_k$ por fase; $u_\phi=\lambda_\phi$ | (b), (c) por MR pasan a ser por fase |
| N7 | Recargo en C | $\beta_k$ por EV o degradación; $\beta=0$ en el caso base | nuevo |
| N8 | Consenso | centralizado por fase en la tesis; consenso como extensión | nuevo |

---

## 12. Preguntas probables y respuestas

1. **"Si α cambia, ¿no cambia la dinámica del lazo?"** No. $\sum\alpha_k=1$, así que la planta sigue siendo $e_\phi=d_\phi-\Delta P_\phi$ (ganancia uno). Además α varía cada 30–60 s y el PI responde en 5–10 s.
2. **"¿Por qué no seguir con $E_k/\sum E$?"** Porque ignora el estado. En el ejemplo, vacía a la MR2 a las 21:20, cuando la MR1 y la MR3 todavía tienen 11 kWh disponibles. B no vacía a nadie.
3. **"¿Qué es $\Theta$ y por qué 4 h?"** Es la duración que la fase debe poder sostener: la del evento típico de desbalance al atardecer. Si se conoce el fin del evento se usa $t_{\mathrm{fin}}-t$, que no deja ningún parámetro libre.
4. **"¿El lazo habla con los DER?"** No. Recibe del IC $\Pi_k$ y $W_k$, que el IC conoce por la envolvente de su MR (correo del 10-nov).
5. **"¿Y el problema bilineal del 23-nov?"** Desaparece. El terciario futuro planifica una batería equivalente por fase ($F_\phi$, $\sum W_k$), sin α en el LP. El lazo garantiza que ese plan se puede repartir (teoremas 1 y 2; desagregación realizable [B3]).
6. **"¿B no es demasiado conservadora?"** Con $\Theta$ fijo sí, y es intencional (teorema 2). Con $\Theta=t_{\mathrm{fin}}-t$ corrige todo el evento del ejemplo sin vaciar a nadie.
7. **"¿Qué aporta C sobre B?"** Permite preferencias ($\beta_k$: no usar el EV del cliente salvo que haga falta) y entrega un precio por fase. Con $\beta=0$ es B, así que no hay que elegir de antemano: es un parámetro.

---

## 13. Referencias (verificadas el 26-nov-2026)

✔ = título, revista, volumen y DOI confirmados en línea. ⚠ = falta confirmar algún dato bibliográfico.

**Base (política afín, ya citada el 23-nov)**
- [1] ✔ J. Warrington, P. J. Goulart, S. Mariéthoz, M. Morari, "Policy-based reserves for power systems," *IEEE Trans. Power Syst.*, vol. 28, no. 4, pp. 4427–4437, 2013, doi:10.1109/TPWRS.2013.2269804.
- [2] ✔ D. Bienstock, M. Chertkov, S. Harnett, "Chance-constrained optimal power flow: risk-aware network control under uncertainty," *SIAM Review*, vol. 56, no. 3, pp. 461–495, 2014.

**Opción B: potencia firme, batería agregada y desagregación realizable**
- [B1] ✔ H. Hao, B. M. Sanandaji, K. Poolla, T. L. Vincent, "Aggregate flexibility of thermostatically controlled loads," *IEEE Trans. Power Syst.*, vol. 30, no. 1, pp. 189–198, 2015, doi:10.1109/TPWRS.2014.2328865. Introduce el modelo de **batería generalizada** (límites de potencia y energía) y sus versiones suficiente y necesaria.
- [B2] ⚠ F. L. Müller, J. Szabó, O. Sundström, J. Lygeros, "Aggregation and disaggregation of energetic flexibility from distributed energy resources," *IEEE Trans. Smart Grid*, 2019. arXiv:1705.02815. Se confirmó el preprint; falta el volumen de la versión de revista. Trata la desagregación "justa" de una señal agregada.
- [B3] ⚠ M. Elsaadany, M. R. Almassalkhi, "Making aggregations reliable: realizability guarantees for battery fleets with heterogeneous power and energy limits," arXiv:2606.01562, 2026. Da condiciones lineales para que un despacho agregado se pueda repartir respetando potencia y energía: es el marco general de los teoremas 1 y 2. Preprint.
- [B4] ⚠ M. Elsaadany, M. R. Almassalkhi, "Linear model of aggregated homogeneous energy storage elements with realizable dispatch guarantees," arXiv:2501.04508. Preprint.
- [B5] ⚠ Y. Zhang, Z. Liu, F. Wang, Z. Chen, "Distributed secondary frequency control and SoC balance for droop-controlled BESSs with a unified SoC relative variation rate," arXiv:2206.14635 (versión relacionada: arXiv:2609.19055). Reparto según el cociente de SoC, de modo que todas las BESS se agotan simultáneamente: es el caso de B limitado por energía. Preprint.

**Opción C: costo incremental, consenso y SoC**
- [C1] ⚠ Z. Zhang, M.-Y. Chow, "Convergence analysis of the incremental cost consensus algorithm under different communication network topologies in a smart grid," *IEEE Trans. Power Syst.*, 2012. Falta confirmar el volumen y el DOI. Converge si el grafo tiene un árbol de expansión.
- [C2] ✔ E. Espina, J. Llanos, C. Burgos-Mellado, R. Cárdenas-Dobson, M. Martínez-Gómez, D. Sáez, "Distributed control strategies for microgrids: an overview," *IEEE Access*, vol. 8, pp. 193412–193448, 2020, doi:10.1109/ACCESS.2020.3032378.
- [C3] ✔ K. Lu, S. Dong, Y. Song, "A distributed economic power dispatch strategy considering state of charge for microgrids," *IEEE Access*, 2025 (IEEE Xplore doc. 10963348). Despacho económico distribuido que además balancea el SoC.
- [C4] ✔ "A distributed AGC power sharing strategy considering BESS participation factors," *Electric Power Systems Research*, vol. 217, art. 109117, 2023. Factor de participación dentro de una función de costo, variable en tiempo real con el SoC; es el antecedente más cercano a C. ⚠ Falta confirmar los autores.

**Contexto (reparto según el SoC)**
- ✔ X. Lu, K. Sun, J. M. Guerrero, J. C. Vasquez, L. Huang, "State-of-charge balance using adaptive droop control for distributed energy storage systems in DC microgrid applications," *IEEE Trans. Ind. Electron.*, vol. 61, no. 6, pp. 2804–2815, 2014, doi:10.1109/TIE.2013.2279374.
- ✔ T. A. Fagundes *et al.*, "Battery energy storage systems in microgrids: a review of SoC balancing and perspectives," *IEEE Open J. Ind. Electron. Soc.*, vol. 5, pp. 961–992, 2024, doi:10.1109/OJIES.2024.3455239.
- ✔ D. G. Díaz González, C. González Morán, J. Gómez-Aleixandre, A. B. Díez, "Scheduling of droop coefficients for frequency and voltage regulation in isolated microgrids," *IEEE Trans. Power Syst.*, vol. 25, no. 1, pp. 489–496, 2010, doi:10.1109/TPWRS.2009.2030425. Un nivel superior programa los coeficientes de reparto.
