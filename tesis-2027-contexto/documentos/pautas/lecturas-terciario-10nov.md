# Arquitectura reformulada, terciario y lazo rápido: recomendaciones y lecturas (v3, 12 nov 2026, tras el correo del Prof. Espina)

> **Corrección v3 (12 nov).** La versión anterior de la regla del lazo rápido aplicaba el PI directamente sobre la fracción $u_\phi\in[-1,1]$. Con esa forma, $\sum_\phi\Delta P_\phi=0$ solo se cumple si las tres fases tienen la misma reserva total. La forma correcta, que es la usada en `laminas_reunion_16nov.tex`, es la de la sección 5: el PI entrega $\Delta P_\phi$ en kW y después se normaliza.

## 1. Lo que fija el correo del 10 nov

1. **El lazo rápido actúa solo sobre los IC.** No se comunica con secundarios ni con DER. Los DER solo ven su bus DC: cuando el IC cambia su potencia, el secundario restaura la tensión y reparte ese cambio, sin saber nada del desbalance.
2. **Objetivos separados.**
   - El terciario se encarga de la **energía**: minimiza la compra, define la trayectoria de energía de cada MR y asigna una **reserva** para el balance.
   - El lazo rápido es el **único responsable del balance** en la cabecera, y solo usa esa reserva.
   - Analogía: una reserva de regulación, que el terciario asigna y el lazo rápido despacha.
3. **Cada MR informa al terciario lo que puede ofrecer**, a través de su IC, como una **envolvente** sobre el horizonte: potencia mínima y máxima, y energía mínima y máxima.
   - Basta un pronóstico simple (perfil conocido + error controlado).
   - Hay que definir qué pasa cuando una MR se equivoca.
4. **Lazo rápido por fase:** iguala las potencias de las tres fases en la cabecera. Revisar si tiene sentido usar Q primero en BT.

**Para el lunes 16 nov:**
- lámina de niveles,
- formulación del terciario,
- regla del lazo rápido.

**Del 9 nov:** los IC son grid-following en AC.

## 2. Qué queda obsoleto (verdad cruda)

- **Desbalance en el objetivo del terciario:** el término $w_U(|B|^2+|C|^2)$ sale del objetivo. El balance entra al terciario solo como requisito de reserva.
- **"Usar Q primero":** se descarta. Por el Resultado 2, Q no reduce el desbalance de potencia activa, y en BT se cumple $R>X$.
- **"Llevar $I_0,I_2\to0$":** pasa a ser "igualar las potencias por fase". Con tensión de cabecera balanceada son equivalentes (Resultado 1).
- **Láminas v6:** todavía dicen "grid-supporting", "Q primero" y "mín. costo + desbalance". Las reemplaza `laminas_reunion_16nov`.

## 3. Lo que informa cada MR (la envolvente)

$$\mathcal E_k(t)=\{P^{\min}_k,\,P^{\max}_k,\,W^{\min}_k,\,W^{\max}_k\}(t)$$

**Potencia.** Son los límites del IC, de la BESS y del EV, con el FV y la carga pronosticados ya descontados.

**Energía.** $W$ es la energía acumulada que entrega el IC desde el inicio del horizonte. Sus límites salen de los límites de energía de la BESS y del EV, incluido el $E_{\mathrm{req}}$ del EV:

$$W^{\max}_k(t)=E_k(0)+\sum(\hat P_{\mathrm{PV}}-\hat P_L)\Delta t-E^{\min}_k$$
$$W^{\min}_k(t)=E_k(0)+\sum(\hat P_{\mathrm{PV}}-\hat P_L)\Delta t-E^{\max}_k$$

**Pronóstico.** Perfil conocido más un error acotado $\bar\varepsilon_k$.

**Si la MR se equivoca.** El IC grid-following mantiene su consigna y la BESS absorbe la diferencia. El error consume reserva de energía, y por eso aparece $\bar\varepsilon_k$ en la restricción de energía. Cada 15 min se replanifica con el valor real de $E_k$.

## 4. Formulación del terciario (cada 15 min, $H=12$ h)

**Variables.** Para cada MR: el plan $P^*_k$ y la reserva $r^{\uparrow}_k,\,r^{\downarrow}_k\ge0$.

**Objetivo (solo energía).**
$$\min\ \sum_t c(t)\,P^{+}_{\mathrm{imp}}(t)\,\Delta t,\qquad P_{\mathrm{imp}}=\hat P_{L,\mathrm{tot}}-\sum_k P^*_k$$

**Restricciones.**
- (a) Potencia: $P^{\min}_k+r^{\downarrow}_k\le P^*_k\le P^{\max}_k-r^{\uparrow}_k$
- (b) Energía: $W^{\min}_k+r^{\downarrow}_k\tau+\bar\varepsilon_k\le W^*_k\le W^{\max}_k-r^{\uparrow}_k\tau-\bar\varepsilon_k$, con $W^*_k(t)=\sum_{s\le t}P^*_k\Delta t$
- (c) Reserva por fase: $\sum_{k\in\mathcal N_\phi}r^{\uparrow}_k\ge R^{\uparrow}_\phi$ y $\sum_{k\in\mathcal N_\phi}r^{\downarrow}_k\ge R^{\downarrow}_\phi$

**Dimensionamiento de la reserva por fase.**
- Demanda no gestionada de cada fase: $P_{\mathrm{cl},\phi}=P_{h,\phi}+\sum_{k\in\mathcal N_\phi}P_{\mathrm{IC},k}$
- Su desviación respecto del promedio: $D_\phi=\hat P_{\mathrm{cl},\phi}-\tfrac13\sum_\psi\hat P_{\mathrm{cl},\psi}$
- Reserva: $R^{\uparrow}_\phi=[D_\phi]^++m$ y $R^{\downarrow}_\phi=[-D_\phi]^++m$

**Salidas.** A cada IC: $P^*_k$ y $[r^{\downarrow}_k,r^{\uparrow}_k]$. Al lazo rápido: $R_\phi=\sum r_k$. El problema es lineal.

## 5. Regla del lazo rápido (por fase)

1. **Mide** $P_{h,a},P_{h,b},P_{h,c}$ en la cabecera.
2. **Calcula el error de cada fase:** $e_\phi=P_{h,\phi}-\bar P_h$. Por construcción, $\sum_\phi e_\phi=0$.
3. **PI con anti-windup** (salida en kW): $\Delta P_\phi=\mathrm{sat}_{[-R^{\downarrow}_\phi,\,R^{\uparrow}_\phi]}\big(k_p e_\phi+k_i\!\int e_\phi\big)$
4. **Normaliza:** $u_\phi=\Delta P_\phi/R^{\uparrow}_\phi$ si $\Delta P_\phi\ge0$, o $u_\phi=\Delta P_\phi/R^{\downarrow}_\phi$ si $\Delta P_\phi<0$. Es una sola señal por fase.
5. **Cada IC aplica** $\Delta P_k=u_\phi\,r^{\uparrow}_k$ (o $u_\phi\,r^{\downarrow}_k$). Por lo tanto $\sum_{k\in\mathcal N_\phi}\Delta P_k=\Delta P_\phi$, y cada IC aporta en proporción a su reserva.

**Propiedades.**
- Si las tres fases tienen las mismas ganancias y nada satura, $\sum_\phi\Delta P_\phi=0$. El lazo mueve potencia entre fases sin cambiar la compra total, así que no deshace el plan del terciario.
- **Ejemplo:** la fase $a$ demanda 6 kW más que las otras. Entonces $e=(4,-2,-2)$ kW: las MR de $a$ entregan 4 kW, y las de $b$ y $c$ absorben 2 kW cada una. Las tres fases quedan iguales.
- Si $|u_\phi|=1$, la reserva de esa fase se agotó.
- **Q:** no se usa por ahora ($Q_{\mathrm{ref}}=0$). Queda como extensión opcional.

## 6. Lecturas, en orden

1. Bustos, Marín, Navas-Fonseca, Reyes-Chamorro, Sáez, Applied Energy 342, 2023. https://ideas.repec.org/a/eee/appene/v342y2023ics0306261923005093.html
2. Müller, Szabo, Sundström, Lygeros, IEEE TSG 2019 (envolventes). https://arxiv.org/pdf/1705.02815
3. Nasrolahpour, Kazempour, Zareipour, Rosehart, IEEE TSTE 2017 (energía + reserva). https://core.ac.uk/download/86558459.pdf
4. Mexis, Todeschini, Zhou, IEEE TEC 2022 (inversores monofásicos coordinados). https://cronfa.swansea.ac.uk/Record/cronfa61052/Download/61052__25368__35dfd823984a46369995096bae02a94a.pdf
5. Liu, Braslavsky, Mahdavi, 2023 (envolventes en redes desbalanceadas). https://arxiv.org/abs/2302.13472
6. Hans et al., MPC jerárquico distribuido de microrredes. https://epub.uni-bayreuth.de/id/eprint/3264/1/HBRGR2017.pdf
7. Palma-Behnke et al., IEEE TSG 2013. https://investigadores.anid.cl//en/public_search/work?id=230529
8. Parisio, Rikos, Glielmo, IEEE TCST 2014. https://www.iris.unina.it/handle/11588/910698
9. Pinthurat, Hredzak, arXiv 2011.06181. https://arxiv.org/abs/2011.06181
10. Olivares et al., IEEE TSG 2014. https://uwspace.uwaterloo.ca/items/eaa62661-f72f-4491-888f-acff6e44fc83
11. Kaur, Nonnenmacher, Coimbra, Energy 2016 (prioridad baja). https://ideas.repec.org/a/eee/energy/v114y2016icp1073-1084.html
