# Pauta: niveles de control como conjuntos de entradas y salidas

**Material:** `niveles_control_conjuntos.pdf` (10 láminas, formato USACH)  
**Para qué sirve:** entender y explicar la arquitectura que pidió el profesor Espina (correo del 4 de noviembre), separando cada nivel por **qué mide o recibe** (conjunto de entradas $\mathcal U$), **qué decide** (función $f$) y **qué envía** (conjunto de salidas $\mathcal Y$).  
**Reunión:** lunes 9 de noviembre de 2026.

---

## 0. Cómo usar estas láminas el lunes (verdad cruda)

El profesor pidió **una sola lámina** con los niveles de control, más el caso simple, y que **no se cambie el resto de la presentación**. Por eso:

- **Lo que se presenta:** la lámina de tabla "Niveles de control: qué mide, qué decide y a quién envía" y el caso simple (archivo `lamina_niveles_control_9nov.pdf`).
- **Estas 10 láminas son material de estudio y de respaldo.** Sirven para que tú domines la arquitectura y para mostrar una lámina puntual si él pregunta. Las más útiles como respaldo son la **4 (mapa general)** y la **9 (intersección de conjuntos)**.
- Si él prefiere un diagrama en vez de una tabla, la **lámina 4** puede reemplazar a la tabla como "la lámina única": tiene los cuatro niveles, las entradas y salidas y el punto abierto 4 marcado.

---

## 1. Guion lámina por lámina

### Lámina 2: la idea, cada nivel es una función entre conjuntos (≈ 1 min)

- **Mensaje:** cada nivel se describe completo con tres cosas: su conjunto de entradas $\mathcal U$, su función $f$ (lo que decide) y su conjunto de salidas $\mathcal Y$.
- **Las tres reglas** son la clave para razonar sin ambigüedad:
  1. Un nivel **solo** puede usar lo que está en su $\mathcal U$. Si una variable no está en su conjunto, ese nivel no puede reaccionar a ella.
  2. Lo que un nivel envía es parte de la entrada de otro: $\mathcal Y_T\subseteq\mathcal U_{S,k}\cup\mathcal U_L$. Así se conectan los niveles.
  3. Si dos conjuntos no se cruzan ($\cap=\varnothing$), esos niveles no comparten información.
- **Analogía de la cocina:** el chef arma el menú con la información de la sala (terciario); cada cocinero prepara su plato con sus ingredientes y no mira la sala (secundario); el horno sigue la temperatura que le dan (primario).

### Lámina 3: los conjuntos del escenario (≈ 2 min)

- **Fases:** $\Phi=\{a,b,c\}$.
- **Micro-redes:** el conjunto $\mathcal N$ de todas las micro-redes está **particionado** por fase:
  $$\mathcal N=\mathcal N_a\cup\mathcal N_b\cup\mathcal N_c,\qquad \mathcal N_\phi\cap\mathcal N_\psi=\varnothing.$$
  "Partición" significa dos cosas: cada micro-red está en alguna fase (la unión cubre todo) y en **una sola** (las intersecciones son vacías). Eso es exactamente "cada micro-red se conecta a una sola fase mediante un IC monofásico" (punto 4 del correo). $|\mathcal N_\phi|=N_\phi$ es distinto en cada fase.
- **DER de cada micro-red:** $\mathcal D_k\subseteq\{\text{PV},\text{BESS},\text{EV},\text{carga}\}$. Es un **subconjunto**, porque no todas tienen todo (punto 3: cada micro-red tiene una cantidad distinta de cada recurso).
- **Tiempo:** $\mathcal T_H$ es el conjunto de instantes de la ventana del terciario. Su duración $H$ es el punto abierto 1.
- **No hay barra DC común** (punto 5): en lenguaje de conjuntos, las micro-redes no comparten variables DC; la única variable común es la red AC.

### Lámina 4: mapa general (≈ 2 min)

Recorrer de arriba hacia abajo:

- **Terciario** $f_T$: recibe pronósticos, tarifa, medición de cabecera y SoC. Entrega a cada micro-red su **plan** y su **rango de SoC**.
- **Secundario de cada micro-red** $f_{S,k}$: recibe el plan y el rango y entrega referencias a cada DER. Informa su SoC hacia arriba.
- **Primario** $f_P$: actúa sobre la planta.
- **Lazo rápido** $f_L$: recibe la medición de cabecera ($I_0$, $I_2$) y entrega correcciones $\Delta P_k$, $\Delta Q_k$. La **flecha punteada con el punto 4** muestra que el camino hacia los IC está por definir.

**Escalas:** minutos (terciario), segundos (lazo rápido y secundario), milisegundos (primario).

### Lámina 5: terciario (≈ 2 min)

- $\mathcal U_T$: pronósticos de clientes, FV y EV (llegada, salida, energía requerida) dentro de la ventana; tarifa (punto 2); medición de cabecera; SoC de BESS y EV.
- $f_T$: optimización con ventana fija $H$ (punto 1). Minimiza la compra de energía y el desbalance del intercambio entre fases.
- $\mathcal Y_T$: para cada micro-red, plan $P^*$, $Q^*$ y rango $[\mathrm{SoC}^{\min}_k,\mathrm{SoC}^{\max}_k]$ (punto 3), válidos para los próximos 15 minutos.
- **Frase clave** (aclaración 2 del profesor): "el rango no busca que cada batería aporte según su tamaño; **acota la energía** de cada micro-red en el intervalo y **deja un margen** para corregir el desbalance".

### Lámina 6: lazo rápido (≈ 2 min)

- $\mathcal U_L$: medición de cabecera ($I_0$, $I_2$ o las potencias por fase) y, posiblemente, el margen de SoC de cada micro-red (punto 4).
- $\mathcal Y_L$: correcciones $\Delta P_k$, $\Delta Q_k$ que **no sacan** el SoC fuera de su rango.
- **Tres tarjetas, tres ideas** (aclaración 3 del profesor):
  1. **No sigue el plan**, porque el plan también puede venir desbalanceado: corrige lo **medido**.
  2. Usa **Q primero** porque no gasta energía (Resultado 2).
  3. **Cómo llega a los IC está por definir**, y no se acopla a secundarios por fase.

### Lámina 7: secundario de la micro-red k (≈ 2 min)

- $\mathcal U_{S,k}$: lo que viene del terciario (plan y rango) más las variables **propias** de la micro-red ($V_{dc,k}$, SoC y potencia de su BESS y su EV, FV disponible).
- $\mathcal Y_{S,k}$: una referencia para el primario de cada DER $d\in\mathcal D_k$, respetando los límites de BESS y EV. Hacia arriba envía su SoC.
- **La tarjeta roja es el corazón de la aclaración 1 del profesor**, dicha con conjuntos:
  $$\mathcal U_{S,k}\cap\{S_{h,\phi},I_0,I_2\}=\varnothing\quad\text{(no ve la cabecera)}$$
  $$\mathcal U_{S,k}\cap\mathcal Y_{S,j}=\varnothing,\;j\neq k\quad\text{(no coordina con otras micro-redes)}$$
- **Frase sugerida:** "el secundario es uno por micro-red y su conjunto de información está encerrado dentro de la micro-red".

### Lámina 8: primario (≈ 1 min)

- **DER grid-supporting** (punto 6 del correo): ajustan su potencia según $V_{dc}$ con droop $P$–$V_{dc}$. Apoyan la tensión DC sin formarla solos.
- **IC:** sigue $P^*+\Delta P$ y $Q^*+\Delta Q$ con control de corriente y PLL. Si además es grid-supporting en el lado AC, es el punto abierto 5.
- El primario no envía información a otros niveles: su salida es la acción sobre el convertidor.

### Lámina 9: ¿quién ve qué? (≈ 3 min), la más importante para el respaldo

Es un diagrama de Venn de los **conjuntos de información** $\mathcal I_T$, $\mathcal I_L$, $\mathcal I_{S,k}$. Recorrer región por región:

| Región | Contenido | Significado |
|---|---|---|
| Solo $\mathcal I_T$ | Pronósticos, tarifa, $E^{req}$ del EV | Solo el terciario planifica a futuro |
| $\mathcal I_T\cap\mathcal I_L$ | Medición de cabecera | Los dos miran la cabecera; el secundario no |
| $\mathcal I_T\cap\mathcal I_{S,k}$ | Plan$_k$, SoC$_k$ | El plan baja, el SoC sube |
| Centro (los tres) | **Rango de SoC$_k$** | El terciario lo fija, el lazo rápido usa su margen, el secundario lo respeta |
| $\mathcal I_L\cap\mathcal I_{S,k}$ | ¿$\Delta P_k$? | Depende de si la corrección pasa por el secundario (punto 4) |
| Solo $\mathcal I_{S,k}$ | $V_{dc}$, SoC y potencia de sus DER | Información interna de la micro-red |

**Mensaje para el profesor:** "el rango de SoC es la única variable que comparten los tres niveles; por eso es la interfaz central de la arquitectura".

### Lámina 10: puntos por aclarar (≈ 1 min)

Leer los cinco y pedir su opinión en cada uno. El orden de prioridad sugerido es **4 → 1 → 3 → 5 → 2**, porque el 4 (estructura del lazo rápido) define el diseño y el 1 (ventana $H$) ya tiene una propuesta justificada con el caso simple.

---

## 2. Autoevaluación (responder antes del lunes)

1. ¿A qué conjuntos pertenece SoC$_k$? (A $\mathcal Y_{S,k}$, porque lo informa, y a $\mathcal U_T$, porque el terciario lo usa.)
2. ¿Puede el secundario reaccionar a un aumento de $I_0$? (No: $I_0\notin\mathcal U_{S,k}$. Solo lo hace el lazo rápido.)
3. ¿Qué pasa si el lazo rápido pide un $\Delta P_k$ que sacaría al SoC del rango? (Debe saturarse: la restricción $\mathrm{SoC}_k\in[\mathrm{SoC}^{\min}_k,\mathrm{SoC}^{\max}_k]$ manda.)
4. ¿Por qué $\mathcal N_a\cap\mathcal N_b=\varnothing$ es importante? (Porque una micro-red no puede repartir su potencia entre fases: lo que inyecta queda en su fase.)
5. Si $H$ es más corta que el evento de demanda alta, ¿qué falla? (El terciario no ve el evento completo y tiende a gastar la energía al inicio; ver el caso simple.)

## 3. Preguntas probables del profesor

- **"¿Por qué el rango es la interfaz central?"** Porque es lo único que conecta la planificación (energía en el tiempo) con la corrección rápida (potencia en segundos) sin que los niveles se pisen: el terciario reparte la energía y el lazo rápido solo usa lo que el rango deja libre.
- **"¿El lazo rápido necesita conocer el margen de cada micro-red?"** Hay dos opciones. **(a)** Sí, y reparte la corrección según el margen (centralizado). **(b)** No, envía una señal común y cada micro-red la limita localmente con su rango (descentralizado). La (b) respeta mejor la idea de que el secundario no coordina con otros, pero puede dejar margen sin usar.
- **"¿Qué ventaja tiene describirlo con conjuntos?"** Obliga a decir **explícitamente** qué información tiene cada nivel; así se detectan dependencias ocultas. Por ejemplo, si un nivel necesita una variable que no está en su conjunto, falta un canal de comunicación.

---

## 4. Bibliografía para revisar ahora

Ordenada por tema y en orden de lectura dentro de cada tema. 🔓 = acceso libre.

### A. Qué es un nivel de control y cómo se separan

1. **Rocabert, Luna, Blaabjerg, Rodríguez (2012)**, "Control of Power Converters in AC Microgrids", *IEEE Trans. Power Electronics*, 27(11), 4734–4749. Define **grid-forming, grid-feeding y grid-supporting** (punto 6 del correo). [DOI](https://doi.org/10.1109/TPEL.2012.2199334)
2. **Olivares et al. (2014)**, "Trends in Microgrid Control", *IEEE Trans. Smart Grid*, 5(4). Funciones de cada nivel y del EMS. 🔓 [Repositorio U. de Chile](https://repositorio.uchile.cl/handle/2250/126993)
3. **Bidram y Davoudi (2012)**, "Hierarchical Structure of Microgrids Control System", *IEEE Trans. Smart Grid*, 3(4). Roles por nivel y escalas de tiempo. [DOI](https://doi.org/10.1109/TSG.2012.2197425) (DOI recordado y no verificado; si no abre, buscar por título)

### B. Secundario dentro de una micro-red DC (aclaración 1)

4. **Dragičević, Lu, Vásquez, Guerrero (2016)**, "DC Microgrids—Part I: A Review of Control Strategies and Stabilization Techniques", *IEEE Trans. Power Electronics*, 31(7). Primario y secundario en DC: droop, restauración de $V_{dc}$, reparto entre DER. 🔓 [PDF, Aalborg](https://vbn.aau.dk/ws/files/218830588/Paper1_final.pdf)
5. **Tesis doctoral del profesor Espina**, sec. 2.6.2 y referencias [E116]–[E131] (Nasirian et al., Oliveira et al., Zhang et al.): secundario DC con balance de SoC. Ya la tienes en PDF.

### C. Terciario con plan + capa de tiempo real (rango de SoC, aclaración 2)

6. **Elkazaz, Sumner, Naghiyev, Pholboon, Davies, Thomas (2020)**, "A Hierarchical Two-Stage Energy Management for a Home Microgrid Using Model Predictive and Real-Time Controllers", *Applied Energy*. Un MPC cada 15 min con horizonte de 24 h entrega un **perfil de energía almacenada**; un controlador en tiempo real (cada 1 min) ajusta la batería frente a ese perfil y devuelve el SoC. Es el antecedente más parecido a "plan + rango de SoC + lazo rápido". 🔓 [Repositorio U. de Nottingham](https://nottingham-repository.worktribe.com/file/4481580/1/A%20Hierarchical%20Two-Stage%20Energy%20Management%20for%20a%20Home%20Microgrid%20Using%20Model%20Predictive%20and%20Real-Time%20Controllers) · [ScienceDirect](https://sciencedirect.com/science/article/abs/pii/S0306261920306309)
7. **Mayne, Seron, Raković (2005)**, "Robust model predictive control of constrained linear systems with bounded disturbances", *Automatica*, 41(2). **MPC con tubo**: un plan nominal más un controlador que mantiene al sistema dentro de un "tubo" alrededor del plan. Es la idea matemática detrás de "plan + rango". (Buscar por título en la biblioteca.)
8. **Hao, Sanandaji, Poolla, Vincent (2015)**, "Aggregate Flexibility of Thermostatically Controlled Loads", *IEEE Trans. Power Systems*, 30(1). Modelo de **batería virtual**: describe la flexibilidad como límites de potencia y de energía. Útil para justificar cómo elegir el ancho del rango de SoC (punto 3). [Ficha LBNL](https://certs.lbl.gov/node/8262.html)

### D. Lazo rápido: corregir el desbalance medido en cabecera (aclaración 3)

9. **Mexis, Todeschini, Zhou (2022)**, "Coordinated Control of Three Single-Phase BESS Inverters Using Local Measurements to Mitigate Voltage Unbalance", *IEEE Trans. Energy Conversion*, 37(4). Un controlador superior mide las corrientes en el **secundario del transformador** y fija $P$ y $Q$ de tres inversores monofásicos para cancelar secuencia cero y negativa. **Es el más cercano al lazo rápido.** 🔓 [PDF, Swansea](https://cronfa.swansea.ac.uk/Record/cronfa61052/Download/61052__25368__35dfd823984a46369995096bae02a94a.pdf)
10. **Pinthurat y Hredzak (2020)**, "Dynamic power balancing algorithm for single-phase energy storage systems in LV distribution network with unbalanced PV systems distribution". Balance dinámico con baterías monofásicas y control distribuido. 🔓 [arXiv](https://arxiv.org/abs/2011.06181)
11. **Hashmi et al. (2020)**, "Towards phase balancing using energy storage". Balance de fases con almacenamiento y su costo energético; útil para el caso simple. 🔓 [arXiv](https://arxiv.org/pdf/2002.04177.pdf)
12. **Chen, Zhu, Ibrahim, O'Donnell, Liserre**, "Neutral Current Optimization Control for Smart Transformer-fed Distribution System under Unbalanced Loads". Lazo cerrado sobre la **corriente de neutro medida**, con límite de VUF de 2 % (EN 50160). Usa un transformador inteligente, no baterías, pero la lógica de realimentación sirve. 🔓 [Repositorio UCD](https://researchrepository.ucd.ie/rest/bitstreams/45615/retrieve)

### E. Ventana de predicción y MPC económico (punto 1)

13. **Parisio, Rikos, Glielmo (2014)**, "A Model Predictive Control Approach to Microgrid Operation Optimization", *IEEE TCST*, 22(5). Cómo se eligen el paso y el horizonte en un EMS. 🔓 [Academia.edu](https://www.academia.edu/80581609/A_Model_Predictive_Control_Approach_to_Microgrid_Operation_Optimization)
14. **Ellis, Durand, Christofides (2014)**, "A tutorial review of economic model predictive control methods", *J. Process Control*, 24(8). Horizonte finito, costo terminal y qué pasa cuando la ventana es corta. [DOI](https://doi.org/10.1016/j.jprocont.2014.03.010)

**Ruta mínima antes del lunes:**

1. **Rocabert (2012):** solo la sección de clasificación de convertidores, 20 min.
2. **Mexis (2022):** la figura del controlador superior y la sección de control, 40 min.
3. **Elkazaz (2020):** la figura de las dos etapas y cómo se comunican, 30 min.

Con esas tres lecturas puedes defender los puntos 6 (grid-supporting), 4 (lazo rápido) y 3 (rango de SoC).
