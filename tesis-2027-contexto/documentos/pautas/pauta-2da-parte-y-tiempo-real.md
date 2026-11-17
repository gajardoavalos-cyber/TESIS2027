# Pauta de la segunda parte (láminas 14 a 22) y simulación en tiempo real

**Reunión:** continuación de la propuesta de tema con el Prof. Enrique Espina, lunes 2 de noviembre de 2026, 17:00  
**Material:** `propuesta_tesis_usach.pdf`, láminas 14 a 22, más el respaldo R4, R6, R7 y R8  
**Duración estimada:** ≈ 30 min de exposición + conversación  
**Objetivo de hoy:** cerrar la arquitectura de control (terciario y secundario), presentar aporte y plan, y **resolver con el profesor qué significa para él la simulación en tiempo real y dónde entra en la tesis**.

---

## 0. Antes de entrar (5 minutos)

- Abrir el PDF **directamente en la lámina 14** y probar un botón de respaldo (R6) y el botón "Volver al mapa".
- Tener a mano tus notas de la primera mitad: lo que el profesor dijo ahí se usa en el puente de entrada.
- Tener papel para anotar **textual** sus respuestas a las preguntas de la lámina 21 y todo lo que diga sobre tiempo real.

## 1. Puente de reentrada (≈ 2 min)

No volver a explicar la primera parte. Resumirla en tres frases y conectar:

> "Profesor, para retomar: en la primera parte vimos que el desbalance que ve la subestación depende solo de que las tres fases pidan lo mismo (Resultado 1), que Q puede mover el desbalance entre secuencias pero solo P lo reduce, a costa de energía de las baterías (Resultado 2), y que la media diaria de cada fase pone un piso que ningún control corrige. Lo que queda es **cómo se organiza el control para lograr eso**, el aporte y el plan. Sobre la simulación en tiempo real que usted mencionó, la revisé y le propongo dónde encajaría cuando lleguemos a la validación."

Si en la primera mitad el profesor hizo un comentario que cambie algo de lo que viene (por ejemplo, sobre la cabecera rígida o el alcance), **reconocerlo aquí**: "tomé su comentario sobre X; lo veo reflejado en la lámina Y".

---

## 2. Guion lámina por lámina

### Lámina 14: Arquitectura, un rol por nivel (≈ 3 min)

**Objetivo:** que quede claro que la jerarquía **sale de la estructura del problema** (lámina 10: el desbalance acopla las fases, pero la información está repartida), no de una preferencia.

**Guion sugerido:**

> "Cada nivel hace una sola cosa. El terciario, centralizado en la cabecera, decide cada 15 minutos cuánta P y Q aporta cada **fase**, mirando costo, desbalance y energía disponible. El secundario, uno por fase, reparte esa consigna **entre las Micro-redes de esa fase** por consenso, en segundos. El primario, en cada Micro-red, ejecuta: el IC sigue su corriente y la batería forma la tensión DC."

**Desarrollar en vivo:** escribir en la pizarra las tres escalas, minutos ≫ segundos ≫ milisegundos, y decir que esa separación permite diseñar cada nivel suponiendo que el de abajo ya convergió y que el de arriba está fijo.

**Remarcar la regla del recuadro:** el balance **entre** fases lo decide solo el terciario; el secundario reparte **dentro** de la fase. Esta es la diferencia clave con el planteamiento inicial, donde el consenso igualaba fases.

**Probable pregunta:** "¿por qué centralizado si mi línea es distribuida?" → ver la sección 3, C1, y el botón **R6**.

### Lámina 15: Formulación del problema del terciario (≈ 5 min)

**Objetivo:** mostrar que el problema está **bien planteado** (variables, objetivo, restricciones), que es **convexo** y que **no crece** con el número de Micro-redes.

**Guion, término por término del objetivo:**

- $c_t P_{h,t}$: lo que cuesta la energía importada desde la S/E a cada hora.
- $w_c\sum P_{cu}$: castigo por recortar FV, para que no "resuelva" el desbalance botando sol.
- $w_0|I_0|^2 + w_2|I_2|^2$: castigo por desbalance en cabecera.

**Restricciones, ligadas al modelo de la lámina 9:**

1. Balance DC de cada fase agregada: ecuación (1).
2. Dinámica del SOC con **cierre diario** $SOC_{\phi,H}=SOC_{\phi,0}$: ecuación (2).
3. Límites de batería e inversor ($P^2+Q^2\le S^2$): ecuación (3).
4. Límites de cabecera $3|I_0|\le I_n^{\max}$ y $|I_2|\le I_2^{\max}$, con $I_0$ e $I_2$ de las ecuaciones (4)–(6).

**Dato concreto para dar tamaño:** 5 variables por fase × 3 fases × 96 pasos de 15 min = **1 440 variables**, sea cual sea la cantidad de Micro-redes. Se resuelve en fracciones de segundo.

**Por qué es convexo, en una frase:** $I_0$ e $I_2$ son lineales en P y Q (Resultado 1, respaldo R1), así que sus módulos son normas de funciones afines. Eso da un problema cónico de segundo orden (SOCP), sin variables binarias, con **óptimo global**.

**Pregunta para él:** "¿prefiere pesos $w_0$, $w_2$ en el objetivo o límites duros de $I_n$ y VUF según norma?" (es la pregunta 2 de la lámina 21; puede adelantarse aquí).

**Si pregunta por el VUF:** el límite de tensión se traduce en corriente con $\text{VUF}\approx|Z_2 I_2|/V_1$, donde $Z_2$ es la impedancia de secuencia negativa vista desde la cabecera. Con cabecera rígida, $I_2^{\max}$ es el proxy.

### Lámina 16: Horizonte deslizante y precio de la energía (≈ 3 min)

**Guion del horizonte:**

> "No se resuelve una vez al día. Cada 15 minutos se mide el SOC y la cabecera, se planifican las próximas 24 horas, se aplica **solo el primer cuarto de hora** y se repite. Así el error de pronóstico se corrige cada 15 minutos."

**Guion del precio sombra:**

> "El multiplicador de la ecuación de SOC dice cuánto mejoraría el óptimo si la fase φ tuviera 1 kWh más a la hora t. Es como el 'valor del agua' de un embalse: el terciario descarga la batería de la fase donde ese valor es alto, en la punta y en la fase cargada."

**Ser explícito:** enviar ese precio al secundario es **una idea por evaluar**, no un resultado. Decirlo así evita que el profesor lo tome como una promesa.

**Posible pregunta:** "¿qué pasa con el cierre diario del SOC si el horizonte se desliza?" → se reemplaza por un **costo terminal** o una **referencia de SOC** al final del horizonte (Ellis et al., 2014, en la bibliografía).

### Lámina 17: Nivel secundario, consenso dentro de cada fase (≈ 5 min)

**Objetivo:** mostrar la conexión directa con su tesis doctoral (cap. 4) y que el aporte es **un λ por fase**.

**Desarrollar en vivo la condición de óptimo.** Es corta y lo deja ver que entiendes de dónde sale:

1. Lagrangiano de la fase: $\mathcal L=\sum_k\big[\tfrac{1}{2E_k}P_{B,k}^2+b_kP_{B,k}\big]-\lambda\big(\sum_kP_{IC,k}-P^*_\phi\big)$.
2. Como $P_{IC,k}=P_{PV,k}-P_{cu,k}-P_{dl,k}+P_{B,k}$, derivar respecto de $P_{B,k}$ da $\tfrac{1}{E_k}P_{B,k}+b_k-\lambda=0$.
3. Entonces **todas las Micro-redes no saturadas tienen el mismo λ** (costo incremental común). El consenso consiste en que lleguen a ese λ hablando solo con sus vecinas.

**Interpretar $b_k=\beta(SOC^{ref}-SOC_k)$:** si una Micro-red tiene SOC bajo, $b_k$ es positivo y, para el mismo λ, descarga menos (o carga). Resultado: balance de SOC **dentro** de la fase, sin un coordinador central.

**El líder:** es el único que conoce $P^*_\phi$ y la medición de cabecera. Corrige en segundos el error entre lo que pidió el terciario y lo que realmente pasa.

**Algoritmo completo:** botón **R4** (Yang–Tan–Xu: actualización de λ con pesos de vecinos más un estimador del desajuste $y_k$ cuya suma se conserva).

**Probable pregunta:** "¿por qué un λ por fase y no uno global?" → con uno global, el consenso volvería a mover energía entre fases sin mirar la cabecera, que es lo que hacía el planteamiento inicial. El balance entre fases lo fija el terciario.

### Lámina 18: Diagrama de bloques completo (≈ 3 min) ⟵ **aquí se engancha el tiempo real**

**Guion:** recorrer los tres lazos por color.

- **Lazo lento (naranjo, minutos):** cabecera → terciario → consignas por fase.
- **Lazo medio (verde, segundos):** el líder compara lo medido con la consigna y el consenso reparte la corrección.
- **Lazo rápido (teal, milisegundos):** cada IC sigue su consigna.

**Puente al tiempo real (decirlo aquí):**

> "Este diagrama es justamente lo que se llevaría a tiempo real: la planta y el primario corriendo en el simulador, los agentes del secundario en hardware separado que se comunican de verdad, y el terciario en un computador enviando consignas. Lo detallo en la lámina del plan."

### Lámina 19: Aporte esperado e hipótesis (≈ 2 min)

- Tres aportes en una frase cada uno: **formulación** (gestión de cabecera con varias Micro-redes DC por fase), **análisis** (qué corrige P, qué corrige Q y qué fija la energía) y **control** (un λ por fase).
- Leer la hipótesis completa: es de las pocas cosas que conviene leer textual.
- Decir "aporte **candidato**; la revisión sistemática lo confirmará". Si pregunta por la literatura: **R5**. Si pregunta por el tamaño del trabajo: **R7**.

### Lámina 20: Metodología y plan (≈ 4 min, incluye la propuesta de tiempo real)

- Decir que el plan es **tentativo** y que la revisión sistemática y el modelo van primero.
- **Proponer cómo incorporar el tiempo real** (detalle en la sección 4). Frase sugerida: *"Propongo que la validación (OE4) sea en dos etapas: primero simulación offline en PLECS para diseñar y ajustar, y después **simulación en tiempo real con controladores en el lazo**: la planta en el simulador y el secundario en hardware externo comunicándose por una red real. Eso permitiría probar retardos, pérdida de paquetes y el cálculo en tiempo real, que offline no se ven."*

- Mostrar casos y métricas solo si pregunta: **R8**.

### Lámina 21: Preguntas para conversar (resto del tiempo)

Hacer las cinco preguntas de la lámina y **agregar verbalmente las de tiempo real** (sección 4.7). Orden sugerido:

1. **Validación (pregunta 4 de la lámina), fusionada con tiempo real:** es la que más cambia el plan.
2. **Alcance de red (pregunta 1):** ¿solo cabecera o tensiones a lo largo del alimentador?
3. **Límites (pregunta 2):** ¿pesos o límites duros según norma?
4. **Incertidumbre (pregunta 3)** y **extensiones (pregunta 5)**.
5. **La pregunta de fondo:** ¿el tamaño es adecuado para un magíster? (R7)

**Anotar textual.** Al final, repetir en voz alta los acuerdos: "entonces quedamos en: …".

**Cierre sugerido:**

> "Con esto preparo la revisión sistemática y el modelo, y le traigo una propuesta concreta de la plataforma de tiempo real y de qué se simularía en ella. ¿Le parece que nos reunamos en dos semanas?"

### Lámina 22: Bibliografía base (≈ 30 s)

Solo mencionar que están los trabajos de su grupo, los de balance de fases y los del terciario. No leerla.

---

## 3. Contraargumentos probables de esta mitad

**C1. "¿Por qué centralizado el terciario si mi línea es distribuida?"**

- **Respuesta corta:** trabaja con **agregados por fase**, a escala de minutos, con información que ya está en un punto (pronósticos y medición de cabecera); su tamaño no crece con el número de Micro-redes. Lo distribuido se justifica donde hay muchos agentes y escala de segundos: el secundario.
- **Si insiste:** un terciario distribuido (ADMM o DMPC) es una extensión natural, y el centralizado sirve como referencia de óptimo global para comparar. Respaldo **R6**.

**C2. "¿Qué pasa si se cae la comunicación?"**

- Cada fase mantiene la última consigna y el secundario sigue repartiendo. Si se cae todo, cada Micro-red vuelve a operación local (el caso base). El primario es local, así que la estabilidad no depende de la comunicación.
- **Enlace con tiempo real:** "esto es exactamente lo que el tiempo real con comunicación real permite probar".

**C3. "¿Por qué SOCP y no MILP como en los EMS clásicos?"**

- No hay decisiones binarias (ni diésel ni encendido/apagado). Sin binarios el problema es convexo: óptimo global, rápido y con multiplicadores que se interpretan como precios.

**C4. "¿Cómo garantiza estabilidad del lazo completo?"**

- Separación de escalas: cada nivel ve al de abajo como ya convergido y al de arriba como constante. Una prueba formal de la interacción secundario–primario es parte de la validación, y ahí su experiencia sería clave.

**C5. "¿Converge el consenso con saturaciones y retardos?"**

- Con saturaciones, el algoritmo deja fijas las Micro-redes saturadas y el resto ajusta λ. Con retardos y pérdida de enlaces está en las extensiones, y **la simulación en tiempo real con comunicación real es la herramienta adecuada para estudiarlo**.

**C6. "¿Dónde está el aporte frente a lo que ya existe?"**

- En la combinación: varias Micro-redes DC por fase como actuadores, P y Q con energía por fase, terciario de cabecera con límites de secuencia y secundario distribuido por fase. Es una brecha **candidata**, a confirmar con la revisión sistemática. Respaldo **R5**.

**C7. "Es mucho para un magíster."**

- Por eso está separado en núcleo y extensiones (R7). Si se agrega tiempo real, propongo hacerlo con **modelos promedio** (no conmutados) y con el secundario como foco, no la planta completa en detalle.

---

## 4. Simulación en tiempo real: qué es y qué implicaría en la tesis

### 4.1 Qué es, en palabras simples

En una **simulación normal (offline)**, el computador resuelve las ecuaciones tan rápido como puede. Un segundo de simulación puede tomar diez minutos (modelo detallado) o un milisegundo (modelo simple); el tiempo del reloj no importa.

En una **simulación en tiempo real**, cada paso de tiempo simulado se calcula **en exactamente el mismo tiempo del reloj**. Si el paso es de 50 µs, el simulador tiene 50 µs reales para resolver las ecuaciones y entregar sus salidas. Así el modelo se comporta, visto desde afuera, **como si fuera el equipo físico**.

Tres consecuencias:

1. El paso de tiempo es **fijo**. No hay paso variable como en Simulink o PLECS offline.
2. Si un paso no alcanza a calcularse a tiempo hay un **overrun** y la simulación deja de ser válida. Hay que simplificar el modelo o aumentar el paso.
3. Como el simulador "vive" en el tiempo real, se le puede **conectar hardware real**: un controlador, una red de comunicación o incluso un convertidor de potencia.

**Analogía:** un simulador de vuelo. Una simulación offline es calcular la trayectoria de un avión en una planilla. La simulación en tiempo real es la cabina de entrenamiento: el piloto (el controlador real) maneja el avión simulado y no nota la diferencia.

### 4.2 Modalidades (vocabulario que el profesor va a usar)

| Modalidad | Qué es real y qué es simulado | Para qué sirve en tu caso |
|---|---|---|
| **Offline** (lo que tienes hoy) | Todo simulado en un PC, sin restricción de tiempo | Diseñar y ajustar los controles |
| **SIL** (software-in-the-loop) | El código de control real corre en un PC o en otro núcleo, conectado al modelo | Probar el código del secundario tal como se implementaría |
| **CHIL** (controller hardware-in-the-loop) | La **planta** corre en el simulador de tiempo real; el **controlador** corre en hardware real (DSP, microcontrolador, Raspberry Pi) conectado por señales o red | El candidato más natural para la tesis: el secundario en hardware real, con comunicación real |
| **RCP** (rapid control prototyping) | El **controlador** corre en una plataforma de tiempo real (por ejemplo dSPACE) y maneja un **convertidor físico** | Es lo que se hace en laboratorios con prototipo de convertidores |
| **PHIL** (power hardware-in-the-loop) | Simulador + amplificador de potencia que intercambia **potencia real** con un equipo físico | Fuera del alcance de un magíster, salvo que el laboratorio ya lo tenga montado |

### 4.3 Qué implicaría concretamente en esta tesis

**Arquitectura propuesta de un banco de tiempo real (CHIL):**

```
 ┌───────────────────────────────┐   consignas P*_φ, Q*_φ cada 15 min
 │ PC: TERCIARIO (Python/cvxpy)  │──────────────────────────────┐
 └───────────────────────────────┘     (Ethernet: UDP o Modbus)  │
                                                                 ▼
 ┌──────────────────────────────────────────────────────────────────────┐
 │ AGENTES DEL SECUNDARIO en hardware externo                            │
 │ (Raspberry Pi / microcontroladores), uno por Micro-red,               │
 │ hablando solo con sus vecinas por una RED REAL (Ethernet, CAN, WiFi)  │
 └──────────────────────────────────────────────────────────────────────┘
          │ P*_IC,k, Q*_IC,k                     ▲ SOC_k, P_IC,k, P_h,φ medidos
          ▼                                      │
 ┌──────────────────────────────────────────────────────────────────────┐
 │ SIMULADOR DE TIEMPO REAL                                              │
 │ alimentador 3φ-4W + clientes + 6 Micro-redes DC (modelos promedio)    │
 │ + control primario de cada IC y BESS   (paso fijo ≈ 20–50 µs)        │
 └──────────────────────────────────────────────────────────────────────┘
```

**Qué se gana respecto de la simulación offline:**

- **Comunicación real** en el secundario: retardos, pérdida de paquetes, desconexión de un agente (plug-and-play). Offline todo eso hay que inventarlo; en tiempo real ocurre.
- **Implementación discreta real** del consenso: periodo de comunicación, cuantización y tiempo de cómputo.
- **Tiempo de cómputo del terciario** en hardware real: confirmar que el SOCP se resuelve holgadamente dentro de los 15 minutos (debería tomar segundos o menos).
- **Credibilidad:** "validado en tiempo real con controladores en el lazo" pesa más en una publicación que "validado en simulación".

**Decisiones técnicas que hay que tomar:**

1. **Modelo promedio, no conmutado.** Con modelos promedio de los IC y de los convertidores DC, el paso de 20–50 µs se resuelve en procesador. Los modelos conmutados exigen pasos bajo el microsegundo y FPGA. Para una tesis de control de alto nivel, el promedio basta.
2. **El problema de las escalas de tiempo.** Un día de operación del terciario simulado en tiempo real **dura un día real**. Alternativas:
   - Probar el **terciario offline** (24 h simuladas en segundos) y usar el tiempo real solo para **ventanas de minutos** con el secundario y el primario, recibiendo consignas tomadas del terciario.
   - Correr el terciario como proceso externo **con su reloj acelerado** (por ejemplo, un "cuarto de hora" de consigna cada 15 s reales), cuidando que el secundario y el primario sigan siendo mucho más rápidos que ese ritmo.
   - Esta es una **pregunta para el profesor**: qué quiere ver él en tiempo real.
3. **Tamaño del modelo:** 6 Micro-redes con sus convertidores más el alimentador. Hay que verificar que quepa en los núcleos disponibles sin overruns; si no, se agrupan Micro-redes o se reparte el modelo en varios núcleos.

**Lo que NO cambia:** la formulación, los resultados analíticos y el diseño del terciario y el secundario. El tiempo real es una **etapa de validación**, no un tema nuevo.

### 4.4 Plataformas disponibles en el mercado

| Plataforma | Característica principal | Comentario para tu caso |
|---|---|---|
| **PLECS RT Box** (Plexim) | Carga un modelo de **PLECS** y lo convierte en código de tiempo real | Gran ventaja: ya trabajas en PLECS, así que el modelo pasa casi directo |
| **Typhoon HIL** | Muy usado en microrredes; biblioteca de convertidores lista | Usado en la U. de Chile para estudiar fallas de comunicación en microrredes (tesis de Undurraga, 2025) |
| **OPAL-RT** | Simulink en tiempo real; procesador + FPGA | Muy común en papers de control jerárquico de microrredes |
| **dSPACE** | Más orientado a RCP (controlar convertidores reales) | Presente en el laboratorio de microrredes de la U. de Chile |
| **RTDS** | Sistemas de potencia grandes | Sobredimensionado para este problema |
| **Raspberry Pi / ESP32 / DSP** | No simulan la planta: hacen de **agentes** del secundario | La pieza barata del banco; varios papers la usan |

**Lo que no sé, y conviene preguntar:** qué equipo tiene disponible el profesor o la USACH. El profesor es primer autor de un paper que describe un **prototipo de laboratorio de micro-red híbrida** con controladores en tiempo real y una red de fibra óptica que **emula latencia y pérdida de datos** en el secundario (Espina et al., EPE 2020). Ese laboratorio es la referencia natural para preguntarle.

### 4.5 Riesgos honestos

- **Curva de aprendizaje:** configurar entradas y salidas, escalas de señales, sincronización y redes toma semanas, no días.
- **Disponibilidad del equipo:** si no hay simulador propio, depende de horarios de otro laboratorio.
- **Alcance:** si se suma al núcleo sin recortar otra cosa, el plan se alarga. Propuesta: tiempo real solo con modelo promedio y con foco en el secundario.

### 4.6 Cómo quedaría el OE4 reformulado (propuesta para mostrarle)

> **OE4:** Validar la estrategia primero en simulación offline (PLECS) y luego en simulación en tiempo real con controladores en el lazo, implementando el secundario en hardware externo con comunicación real, para evaluar su desempeño ante retardos, pérdida de paquetes y desconexión de Micro-redes.

### 4.7 Preguntas para el profesor sobre tiempo real

1. "Cuando dice tiempo real, ¿se refiere a correr la planta en un simulador con **los controladores en hardware real** (CHIL), o a otra cosa?"
2. "¿Qué plataforma tendríamos disponible: dSPACE, OPAL-RT, Typhoon, RT Box? ¿Es equipo de la USACH o del laboratorio de la U. de Chile en que usted trabajó?"
3. "¿Qué le interesa ver en tiempo real: el secundario con comunicación real, la interacción con el primario, o el día completo con el terciario?"
4. "¿Lo ve como parte del **núcleo** de la tesis o como una etapa de validación final?"
5. "¿Hay alguien del grupo con experiencia en esa plataforma que me pueda orientar al inicio?"

### 4.8 Qué leer para entenderlo (en este orden)

1. **Marco conceptual (definiciones, paso fijo, overruns, CHIL vs. PHIL):** Faruque et al., "Real-Time Simulation Technologies for Power Systems Design, Testing, and Analysis", *IEEE Power and Energy Technology Systems Journal*, vol. 2, no. 2, 2015. [PDF de acceso libre](https://infoscience.epfl.ch/record/210998/files/07138557.pdf?version=1)
2. **Aplicaciones (RCP, CHIL, PHIL, microrredes, co-simulación con comunicaciones):** Guillaud et al., "Applications of Real-Time Simulation Technologies in Power and Energy Systems", *IEEE PETSJ*, vol. 2, no. 3, 2015. [PDF de acceso libre](https://infoscience.epfl.ch/record/213842/files/07234831.pdf)
3. **El caso más parecido a tu tesis (banco de control jerárquico de microrred):** Tu, Du, Yu, Lukic et al., "A Hardware-in-the-Loop Real-Time Testbed for Microgrid Hierarchical Control", 2018. Planta en OPAL-RT, primario en DSP y secundario distribuido en nodos con comunicación real. [PDF](https://www.freedm.ncsu.edu/wp-content/uploads/2018/10/ECCE-2018-HIL-Testbed-for-Microgrid-Control-Tu-Du-Lu-Lukic.pdf)
4. **Consenso con comunicación real y PLECS RT Box (autores chilenos):** Aguilar, Riffo, Veliz, González-Castaño, Restrepo, "RT Box card for studying the control communication impacts on microgrid performance and stability", *HardwareX*, 2022. Secundario por consenso con retardos y 80 % de pérdida de paquetes. [Acceso libre](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9184748/)
5. **Tesis chilena con Typhoon HIL y fallas de comunicación:** Undurraga, "Evaluación del desempeño de una microrred ante problemas en las comunicaciones utilizando simulación en tiempo real y hardware in the loop", U. de Chile, 2025. [Repositorio](https://repositorio.uchile.cl/handle/2250/205292)
6. **El prototipo de laboratorio del grupo del profesor:** Espina et al., "Experimental Hybrid AC/DC-Microgrid Prototype for Laboratory Research", EPE'20 ECCE Europe, 2020. [Ficha ANID](https://investigadores.anid.cl//en/public_search/work?id=822381)
7. **Plataforma que conecta con PLECS:** [Introducción al PLECS RT Box (Plexim)](https://www.plexim.com/node/1047)
8. **Laboratorio de microrredes de la U. de Chile (equipamiento):** [Laboratorio de Control de Micro-redes, DIE U. de Chile](https://www.die.cl/laboratorio-de-control-de-micro-redes/)

**Si solo alcanzas a leer uno antes de las 17:00:** el resumen e introducción de Faruque et al. (2015), y la figura del banco de Tu et al. (2018).
