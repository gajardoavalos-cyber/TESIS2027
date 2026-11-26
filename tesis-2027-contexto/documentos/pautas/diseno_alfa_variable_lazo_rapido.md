# Rediseño del factor de participación α_k del lazo rápido: tres propuestas

**Preparado:** 26-nov-2026, después de la reunión del 25-nov (acuerdo 1: "definir con precisión la matemática del lazo rápido y sus variables, justificando su uso"; acuerdo 3: terciario como trabajo futuro).
**Estado:** propuesta, aún no validada por el profesor Espina.

---

## 0. Por qué hay que rediseñar α_k

En la propuesta del 23-nov, α_k = E_k/ΣE_j se justificaba **dentro del LP del terciario**: el terciario planificaba con el mismo reparto que ejecuta el lazo, y fijar α evitaba un término bilineal α_k·b_φ. Con el terciario fuera del alcance, ese argumento deja de sostener a α. Ahora el lazo rápido tiene que:

1. justificar el reparto por sí mismo (con criterio físico y energético);
2. **generar la información de disponibilidad** que un terciario futuro usará para planificar.

### 0.1 Marco común a las tres propuestas

Sea una fase φ con Micro-redes k ∈ 𝒩_φ, cada una conectada por su IC monofásico.

| Símbolo | Significado | Unidad | Quién lo calcula |
|---|---|---|---|
| ΔP_φ | corrección total de la fase, salida del PI del lazo rápido | kW | lazo rápido (cabecera) |
| α_k | factor de participación, α_k ≥ 0, Σα_k = 1 | – | **lo que se diseña** |
| P*_k | potencia base del IC (sin terciario: plan local o 0) | kW | MR / constante |
| E_k | energía útil de la MR (BESS + EV conectados) | kWh | secundario de la MR |
| SoC_k | estado de carga agregado de la MR | p.u. | secundario |
| [SoC_min,k, SoC_max,k] | banda de SoC reservada para el balance | p.u. | parámetro |
| H^dis_k = (SoC_k − SoC_min,k)E_k | energía que puede **entregar** (descargar) | kWh | secundario → IC |
| H^ch_k = (SoC_max,k − SoC_k)E_k | energía que puede **absorber** (cargar) | kWh | secundario → IC |
| h_k = H_k/E_k ∈ [0,1] | holgura normalizada | p.u. | IC |
| Π^up_k = P^max_k − P*_k, Π^dn_k = P*_k − P^min_k | holgura de potencia del IC | kW | IC |

**Convención de signo** (CLAUDE.md §4): ΔP_φ > 0 significa que los IC de la fase deben inyectar más a la red, es decir, que la MR descarga. Por eso se usa H^dis cuando ΔP_φ > 0 y H^ch cuando ΔP_φ < 0.

**Estructura común.** Las tres propuestas comparten la misma forma:

$$
P_{\mathrm{ref},k}=P^{\ast}_k+\alpha_k\,\Delta P_\phi,\qquad 
\alpha_k=\frac{\kappa_k}{\sum_{j\in\mathcal N_\phi}\kappa_j},\qquad \kappa_k\ge 0
$$

**Solo cambia qué mide el "peso" κ_k.** Esta es la idea pedagógica central: α es una **fracción de un pastel**, y cada propuesta define de otra manera cuánto pastel le corresponde a cada Micro-red.

**Dinámica de energía** (supuesto: sin pérdidas, η = 1, y la MR solo usa la banda reservada para el balance):

$$
\frac{dH^{\mathrm{dis}}_k}{dt}=-\alpha_k\,\Delta P_\phi\quad(\Delta P_\phi>0)
$$

### 0.2 Propiedades comunes (valen para las tres; conviene defenderlas primero)

- **P1, desacople del PI.** Σ_k α_kΔP_φ = ΔP_φ. La potencia total que entrega la fase no depende de α, así que el PI ve la misma planta y su sintonía no cambia. Esto vale si los IC tienen dinámicas de corriente parecidas; si son muy distintas, aparece un acoplamiento de segundo orden que la simulación debe mostrar que es despreciable. **α decide quién aporta, no cuánto aporta la fase.**
- **P2, continuidad al cambiar de dirección.** α salta entre α^dis y α^ch cuando ΔP_φ cruza 0, pero el producto α_kΔP_φ vale 0 en ese punto, así que P_ref,k es continua.
- **P3, separación de escalas.** H_k cambia en minutos y el PI actúa en ~1 s. Se filtra κ_k con un paso bajo τ_α ≈ 30–60 s, de modo que τ_α ≫ τ_PI. El filtro también amortigua los saltos de E_k cuando un EV se conecta o desconecta.
- **P4, saturación.** Si α_kΔP_φ supera Π_k, se fija ΔP_k = Π_k y el resto se reparte entre las MR no saturadas con la misma regla (water-filling). En la propuesta B esto queda incorporado en la ley misma.

---

## 1. Propuesta A: reparto por holgura de energía con exponente (α SoC-adaptivo)

### 1.1 Ley

$$
\kappa_k=w_k\,E_k\,h_k^{\,n},\qquad 
\alpha_k=\frac{w_kE_kh_k^{\,n}}{\sum_jw_jE_jh_j^{\,n}},\qquad n\ge 0
$$

w_k es un peso que, por ahora, vale 1. Queda reservado como "perilla" para el terciario futuro.

### 1.2 Matemática

**Caso n = 0** (es la propuesta del 23-nov): α_k = E_k/ΣE_j. La MR k cambia su SoC en dSoC_k/dt = −α_kΔP/E_k = −ΔP/ΣE_j, igual para todas. **Todas cambian su SoC en lo mismo.** Si parten de SoC distintos, la que parte más baja llega primero a SoC_min y desde ese instante la fase pierde su potencia.

**Caso n = 1** (agotamiento simultáneo): α_k = H_k/S, con S = ΣH_j. Las derivadas son

$$
\frac{dH_k}{dt}=-\frac{H_k}{S}\Delta P,\qquad \frac{dS}{dt}=-\Delta P
$$

y por lo tanto

$$
\frac{d}{dt}\left(\frac{H_k}{S}\right)=\frac{\dot H_kS-H_k\dot S}{S^2}=\frac{-H_k\Delta P+H_k\Delta P}{S^2}=0 .
$$

Las fracciones H_k/S son **constantes**, así que todas las MR llegan a H_k = 0 en el mismo instante t* (con ΔP constante, t* = S(0)/ΔP). Ninguna satura antes, y la fase conserva todas sus MR activas hasta el final. **La fase se comporta exactamente como una sola batería de energía S.**

**Caso n > 1** (ecualización de SoC): con dh_k/dt = −ΔP·h_k^n/D, donde D = Σ_jE_jh_j^n,

$$
\frac{d}{dt}\ln\frac{h_i}{h_j}=-\frac{\Delta P}{D}\left(h_i^{\,n-1}-h_j^{\,n-1}\right).
$$

Si h_i > h_j y ΔP > 0, el cociente h_i/h_j disminuye. Las holguras normalizadas **convergen entre sí**, y más rápido cuanto mayor es n. Es el mismo mecanismo del droop adaptativo de Lu et al. [A1, A2], donde el exponente n "regula la velocidad del balance de SoC".

### 1.3 Información que entrega hacia arriba

- H^dis_φ = ΣH^dis_k y H^ch_φ = ΣH^ch_k (kWh), la energía de balance disponible en la fase.
- Autonomía T_φ = H_φ/|ΔP_φ| (h). **Con n = 1 es exacta para toda la fase**; con n = 0 sobreestima, porque la MR más débil se agota antes.

### 1.4 Explicación pedagógica

Imagina tres estanques de agua (las MR) que deben llenar entre todos una piscina (el desbalance de la fase).
- **n = 0:** cada estanque aporta según su tamaño, sin mirar cuánta agua tiene. Uno grande pero casi vacío se seca primero y deja a los demás solos.
- **n = 1:** cada estanque aporta según **cuánta agua le queda**. El que tiene más da más, y todos se secan **al mismo tiempo**. Desde la piscina se ve un solo estanque grande.
- **n > 1:** el que tiene más agua aporta **desproporcionadamente** más, así que los niveles se igualan con el tiempo. Es útil si además se quiere que todas las MR terminen con el mismo SoC.

### 1.5 Fortalezas y debilidades

- (+) Un parámetro (n), fácil de defender y de implementar. Contiene la propuesta anterior (n = 0) como caso particular.
- (+) Es la línea más citada en Micro-redes DC [A1–A4].
- (−) **No mira la potencia.** Una MR con mucha energía pero un IC pequeño recibe un α_kΔP que no puede entregar, y queda dependiendo de P4 (saturación).
- (−) Con n > 1, el modelo de "una batería equivalente" deja de ser exacto.

### 1.6 Qué valida la simulación

Comparar n = 0, 1 y 2 con una fase de 3 MR heterogéneas: instante en que satura la primera MR, dispersión de SoC y error de la autonomía estimada T_φ.

---

## 2. Propuesta B: reparto por disponibilidad sostenible potencia–energía (autonomía objetivo T)

### 2.1 Ley

Se define la **potencia sostenible** de la MR k durante un tiempo objetivo T:

$$
\kappa_k=S_k(T)=\min\!\left(\Pi_k,\ \frac{H_k}{T}\right),\qquad 
\alpha_k=\frac{S_k(T)}{\sum_jS_j(T)}
$$

con Π_k y H_k en la dirección que corresponda (up/dis si ΔP_φ > 0; dn/ch si ΔP_φ < 0). T es la duración que se quiere asegurar: la duración típica del evento de desbalance (por ejemplo, 3–4 h en el ejemplo a mano del 16-nov) o, en versión de horizonte decreciente, T(t) = t_fin − t.

**Límite del PI de la fase**, que ahora sale de la propia ley:

$$
\Delta P^{\max}_\phi(T)=\sum_{k}S_k(T)
$$

### 2.2 Matemática

**Teorema (garantía de autonomía).** Si |ΔP_φ| ≤ ΣS_j(T) durante [0, T], ninguna MR excede su potencia ni agota su energía antes de T.

*Demostración.* ΔP_k = α_kΔP_φ = S_k·ΔP_φ/ΣS_j ≤ S_k, porque ΔP_φ/ΣS_j ≤ 1.
- Potencia: ΔP_k ≤ S_k ≤ Π_k. ✓
- Energía: ∫₀^T ΔP_k dt ≤ S_k·T ≤ (H_k/T)·T = H_k. ✓ ∎

**Casos límite** (conectan B con A):
- Si todas las MR están limitadas por energía (H_k/T < Π_k), entonces S_k = H_k/T y α_k = H_k/ΣH_j, que es **la propuesta A con n = 1**.
- Si todas están limitadas por potencia, α_k = Π_k/ΣΠ_j: el reparto clásico por capacidad, el mismo criterio de los factores de participación del AGC.

B **elige sola**, MR por MR, cuál de los dos recursos es el escaso. Por eso maneja el caso que A no cubre (IC chico con BESS grande).

**Agregación exacta.** El par (ΣΠ_k, ΣH_k), o más precisamente la curva T ↦ ΣS_k(T), es la **envolvente de la fase**: la "batería generalizada" de Hao et al. [B1]. Es lo que el terciario futuro necesita, y coincide con lo que Espina pidió el 10-nov: que cada MR informe su envolvente de potencia y energía mínima y máxima.

### 2.3 Información que entrega hacia arriba

- **Potencia firme de la fase para T horas:** ΔP^max_φ(T) = ΣS_k(T). Es la frase que el terciario entiende: "la fase a puede sostener 2,3 kW de corrección durante 4 h".
- La curva completa ΔP^max_φ(T) para varios T (1, 2, 4, 8 h): una envolvente potencia–duración por fase.
- Utilización u_φ = ΔP_φ/ΔP^max_φ ∈ [−1, 1].

### 2.4 Explicación pedagógica

Piensa en un equipo de corredores (las MR) que debe mantener una velocidad conjunta durante una carrera de T horas. No le pides a cada uno lo mismo, ni lo proporcional a su tamaño: le pides **la velocidad que puede mantener toda la carrera**. Un velocista (IC grande, poca batería) puede ir muy rápido, pero poco rato. Un fondista (IC chico, mucha batería) va lento, pero aguanta. Para cada corredor, la velocidad sostenible es el mínimo entre "qué tan rápido puede ir" (Π_k) y "cuánta energía tiene dividida por la duración" (H_k/T). La suma de esas velocidades es lo máximo que el equipo puede **prometer** para toda la carrera, y esa promesa es justo la información que necesita el terciario.

### 2.5 Fortalezas y debilidades

- (+) Considera potencia **y** energía. Entrega una garantía demostrable (el teorema) y produce de forma natural la envolvente que pidió el profesor.
- (+) Contiene a A (n = 1) y al reparto por capacidad como casos límite.
- (−) Agrega un parámetro de diseño, T, que hay que justificar (duración del evento, o T(t) decreciente).
- (−) El min(·) hace que α sea continua por tramos, no suave. Con el filtro de P3 no es problema práctico, pero hay que mencionarlo.

### 2.6 Qué valida la simulación

Que el límite del PI ΔP^max_φ(T) se respete; que ninguna MR se agote antes de T cuando |ΔP_φ| ≤ ΣS_k; y que la potencia firme informada coincida con la que la fase sostiene realmente.

---

## 3. Propuesta C: reparto por costo marginal de uso (KKT / consenso de costo incremental)

### 3.1 Ley

Se plantea el reparto como un **despacho económico instantáneo** dentro de la fase:

$$
\min_{\Delta P_k}\ \sum_{k}\tfrac12\,c_k\,\Delta P_k^2\quad\text{s.a.}\quad \sum_k\Delta P_k=\Delta P_\phi,\quad -\Pi^{dn}_k\le\Delta P_k\le\Pi^{up}_k
$$

donde c_k > 0 es el "costo" de pedirle potencia a la MR k (en $/kW²h, o adimensional). Sin límites activos, las condiciones KKT son

$$
c_k\,\Delta P_k=\lambda_\phi\ \ \forall k\ \Rightarrow\ \Delta P_k=\frac{\lambda_\phi}{c_k},\qquad 
\lambda_\phi=\frac{\Delta P_\phi}{\sum_j 1/c_j},\qquad 
\alpha_k=\frac{1/c_k}{\sum_j 1/c_j}
$$

Es decir, κ_k = 1/c_k. Con límites activos, las MR saturadas quedan en su límite y las demás siguen igualando λ_φ: es el water-filling de P4, ahora con justificación de optimalidad.

### 3.2 Elección del costo: aquí se codifica la energía

- c_k = 1/(E_k h_k^n) → se recupera **A**. Esto demuestra que A es **óptima** para un costo que crece cuando la MR se vacía.
- c_k = 1/S_k(T) → se recupera **B**.
- c_k = c^E_k(h_k) + c^deg_k + c^usr_k: costo por energía escasa, más degradación de la batería, más un costo por usar el EV de un cliente (prioridad del usuario). Esta es la versión "propia" de C.

**Función barrera** recomendada para la energía: c^E_k = γ/h_k. Tiende a infinito cuando h_k → 0, así que una MR casi vacía deja de participar sola.

### 3.3 Implementación distribuida (línea de Espina)

λ_φ se puede obtener **sin un nodo central**, con consenso de costo incremental entre los IC de la fase [C1, C3]. Cada IC actualiza

$$
\lambda_k[m+1]=\sum_j a_{kj}\lambda_j[m]+\varepsilon\,\big(\text{desajuste local de potencia}\big)
$$

y converge a λ_φ común si el grafo de comunicación tiene un árbol de expansión. Así se extiende directamente la contribución doctoral de Espina (el IC como agente de consenso) [C2]. **Condición de escalas:** el consenso debe converger más rápido que τ_α, o se filtra igual que en P3.

### 3.4 Información que entrega hacia arriba

- **λ_φ, el precio sombra del balance en la fase φ:** cuánto "cuesta" un kW adicional de corrección. Si λ_a ≫ λ_b, la fase a está cerca de su límite energético. Es una señal escalar, económica y comparable entre fases, ideal para un terciario de mercado o de optimización.
- Además, la misma ΣH y ΣΠ de A y B.

### 3.5 Explicación pedagógica

Es un mercado. El lazo de la fase necesita "comprar" ΔP_φ kW de corrección. Cada MR pone un **precio** que sube a medida que se vacía (no quiere quedarse sin batería) y que puede incluir el desgaste de la batería o la molestia de usar el auto del cliente. El lazo compra a las más baratas hasta que **todas cobran lo mismo** por el último kW: ese precio común es λ_φ. Si una fase tiene λ alto, el terciario sabe que el balance allí "sale caro" y conviene planificar distinto. A y B son mercados con reglas de precio particulares; C es el mercado general.

### 3.6 Fortalezas y debilidades

- (+) Es el **marco unificador**: A y B son casos particulares, así que justifica las tres propuestas como óptimas para un costo dado.
- (+) Es distribuible por consenso, en continuidad directa con la línea doctoral de Espina. Puede incorporar degradación y prioridad de EV.
- (−) Tiene más parámetros (γ, c^deg, c^usr) y hay que justificar cada uno. Al acuerdo 1 le exigen "justificar cada variable".
- (−) Agrega una dinámica (el consenso) que hay que validar. Es más trabajo de simulación para la próxima semana.

### 3.7 Qué valida la simulación

Que el consenso converja más rápido que el PI sin perturbarlo; que λ_φ refleje la escasez energética; y la comparación con A y B usando los costos que las reproducen.

---

## 4. Comparación y recomendación

| Criterio | A: holgura^n | B: potencia sostenible | C: costo marginal |
|---|---|---|---|
| Considera energía | sí | sí | sí (vía c_k) |
| Considera potencia | no (solo saturación) | **sí, en la ley** | sí (restricciones) |
| Garantía demostrable | agotamiento simultáneo (n = 1) | **autonomía ≥ T** | optimalidad KKT |
| Información para el terciario | ΣH, autonomía | **envolvente P–T de la fase** | precio λ_φ |
| Parámetros nuevos | n | T | γ, c^deg, c^usr |
| Comunicación | H_k de cada IC a la cabecera | H_k, Π_k a la cabecera | consenso entre IC |
| Riesgo para la próxima semana | bajo | bajo–medio | alto |
| Vínculo con la línea de Espina | droop SoC (Guerrero/Lu) | envolvente del 10-nov | consenso (doctorado) |

**Recomendación.** Para lo que quieres validar (un α que **informe la disponibilidad de energía** para que el terciario reparta después), la que mejor se ajusta es **B**:
1. su información de salida es justamente la envolvente potencia–energía que Espina pidió que cada MR comunicara;
2. tiene una garantía demostrable y fácil de defender (el teorema de 2.2);
3. contiene a A (n = 1) como caso límite, así que A queda como línea base sin trabajo extra.

C conviene presentarla como **marco teórico** (A y B son óptimas para ciertos costos) y como **trabajo futuro** distribuido, junto con el terciario.

Plan de simulación sugerido: **A con n = 0** (línea base, la del 23-nov), **A con n = 1** y **B**, sobre el mismo caso.

---

## 5. Ejemplo numérico (mismo caso para las tres)

Una fase con 3 MR, banda SoC_min = 0,2, desbalance escalón ΔP_φ = 3 kW (descarga).

| MR | E_k [kWh] | SoC₀ | H^dis_k [kWh] | Π^up_k [kW] |
|---|---|---|---|---|
| 1 | 10 | 0,8 | 6,0 | 5,0 |
| 2 | 6 | 0,5 | 1,8 | 3,0 |
| 3 | 4 | 0,6 | 1,6 | 0,4 |

ΣH = 9,4 kWh, así que la autonomía máxima teórica es 9,4/3 = 3,13 h.

**A con n = 0:** α = (0,50; 0,30; 0,20) → ΔP = (1,5; 0,9; **0,6**) kW. La MR3 **no puede**, porque Π₃ = 0,4: satura y el exceso se redistribuye. Tiempos de agotamiento sin saturar: 6/1,5 = 4 h; 1,8/0,9 = **2 h**; 1,6/0,6 = 2,7 h. La MR2 se agota a las 2 h, y la fase pierde un tercio de sus recursos con 1,1 h de energía aún disponible en las otras.

**A con n = 1:** α = H/ΣH = (0,638; 0,191; 0,170) → ΔP = (1,91; 0,57; **0,51**) kW. La MR3 vuelve a exceder Π₃ = 0,4. Sin el límite de potencia, las tres se agotarían juntas a las 3,13 h; con el límite, la saturación rompe la simultaneidad.

**B con T = 3 h:** H/T = (2,0; 0,6; 0,53) y Π = (5; 3; 0,4), así que S = (2,0; 0,6; **0,4**) y ΣS = 3,0 kW = ΔP_φ.
- α = (0,667; 0,200; 0,133) → ΔP = (2,0; 0,6; 0,4) kW.
- Tiempos de agotamiento: 6/2 = 3 h; 1,8/0,6 = 3 h; 1,6/0,4 = 4 h. **Todas ≥ T = 3 h** y ninguna supera su potencia. ✓
- Mensaje al terciario: "la fase sostiene 3,0 kW durante 3 h".

**B con T = 4 h:** S = (1,5; 0,45; 0,4), así que ΣS = 2,35 kW < 3 kW. Mensaje al terciario: "para 4 h la fase solo garantiza 2,35 kW". **Esta es la información de disponibilidad que buscas.**

**C con c_k = 1/S_k(3 h):** se reproduce B exactamente. Si además c₂ incluye un costo de EV (por ejemplo, porque la MR2 es casi toda EV), su α baja y la diferencia la cubre la MR1.

---

## 6. Bibliografía (verificada en internet el 26-nov-2026)

Marcadas con ✔ las referencias cuyo título, revista, volumen y DOI se confirmaron. Marcadas con ⚠ las que quedaron con algún dato sin confirmar: revisarlas en IEEE Xplore antes de citarlas.

**Base común (política afín y factores de participación)**
- [0.1] ✔ J. Warrington, P. J. Goulart, S. Mariéthoz, M. Morari, "Policy-based reserves for power systems," *IEEE Trans. Power Syst.*, vol. 28, no. 4, pp. 4427–4437, nov. 2013, doi:10.1109/TPWRS.2013.2269804. arXiv:1212.2119.
- [0.2] ✔ D. Bienstock, M. Chertkov, S. Harnett, "Chance-constrained optimal power flow: risk-aware network control under uncertainty," *SIAM Review*, vol. 56, no. 3, pp. 461–495, 2014. arXiv:1209.5779. (Los autores no aparecieron en el resultado de búsqueda; el título, la revista y el volumen sí.)
- [0.3] ✔ L. Roald, S. Misra, T. Krause, G. Andersson, "Corrective control to handle forecast uncertainty: a chance constrained optimal power flow," *IEEE Trans. Power Syst.*, 2017. arXiv:1609.02194. ⚠ Falta confirmar el volumen y las páginas.

**Propuesta A**
- [A1] ✔ X. Lu, K. Sun, J. M. Guerrero, J. C. Vasquez, L. Huang, "State-of-charge balance using adaptive droop control for distributed energy storage systems in DC microgrid applications," *IEEE Trans. Ind. Electron.*, vol. 61, no. 6, pp. 2804–2815, 2014, doi:10.1109/TIE.2013.2279374.
- [A2] ✔ X. Lu, K. Sun, J. M. Guerrero, J. C. Vasquez, L. Huang, "Double-quadrant state-of-charge-based droop control method for distributed energy storage systems in autonomous DC microgrids," *IEEE Trans. Smart Grid*, vol. 6, no. 1, pp. 147–157, 2015, doi:10.1109/TSG.2014.2352342. En carga el coeficiente escala con SoC^n y en descarga con 1/SoC^n; un n mayor acelera el balance.
- [A3] ✔ T. A. Fagundes *et al.*, "Battery energy storage systems in microgrids: a review of SoC balancing and perspectives," *IEEE Open J. Ind. Electron. Soc.*, vol. 5, pp. 961–992, 2024, doi:10.1109/OJIES.2024.3455239. Revisión reciente, de acceso abierto.
- [A4] ✔ "A distributed AGC power sharing strategy considering BESS participation factors," *Electric Power Systems Research*, vol. 217, art. 109117, 2023. Factor de participación que varía en tiempo real con el SoC. ⚠ Falta confirmar los autores.
- [A5] ✔ Y. Zhang, Z. Liu, F. Wang, Z. Chen, "Distributed secondary frequency control and SoC balance for droop-controlled BESSs with a unified SoC relative variation rate," arXiv:2206.14635 (versión relacionada: arXiv:2609.19055). Droop dinámico con reparto según el cociente de SoC, de modo que **todas las BESS se agotan simultáneamente**: es el resultado de A con n = 1. ⚠ Preprint.

**Propuesta B**
- [B1] ✔ H. Hao, B. M. Sanandaji, K. Poolla, T. L. Vincent, "Aggregate flexibility of thermostatically controlled loads," *IEEE Trans. Power Syst.*, vol. 30, no. 1, pp. 189–198, 2015, doi:10.1109/TPWRS.2014.2328865. Modelo de batería generalizada (límites de potencia y energía).
- [B2] ✔ F. L. Müller, J. Szabó, O. Sundström, J. Lygeros, "Aggregation and disaggregation of energetic flexibility from distributed energy resources," arXiv:1705.02815 (publicado luego en *IEEE Trans. Smart Grid*). ⚠ Falta confirmar el volumen y el año de la versión de revista. Trata la desagregación "justa" de una señal agregada.
- [B3] ✔ M. Elsaadany, M. R. Almassalkhi, "Making aggregations reliable: realizability guarantees for battery fleets with heterogeneous power and energy limits," arXiv:2606.01562, 2026. Da condiciones lineales para desagregar respetando potencia y energía: es el teorema de B generalizado. ⚠ Preprint.
- [B4] ✔ M. Elsaadany, M. R. Almassalkhi, "Linear model of aggregated homogeneous energy storage elements with realizable dispatch guarantees," arXiv:2501.04508.

**Propuesta C**
- [C1] ✔ Z. Zhang, M.-Y. Chow, "Convergence analysis of the incremental cost consensus algorithm under different communication network topologies in a smart grid," *IEEE Trans. Power Syst.*, 2012. ⚠ No se confirmaron el volumen ni el DOI. Converge si el grafo tiene un árbol de expansión.
- [C2] ✔ E. Espina, J. Llanos, C. Burgos-Mellado, R. Cárdenas-Dobson, M. Martínez-Gómez, D. Sáez, "Distributed control strategies for microgrids: an overview," *IEEE Access*, vol. 8, pp. 193412–193448, 2020, doi:10.1109/ACCESS.2020.3032378. Incluye despacho económico por consenso.
- [C3] ✔ K. Lu, S. Dong, Y. Song, "A distributed economic power dispatch strategy considering state of charge for microgrids," *IEEE Access*, 2025 (IEEE Xplore doc. 10963348). Cada nodo estima el SoC promedio y logra el balance de SoC con menor costo que el despacho distribuido tradicional.
- [C4] "A marginal cost consensus scheme with reset mechanism for distributed economic dispatch in BESSs," arXiv:2609.19068, 2026. ⚠ Preprint; solo se vio su sección de contribuciones.

**Complementarias**
- ✔ J. M. Guerrero, J. C. Vasquez, J. Matas, L. G. de Vicuña, M. Castilla, "Hierarchical control of droop-controlled AC and DC microgrids," *IEEE Trans. Ind. Electron.*, vol. 58, no. 1, pp. 158–172, 2011.
- ✔ D. G. Díaz González, C. González Morán, J. Gómez-Aleixandre, A. B. Díez, "Scheduling of droop coefficients for frequency and voltage regulation in isolated microgrids," *IEEE Trans. Power Syst.*, vol. 25, no. 1, pp. 489–496, 2010, doi:10.1109/TPWRS.2009.2030425. Un nivel superior programa los coeficientes de reparto: es el antecedente para el w_k del terciario futuro.
- ⚠ T. Morstyn, B. Hredzak, V. G. Agelidis, "Cooperative multi-agent control of heterogeneous storage devices distributed in a DC microgrid," *IEEE Trans. Power Syst.* Se confirmaron el título y los autores (ORA Oxford), pero no el año ni el volumen.

---

## 7. Preguntas que te puede hacer el profesor (y respuestas)

1. **"¿Por qué α variable no desestabiliza el PI?"** Por P1: Σα = 1, así que el PI ve ΔP_φ completo y α solo redistribuye. Además, por P3, α varía en minutos y el PI en segundos.
2. **"¿Por qué no α ∝ E_k, como antes?"** Porque ignora el estado de la MR. En el ejemplo de §5, la MR2 se agota a las 2 h, con 1,1 h de energía aún disponible en las otras.
3. **"¿Cómo se elige T en B?"** T es la duración del evento de desbalance que se quiere cubrir; con el perfil de clientes monofásicos se estima del dato. La alternativa es T(t) = t_fin − t, sin parámetro libre.
4. **"¿El lazo rápido conversa con los DER?"** No. Solo recibe H_k y Π_k **desde el IC**, que ya los conoce por su secundario (la envolvente). Se respeta la separación de roles del 10-nov.
5. **"¿Qué recibe el terciario cuando exista?"** En B, ΔP^max_φ(T) para varios T: la envolvente de la fase. En C, el precio λ_φ.
