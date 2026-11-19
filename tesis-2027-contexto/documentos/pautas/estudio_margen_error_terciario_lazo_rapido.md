# Estudio paso a paso: margen de error del terciario y lazo rápido como política afín

Documento de estudio para la reunión del lunes 23-nov-2026 con el Prof. Enrique Espina (acuerdo 3 del acta del 16-nov: "trabajar el álgebra del margen de error y dejar las ecuaciones acabadas"). Acompaña a `presentaciones/laminas_reunion_23nov.tex` y a `pautas/guia_reunion_23nov.md`.

**Cómo leerlo.** Cada sección parte de lo que ya está definido, deriva un resultado y termina con un recuadro "Para defender", que es lo que hay que poder decir de memoria. Al final hay ejercicios con solución. Las derivaciones son propias, salvo donde se cita una fuente; lo que es supuesto se marca como tal.

---

## 0. Notación y convenciones

| Símbolo | Significado | Unidad | Origen |
|---|---|---|---|
| $\phi\in\lbrace a,b,c\rbrace$ | fase | – | – |
| $\mathcal N_\phi$ | conjunto de Micro-redes (MR) conectadas a la fase $\phi$ | – | topología |
| $t=0,\dots,T-1$ | tramo de 15 min del horizonte; $T=48$ (12 h) | – | diseño |
| $\Delta t$ | duración del tramo, $0{,}25$ h | h | diseño |
| $P_{h,\phi}$ | potencia de la fase $\phi$ en la cabecera; $>0$ importa desde la S/E | kW | medido |
| $\bar P_h$ | promedio de las tres fases, $\tfrac13\sum_\psi P_{h,\psi}$ | kW | medido |
| $P_{\mathrm{IC},k}$ | potencia del IC de la MR $k$; $>0$ entrega a la red (DC→AC) | kW | medido |
| $L_\phi$ | demanda no gestionada de la fase (clientes monofásicos) | kW | estimado |
| $D_\phi$ | desviación de $L_\phi$ respecto del promedio de fases | kW | estimado |
| $\hat D_\phi$ | pronóstico de $D_\phi$ | kW | pronóstico |
| $\xi_\phi$ | error del pronóstico, $D_\phi-\hat D_\phi$ | kW | aleatorio |
| $\sigma_\phi$, $a_\phi$ | desviación estándar y autocorrelación (de un tramo al siguiente) de $\xi_\phi$ | kW, – | historia |
| $\varepsilon$ | riesgo aceptado (probabilidad de quedarse corto) | – | diseño |
| $z$ | multiplicador del margen ($z=\Phi^{-1}(1-\varepsilon)$ en el caso gaussiano) | – | diseño |
| $m$ | margen por variación dentro del tramo, medida y seguimiento | kW | historia |
| $P^{\ast}_k$ | plan de potencia del IC$_k$ (decisión del terciario) | kW | decisión |
| $\alpha_k$ | factor de participación de la MR $k$ en su fase | – | parámetro |
| $\hat e_\phi$ | parte previsible de lo que verá el lazo | kW | expresión |
| $\rho_\phi$ | residual previsto que se acepta no corregir | kW | decisión |
| $b_\phi$ | parte previsible que el lazo sí corrige, $\hat e_\phi-\rho_\phi$ | kW | expresión |
| $\hat y_k$ | energía comprometida (como potencia media) de la MR $k$ | kW | expresión |
| $\tilde P_k$ | potencia media esperada del IC$_k$, $P^{\ast}_k+\hat y_k$ | kW | expresión |
| $R^{\varepsilon\uparrow}_\phi$, $R^{\varepsilon\downarrow}_\phi$ | margen de la fase para el error, hacia arriba y hacia abajo | kW | parámetro |
| $r^{\uparrow}_k$, $r^{\downarrow}_k$ | margen de la MR $k$, $\alpha_k R^{\varepsilon}_\phi$ | kW | expresión |
| $Z_\phi(t)$ | margen de energía de la fase al tramo $t$ | kWh | parámetro |
| $P^{\min/\max}_k$, $W^{\min/\max}_k$ | envolvente de potencia y de energía acumulada que informa la MR | kW, kWh | secundario |
| $E_k$ | energía útil de BESS y EV de la MR $k$ | kWh | secundario |
| $c(t)$ | tarifa | \$/kWh | dato |
| $g(t)$ | compra a la S/E | kW | decisión |

Convención: $W_k(t)$ es la energía **entregada** por el IC$_k$ desde ahora hasta el final del tramo $t$. Entregar energía descarga la MR, así que $W^{\max}_k$ es lo máximo que puede entregar sin bajar del SoC mínimo y $W^{\min}_k\le0$ es lo máximo que puede absorber sin pasar del SoC máximo.

---

## 1. De dónde partimos

En las láminas del 16-nov el terciario era el LP:

```math
\min \sum_t c(t)\,g(t)\,\Delta t \quad\text{s.a.}\quad g \ge \hat P_{L,\mathrm{tot}}-\sum_k P^{\ast}_k,\; g\ge 0
```

con cuatro restricciones:

```math
\begin{aligned}
&\text{(a)}\quad \sum_{k\in\mathcal N_\phi}\hat y_k=\hat D_\phi-(S_\phi-\bar S)-\rho_\phi,\qquad |\rho_\phi|\le\bar\rho\\
&\text{(b)}\quad P^{\min}_k+r^{\downarrow}_k\le P^{\ast}_k+\hat y_k\le P^{\max}_k-r^{\uparrow}_k\\
&\text{(c)}\quad W^{\min}_k+r^{\downarrow}_k\tau+\bar\varepsilon_k\le\sum_{s\le t}(P^{\ast}_k+\hat y_k)\Delta t\le W^{\max}_k-r^{\uparrow}_k\tau-\bar\varepsilon_k\\
&\text{(d)}\quad \sum_{k\in\mathcal N_\phi}r^{\uparrow}_k\ge z\sigma_\phi+m,\qquad \sum_{k\in\mathcal N_\phi}r^{\downarrow}_k\ge z\sigma_\phi+m
\end{aligned}
```

y el lazo rápido aplicaba $P_{\mathrm{ref},k}=P^{\ast}_k+u_\phi r_k$ con $u_\phi=\Delta P_\phi/R_\phi$ y un PI limitado a $\pm R_\phi=\pm\sum_k r_k$.

El profesor pidió: definir cada símbolo, el modelo del error, el reparto del margen, la energía en toda la trayectoria, el LP completo con horizonte rodante y la coherencia con el PI. Al hacerlo aparecen cuatro detalles que hay que cerrar (secciones 4, 5, 6 y 8).

---

## 2. Qué ve el lazo rápido: derivación de $e_\phi$

**Paso 1.** La potencia de cada fase en la cabecera es la demanda no gestionada menos lo que inyectan sus IC:

```math
P_{h,\phi}=L_\phi-S_\phi,\qquad S_\phi=\sum_{k\in\mathcal N_\phi}P_{\mathrm{IC},k}
```

**Paso 2.** Promediando las tres fases, $\bar P_h=\bar L-\bar S$. Restando:

```math
e_\phi=P_{h,\phi}-\bar P_h=\underbrace{(L_\phi-\bar L)}_{D_\phi}-(S_\phi-\bar S)
```

**Paso 3.** Suma cero. Como $\sum_\phi(L_\phi-\bar L)=0$ y $\sum_\phi(S_\phi-\bar S)=0$:

```math
\sum_\phi e_\phi=0
```

**Paso 4.** Separar lo previsible del error. Si los IC siguen el plan $P^{\ast}$ y $D_\phi=\hat D_\phi+\xi_\phi$:

```math
e_\phi=\underbrace{\hat D_\phi-(S^{\ast}_\phi-\bar S^{\ast})}_{\hat e_\phi\ \text{(previsible)}}+\underbrace{\xi_\phi}_{\text{error}}
```

Como $\sum_\phi D_\phi=0$ y $\sum_\phi\hat D_\phi=0$ (si el pronóstico se construye por fase y luego se le resta el promedio), también $\sum_\phi\xi_\phi=0$: **los errores de las tres fases no son independientes**. Basta modelar dos.

**Paso 5.** Cómo se obtiene $D_\phi$ sin medir a los clientes: $L_\phi=P_{h,\phi}+S_\phi$, con $P_{h,\phi}$ medido en la cabecera y $S_\phi$ conocido (los IC informan su potencia). Es el "indicador" que el profesor sugirió el 9-nov.

> **Para defender.** "Lo que corrige el lazo es $e_\phi=D_\phi-(S_\phi-\bar S)$. Tiene suma cero por construcción. El terciario conoce la parte previsible $\hat e_\phi$ porque depende de su propio plan y del pronóstico; lo único que no conoce es $\xi_\phi$."

---

## 3. El lazo rápido es una política afín de reserva

### 3.1 Qué es una política afín

Warrington, Goulart, Mariéthoz y Morari [1] proponen que cada participante $i$ (generador, carga o almacenamiento) no reciba solo un programa, sino una **regla**: un programa nominal más una corrección lineal en los errores que se van revelando:

```math
u_i(t)=e_i(t)+\sum_{s\le t}D_i(t,s)\,\delta(s)
```

- $e_i$ es el programa nominal, que se fija antes.
- $D_i$ es la matriz de respuesta. Es **triangular inferior** porque en el instante $t$ solo se conocen los errores hasta $t$ (causalidad).
- Si $D_i$ es **solo diagonal**, la corrección en $t$ depende solo del error en $t$. Los autores lo dicen explícitamente: es la reserva secundaria clásica, donde la entrada diagonal es el **factor de participación** del controlador (secc. 4.2 de [1]).

Bienstock, Chertkov y Harnett [2] usan el mismo esquema en un OPF probabilístico: cada generador responde $-\alpha_i\Omega$ a la desviación total $\Omega$, con $\sum_i\alpha_i=1$.

### 3.2 Nuestro lazo, escrito como política

En régimen (después de unos segundos, que es mucho menos que 15 min), el PI de la fase entrega $\Delta P_\phi\approx e_\phi$, porque su integrador lleva el error a cero. Si la corrección de la fase se reparte entre sus IC con proporciones fijas $\alpha_k$:

```math
P_{\mathrm{IC},k}(t)=P^{\ast}_k(t)+\alpha_k\,\Delta P_\phi(t),\qquad \alpha_k\ge 0,\quad \sum_{k\in\mathcal N_\phi}\alpha_k=1
```

Es exactamente la política afín con $D$ diagonal: nominal $=P^{\ast}_k$, participación $=\alpha_k$, error $=e_\phi$.

### 3.3 Consecuencia: qué energía y qué potencia gasta cada MR

Reemplazando $\Delta P_\phi\approx e_\phi=\hat e_\phi+\xi_\phi$:

```math
P_{\mathrm{IC},k}=P^{\ast}_k+\underbrace{\alpha_k\hat e_\phi}_{\text{previsible}}+\underbrace{\alpha_k\xi_\phi}_{\text{error}}
```

La parte previsible dura horas y es **energía comprometida**. La parte del error tiene media cero y es **margen de potencia**. Esta es la separación de las láminas del 16-nov, ahora con un único parámetro de reparto, $\alpha_k$.

> **Para defender.** "No inventé una regla nueva: el lazo es una política afín diagonal, el mismo objeto que la reserva secundaria clásica. Lo que agrego es que el terciario la conoce de antemano y por eso puede apartar la energía y el margen que va a consumir."

---

## 4. Reparto en la fase: por qué los factores de participación se fijan antes

### 4.1 El detalle

En la formulación del 16-nov el terciario elegía libremente $\hat y_k$ (con $\sum_k\hat y_k$ dado) y $r_k$ (con $\sum_k r_k$ acotado). Pero el lazo reparte **en proporción fija**: $\Delta P_k=u_\phi r_k=(r_k/R_\phi)\Delta P_\phi$. Para que lo ejecutado coincida con lo planificado, la proporción con que se reparte lo previsible tiene que ser la misma que la del margen:

```math
\frac{\hat y_k}{\sum_j \hat y_j}=\frac{r_k}{\sum_j r_j}\quad\Longleftrightarrow\quad \hat y_k\,R_\phi=r_k\,b_\phi
```

Con $\hat y_k$, $r_k$ y $b_\phi$ como variables, esa igualdad es **bilineal** (producto de variables) y el problema deja de ser un LP.

### 4.2 La solución: $\alpha_k$ como parámetro

Si $\alpha_k$ se fija antes de resolver, todo queda lineal:

```math
\hat y_k=\alpha_k\,b_\phi,\qquad r^{\uparrow}_k=\alpha_k R^{\varepsilon\uparrow}_\phi,\qquad r^{\downarrow}_k=\alpha_k R^{\varepsilon\downarrow}_\phi
```

$b_\phi$ es lineal en $P^{\ast}$ y $\rho$, y $\alpha_k$ es un número, así que $\hat y_k$ es lineal. Además $\sum_k r^{\uparrow}_k=R^{\varepsilon\uparrow}_\phi$, de modo que **(d) se cumple por construcción**.

### 4.3 Qué valor de $\alpha_k$: mismo $\Delta$SoC

Si la fase gasta una energía $\Delta E_\phi$ en balance, la MR $k$ gasta $\alpha_k\Delta E_\phi$ y su SoC cambia en

```math
\Delta\mathrm{SoC}_k=\frac{\alpha_k\,\Delta E_\phi}{E_k}
```

Para que **todas** las MR de la fase cambien su SoC en lo mismo, $\alpha_k/E_k$ tiene que ser constante:

```math
\alpha_k=\frac{E_k}{\sum_{j\in\mathcal N_\phi}E_j}\quad\Rightarrow\quad \Delta\mathrm{SoC}_k=\frac{\Delta E_\phi}{\sum_j E_j}\ \ \forall k
```

Es el mismo principio del reparto de carga proporcional al SoC en Micro-redes DC: nadie se agota antes que los demás.

**Alternativas** (para mencionar, no para presentar como cerradas):
1. $\alpha_k$ proporcional a la holgura de energía de la solución anterior (sigue siendo LP, se actualiza cada 15 min).
2. $\alpha_k$ como variable, resuelto con LP secuencial: se fija $\alpha$, se resuelve, se recalcula $\alpha$ y se repite. Es la extensión natural.

> **Para defender.** "El terciario planifica con el mismo reparto que el lazo ejecuta. Si los dejo libres por separado, el lazo no hace lo planificado o el problema deja de ser lineal. Elijo $\alpha_k\propto E_k$ porque iguala el $\Delta$SoC."

---

## 5. Modelo del error: de dónde salen $\sigma_\phi$, $z$ y $m$

### 5.1 Pronóstico simple

El profesor pidió un pronóstico simple. El estándar de comparación en alimentadores BT es el **naive estacional** [8]: el mismo tramo de 15 min de días anteriores equivalentes. Con 96 tramos por día:

```math
\hat D_\phi(t)=\frac1n\sum_{d=1}^{n}D_\phi(t-96d)
```

Variantes: usar solo días hábiles o solo fines de semana, o corregir con la última medición (por ejemplo $\hat D_\phi\leftarrow\hat D_\phi+\beta\,\xi_\phi(t-1)$, que aprovecha la autocorrelación del error).

### 5.2 Estadística del error

Con una historia de $N_d$ días se calcula el error en cada tramo, $\xi_\phi(t)=D_\phi(t)-\hat D_\phi(t)$, y luego, **por hora del día** $h$:

```math
\mu_\phi(h)=\frac{1}{|\mathcal T_h|}\sum_{t\in\mathcal T_h}\xi_\phi(t),\qquad
\sigma^2_\phi(h)=\frac{1}{|\mathcal T_h|-1}\sum_{t\in\mathcal T_h}\big(\xi_\phi(t)-\mu_\phi(h)\big)^2
```

donde $\mathcal T_h$ son los tramos de la historia que caen en la hora $h$. La autocorrelación entre tramos consecutivos es

```math
a_\phi=\frac{\sum_t(\xi_\phi(t)-\mu)(\xi_\phi(t-1)-\mu)}{\sum_t(\xi_\phi(t)-\mu)^2}
```

Si $\mu_\phi(h)\neq0$ de forma sistemática, el pronóstico está sesgado y conviene corregirlo (sumarle $\mu_\phi$) antes de dimensionar el margen.

### 5.3 Margen de potencia como restricción probabilística

Queremos que el margen hacia arriba cubra el error con probabilidad $1-\varepsilon$:

```math
\Pr\big[\xi_\phi\le R^{\varepsilon\uparrow}_\phi-m\big]\ge 1-\varepsilon
```

Si $F$ es la función de distribución de $\xi_\phi$, esto equivale a $F(R-m)\ge1-\varepsilon$, es decir, $R-m\ge F^{-1}(1-\varepsilon)=q_{1-\varepsilon}$. Entonces:

```math
R^{\varepsilon\uparrow}_\phi=q_{1-\varepsilon}(\xi_\phi)+m,\qquad R^{\varepsilon\downarrow}_\phi=-q_{\varepsilon}(\xi_\phi)+m
```

Hay tres maneras de obtener el cuantil:

**(i) Gaussiana.** Si $\xi\sim\mathcal N(\mu,\sigma^2)$, entonces $q_{1-\varepsilon}=\mu+z\sigma$ con $z=\Phi^{-1}(1-\varepsilon)$. Para $\varepsilon=5\,\%$, $z=1{,}645$; para $1\,\%$, $z=2{,}326$. Es la reformulación analítica de [2], [3].

**(ii) Sin supuesto de distribución (Cantelli).** Si solo se conocen $\mu$ y $\sigma$, la desigualdad de Cantelli dice

```math
\Pr[\xi-\mu\ge\lambda]\le\frac{\sigma^2}{\sigma^2+\lambda^2}
```

Imponiendo que el lado derecho sea $\le\varepsilon$ y despejando:

```math
\frac{\sigma^2}{\sigma^2+\lambda^2}\le\varepsilon\iff\sigma^2\le\varepsilon\sigma^2+\varepsilon\lambda^2\iff\lambda\ge\sigma\sqrt{\frac{1-\varepsilon}{\varepsilon}}
```

Para $\varepsilon=5\,\%$ da $4{,}36\sigma$ y para $1\,\%$ da $9{,}95\sigma$. Es válida para cualquier distribución, pero muy conservadora. Es la base de las versiones distribucionalmente robustas [4].

**(iii) Cuantil empírico (propuesta).** Se ordenan los errores históricos de la hora $h$ y se toma el valor que deja por encima una fracción $\varepsilon$. No supone forma alguna y captura la asimetría (subida y bajada distintas). Tiene un precedente normativo directo: el reglamento europeo de operación (SOGL, Reg. UE 2017/1485, art. 157) dimensiona la reserva FRR para cubrir los desbalances históricos **el 99 % del tiempo**, por separado en cada dirección [7].

### 5.4 Qué es $m$

El terciario trabaja con promedios de 15 min, pero el lazo actúa cada segundo. $m$ cubre lo que el promedio no ve: la variación dentro del tramo, el error de medida y el error de seguimiento del PI. Se estima con datos de 1 min:

```math
m=q_{1-\varepsilon}\Big(\big|P^{1\,\mathrm{min}}_{h,\phi}-\bar P^{15\,\mathrm{min}}_{h,\phi}\big|\Big)
```

Su efecto en energía dentro de un tramo es pequeño (oscila alrededor del promedio), por eso en la sección 6 entra una sola vez por tramo y no se acumula.

### 5.5 Error propio de cada MR ($\bar\varepsilon_k$)

La FV y la carga **dentro** de cada MR también se pronostican con error. Ese error no pasa por la fase: lo absorbe la BESS de la MR, porque el IC sigue su consigna. Por eso conviene que **cada MR informe su envolvente ya ajustada** por su propio error:

```math
W^{\max}_k(t)=\hat W^{\max}_k(t)-z\,\sigma_{E,k}(t),\qquad W^{\min}_k(t)=\hat W^{\min}_k(t)+z\,\sigma_{E,k}(t)
```

con $\sigma_{E,k}(t)$ calculado como en la sección 6. Así el terciario no necesita conocer el detalle interno de cada MR, que es la idea de la envolvente de flexibilidad de Müller et al. [5].

> **Para defender.** "$\sigma_\phi$ sale del historial del error del pronóstico simple, por hora del día. El nivel de riesgo $\varepsilon$ lo fijo yo; propongo el cuantil empírico al 99 %, que es como se dimensiona la reserva FRR en Europa. $m$ cubre lo que no ve el promedio de 15 minutos."

---

## 6. Energía en toda la trayectoria

### 6.1 Energía entregada bajo la política

Con la política de la sección 3, la energía que entrega el IC$_k$ hasta el final del tramo $t$ es

```math
W_k(t)=\sum_{s=0}^{t}P_{\mathrm{IC},k}(s)\,\Delta t=\sum_{s=0}^{t}\tilde P_k(s)\,\Delta t+\alpha_k\sum_{s=0}^{t}\xi_\phi(s)\,\Delta t
```

El primer término es determinista (plan más previsto). El segundo es el **error acumulado**, y es el que consume la banda de SoC.

### 6.2 Varianza del error acumulado

Sea $n=t+1$ el número de tramos y supongamos $\sigma$ constante en el intervalo. La varianza de la suma es la suma de todas las covarianzas:

```math
\mathrm{Var}\Big(\sum_{i=1}^{n}\xi_i\Big)=\sum_{i=1}^{n}\sum_{j=1}^{n}\mathrm{Cov}(\xi_i,\xi_j)
```

**Modelo AR(1).** Si $\xi_i=a\,\xi_{i-1}+\eta_i$, con $\eta$ ruido blanco, entonces $\mathrm{Cov}(\xi_i,\xi_j)=\sigma^2a^{|i-j|}$. Contando cuántos pares hay a cada distancia $d=|i-j|$ (hay $n$ con $d=0$ y $2(n-d)$ con $d\ge1$):

```math
\mathrm{Var}\Big(\sum_{i=1}^{n}\xi_i\Big)=\sigma^2\Big[n+2\sum_{d=1}^{n-1}(n-d)\,a^{d}\Big]=\sigma^2 f(n)
```

**Forma cerrada.** Usando $\sum_{d=1}^{n-1}a^d=\frac{a(1-a^{n-1})}{1-a}$ y $\sum_{d=1}^{n-1}d\,a^{d}$ (derivada de la serie geométrica), y simplificando:

```math
f(n)=\frac{n(1+a)}{1-a}-\frac{2a(1-a^{n})}{(1-a)^{2}}
```

**Comprobaciones** (hacerlas a mano una vez):
- $n=1$: $\frac{1+a}{1-a}-\frac{2a(1-a)}{(1-a)^2}=\frac{1+a-2a}{1-a}=1$. ✓
- $n=2$: debe dar $2+2a$. $\frac{2(1+a)}{1-a}-\frac{2a(1-a)(1+a)}{(1-a)^2}=\frac{2(1+a)(1-a)}{1-a}=2(1+a)$. ✓
- $a=0$: $f(n)=n$, errores independientes, y la desviación crece como $\sqrt n$.
- $a\to1$: $f(n)\to n^2$, sesgo persistente, y la desviación crece como $n$.

Entonces la desviación estándar del error acumulado en energía es

```math
\sigma_{E,\phi}(n)=\sigma_\phi\,\Delta t\,\sqrt{f(n)}
```

**Caso general (σ variable en el día).** Si $\sigma$ cambia de tramo en tramo:

```math
\sigma^2_{E,\phi}(n)=\Delta t^2\sum_{i=1}^{n}\sum_{j=1}^{n}\sigma_\phi(i)\,\sigma_\phi(j)\,a^{|i-j|}
```

Es un número que se calcula fuera del LP, antes de cada resolución.

### 6.3 Margen de energía y restricción (c) acabada

Aplicando el mismo nivel de riesgo al error acumulado y sumando $m$ una vez por tramo:

```math
Z^{\uparrow}_\phi(t)=\Big(z\,\sigma_\phi\sqrt{f(t+1)}+m\Big)\Delta t
```

(o con el cuantil empírico del error acumulado, si se usa la versión empírica). La restricción de energía queda:

```math
W^{\min}_k(t)+\alpha_k Z^{\downarrow}_\phi(t)\;\le\;\sum_{s=0}^{t}\tilde P_k(s)\,\Delta t\;\le\;W^{\max}_k(t)-\alpha_k Z^{\uparrow}_\phi(t)
```

**¿Por qué el error de la fase y el propio de la MR no se suman directo?** Si son independientes, la varianza total es la suma de varianzas, así que el margen exacto es $z\sqrt{\alpha_k^2\sigma^2_{E,\phi}+\sigma^2_{E,k}}$, menor que la suma $z\alpha_k\sigma_{E,\phi}+z\sigma_{E,k}$. Con $\alpha_k$ fijo los dos son números, así que ambas formas siguen siendo lineales. Separarlos (como arriba) es más conservador, pero permite que cada MR ajuste su envolvente sin conocer la fase.

### 6.4 Qué pasa con $\tau$

En el primer tramo, $f(1)=1$:

```math
Z_\phi(0)=(z\sigma_\phi+m)\,\Delta t=R^{\varepsilon}_\phi\,\Delta t
```

Es exactamente el "margen de potencia por $\tau$" de la formulación anterior, con $\tau=\Delta t$. **$\tau$ deja de ser un parámetro libre**: es el período con que el terciario re-planifica con el SoC medido. Lo que ya ocurrió se mide; solo hay que asegurar el tramo en curso. Para los tramos futuros, el margen crece con $\sqrt{f}$.

### 6.5 Dos variantes a comparar

- **(c-i) Optimista:** $Z$ solo en el primer tramo; el resto del horizonte se planifica nominal. Barata, pero el plan futuro puede no ser alcanzable si el error persiste.
- **(c-ii) Conservadora:** $Z(t)$ creciente en todo el horizonte. Garantiza que el plan sigue siendo alcanzable con probabilidad $1-\varepsilon$ en cada tramo, a costa de apartar más energía.

Comparar las dos en simulación (energía comprada, veces que se agota el margen, residual) es un resultado en sí mismo. Ghosh et al. [6] proponen además ajustar el margen según las violaciones observadas, lo que reduce el conservadurismo.

### 6.6 Ejemplo numérico (ilustrativo; los valores de σ, a y E son supuestos)

Datos: $\sigma=0{,}5$ kW, $z=2{,}33$, $m=0{,}2$ kW, $\Delta t=0{,}25$ h, de modo que $z\sigma\Delta t=0{,}291$ kWh y $m\Delta t=0{,}05$ kWh.

| Horizonte | $n$ | $\sqrt{f}$ con $a=0$ | $Z$ con $a=0$ [kWh] | $\sqrt{f}$ con $a=0{,}8$ | $Z$ con $a=0{,}8$ [kWh] |
|---|---|---|---|---|---|
| 15 min | 1 | 1,00 | 0,34 | 1,00 | 0,34 |
| 1 h | 4 | 2,00 | 0,63 | 3,52 | 1,07 |
| 2 h | 8 | 2,83 | 0,87 | 6,22 | 1,86 |
| 4 h | 16 | 4,00 | 1,22 | 10,25 | 3,04 |

Detalle para $a=0{,}8$, $n=4$: $f=\frac{4\cdot1{,}8}{0{,}2}-\frac{2\cdot0{,}8\,(1-0{,}8^4)}{0{,}04}=36-\frac{1{,}6\cdot0{,}5904}{0{,}04}=36-23{,}62=12{,}38$, y $\sqrt{12{,}38}=3{,}52$.

En la MR$_1$ con $\alpha_1=0{,}4$ y un evento previsto de $b=1{,}5$ kW durante 4 h, la energía comprometida es $0{,}4\cdot1{,}5\cdot4=2{,}4$ kWh y el margen $0{,}4\cdot3{,}04=1{,}21$ kWh. En total, 3,6 kWh de su banda de 10 kWh. Con $r\tau$ constante se habrían apartado $0{,}4\cdot1{,}37\cdot0{,}25=0{,}14$ kWh.

> **Para defender.** "La reserva en kW no dice cuántos kWh se gastan. El error acumulado crece con el horizonte; si es persistente, crece casi linealmente. En el primer tramo mi margen de energía es exactamente $R\cdot\Delta t$; después crece con $\sqrt{f(n)}$."

---

## 7. Potencia: de dónde sale (b)

El PI de la fase entrega $\Delta P_\phi\in[b_\phi-R^{\varepsilon\downarrow}_\phi,\ b_\phi+R^{\varepsilon\uparrow}_\phi]$ (sección 9). La potencia del IC$_k$ es $P^{\ast}_k+\alpha_k\Delta P_\phi$. Sus valores extremos son:

```math
\max P_{\mathrm{IC},k}=P^{\ast}_k+\alpha_k b_\phi+\alpha_k R^{\varepsilon\uparrow}_\phi=\tilde P_k+r^{\uparrow}_k,\qquad
\min P_{\mathrm{IC},k}=\tilde P_k-r^{\downarrow}_k
```

Exigir que ambos queden dentro de $[P^{\min}_k,P^{\max}_k]$ da exactamente (b):

```math
P^{\min}_k+\alpha_kR^{\varepsilon\downarrow}_\phi\le\tilde P_k\le P^{\max}_k-\alpha_kR^{\varepsilon\uparrow}_\phi
```

(b) era correcta; ahora se sabe de dónde sale.

---

## 8. Compra, residual y condición final

### 8.1 La compra se escribe con $\tilde P$

La potencia total que entregan los IC es $\sum_k P_{\mathrm{IC},k}=\sum_k\tilde P_k+\sum_\phi\xi_\phi$ en promedio, y $\sum_\phi\xi_\phi=0$. Entonces lo que se compra en promedio es

```math
g=\hat P_{L,\mathrm{tot}}-\sum_k\tilde P_k
```

y no $\hat P_{L,\mathrm{tot}}-\sum_kP^{\ast}_k$. Ambas coinciden solo si $\sum_k\hat y_k=0$.

### 8.2 El residual debe sumar cero entre fases

$\sum_k\hat y_k=\sum_\phi b_\phi=\sum_\phi\hat e_\phi-\sum_\phi\rho_\phi=-\sum_\phi\rho_\phi$, porque $\sum_\phi\hat e_\phi=0$. Además, la parte común del residual no tiene efecto sobre el balance. Si el lazo corrige $b_\phi$, lo que queda en cada fase es

```math
e_\phi^{\text{final}}=\rho_\phi-\tfrac13\sum_\psi\rho_\psi
```

Solo la parte diferencial de $\rho$ importa; la parte común solo cambia la compra. Por eso se impone

```math
\sum_\phi\rho_\phi=0
```

lo que elimina esa redundancia, hace $\sum_k\hat y_k=0$ y deja la propiedad "el balance previsto no cambia la compra total" exacta. Se deja $g$ escrito con $\tilde P$ igual, por claridad.

### 8.3 Condición final del horizonte

Sin una condición sobre la energía al final, el LP no valora lo que queda en las baterías después de $T$. Si la tarifa es positiva, descargar reduce $g$, así que el óptimo tiende a vaciar las BESS al final de las 12 h (miopía del horizonte finito). Se agrega:

```math
\sum_{s=0}^{T-1}\tilde P_k(s)\,\Delta t\le W^{\mathrm{fin}}_k
```

donde $W^{\mathrm{fin}}_k$ es la energía que se permite entregar en el horizonte para terminar con un SoC objetivo, por ejemplo el SoC medio. Una alternativa es valorar la energía final en el objetivo con un precio sombra, pero eso agrega un término; la restricción es más simple de defender.

---

## 9. El lazo rápido, coherente con el terciario

### 9.1 Banda del PI

En lo nominal el lazo entrega $\Delta P_\phi\approx b_\phi$, que **puede ser mayor que el margen del error** (en el ejemplo, $b=1{,}5$ kW y $R^{\varepsilon}=1{,}37$ kW). Si el PI se limita a $\pm\sum_kr_k$, como en la formulación anterior, queda saturado todo el evento y $u_\phi>1$ en lo nominal. La banda coherente es

```math
\Delta P_\phi\in\big[\,b_\phi-R^{\varepsilon\downarrow}_\phi,\ b_\phi+R^{\varepsilon\uparrow}_\phi\,\big]
```

y el indicador de uso del margen es

```math
u_\phi=\frac{\Delta P_\phi-b_\phi}{R^{\varepsilon}_\phi}\in[-1,1]
```

con $u_\phi=0$ en lo nominal y $|u_\phi|\le1$ con probabilidad $1-\varepsilon$. Esto responde al punto 6 del acta.

### 9.2 Referencia del lazo

Para que el lazo no gaste margen corrigiendo el residual que el terciario aceptó dejar, su error debe ser $e_\phi-\rho_\phi$ (normalmente $\rho_\phi=0$). Como $\sum_\phi e_\phi=0$ y $\sum_\phi\rho_\phi=0$, la suma de los errores de las tres fases sigue siendo cero.

### 9.3 Dinámica y sintonía (primer paso)

Sea $\mathbf d$ el vector de perturbaciones por fase y $\Delta\mathbf P$ el de correcciones. Como $e_\phi$ es "fase menos promedio", el lazo ve

```math
\mathbf e=M(\mathbf d-\Delta\mathbf P),\qquad M=I-\tfrac13\mathbf 1\mathbf 1^{\top}
```

$M$ es un proyector: deja intacto todo lo que tiene suma cero y anula la parte común. Si las correcciones tienen suma cero, $M\Delta\mathbf P=\Delta\mathbf P$, y cada fase ve una planta de **ganancia unitaria**, $e_\phi=d_\phi-\Delta P_\phi$. La parte común no es observable por el lazo, pero tampoco se mueve: como $\sum_\phi e_\phi=0$, la suma de los integradores es constante. Si se inicializan en $b_\phi$ (con $\sum_\phi b_\phi=0$), queda en cero.

Si el IC sigue su referencia con una constante de tiempo $T_{\mathrm{IC}}$ (unas decenas de ms), el lazo abierto es

```math
L(s)=\Big(K_p+\frac{K_i}{s}\Big)\frac{1}{1+sT_{\mathrm{IC}}}
```

Con cancelación polo-cero, $K_p/K_i=T_{\mathrm{IC}}$, queda $L(s)=K_i/s$: un lazo cerrado de primer orden con constante de tiempo $1/K_i$. Una elección razonable es $1/K_i$ de 5 a 10 s, mucho más lento que el IC y mucho más rápido que 15 min (separación de escalas). Hay que validarlo en PLECS cuando el IC tenga lado AC.

### 9.4 Implementación discreta con anti-windup ($T_s\approx1$ s)

```math
\begin{aligned}
v[n]&=K_p\,(e_\phi[n]-\rho_\phi)+x[n]\\
\Delta P_\phi[n]&=\mathrm{sat}_{[\,b_\phi-R^{\downarrow},\;b_\phi+R^{\uparrow}\,]}\big(v[n]\big)\\
x[n+1]&=x[n]+K_iT_s\,(e_\phi[n]-\rho_\phi)+K_{aw}\big(\Delta P_\phi[n]-v[n]\big)
\end{aligned}
```

Cada 15 min cambian $b_\phi$ y la banda. Para que no haya saltos (bumpless), al cambiar $b_\phi$ se desplaza el integrador en la misma cantidad: $x\leftarrow x+(b^{\text{nuevo}}_\phi-b^{\text{viejo}}_\phi)$.

### 9.5 Dos formas equivalentes en el IC

```math
P_{\mathrm{ref},k}=P^{\ast}_k+\alpha_k\Delta P_\phi=P^{\ast}_k+\hat y_k+u_\phi\,r_k
```

La segunda forma muestra que $\hat y_k$ puede enviarse como **prealimentación**: el PI parte en $b_\phi$ y solo corrige el error. Es una decisión de implementación que conviene preguntar al profesor.

### 9.6 Cuándo se pierde la suma cero

Si una fase se satura, su $\Delta P_\phi$ queda fijo en el borde y $\sum_\phi\Delta P_\phi\neq0$: la compra total cambia y vuelve parte del desbalance. Con la formulación propuesta esto ocurre con probabilidad de orden $\varepsilon$ por tramo. Es el caso que hay que mostrar en simulación.

> **Para defender.** "El límite del PI no es $\pm\sum r_k$ sino $b_\phi\pm R^{\varepsilon}_\phi$, porque el lazo también entrega lo previsible. Así $u_\phi$ mide solo cuánto margen de error está usando."

---

## 10. El LP completo, en una página

**Conjuntos:** $\phi\in\lbrace a,b,c\rbrace$; $k\in\mathcal N_\phi$; $t=0,\dots,T-1$; $T=48$; $\Delta t=0{,}25$ h.

**Parámetros:** $c(t)$; $\hat P_{L,\mathrm{tot}}(t)$; $\hat D_\phi(t)$; $P^{\min/\max}_k(t)$; $W^{\min/\max}_k(t)$ (ya ajustadas por el error propio); $\alpha_k$; $R^{\varepsilon\uparrow\downarrow}_\phi(t)$; $Z^{\uparrow\downarrow}_\phi(t)$; $\bar\rho$; $W^{\mathrm{fin}}_k$.

**Variables:** $P^{\ast}_k(t)$, $\rho_\phi(t)$, $g(t)$.

```math
\begin{aligned}
\min\quad & \sum_{t=0}^{T-1}c(t)\,g(t)\,\Delta t\\
\text{def.}\quad & S_\phi=\textstyle\sum_{k\in\mathcal N_\phi}P^{\ast}_k,\quad \bar S=\tfrac13\sum_\psi S_\psi,\quad \hat e_\phi=\hat D_\phi-(S_\phi-\bar S)\\
& b_\phi=\hat e_\phi-\rho_\phi,\quad \hat y_k=\alpha_k b_\phi,\quad \tilde P_k=P^{\ast}_k+\hat y_k\\
\text{(0)}\quad & g(t)\ge\hat P_{L,\mathrm{tot}}(t)-\textstyle\sum_k\tilde P_k(t),\qquad g(t)\ge0\\
\text{(a)}\quad & -\bar\rho\le\rho_\phi(t)\le\bar\rho,\qquad \textstyle\sum_\phi\rho_\phi(t)=0\\
\text{(b)}\quad & P^{\min}_k(t)+\alpha_kR^{\varepsilon\downarrow}_\phi(t)\le\tilde P_k(t)\le P^{\max}_k(t)-\alpha_kR^{\varepsilon\uparrow}_\phi(t)\\
\text{(c)}\quad & W^{\min}_k(t)+\alpha_kZ^{\downarrow}_\phi(t)\le\textstyle\sum_{s=0}^{t}\tilde P_k(s)\Delta t\le W^{\max}_k(t)-\alpha_kZ^{\uparrow}_\phi(t)\\
\text{(d)}\quad & \textstyle\sum_{k\in\mathcal N_\phi}r_k=R^{\varepsilon}_\phi\quad\text{(se cumple por construcción)}\\
\text{(e)}\quad & \textstyle\sum_{s=0}^{T-1}\tilde P_k(s)\Delta t\le W^{\mathrm{fin}}_k
\end{aligned}
```

**Linealidad:** todo es lineal en $(P^{\ast},\rho,g)$ porque $\alpha_k$, $R^{\varepsilon}$ y $Z$ son parámetros.

**Tamaño:** con $N$ MR en total hay $(N+3+1)\,T$ variables. Con $N=9$ (tres por fase) son $13\cdot48=624$ variables: un LP pequeño que se resuelve en milisegundos.

**Horizonte rodante (cada 15 min):**
1. Cada secundario mide su SoC y envía su envolvente ajustada $\mathcal E_k$ y su $E_k$.
2. El terciario actualiza $\hat D_\phi$ con la última medición y recalcula $\alpha_k$, $R^{\varepsilon}_\phi$ y $Z_\phi$.
3. Resuelve el LP.
4. Aplica solo el primer tramo: envía $P^{\ast}_k(0)$ y $\alpha_k$ a cada IC, y $b_\phi(0)$, $\rho_\phi(0)$ y $R^{\varepsilon}_\phi(0)$ al lazo de cada fase.
5. Repite con el horizonte desplazado.

Warrington et al. notan que, al re-resolver en cada paso, solo se aplica la primera fila de la política, pero los tramos futuros siguen influyendo en esa primera decisión [1, secc. 4.3]. Es la justificación de mantener $H=12$ h aunque solo se aplique el primer tramo.

**Si no hay solución:** si la energía no alcanza para el desbalance previsto dentro de $\bar\rho$, el LP queda infactible. Conviene agregar una holgura sobre (a), muy penalizada en el objetivo, que actúe como alarma ("faltan X kWh en la fase $\phi$ a partir de las HH:MM"). Es la ventaja de anticipar 12 h.

---

## 11. Supuestos y límites (verdad cruda)

1. **Límite físico:** una BESS solo compensa la parte del desbalance con media diaria cero (el "piso energético"). Si la fase $a$ es la más cargada todos los días y no hay excedente FV en esa fase, el residual $\rho$ no puede ser cero de forma sostenida. Sun et al. [9] llegan a lo mismo cuando relajan el almacenamiento a carga neta cero en promedio.
2. **$\Delta P_\phi\approx e_\phi$** supone que el PI es mucho más rápido que 15 min. Hay que verificarlo en simulación.
3. **AR(1)** es un modelo simple del error. Si la historia muestra otra estructura, se usa la fórmula general (doble suma) con las autocorrelaciones medidas.
4. **Pérdidas:** la envolvente se expresa en el lado AC del IC; las eficiencias de BESS y del IC quedan dentro de $W^{\min/\max}_k$, que calcula el secundario.
5. **Datos:** no hay historia real del alimentador. Para estimar $\sigma_\phi$ y $a_\phi$ hay que usar perfiles sintéticos; el IEEE European LV Test Feeder (3φ-4h, 50 Hz, unas 55 cargas monofásicas con perfiles) es un candidato natural. Queda por verificar su disponibilidad.
6. **Nada de esto está simulado todavía.** El ejemplo es un cálculo a mano.

---

## 12. Ejercicios (con solución)

**E1.** Una fase tiene 2 MR con $E=8$ y $4$ kWh, $b_\phi=0{,}9$ kW y $R^{\varepsilon}_\phi=0{,}6$ kW. Calcula $\alpha_k$, $\hat y_k$ y $r_k$.
*Solución:* $\alpha=(2/3,\ 1/3)$; $\hat y=(0{,}6;\ 0{,}3)$ kW; $r=(0{,}4;\ 0{,}2)$ kW.

**E2.** Con $\varepsilon=2{,}5\,\%$ y error gaussiano, ¿cuánto vale $z$? ¿Y el multiplicador de Cantelli?
*Solución:* $z=\Phi^{-1}(0{,}975)=1{,}96$. Cantelli: $\sqrt{0{,}975/0{,}025}=\sqrt{39}=6{,}24$.

**E3.** Calcula $f(3)$ con $a=0{,}5$ de dos maneras: con la doble suma y con la fórmula cerrada.
*Solución:* doble suma: $3+2[(2)(0{,}5)+(1)(0{,}25)]=3+2(1{,}25)=5{,}5$. Fórmula: $\frac{3\cdot1{,}5}{0{,}5}-\frac{2\cdot0{,}5\,(1-0{,}125)}{0{,}25}=9-3{,}5=5{,}5$. ✓

**E4.** ¿Por qué el PI no puede tener límites $\pm\sum_k r_k$ si $b_\phi\neq0$?
*Solución:* porque en lo nominal debe entregar $b_\phi$, y si $|b_\phi|>\sum_k r_k$ se satura todo el evento. Aun si $|b_\phi|<\sum_k r_k$, la banda que le queda al error es asimétrica y menor que la dimensionada.

**E5.** Muestra que si $\sum_\phi\rho_\phi=0$ entonces $\sum_k\hat y_k=0$.
*Solución:* $\sum_k\hat y_k=\sum_\phi\sum_{k\in\mathcal N_\phi}\alpha_kb_\phi=\sum_\phi b_\phi$ (porque $\sum_k\alpha_k=1$) $=\sum_\phi\hat e_\phi-\sum_\phi\rho_\phi=0-0=0$.

**E6.** En el ejemplo de la sección 6.6, ¿cuánta energía hay que apartar en la MR$_3$ ($\alpha=0{,}2$) a las 2 h con $a=0$?
*Solución:* comprometida $0{,}2\cdot1{,}5\cdot2=0{,}6$ kWh; margen $0{,}2\cdot0{,}87=0{,}17$ kWh; total $0{,}77$ kWh.

---

## Referencias

[1] J. Warrington, P. Goulart, S. Mariéthoz y M. Morari, "Policy-based reserves for power systems," *IEEE Trans. Power Syst.*, vol. 28, no. 4, pp. 4427–4437, 2013. arXiv: https://arxiv.org/abs/1212.2119

[2] D. Bienstock, M. Chertkov y S. Harnett, "Chance-constrained optimal power flow: Risk-aware network control under uncertainty," *SIAM Review*, vol. 56, no. 3, pp. 461–495, 2014. arXiv: https://arxiv.org/abs/1209.5779

[3] L. Roald, F. Oldewurtel, B. Van Parys y G. Andersson, "Security constrained optimal power flow with distributionally robust chance constraints," arXiv:1508.06061, 2015. https://arxiv.org/abs/1508.06061

[4] T. Summers, J. Warrington, M. Morari y J. Lygeros, "Stochastic optimal power flow based on conditional value at risk and distributional robustness," *Int. J. Electr. Power Energy Syst.*, vol. 72, pp. 116–125, 2015. https://personal.utdallas.edu/~tyler.summers/papers/SummersWarringtonMorariLygeros2015.pdf

[5] F. L. Müller, J. Szabó, O. Sundström y J. Lygeros, "Aggregation and disaggregation of energetic flexibility from distributed energy resources," *IEEE Trans. Smart Grid*, vol. 10, no. 2, pp. 1205–1214, 2019. arXiv: https://arxiv.org/abs/1705.02815

[6] Ghosh et al., "Adaptive relaxation based non-conservative chance constrained stochastic MPC," arXiv:2406.01973, 2024. https://arxiv.org/abs/2406.01973

[7] Reglamento (UE) 2017/1485 de la Comisión (SOGL), art. 157, dimensionamiento de FRR. https://gesetze.legal/eu/vo_eu_2017_1485/157

[8] S. Haben, G. Giasemidis, F. Ziel y S. Arora, "Short term load forecasts of low voltage demand and the effects of weather," *Int. J. Forecasting*, vol. 35, no. 4, pp. 1469–1484, 2019. arXiv: https://arxiv.org/abs/1804.02955

[9] S. Sun, B. Liang, M. Dong y J. A. Taylor, "Phase balancing using energy storage in power grids under uncertainty," arXiv:1505.03187, 2015. https://arxiv.org/abs/1505.03187

[10] Lei, C. A. Hans y P. Sopasakis, "Optimal operation of microgrids with risk-constrained state of charge," arXiv:2104.08357, 2021. https://arxiv.org/abs/2104.08357

**Nota sobre las referencias.** De [1] y [9] se revisó el texto completo. De las demás se revisaron el resumen y el registro bibliográfico; los volúmenes y páginas de [1], [2], [4], [5] y [8] son de memoria y conviene verificarlos antes de citarlos en un documento formal.
