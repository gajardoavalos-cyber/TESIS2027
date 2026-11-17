# Pauta de exposición: reunión de tesis del 26 de octubre

**Tesis:** Gestión jerárquica de un alimentador BT 3φ-4W con Micro-redes DC por fase  
**Reunión con:** Prof. Dr. Enrique Espina González (profesor guía)  
**Duración estimada:** 45 min (≈ 28 min de exposición + 15–20 min de conversación)  
**Material asociado:** `reunion_tesis_26oct_usach.pdf` (29 diapositivas, formato de clases USACH)  
**Objetivo de la reunión:** demostrar que las seis observaciones del 20 de octubre se entendieron y se incorporaron, presentar el escenario ampliado con su arquitectura terciario–secundario ya formalizada, y salir de la reunión con una respuesta concreta a las cinco preguntas de la diapositiva B15.

---

## 0. El problema que soluciona la tesis, en palabras sencillas

Conviene tener esta parte **memorizada en tres versiones** y elegir según el momento. Si el profesor interrumpe al inicio con "a ver, ¿qué es lo que resuelves?", la versión de 30 segundos es la respuesta.

**Versión de 30 segundos (para abrir o para responder de golpe):**

> "En baja tensión las casas se conectan a una sola fase. Como cada fase tiene clientes distintos, durante el día una fase va más cargada que las otras. La subestación ve eso como corriente por el neutro y secuencia negativa: más pérdidas, transformador más exigido y tensiones desiguales. Hoy, en cada fase, hay Micro-redes DC con paneles, baterías e inversor monofásico, pero cada una mira solo su casa. La tesis propone coordinarlas para que, vistas desde la subestación, las tres fases tiren parejo y la energía se compre barata, sin vaciar ninguna batería ni pasarse de los límites de los equipos."

**Versión con analogía (si el profesor pide intuición o si hay que explicárselo a alguien fuera del área):**

> "Piensa en tres personas cargando una mesa, una en cada pata. Si una carga más que las otras, la mesa se inclina: eso es el desbalance, y el neutro es el que 'sostiene la inclinación'. Las Micro-redes DC son ayudantes con mochila (la batería): pueden ayudar a la persona más cargada en la hora más pesada, pero la mochila se vacía. Entonces hay que decidir **cuándo** y **a quién** ayudar durante el día, para que la mesa vaya derecha la mayor parte del tiempo y nadie se quede sin energía. Esa decisión del día completo es el nivel terciario; repartir la ayuda entre los ayudantes de una misma pata es el nivel secundario."

**Versión técnica (una frase, para el documento o el abstract):**

> "Se propone una arquitectura jerárquica —terciario centralizado en cabecera y secundario distribuido por fase— que usa como actuadores varias Micro-redes DC monofásicas por fase, con potencia activa y reactiva por fase, para gestionar el intercambio de energía y las componentes de secuencia cero y negativa en la cabecera de un alimentador BT 3φ-4W, sujeto a restricciones energéticas por fase."

**Qué NO soluciona (decirlo antes de que lo pregunte; da credibilidad):**

- No elimina el desbalance activo **medio del día**: si una fase tiene más carga neta que otra durante todo el día, ninguna batería puede corregirlo indefinidamente (piso energético). Eso es un tema de diseño (dónde instalar FV/BESS), no de control.
- Todavía no regula tensiones **a lo largo** del alimentador; el modelo actual es de cabecera (sin impedancias de línea ni neutro).
- No propone un control primario nuevo: el primario (PLL + PR, droop DC) se toma del estado del arte.

## 1. Idea central de la reunión

El mensaje que el profesor tiene que llevarse es: **"entendí por qué la ley anterior no servía, y la reformulación ahora tiene un objetivo que sí se puede alcanzar y está bien repartido entre niveles"**. Todo lo demás (prototipo, resultados) respalda esa frase.

Frase de apertura sugerida: "Profesor, sus observaciones tenían razón en los seis puntos. Lo verifiqué numéricamente, corregí lo que estaba mal y reformulé el escenario como usted propuso. Le muestro primero las respuestas y después el escenario nuevo."

Actitud: no defender la ley anterior. Reconocer el error rápido y con datos es lo que distingue a un investigador serio; pasar más de 6 minutos en la parte A hace parecer que uno se está justificando.

## 2. Portada, contenido y problema simple (diapositivas 1–3, ~3 min)

En la portada, solo saludar y decir el objetivo de la reunión. En el contenido, mencionar que la reunión tiene dos partes (A: respuestas; B: escenario ampliado) y que al final hay una bibliografía del nivel terciario para validar con él.

Diapositiva 3 (problema simple): usar la versión de 30 segundos de la sección 0. Apuntar a las barras: "a la izquierda, hoy; a la derecha, lo que se busca". **No** detenerse en las ecuaciones aún. Si el profesor asiente, pasar rápido; esta lámina existe para fijar el lenguaje común.

## 3. Parte A: respuestas a las observaciones (diapositivas 4–7, ~6 min)

**A1 (obs. 1–2).** Punto clave: la ley hacía que la suma de potencias de las BESS fuera idénticamente cero, así que el promedio de SOC nunca cambiaba y las baterías solo se pasaban energía entre ellas. En régimen permanente el IC sigue a la potencia neta, igual que sin coordinación (15,06 A en ambos casos). Frase sugerida: "la ley era un filtro pasa bajos del desbalance: suavizaba la punta del EV, pero no reducía el desbalance sostenido. El −42 % que le reporté venía de ese transitorio."

**A2 (obs. 3).** El Resultado 1 es la respuesta formal: con tensión balanceada, I₀ = I₂ = 0 si y solo si las tres potencias complejas de cabecera son iguales. En el escenario original no había nada que compensar, así que mover energía entre fases solo podía **crear** desbalance. En el ampliado, la red ya viene desbalanceada por los clientes, entonces la transferencia "a través de la red" sirve para **igualar** las fases. Mencionar el piso energético (5,1 A) como límite honesto.

**A3 (obs. 4–5).** Dos ideas: (i) las métricas pasan de "algo que se mide" a "restricciones del optimizador", y en cabecera son normas de funciones lineales de P y Q, por eso el problema sigue siendo convexo; (ii) cada nivel tiene un solo rol, según la tabla. Frase sugerida: "el consenso ya no decide el balance entre fases; solo ejecuta dentro de cada fase lo que decidió el terciario".

**A4 (obs. 6).** Reconocer directamente: "la afirmación de que la literatura solo trataba el desbalance desde el lado AC era incorrecta". Mostrar la tabla por líneas de trabajo y terminar con la brecha **candidata** (decir "candidata": falta la revisión sistemática).

## 4. Escenario, arquitectura y nomenclatura (diapositivas 8–10, ~4 min)

**B1.** Recorrer el dibujo de arriba abajo: subestación con medidor M → terciario de cabecera → alimentador 3φ-4W con clientes monofásicos → Micro-redes DC por fase (2 en a, 1 en b, 3 en c), unidas por grafos de comunicación dentro de cada fase. Remarcar que **no hay barra DC común entre fases**: cada DC-MR tiene su propia referencia; por eso la energía entre fases solo puede pasar por la red AC.

**B2.** Separación de escalas: minutos ≫ segundos ≫ milisegundos. Esto justifica diseñar cada nivel por separado (supuesto de separación temporal).

**B3.** No leer la tabla. Decir: "dejo la nomenclatura para que la revise; los signos son: P_IC > 0 de DC a AC, P_B > 0 descarga". Esos dos signos son los que más confunden.

## 5. Qué hace P y qué hace Q (diapositivas 11–12, ~5 min): el aporte conceptual

Esta es la parte técnicamente más fuerte de la reunión. Conviene ir lento y, si hay pizarra, dibujar el paralelogramo a mano.

**B4.** Explicar B y C como "medidores de qué tan distintas son las P y las Q de las tres fases". Si las tres P son iguales, B = 0 porque 1 + a + a² = 0. Remarcar la linealidad: I₀ = B − jC y |I₂| = |B + jC|.

**B5 (Resultado 2).** Secuencia sugerida:

1. Mostrar los dos vectores B (de P) y jC (de Q).
2. Las diagonales del paralelogramo son I₀ e I₂.
3. Ley del paralelogramo: |I₀|² + |I₂|² = 2|B|² + 2|C|².
4. Conclusión: Q solo mueve jC; **no puede achicar B**. Con Q se puede anular I₀, pero I₂ se duplica (ejemplo 7,2 → 0 A y 7,2 → 14,4 A).
5. Achicar B requiere que las P se parezcan, y eso cuesta energía de batería.

Frase de cierre sugerida: "Q es gratis en energía pero no achica el desbalance activo; P sí lo achica pero gasta batería. Por eso el terciario tiene que decidir P y Q juntas, con la energía por fase como restricción."

## 6. Nivel terciario y secundario (diapositivas 13–15, ~6 min)

**B6 (formulación).** Leer el objetivo en voz alta en palabras: "costo de la energía comprada + castigo por recortar FV + castigo por desbalance". Luego las restricciones por grupo: balance DC, dinámica de SOC con cierre diario, límites de batería y de inversor, límites de cabecera. Remarcar dos cosas: es **convexo** (óptimo global) y usa **agregados por fase** (no crece con el número de Micro-redes).

**B7 (cómo leer el terciario).** Explicar el horizonte deslizante con el dibujo: se planifica el día, se aplica solo el primer cuarto de hora, se mide y se vuelve a planificar. Luego el precio sombra: el multiplicador de la ecuación de SOC dice cuánto vale 1 kWh extra en la batería de esa fase a esa hora. Presentarlo como **idea en evaluación** (señal de precio hacia el secundario), no como resultado.

**B8 (secundario).** La conexión con la tesis doctoral del profesor es explícita: es su formulación de costo incremental del cap. 4, pero con **un λ por fase**. Explicar b_k: con SOC bajo, descargar es "caro", así que la Micro-red con menos energía descarga menos (o carga). El algoritmo es el de Yang–Tan–Xu: el estimador y_k conserva la suma y el líder es el único que conoce la consigna y la medición de cabecera.

Cuidado: si el profesor pregunta por la convergencia con saturaciones, responder que el prototipo ya incluye saturación (la Micro-red 2 queda en 5,0 kW) y que la prueba formal con retardos y pérdida de enlaces está en los próximos pasos.

## 7. Diagrama de bloques completo (diapositiva 16, ~2 min)

Recorrer los tres lazos con colores: lento (naranjo), medio (verde), rápido (teal). La pregunta que esta lámina debe responder sola es "¿qué información va a dónde?". Si el profesor no pregunta nada aquí, es buena señal.

## 8. Prototipo numérico (diapositivas 17–21, ~5 min)

No explicar cada curva. Para cada lámina, una sola idea:

- **B10:** el escenario es realista en forma (residencial, comercial, residencial con FV) y tiene distinto N por fase.
- **B11:** I_n RMS baja 63 % con costo comparable; el P óptimo es el mismo con y sin Q (confirma el Resultado 2).
- **B12:** el terciario hace explícitos los compromisos: imponer I_n,max baja I_n pero sube I₂, justo lo que predice el paralelogramo.
- **B13:** todas las fases cierran el día en 50 % de SOC; Q compensa el reactivo sin costo energético.
- **B14:** el consenso llega al mismo óptimo que el cálculo centralizado (λ_c = 0,413).

Mencionar la corrección del caso local (cerraba el día con −26,3 kWh): muestra rigor.

## 9. Aporte, preguntas y próximos pasos (diapositivas 22–23, ~3 min + conversación)

Presentar el aporte como **candidato**. Luego leer las cinco preguntas y **pedir respuesta explícita** a cada una; anotar lo que diga. Las más importantes para avanzar son la 1 (¿solo cabecera o tensiones a lo largo del alimentador?) y la 4 (validación en PLECS), porque cambian el plan de trabajo.

Cierre sugerido: "Con sus respuestas a estas preguntas puedo cerrar el planteamiento formal y empezar la revisión sistemática. ¿Le parece que la próxima reunión le traiga la revisión y el modelo del alimentador?"

## 10. Preguntas difíciles que podría hacer el profesor (con respuesta preparada)

| Pregunta probable | Respuesta corta |
|---|---|
| ¿Por qué el terciario es centralizado si su línea es control distribuido? | Porque decide sobre **agregados por fase** con pronósticos y medición de cabecera, a escala de minutos; el tamaño no crece con N y la comunicación es solo cabecera ↔ líder de fase. Lo distribuido se justifica donde hay muchos agentes y escala de segundos: el secundario. |
| ¿Por qué suponer cabecera rígida y balanceada? | Es el supuesto mínimo para que I₀ e I₂ sean lineales en P y Q (Resultado 1). El siguiente paso es el flujo 3φ-4W linealizado con impedancias de fase y neutro ([T18], [T19]). |
| ¿Y las pérdidas y caídas de tensión? | No están en el modelo de cabecera. Entran con el modelo de alimentador; el objetivo puede pasar a VUF por nodo (ver [T12], [T13]). |
| ¿Por qué SOCP y no MILP como Parisio o Palma-Behnke? | Porque no hay decisiones binarias (no hay diésel ni encendido/apagado). Sin binarios el problema es convexo y da óptimo global y multiplicadores duales con significado de precio. |
| ¿Por qué SOC final = SOC inicial? | Para que la comparación de costos sea justa (no "gastar" la batería para bajar el costo del día) y evitar deriva día a día. En MPC deslizante se reemplaza por un costo terminal o una referencia de SOC. |
| ¿Cómo maneja el error de pronóstico? | Dos capas: el MPC replanifica cada 15 min con la medición, y el líder de cada fase corrige en segundos con ΔP_corr medido en cabecera. Falta cuantificarlo (próximos pasos). |
| ¿El piso de 5,1 A no invalida la propuesta? | No: separa lo que es control (lo que sobra sobre el piso, y ahí se baja 63 %) de lo que es diseño (ubicación y tamaño de FV/BESS por fase). Es un resultado útil para planificación. |
| Si [7]–[13] ya balancean fases con baterías, ¿dónde está lo nuevo? | En la combinación: varias DC-MR por fase como actuadores, P y Q por fase con restricciones energéticas por fase, terciario en cabecera + secundario distribuido por fase. Por eso falta la revisión sistemática para confirmarlo. |
| ¿Con Q solamente no basta? | No (Resultado 2): Q no puede achicar B; solo traslada entre I₀ e I₂ o cancela el reactivo de los clientes. |

## 11. Errores a evitar al exponer

- Leer las diapositivas. Cada lámina tiene una idea principal; decir esa idea y dejar que él pregunte el detalle.
- Decir "la literatura no lo ha hecho". Decir "no encontré todavía; la revisión sistemática lo confirmará".
- Usar "coordinador" y "consenso" como sinónimos. Ahora son niveles distintos.
- Confundir signos: P_IC > 0 es DC→AC; P_B > 0 es descarga; P_h > 0 es importación.
- Prometer validación experimental. Por ahora, la validación comprometida es en PLECS.

## 12. Chequeo de comprensión propio (para repasar antes de entrar)

1. ¿Por qué ΣP_B ≡ 0 con la ley anterior? (Porque Σ E_i(SOC_w − SOC_i) = 0 por definición del promedio ponderado.)
2. ¿Qué tres potencias complejas tienen que ser iguales para I₀ = I₂ = 0? (Las de cabecera S_h,a, S_h,b, S_h,c.)
3. Si C = 0, ¿cuánto valen |I₀| e |I₂|? (Ambos |B|.)
4. ¿Qué restricción del terciario impide "regalar" energía de la batería para bajar el costo del día? (SOC_H = SOC_0.)
5. ¿Qué agente conoce P*_φ en el secundario? (Solo el líder de la fase.)
6. ¿Qué significa que λ_c = 0,413 sea igual en las tres Micro-redes de la fase c? (Que se alcanzó la condición KKT: igual costo incremental para todas las no saturadas.)

---

## Anexo: bibliografía del nivel terciario, guía de lectura y cómo aplicarla a la tesis

La bibliografía está ordenada por **orden de lectura sugerido**. Para cada trabajo se indica qué extraer y dónde entra en la tesis tal como está planteada (terciario centralizado en cabecera, SOCP/MPC económico, agregados por fase, restricciones de I₀ e I₂).

### Bloque 1: qué le toca al terciario (semana 1)

| Ref. | Trabajo | Qué extraer | Dónde entra en la tesis |
|---|---|---|---|
| [T1] | Bidram & Davoudi, "Hierarchical structure of microgrids control system", *IEEE Trans. Smart Grid* 3(4), 1963–1976, 2012. | Definición de roles primario/secundario/terciario y escalas de tiempo. | Justifica la separación de la diapositiva B2 y el capítulo de arquitectura. |
| [T2] | Olivares et al., "Trends in microgrid control", *IEEE Trans. Smart Grid* 5(4), 1905–1919, 2014. [DOI](https://doi.org/10.1109/TSG.2013.2295514) | Sección de EMS: centralizado vs. descentralizado; funciones del terciario. | Argumento para un terciario **centralizado** (respuesta a la pregunta difícil 1). |

### Bloque 2: EMS con horizonte deslizante y MPC económico (semanas 1–2)

| Ref. | Trabajo | Qué extraer | Dónde entra en la tesis |
|---|---|---|---|
| [T3] | Palma-Behnke, Benavides, Lanas, Severino, Reyes, Llanos, Sáez, "A microgrid energy management system based on the rolling horizon strategy", *IEEE Trans. Smart Grid* 4(2), 996–1006, 2013. [DOI](https://doi.org/10.1109/TSG.2012.2231440) | Estructura completa de un EMS real (Huatacondo, Chile): pronósticos → optimización → consignas, con horizonte deslizante. | Plantilla para el capítulo del terciario; grupo de la U. de Chile, cercano al del profesor. |
| [T4] | Parisio, Rikos, Glielmo, "A model predictive control approach to microgrid operation optimization", *IEEE Trans. Control Syst. Technol.* 22(5), 1813–1827, 2014. [Enlace](https://www.academia.edu/80581609/A_Model_Predictive_Control_Approach_to_Microgrid_Operation_Optimization) | MPC con horizonte de 24 h y paso de 15 min, modelo de batería y comparación con/sin MPC. | Mismos Δt y horizonte que el prototipo; comparar cómo modelan la batería y el costo terminal. |
| [T5] | Olivares, Cañizares, Kazerani, "A centralized energy management system for isolated microgrids", *IEEE Trans. Smart Grid* 5(4), 1864–1875, 2014. | EMS centralizado con MPC para micro-red aislada; descomposición del problema. | Kazerani fue profesor guía (cotutela con Waterloo) de la tesis doctoral del profesor Espina: útil para hablar su mismo lenguaje. |
| [T6] | Hu, Shan, Guerrero, Ioinovici, Chan, Rodriguez, "Model predictive control of microgrids – An overview", *Renew. Sustain. Energy Rev.* 136, 110422, 2021. [DOI](https://doi.org/10.1016/j.rser.2020.110422) | Mapa de MPC por nivel (convertidor, secundario, EMS). | Para ubicar el terciario propuesto en la clasificación del estado del arte. |
| [T7] | Hu et al., "Economic model predictive control for microgrid optimization: A review", *IEEE Trans. Smart Grid* 15(1), 472–484, 2024. [DOI](https://doi.org/10.1109/TSG.2023.3266253) | Formulaciones de MPC **económico** (costo de operación como objetivo, no seguimiento de referencia). | El terciario de la tesis es un MPC económico; usar su terminología. |
| [T8] | Ellis, Durand, Christofides, "A tutorial review of economic model predictive control methods", *J. Process Control* 24(8), 1156–1178, 2014. | Estabilidad y costo terminal en MPC económico. | Responde "¿qué pasa con SOC_H = SOC_0 cuando el horizonte se desliza?" |

### Bloque 3: terciario que incluye el desbalance trifásico (semanas 2–3)

| Ref. | Trabajo | Qué extraer | Dónde entra en la tesis |
|---|---|---|---|
| [14] | Meng, Tang, Savaghebi, Vasquez, Guerrero, "Tertiary control of voltage unbalance compensation for optimal power quality in islanded microgrids", *IEEE Trans. Energy Convers.* 29(4), 802–815, 2014. [PDF](https://vbn.aau.dk/ws/files/205472678/Tertiary_Control_of_Voltage_Unbalance_Compensation_for_Optimal_Power_Quality_in_Islanded_Microgrids_TEC_V20141014.pdf) | Terciario que minimiza VUF ponderado por barra y le entrega al secundario ganancias de compensación. | Antecedente directo de "VUF como objetivo/restricción del terciario" (obs. 4). Diferencia: micro-red aislada y AC. |
| [T10] | Vergara, Rey, Shaker, Guerrero, Jørgensen, da Silva, "Distributed strategy for optimal dispatch of unbalanced three-phase islanded microgrids", *IEEE Trans. Smart Grid* 10, 2019. [Ficha](https://portaldelaciencia.uva.es/documentos/6796b4a4c8fe9e422476b1ad) | Despacho óptimo en red trifásica desbalanceada con descomposición primal-dual + consenso. | Cómo pasar del óptimo centralizado a uno distribuido conservando el desbalance: puente terciario ↔ secundario. |
| [T11] | Vergara, López, Rider, Shaker, da Silva, Jørgensen, "A stochastic programming model for the optimal operation of unbalanced three-phase islanded microgrids", *Int. J. Electr. Power Energy Syst.* 115, 105446, 2020. [Ficha](https://research.tudelft.nl/en/publications/a-stochastic-programming-model-for-the-optimal-operation-of-unbal/) | Operación óptima con BESS en red desbalanceada, escenarios de incertidumbre y linealizaciones. | Si el profesor responde "terciario con incertidumbre" (pregunta 3), esta es la referencia de partida. |
| [T12] | Fu et al., "Three-phase four-wire OPF-based collaborative control of PV inverter and ESS for low-voltage distribution networks with high proportion PVs", *Front. Energy Res.* 8, 615870, 2021. [DOI](https://doi.org/10.3389/fenrg.2020.615870) | OPF **3φ-4W** con VUF ≤ 2 % como restricción convexa, BESS con SOC entre 20 y 80 % y **cierre diario de SOC**. | Es lo más parecido a la formulación del terciario de la tesis: comparar restricciones y convexificación del VUF. |
| [T13] | Held et al., "An optimal power flow algorithm for the simulation of energy storage systems in unbalanced three-phase distribution grids", *Energies* 14(6), 1623, 2021. [DOI](https://doi.org/10.3390/en14061623) | OPF dinámico con **neutro explícito** y camino a tierra, restricción de desbalance y BESS. | Modelo del alimentador (próximo paso): cómo agregar impedancias de fase y neutro. |
| [T14] | Giraldo, Castrillon, Castro, Milano, "Optimal energy management of unbalanced three-phase grid-connected microgrids", IEEE PowerTech, 2019. [DOI](https://doi.org/10.1109/PTC.2019.8810498) | Muestra cuánto cambia el resultado del EMS al modelar o no el desbalance. | Argumento para no usar modelos monofásicos equivalentes en el terciario. |
| [T15] | Ma, Fang, Kong, "Review of distribution network phase unbalance: scale, causes, consequences, solutions, and future research direction", *CSEE J. Power Energy Syst.* 6(3), 2020. [Ficha](https://researchportal.bath.ac.uk/en/publications/review-of-distribution-network-phase-unbalance-scale-causes-conse/) | Magnitud real del desbalance en BT, consecuencias y soluciones. | Introducción y motivación de la tesis (el "por qué importa"). |

### Bloque 4: matemática del terciario (en paralelo, como consulta)

| Ref. | Trabajo | Qué extraer | Dónde entra en la tesis |
|---|---|---|---|
| [T21] | Boyd & Vandenberghe, *Convex Optimization*, Cambridge Univ. Press, 2004. [Libro libre](https://web.stanford.edu/~boyd/cvxbook/) | Cap. 4 (SOCP) y cap. 5 (dualidad y KKT). | Para demostrar que el terciario es SOCP y para interpretar los multiplicadores como precios. |
| [T16] | Palomar & Chiang, "A tutorial on decomposition methods for network utility maximization", *IEEE J. Sel. Areas Commun.* 24(8), 1439–1451, 2006. [PDF](https://www.princeton.edu/~chiangm/tutorial.pdf) | Descomposición primal y dual; coordinación por precios. | Base formal de la idea "terciario entrega precio, secundario reparte" (diapositiva B7). |
| [T17] | Dall'Anese, Zhu, Giannakis, "Distributed optimal power flow for smart microgrids", *IEEE Trans. Smart Grid* 4(3), 1464–1475, 2013. [arXiv](https://arxiv.org/abs/1211.5856) | OPF de redes **multifásicas desbalanceadas** con relajación SDP y solución distribuida. | Si se pasa de cabecera a alimentador completo y se quiere mantener la convexidad. |
| [T18] | Gan & Low, "Convex relaxations and linear approximation for optimal power flow in multiphase radial networks", PSCC, 2014. [arXiv](https://arxiv.org/abs/1406.3054) | Aproximación lineal multifásica (tipo LinDistFlow trifásico). | Candidato directo para el "flujo 3φ-4W linealizado" de los próximos pasos. |
| [T19] | Bernstein & Dall'Anese, "Linear power-flow models in multiphase distribution networks", IEEE PES ISGT Europe, 2017. [Ficha](https://research-hub.nrel.gov/en/publications/linear-power-flow-models-in-multiphase-distribution-networks-prep/) | Modelos lineales multifásicos que incluyen conexiones en estrella y delta. | Alternativa a [T18]; elegir uno de los dos con el profesor. |
| [T20] | Molzahn & Hiskens, "A survey of relaxations and approximations of the power flow equations", *Found. Trends Electr. Energy Syst.* 4(1–2), 1–221, 2019. [Ficha](https://nowpublishers.com/article/Details/EES-012) | Catálogo de relajaciones y aproximaciones con sus supuestos. | Consulta para justificar la elección de modelo. |

### Bloque 5: puente terciario–secundario en el grupo del profesor (semana 3)

| Ref. | Trabajo | Qué extraer | Dónde entra en la tesis |
|---|---|---|---|
| [2] | Espina, tesis doctoral, 2021, **cap. 4**. | Minimización de costos por consenso, condiciones KKT y costo incremental común. | El secundario de la tesis es esta formulación con un λ por fase: citarla así. |
| [6] | Navas-Fonseca et al., "Distributed predictive secondary control with soft constraints for optimal dispatch in hybrid AC/DC microgrids", *IEEE Trans. Smart Grid* 14(6), 4204–4218, 2023. | DMPC con restricciones blandas para despacho óptimo con IC. | Alternativa predictiva al consenso de primer orden; el profesor es coautor. |
| [T9] | Martínez Gómez, "Finite-time cooperative control strategies for the economic operation of hybrid AC/DC microgrids", tesis doctoral, U. de Chile / U. of Nottingham, 2023. [Repositorio](https://repositorio.uchile.cl/handle/2250/199532) | Despacho económico distribuido con clústeres de IC, diseñado para convivir con secundario y terciario. | Cómo otra tesis chilena articuló el despacho económico con los niveles inferiores. |

**Ruta mínima si hay poco tiempo:** [T3] → [T12] → [14] → [T16] → cap. 4 de [2]. Con esas cinco lecturas se puede defender la formulación del terciario, su relación con el desbalance y su conexión con el secundario.

**Cómo leer cada paper (hábito recomendado):** primero el resumen, las figuras y las conclusiones; después solo la sección de formulación. Anotar en una ficha: (1) variables de decisión, (2) objetivo, (3) restricciones, (4) supuestos de red, (5) qué haría distinto en la tesis. La fila (5) es la que después se convierte en el estado del arte del documento.
