# Pauta de exposición: propuesta de tema de tesis

**Tesis:** Gestión jerárquica de un alimentador BT 3φ-4W con Micro-redes DC por fase  
**Reunión con:** Prof. Dr. Enrique Espina González (profesor guía), lunes 26 de octubre de 2026  
**Duración estimada:** 45–50 min (≈ 22 min de exposición + 25 min de conversación)  
**Material asociado:** `propuesta_tesis_usach.pdf`: 22 láminas principales + mapa de respaldo + 8 láminas de respaldo (R1–R8) enlazadas con botones naranjos  
**Objetivo de la reunión:** presentar el tema como una **propuesta nueva y completa** (problema, nomenclatura, ecuaciones, planteamiento formal, arquitectura, plan) y salir con el foco, el alcance y las decisiones de modelado acordadas.

---

## 0. El problema que soluciona la tesis, en palabras sencillas

Tenerlo **memorizado**. Es la respuesta a "¿qué resuelves?" en cualquier momento de la reunión.

**En 30 segundos:**

> "En baja tensión cada casa se conecta a una sola fase. Como cada fase tiene clientes distintos, durante el día una fase va más cargada que las otras. La subestación ve eso como corriente por el neutro y secuencia negativa: más pérdidas, transformador desaprovechado y tensiones desiguales. En cada fase ya hay Micro-redes DC con paneles, baterías e inversor monofásico, pero cada una mira solo su casa. La tesis propone coordinarlas para que, vistas desde la subestación, las tres fases tiren parejo y la energía se compre barata, sin vaciar ninguna batería ni pasarse de los límites de los equipos."

**Con analogía (si pide intuición):**

> "Tres personas cargan una mesa, una en cada pata. Si una carga más, la mesa se inclina: eso es el desbalance, y el neutro sostiene la inclinación. Las Micro-redes son ayudantes con mochila (la batería): pueden ayudar a la pata más cargada en la hora pesada, pero la mochila se vacía. Hay que decidir cuándo y a quién ayudar durante el día —eso es el terciario— y cómo repartir la ayuda entre los ayudantes de una misma pata —eso es el secundario—."

**En una frase técnica:**

> "Arquitectura jerárquica —terciario centralizado en cabecera y secundario distribuido por fase— que usa varias Micro-redes DC monofásicas por fase, con P y Q por fase, para gestionar el intercambio de energía y las secuencias cero y negativa en la cabecera de un alimentador BT 3φ-4W, sujeta a la energía disponible en cada fase."

**Qué NO resuelve (decirlo antes de que lo pregunte):**

- El desbalance activo **medio del día** de cada fase: eso lo fija la energía disponible (es diseño, no control).
- Las tensiones **a lo largo** del alimentador: por ahora el modelo es de cabecera.
- Un control primario nuevo: el primario se toma del estado del arte.

## 1. Idea central y actitud

**Mensaje que el profesor debe llevarse:** "hay un problema real en BT, hay recursos que ya existen para atacarlo, y la formulación separa bien qué puede hacer el control y qué no".

**Frase de apertura sugerida:** "Profesor, le traigo el tema planteado de nuevo desde cero, con el escenario que usted sugirió. Primero el problema, después cómo llegué aquí, y luego la formulación. Al final tengo cinco preguntas en las que necesito su opinión."

**Cómo usar las láminas:** son livianas a propósito. Cada lámina tiene **una idea**; la idea se dice y se desarrolla en voz alta o en la pizarra. Las ecuaciones completas y los detalles están en las láminas de respaldo R1–R8: **no se muestran salvo que él pregunte**. Los botones naranjos (R1, R2…) llevan a cada respaldo y el botón "Volver al mapa" regresa. Conviene probar los botones en el PDF antes de la reunión (funcionan en Acrobat, Vista Previa y en el navegador; en modo presentación de algunos visores se pierde el clic).

**Actitud frente a la crítica:** escuchar la pregunta completa, repetirla en una frase ("si entiendo bien, usted pregunta si…"), responder corto y ofrecer el respaldo. Si no se sabe la respuesta: "no lo he verificado; lo anoto y lo traigo resuelto la próxima reunión". Nunca inventar.

## 2. Guion por lámina

Para cada bloque: tiempo, qué decir, qué dibujar o desarrollar en vivo, y qué pregunta hacerle al profesor para que la reunión sea conversación y no monólogo.

### Láminas 1–2: portada y hoja de ruta (~1 min)

Solo el objetivo de la reunión (recuadro naranjo de la lámina 2): validar tema, foco y alcance, y acordar decisiones de modelado.

### Lámina 3: el problema (~2 min)

- **Decir:** "cinco casas en a, tres en b, una en c: cada fase pide distinto y cambia durante el día". Apuntar al fasorial: tres corrientes distintas, su suma es la corriente de neutro.
- **Desarrollar en vivo:** si hay pizarra, dibujar los tres fasores desiguales y sumarlos punta con cola para mostrar I_n. Es un dibujo que él reconoce de inmediato y fija el lenguaje común.
- **No** entrar todavía en secuencias ni en ecuaciones.

### Lámina 4: por qué importa (~2 min)

- Recorrer las cuatro tarjetas en una frase cada una.
- Remarcar la última línea: "las Micro-redes con batería **ya están** en cada fase". Ese es el gancho de la tesis: no se propone instalar un equipo nuevo, sino coordinar lo que existe.
- Mencionar que un compensador de reactivos no basta (botón R2) solo si él lo trae a la mesa.

### Lámina 5: de dónde viene la idea (~2 min)

- **Clave de tono:** presentar esto como **evolución del tema**, no como corrección. Frase sugerida: "el planteamiento inicial tenía una Micro-red por fase y un consenso para igualar potencias. Al analizarlo encontré tres cosas, y por eso el tema se reformuló".
- Leer los tres puntos del recuadro rojo en voz alta, rápido.
- Cerrar con el recuadro de abajo: **qué se conserva** (Micro-redes DC con IC monofásico, consenso, balance de SOC) y **qué cambia** (objetivo en cabecera, un rol por nivel). Esto muestra continuidad con su línea de investigación.
- Si pide el detalle matemático: R3.

### Lámina 6: escenario propuesto (~2 min)

- Recorrer de arriba abajo: S/E con medidor → gestión de cabecera → alimentador ya desbalanceado → Micro-redes por fase, con distinto número por fase, unidas por grafos dentro de cada fase.
- **Remarcar:** no hay barra DC común entre fases; entre fases la energía solo pasa por la red AC.
- **Pregunta al profesor:** "¿le parece representativo de una red BT real, o agregaría algo más al escenario, por ejemplo EV?"

### Lámina 7: pregunta de investigación y objetivos (~2 min)

- Leer la pregunta completa (es la única lámina donde conviene leer).
- Los cuatro OE se dicen con los verbos: **modelar, formular, diseñar, validar**.
- **Pregunta al profesor:** "¿los objetivos tienen el tamaño adecuado para un magíster?" (también se retoma al final).

### Lámina 8: nomenclatura (~1 min)

- No leer la tabla. Decir solo las **convenciones de signo**, que son las que confunden:
  - P_IC > 0: de DC hacia AC (el IC inyecta a la red).
  - P_B > 0: la batería se descarga.
  - P_h > 0: el alimentador importa desde la subestación.
  - X_φ = suma de X_k sobre las Micro-redes de la fase φ (agregado por fase).
- "Dejo la tabla para revisión; la uso igual en todo el documento."

### Lámina 9: modelo, ecuaciones del sistema (~2 min)

- Recorrer el dibujo de izquierda a derecha: lado DC (FV, BESS, carga DC) → IC → fase → cabecera → S/E.
- **Ecuaciones 1–3 (cada Micro-red):** balance de potencia del bus DC, dinámica del SOC, capacidad del inversor.
- **Ecuaciones 4–6 (cabecera):** lo que pide la fase a la S/E es lo de los clientes menos lo que inyectan las Micro-redes; la corriente sale de dividir la potencia conjugada por la tensión conjugada; Fortescue da las secuencias.
- **Frase clave:** "las fases solo se acoplan en (4)–(6), a través de la red; por eso el problema es de cabecera".
- **Desarrollar en vivo:** escribir en la pizarra la ecuación (4) y preguntar "¿qué parte de esto puedo controlar?" → solo la sumatoria de los IC.

### Lámina 10: planteamiento formal del problema (~2 min)

- Es la lámina más importante para la exigencia de "plantear el problema". Leer las tres columnas como una oración: "**dados** los pronósticos, el precio, los parámetros y la medición, **encontrar** las consignas de P y Q de cada IC, **tal que** minimicen costo y desbalance, cumplan las ecuaciones de cada Micro-red y la energía por fase, respeten los límites de neutro y secuencia negativa, y se puedan ejecutar con información local".
- **Recuadro rojo (dificultad):** el desbalance acopla las tres fases (pide decidir en conjunto), pero la información está repartida. Esa tensión es la que justifica la jerarquía. Frase sugerida: "la arquitectura no es una preferencia: sale de la estructura del problema".

### Lámina 11: idea 1, lo que ve la subestación (~1,5 min)

- **Resultado 1:** con tensión balanceada, no hay I_0 ni I_2 si y solo si las tres fases piden la misma potencia compleja.
- "El objetivo físico es simple: que las tres fases pidan lo mismo a la subestación."
- Derivación disponible en R1 si la pide.

### Lámina 12: idea 2, P y Q hacen cosas distintas (~3 min)

Es el aporte conceptual más fuerte. Ir lento.

1. B mide qué tan distintas son las P por fase; C, las Q.
2. Las diagonales del paralelogramo formado por B y jC son I_0 e I_2.
3. Ley del paralelogramo: |I_0|² + |I_2|² = 2|B|² + 2|C|².
4. Q solo mueve jC: **no puede achicar B**. Puede cancelar el reactivo de los clientes o trasladar desbalance entre I_0 e I_2 (si jC = B, se anula I_0 pero I_2 se duplica).
5. P achica B, pero gasta batería.

**Desarrollar en vivo:** dibujar el paralelogramo a mano y mover jC con el dedo para mostrar que una diagonal se achica y la otra crece.

**Frase de cierre:** "Q es gratis en energía pero no achica el desbalance activo; P sí, pero gasta batería. Por eso P y Q se deciden juntas."

### Lámina 13: idea 3, la energía pone un límite (~2 min)

- Izquierda: la batería aplana en el tiempo (carga en el valle, descarga en la punta; áreas iguales si el SOC cierra el día igual).
- Derecha: pero la **media diaria** de cada fase no cambia, porque la integral diaria de la potencia del IC está fijada por la FV y la carga DC de la fase. La diferencia entre medias es un **piso** que ningún control corrige.
- **Mensaje:** separa control (aplanar) de diseño (dónde y cuánta FV/BESS por fase). Es un resultado útil, no una debilidad.

### Lámina 14: arquitectura (~1,5 min)

- Un rol por nivel: el terciario decide **entre** fases; el secundario reparte **dentro** de cada fase; el primario ejecuta.
- Separación de escalas: minutos ≫ segundos ≫ milisegundos.
- Si pregunta "¿por qué centralizado?": R6.

### Lámina 15: formulación del problema del terciario (~2 min)

- Leer el objetivo en palabras: costo de la energía comprada + castigo por recortar FV + castigo por desbalance.
- Restricciones por grupo, enlazadas al modelo: balance DC (1), SOC con cierre diario (2), capacidad (3), límites de cabecera con I_0 e I_2 de (4)–(6).
- **Dos propiedades a remarcar:** es **convexo** (SOCP, óptimo global, sin binarios) y usa **agregados por fase** (no crece con el número de Micro-redes).

### Lámina 16: horizonte deslizante y precio de la energía (~1,5 min)

- Planificar 24 h, aplicar 15 min, medir y replanificar.
- El multiplicador de la ecuación de SOC es el **precio** de 1 kWh en cada fase y hora. Presentarlo como **idea en evaluación** (señal de precio al secundario), no como resultado.

### Lámina 17: secundario (~2 min)

- Conexión explícita con la tesis doctoral del profesor: es su despacho por costo incremental (cap. 4), pero con **un λ por fase**.
- Explicar b_k: con SOC bajo, descargar es caro, así que la Micro-red con menos energía aporta menos. Resultado: balance de SOC dentro de la fase.
- Solo el líder conoce la consigna y la medición de cabecera: corrige en segundos el error de pronóstico.
- Algoritmo completo en R4.

### Lámina 18: diagrama de bloques completo (~1,5 min)

- Recorrer los tres lazos por color: lento (naranjo), medio (verde), rápido (teal). La lámina debe responder sola "¿qué información va a dónde?".

### Lámina 19: aporte e hipótesis (~1,5 min)

- Tres aportes: **formulación**, **análisis** (P / Q / energía) y **control** (un λ por fase).
- Leer la hipótesis. Decir "aporte **candidato**: la revisión sistemática lo confirmará" (botón R5 si pregunta por la literatura).

### Lámina 20: metodología y plan (~1 min)

- Decir que es **tentativo** y que la revisión sistemática y el modelo van primero.
- Casos y métricas de comparación (R8 si pregunta).

### Lámina 21: preguntas para conversar (resto del tiempo)

- Leer cada pregunta y **pedir respuesta explícita**; anotar textual.
- Prioridad: la 1 (cabecera vs. tensiones a lo largo del alimentador) y la 4 (validación), porque cambian el plan.
- Terminar con la pregunta de fondo sobre el tamaño del tema (R7).

**Cierre sugerido:** "Con sus respuestas puedo cerrar el planteamiento y empezar la revisión sistemática. ¿Le parece que en la próxima reunión le traiga la revisión y el modelo del alimentador?"

## 3. Banco de preguntas y contraargumentos

Esta es la parte **vital** de la preparación. Cada entrada tiene: lo que podría decir el profesor, la respuesta corta (≈ 20 s), la lámina de respaldo y qué decir si insiste. Conviene leerlas en voz alta la noche anterior.

### A. Sobre el problema y su relevancia

**A1. "¿El desbalance en BT es realmente un problema importante, o es marginal?"**

- **Respuesta corta:** sí lo es. La corriente de neutro produce pérdidas y calentamiento sin transportar energía útil, la fase más cargada limita la capacidad del transformador y la secuencia negativa afecta a motores. Con FV y EV monofásicos el desbalance crece y cambia durante el día.
- **Respaldo:** lámina 4; referencia de revisión [T15] (Ma et al., 2020) en el anexo.
- **Si insiste:** "Lo voy a cuantificar en la revisión con datos de distribuidoras; si el desbalance resulta pequeño en Chile, el aporte de la parte económica (costo de energía) se mantiene."

**A2. "¿Por qué no simplemente reconectar clientes entre fases?"**

- **Respuesta corta:** la reconexión es discreta, manual y estática; corrige el promedio, pero no la variación diaria (punta residencial en la tarde vs. FV a mediodía). Además, es complementaria: justamente corrige el **piso** que el control no puede corregir (idea 3).
- **Si insiste:** "Es más: la tesis puede entregar un criterio para decidir cuándo conviene reconectar (cuando el piso domina) y cuándo basta coordinar."

**A3. "¿Por qué no un STATCOM o un filtro activo?"**

- **Respuesta corta:** un compensador que solo mueve Q no puede achicar B (Resultado 2): traslada desbalance entre I_0 e I_2. Para achicarlo hay que igualar las P, y eso requiere energía, que está en las baterías de las Micro-redes.
- **Respaldo:** R2.
- **Si insiste:** "Los compensadores con transferencia de potencia activa entre fases sí lo logran, pero son un equipo trifásico nuevo; la propuesta usa recursos monofásicos que ya existen."

### B. Sobre la novedad

**B1. "Pinthurat, Mexis, Raza y otros ya balancean fases con baterías monofásicas. ¿Dónde está lo nuevo?"**

- **Respuesta corta:** en la combinación: varias Micro-redes DC por fase como actuadores, P y Q por fase con restricción de **energía por fase**, terciario de cabecera con límites de I_0 e I_2, y secundario distribuido por fase. Los trabajos revisados cubren partes, no el conjunto.
- **Respaldo:** R5 (tabla por líneas de trabajo).
- **Si insiste:** "Es una brecha **candidata**; la revisión sistemática es la primera tarea del plan precisamente para confirmarla o ajustarla."

**B2. "Esto parece más ingeniería de aplicación que investigación."**

- **Respuesta corta:** hay dos resultados analíticos: la condición de cabecera (Resultado 1) y la descomposición P/Q con el paralelogramo y el piso energético (Resultado 2 e idea 3), que dicen qué puede y qué no puede hacer cualquier control. Más el secundario con un λ por fase.
- **Si insiste:** "Puedo formalizar el piso como una cota inferior demostrable del desbalance alcanzable dada la energía por fase; eso sería un resultado teórico publicable."

**B3. "¿Qué cambia respecto de mi tesis doctoral?"**

- **Respuesta corta:** su trabajo resuelve el secundario en Micro-redes híbridas trifásicas balanceadas con bus DC único. Aquí hay **varias Micro-redes DC por fase sin barra común**, una red desbalanceada y un terciario de cabecera; su despacho por consenso se reutiliza con **un λ por fase**.
- **Si insiste:** "La extensión no es trivial: el reparto dentro de una fase no puede compensar otra fase, por eso el balance entre fases tiene que venir de arriba."

### C. Sobre la arquitectura y el control

**C1. "Mi línea es control distribuido. ¿Por qué el terciario es centralizado?"**

- **Respuesta corta:** el terciario trabaja con **agregados por fase**, a escala de minutos, con información que ya está en un punto (pronósticos y medición de cabecera); su tamaño no crece con el número de Micro-redes. Lo distribuido se justifica donde hay muchos agentes, información repartida y escala de segundos: el secundario.
- **Respaldo:** R6 (tabla por criterio).
- **Si insiste:** "Un terciario distribuido (ADMM o DMPC) es una extensión natural, y el centralizado sirve como referencia de comparación (óptimo global)."

**C2. "Si se cae la comunicación con el terciario, ¿qué pasa?"**

- **Respuesta corta:** cada fase mantiene la última consigna y el secundario sigue repartiendo; si se cae todo, cada Micro-red vuelve a operación local (autoconsumo), que es el caso base de comparación. No hay riesgo de estabilidad: el primario es local.
- **Si insiste:** "Retardos y pérdida de enlaces en el secundario están en las extensiones (R7)."

**C3. "¿Por qué un λ por fase y no uno global?"**

- **Respuesta corta:** porque el reparto dentro de una fase no afecta el desbalance, pero entre fases sí. Un λ global igualaría el costo incremental entre fases y movería energía entre ellas sin mirar la cabecera, que es exactamente lo que hacía el planteamiento anterior. El balance entre fases lo fija el terciario; el λ de cada fase reparte su consigna.

**C4. "¿Por qué SOCP y no un MILP como en los EMS clásicos?"**

- **Respuesta corta:** no hay decisiones binarias (no hay diésel ni encendido/apagado). Sin binarios el problema es convexo: óptimo global, rápido y con multiplicadores con significado de precio.
- **Respaldo:** lámina 15.
- **Si insiste:** "Si se agregan EV con decisiones de conexión discretas, aparecen binarios; eso es extensión."

**C5. "¿Por qué el SOC tiene que cerrar el día igual?"**

- **Respuesta corta:** para que la comparación de costos sea justa (no "gastarse" la batería para abaratar el día) y evitar deriva día a día. En MPC deslizante se reemplaza por un costo terminal o una referencia de SOC.

**C6. "¿Cómo maneja el error de pronóstico?"**

- **Respuesta corta:** en dos capas: el MPC replanifica cada 15 min con la medición, y el líder de cada fase corrige en segundos con la diferencia medida en cabecera.
- **Si insiste:** "Cuantificar el efecto del error y, si es necesario, pasar a MPC robusto o estocástico (Vergara 2020) es la pregunta 3 que quiero acordar con usted."

**C7. "¿Y la estabilidad del lazo completo?"**

- **Respuesta corta:** se apoya en separación de escalas: el terciario cambia consignas cada 15 min, el secundario converge en segundos y el primario en milisegundos. Cada nivel ve al de abajo como estático y al de arriba como constante.
- **Si insiste:** "Una prueba formal de la interacción secundario–primario con modelo promedio es parte de la validación (OE4); es el punto donde más me serviría su experiencia."

### D. Sobre el modelo y los supuestos

**D1. "Suponer la cabecera rígida y balanceada es muy fuerte."**

- **Respuesta corta:** es el supuesto mínimo para que I_0 e I_2 sean lineales en P y Q y el problema sea convexo. Es razonable en la barra BT del transformador para una primera etapa.
- **Si insiste:** "El siguiente paso es un flujo 3φ-4W linealizado con impedancias de fase y neutro (Gan–Low o Bernstein–Dall'Anese), que conserva la convexidad. Es la pregunta 1 de la lámina 21."

**D2. "No considera pérdidas ni caídas de tensión."**

- **Respuesta corta:** correcto, en el modelo de cabecera no están. Entran con el modelo de alimentador, y el objetivo puede pasar a VUF por nodo (Fu 2021, Held 2021).

**D3. "Con varias Micro-redes por fase en distintos puntos del alimentador, su ubicación importa."**

- **Respuesta corta:** en el modelo de cabecera no importa (solo cuenta el agregado por fase); con impedancias sí, y es justamente lo que el modelo de alimentador permitiría estudiar.

**D4. "¿Qué pasa con los armónicos de los inversores monofásicos?"**

- **Respuesta corta:** quedan fuera del alcance; el trabajo es a frecuencia fundamental. El grupo tiene trabajos de reparto de armónicos (Burgos-Mellado 2020) que se podrían incorporar como extensión.

### E. Sobre alcance y validación

**E1. "Es demasiado para un magíster."**

- **Respuesta corta:** por eso el alcance está separado en núcleo y extensiones. El núcleo es modelo de cabecera, terciario, secundario y validación en PLECS con modelo promedio.
- **Respaldo:** R7.
- **Si insiste:** "Si hay que recortar, recorto la validación conmutada y dejo el modelo promedio; el aporte de formulación y análisis se mantiene."

**E2. "¿Cómo va a demostrar que funciona?"**

- **Respuesta corta:** comparando contra operación local, solo P, P+Q y estrategias de la literatura, con métricas de neutro, secuencia negativa, costo, FV recortada y SOC.
- **Respaldo:** R8.

**E3. "¿Habrá validación experimental?"**

- **Respuesta corta:** no lo comprometo hoy. El compromiso es simulación en PLECS; si el laboratorio lo permite, el secundario es el candidato natural para una prueba experimental o HIL.

**E4. "¿Quién es dueño de las Micro-redes y por qué cooperarían?"**

- **Respuesta corta:** es una pregunta regulatoria y de mercado, fuera del alcance técnico. La formulación entrega el precio sombra de la energía por fase, que podría usarse como señal de incentivo de un agregador o de la distribuidora.
- **Si insiste:** "Lo dejo como trabajo futuro explícito en el documento."

### F. Preguntas de criterio (las que miden madurez)

**F1. "¿Cuál es la limitación más fuerte de su propuesta?"**

- **Respuesta honesta:** el modelo de cabecera sin impedancias; y que el beneficio está acotado por la energía disponible por fase (el piso). Ambas están identificadas y tienen camino de solución.

**F2. "Si tuviera que publicar algo en seis meses, ¿qué sería?"**

- **Respuesta:** la descomposición P/Q/energía (Resultados 1–2 y el piso) con el terciario convexo, en una conferencia (por ejemplo, IEEE PES o una conferencia latinoamericana del área).

**F3. "¿Por qué Micro-redes DC y no baterías monofásicas AC directamente?"**

- **Respuesta corta:** el actuador en ambos casos es el IC monofásico, así que la formulación de cabecera aplica igual. Lo específico del caso DC es que detrás de cada IC hay varias fuentes y cargas DC con su propio control (secundario DC interno), y no hay barra común entre fases. Además, es la línea de Micro-redes híbridas del grupo.

## 4. Errores a evitar

- Presentar la lámina 5 como "me equivoqué": es evolución del tema; se dice en un minuto y se sigue.
- Leer las láminas (salvo la pregunta de investigación).
- Decir "la literatura no lo ha hecho": decir "no lo encontré todavía; la revisión lo confirmará".
- Abrir las láminas de respaldo sin que él pregunte.
- Confundir signos: P_IC > 0 es DC→AC; P_B > 0 es descarga; P_h > 0 es importación.
- Comprometer validación experimental.

## 5. Chequeo de comprensión (repasar antes de entrar)

1. ¿Qué tres potencias tienen que ser iguales para que I_0 = I_2 = 0? (Las de cabecera S_h,a, S_h,b, S_h,c.)
2. Si C = 0, ¿cuánto valen |I_0| e |I_2|? (Ambos |B|.)
3. Si con Q hago jC = B, ¿qué pasa? (I_0 = 0 e |I_2| = 2|B|.)
4. ¿Qué ecuación impide que el terciario "regale" energía de la batería? (El cierre diario del SOC.)
5. ¿Por qué el terciario no crece con el número de Micro-redes? (Usa agregados por fase.)
6. ¿Qué significa que todas las Micro-redes de una fase lleguen al mismo λ? (Condición KKT: igual costo incremental entre las no saturadas.)
7. ¿Qué parte del desbalance no corrige ningún control? (La diferencia entre las medias diarias de potencia activa de cada fase.)

---

## Anexo: bibliografía del nivel terciario, guía de lectura y cómo aplicarla a la tesis

*Numeración del anexo: [T#] son referencias de lectura; [2], [4] y [9] coinciden con la lámina "Bibliografía base" de la presentación. En la presentación, [T3] aparece como [8] y [T12] como [10].*

La bibliografía está ordenada por **orden de lectura sugerido**. Para cada trabajo se indica qué extraer y dónde entra en la tesis tal como está planteada (terciario centralizado en cabecera, SOCP/MPC económico, agregados por fase, restricciones de I₀ e I₂).

### Bloque 1: qué le toca al terciario (semana 1)

| Ref. | Trabajo | Qué extraer | Dónde entra en la tesis |
|---|---|---|---|
| [T1] | Bidram & Davoudi, "Hierarchical structure of microgrids control system", *IEEE Trans. Smart Grid* 3(4), 1963–1976, 2012. | Definición de roles primario/secundario/terciario y escalas de tiempo. | Justifica la separación de la lámina 14 y el capítulo de arquitectura. |
| [T2] | Olivares et al., "Trends in microgrid control", *IEEE Trans. Smart Grid* 5(4), 1905–1919, 2014. [DOI](https://doi.org/10.1109/TSG.2013.2295514) | Sección de EMS: centralizado vs. descentralizado; funciones del terciario. | Argumento para un terciario **centralizado** (respuesta a la pregunta C1 de la sección 3). |

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
| [9] | Meng, Tang, Savaghebi, Vasquez, Guerrero, "Tertiary control of voltage unbalance compensation for optimal power quality in islanded microgrids", *IEEE Trans. Energy Convers.* 29(4), 802–815, 2014. [PDF](https://vbn.aau.dk/ws/files/205472678/Tertiary_Control_of_Voltage_Unbalance_Compensation_for_Optimal_Power_Quality_in_Islanded_Microgrids_TEC_V20141014.pdf) | Terciario que minimiza VUF ponderado por barra y le entrega al secundario ganancias de compensación. | Antecedente directo de "VUF como objetivo/restricción del terciario" (obs. 4). Diferencia: micro-red aislada y AC. |
| [T10] | Vergara, Rey, Shaker, Guerrero, Jørgensen, da Silva, "Distributed strategy for optimal dispatch of unbalanced three-phase islanded microgrids", *IEEE Trans. Smart Grid* 10, 2019. [Ficha](https://portaldelaciencia.uva.es/documentos/6796b4a4c8fe9e422476b1ad) | Despacho óptimo en red trifásica desbalanceada con descomposición primal-dual + consenso. | Cómo pasar del óptimo centralizado a uno distribuido conservando el desbalance: puente terciario ↔ secundario. |
| [T11] | Vergara, López, Rider, Shaker, da Silva, Jørgensen, "A stochastic programming model for the optimal operation of unbalanced three-phase islanded microgrids", *Int. J. Electr. Power Energy Syst.* 115, 105446, 2020. [Ficha](https://research.tudelft.nl/en/publications/a-stochastic-programming-model-for-the-optimal-operation-of-unbal/) | Operación óptima con BESS en red desbalanceada, escenarios de incertidumbre y linealizaciones. | Si el profesor responde "terciario con incertidumbre" (pregunta 3 de la lámina 21), esta es la referencia de partida. |
| [T12] | Fu et al., "Three-phase four-wire OPF-based collaborative control of PV inverter and ESS for low-voltage distribution networks with high proportion PVs", *Front. Energy Res.* 8, 615870, 2021. [DOI](https://doi.org/10.3389/fenrg.2020.615870) | OPF **3φ-4W** con VUF ≤ 2 % como restricción convexa, BESS con SOC entre 20 y 80 % y **cierre diario de SOC**. | Es lo más parecido a la formulación del terciario de la tesis: comparar restricciones y convexificación del VUF. |
| [T13] | Held et al., "An optimal power flow algorithm for the simulation of energy storage systems in unbalanced three-phase distribution grids", *Energies* 14(6), 1623, 2021. [DOI](https://doi.org/10.3390/en14061623) | OPF dinámico con **neutro explícito** y camino a tierra, restricción de desbalance y BESS. | Modelo del alimentador (próximo paso): cómo agregar impedancias de fase y neutro. |
| [T14] | Giraldo, Castrillon, Castro, Milano, "Optimal energy management of unbalanced three-phase grid-connected microgrids", IEEE PowerTech, 2019. [DOI](https://doi.org/10.1109/PTC.2019.8810498) | Muestra cuánto cambia el resultado del EMS al modelar o no el desbalance. | Argumento para no usar modelos monofásicos equivalentes en el terciario. |
| [T15] | Ma, Fang, Kong, "Review of distribution network phase unbalance: scale, causes, consequences, solutions, and future research direction", *CSEE J. Power Energy Syst.* 6(3), 2020. [Ficha](https://researchportal.bath.ac.uk/en/publications/review-of-distribution-network-phase-unbalance-scale-causes-conse/) | Magnitud real del desbalance en BT, consecuencias y soluciones. | Introducción y motivación de la tesis (el "por qué importa"). |

### Bloque 4: matemática del terciario (en paralelo, como consulta)

| Ref. | Trabajo | Qué extraer | Dónde entra en la tesis |
|---|---|---|---|
| [T21] | Boyd & Vandenberghe, *Convex Optimization*, Cambridge Univ. Press, 2004. [Libro libre](https://web.stanford.edu/~boyd/cvxbook/) | Cap. 4 (SOCP) y cap. 5 (dualidad y KKT). | Para demostrar que el terciario es SOCP y para interpretar los multiplicadores como precios. |
| [T16] | Palomar & Chiang, "A tutorial on decomposition methods for network utility maximization", *IEEE J. Sel. Areas Commun.* 24(8), 1439–1451, 2006. [PDF](https://www.princeton.edu/~chiangm/tutorial.pdf) | Descomposición primal y dual; coordinación por precios. | Base formal de la idea "terciario entrega precio, secundario reparte" (lámina 16). |
| [T17] | Dall'Anese, Zhu, Giannakis, "Distributed optimal power flow for smart microgrids", *IEEE Trans. Smart Grid* 4(3), 1464–1475, 2013. [arXiv](https://arxiv.org/abs/1211.5856) | OPF de redes **multifásicas desbalanceadas** con relajación SDP y solución distribuida. | Si se pasa de cabecera a alimentador completo y se quiere mantener la convexidad. |
| [T18] | Gan & Low, "Convex relaxations and linear approximation for optimal power flow in multiphase radial networks", PSCC, 2014. [arXiv](https://arxiv.org/abs/1406.3054) | Aproximación lineal multifásica (tipo LinDistFlow trifásico). | Candidato directo para el "flujo 3φ-4W linealizado" de los próximos pasos. |
| [T19] | Bernstein & Dall'Anese, "Linear power-flow models in multiphase distribution networks", IEEE PES ISGT Europe, 2017. [Ficha](https://research-hub.nrel.gov/en/publications/linear-power-flow-models-in-multiphase-distribution-networks-prep/) | Modelos lineales multifásicos que incluyen conexiones en estrella y delta. | Alternativa a [T18]; elegir uno de los dos con el profesor. |
| [T20] | Molzahn & Hiskens, "A survey of relaxations and approximations of the power flow equations", *Found. Trends Electr. Energy Syst.* 4(1–2), 1–221, 2019. [Ficha](https://nowpublishers.com/article/Details/EES-012) | Catálogo de relajaciones y aproximaciones con sus supuestos. | Consulta para justificar la elección de modelo. |

### Bloque 5: puente terciario–secundario en el grupo del profesor (semana 3)

| Ref. | Trabajo | Qué extraer | Dónde entra en la tesis |
|---|---|---|---|
| [2] | Espina, tesis doctoral, 2021, **cap. 4**. | Minimización de costos por consenso, condiciones KKT y costo incremental común. | El secundario de la tesis es esta formulación con un λ por fase: citarla así. |
| [4] | Navas-Fonseca et al., "Distributed predictive secondary control with soft constraints for optimal dispatch in hybrid AC/DC microgrids", *IEEE Trans. Smart Grid* 14(6), 4204–4218, 2023. | DMPC con restricciones blandas para despacho óptimo con IC. | Alternativa predictiva al consenso de primer orden; el profesor es coautor. |
| [T9] | Martínez Gómez, "Finite-time cooperative control strategies for the economic operation of hybrid AC/DC microgrids", tesis doctoral, U. de Chile / U. of Nottingham, 2023. [Repositorio](https://repositorio.uchile.cl/handle/2250/199532) | Despacho económico distribuido con clústeres de IC, diseñado para convivir con secundario y terciario. | Cómo otra tesis chilena articuló el despacho económico con los niveles inferiores. |

**Ruta mínima si hay poco tiempo:** [T3] → [T12] → [9] → [T16] → cap. 4 de [2]. Con esas cinco lecturas se puede defender la formulación del terciario, su relación con el desbalance y su conexión con el secundario.

**Cómo leer cada paper (hábito recomendado):** primero el resumen, las figuras y las conclusiones; después solo la sección de formulación. Anotar en una ficha: (1) variables de decisión, (2) objetivo, (3) restricciones, (4) supuestos de red, (5) qué haría distinto en la tesis. La fila (5) es la que después se convierte en el estado del arte del documento.
