# Cronología de la tesis (jul–nov 2026)

Cómo evolucionó el tema, en orden. Cada entrada indica de dónde sale (conversación o documento).

| Fecha | Hito | Fuente |
|---|---|---|
| Jul 2026 | Documento de orientación: control por fase de una Micro-red híbrida AC/DC con 3 IC monofásicos y 3 Micro-redes DC independientes, sin barra DC común. | `referencias/documento_tesis_microredes_felipe.pdf`, conv. 01 |
| 27-jul | Descripción del tema, bibliografía R1–R19 y estrategia PLECS en 4 pasos. | conv. 01 |
| 06-ago | Bibliografía anclada en las tesis de Espina (magíster 2017, doctorado 2021) y explicación de conceptos base. | conv. 02 |
| 07-oct | Modelo energético `sim_soc.py` y escenario de 4 días `final.py`. Ley de coordinación por SOC: P*_IC,i = P̄_net + (E_i/τ)(SOC̄_w − SOC_i). | `documentos/simulacion/historico_ley_soc/` |
| 19-oct | Diagnóstico (CB1–CB11), formulación y piso energético de 6,6 A. Correo a Espina con la idea. | conv. 04, `presentacion_tesis_espina.tex` |
| **20-oct** | **Espina responde con 6 observaciones.** La ley no sirve (ΣP_B ≡ 0; en régimen permanente P_IC → P_net; solo filtra transitorios). Propone el **escenario ampliado**: alimentador BT ya desbalanceado por clientes, varias Micro-redes por fase (N_a, N_b, N_c), gestión desde la cabecera. | conv. 06 |
| 22-oct | Prototipo cvxpy del escenario ampliado: terciario SOCP + secundario por consenso con λ por fase. **Resultado 1:** I₀ = I₂ = 0 ⇔ S_h,a = S_h,b = S_h,c. **Resultado 2:** |I₀|²+|I₂|² = 2|B|²+2|C|², así que Q no reduce el desbalance activo. | `escenario.py`, `secundario.py`, `observaciones.py` |
| 26-oct | Reunión: respuesta a las observaciones y propuesta de tema completa (con respaldo R1–R8). Desde esta fecha la reunión semanal es los lunes a las 17:00 en el lab E2Tech. | `reunion_tesis_26oct_usach.tex`, `propuesta_tesis_usach.tex`, conv. 05 |
| 02-nov | Segunda parte de la propuesta y simulación en tiempo real (CHIL, PLECS RT Box). **Correo de Espina:** confirmar 9 puntos y opinar sobre 2 ideas (rango de SoC por MR y lazo rápido). El secundario pasa a ser **uno por Micro-red** y los DER pasan a **grid-supporting**. | `pauta-2da-parte-y-tiempo-real.md`, conv. 08 |
| 05-nov | Respuesta al correo, niveles de control como conjuntos, diagramas de bloques al estilo Rocabert y caso simple de demanda prolongada. | `respuesta-correo-espina-5nov.md`, `niveles_control_conjuntos.tex`, `control_bloques_9nov.tex`, `pauta-matematica-caso-simple.md` |
| **09-nov** | **Reunión.** Espina visa en gran medida. **IC grid-following** en AC. Próximo paso: simular una Micro-red DC (primario + secundario) y luego su conexión a la red. Pendiente: indicadores para el terciario. | `laminas_reunion_9nov_v6.tex`, `pauta_reunion_9nov_v4.tex`, memoria |
| **10-nov** | **Correo de Espina: reformular la arquitectura.** El lazo rápido actúa solo sobre los IC. El terciario se encarga de la energía y la reserva; el lazo rápido, del balance. Cada MR informa una envolvente (P y W mín/máx). Basta un pronóstico simple. El lazo rápido es por fase e iguala las potencias. Revisar Q en BT. | `lecturas-terciario-10nov.md`, memoria |
| 11-nov | Modelo PLECS de la Micro-red DC (FV, BESS, EV, carga, IC) con primario droop y secundario, más su referencia en Python. | `MicroRed_DC_Validacion.plecs`, `referencia_microred_dc.py`, conv. 07 |
| 12-nov | Láminas para el 16-nov: niveles actualizados, terciario LP con envolvente y reserva, regla del lazo rápido y respaldo con la envolvente. Corrección v3 de la regla del lazo rápido. | `laminas_reunion_16nov.tex`, conv. 08 |
| 13–16-nov | PLECS reestructurado: FV, BESS, EV y carga como subsistemas dentro de "MR a1: PV - BESS - EV - carga" (igual que el esquema). Corrección del error "cannot determine start point of connection segment" (quiebres a ≥ 45 px de los bloques). Guía de simulación actualizada. | conv. 07, `simulacion/guia_simulacion_plecs.md` |
| 16-nov (mañana) | **"El problema del terciario":** el desbalance previsible se cubría con reserva de potencia de 15 min y el lazo rápido gastaba SoC no planificado. **Corrección:** lo previsible es energía comprometida (ŷ_k, restricción (a)); el error del pronóstico es reserva r_k (restricción (d), zσ_φ + m). Láminas v2 (6 láminas tras quitar índice, decisiones y respaldos R1–R2) y guía con lecturas (Warrington 2013, Sun 2016). | `laminas_reunion_16nov_v2.tex`, `pautas/guia_reunion_16nov_problema_terciario.md`, conv. 07 |
| **16-nov 17:00** | **Reunión.** Se valida la Micro-red DC con primario y secundario. Pide: (1) IC conectado a una **fuente de tensión de 50 Hz** y simulación sin fallas; (2) mostrar flujos de potencia DC y AC del IC; (3) trabajar el **álgebra del margen de error** del terciario y dejar una formulación acabada y más detallada. | `correos/acta-reunion-16nov.md` |
| 17-nov 14:50 | Felipe envía el acta al profesor (con imagen de la lámina de niveles). Sin respuesta registrada al 17-nov 18:36. | `correos/acta-reunion-16nov.md` |
| 19-nov | **Formulación del margen de error (propuesta, acuerdo A4).** El lazo rápido se escribe como política afín de reserva diagonal (Warrington 2013) con factores de participación α_k (propuesta α_k ∝ E_k). Margen de potencia por cuantil del error del pronóstico (+ m); margen de energía creciente Z_φ(t) con el error acumulado AR(1) (τ = Δt); LP completo con compra en P̃, Σρ_φ = 0 y condición final; PI limitado a b_φ ± R^ε_φ con error e_φ − ρ_φ. Láminas, estudio paso a paso y guía. El modelo PLECS aún no tiene lado AC (A2/A3 pendientes). | `presentaciones/laminas_reunion_23nov.tex`, `pautas/estudio_margen_error_terciario_lazo_rapido.md`, `pautas/guia_reunion_23nov.md` |
| **23-nov (prob.)** | Próxima reunión (no confirmada): IC con red de 50 Hz, flujos DC/AC y terciario formalizado. | — |

## Decisiones vigentes (al 17-nov-2026)
- **Red:** alimentador BT 3φ-4W, ya desbalanceado por clientes monofásicos sin gestión.
- **Micro-redes:** N_a, N_b y N_c Micro-redes DC por fase, cada una con un IC monofásico. Sin barra DC común: solo intercambian energía a través del alimentador.
- **DER** (FV, BESS, EV): grid-supporting en el lado DC (droop V_dc–P). El **EV entra en el núcleo** de la formulación.
- **IC:** grid-following en AC; sigue P_ref = P*_k + u_φ·r_k, con Q_ref = 0.
- **Secundario:** uno por Micro-red. Restaura V_dc, reparte entre sus DER, cuida los límites de BESS y EV y calcula su envolvente. No ve la cabecera.
- **Terciario:** central, cada 15 min, H = 12 h. **Solo energía en el objetivo:** minimiza el costo de compra. Recibe la envolvente de cada MR, el desbalance previsto por fase D̂_φ y su error σ_φ. Asigna plan P*_k, uso previsto del margen ŷ_k (lo previsible del desbalance, como **energía** dentro de la banda de SoC) y margen para el error r↑_k, r↓_k (como **potencia**, zσ_φ + m por fase). Es un LP. Restricciones (a)–(d) en `CLAUDE.md` §2. *El profesor pidió detallar su álgebra (acta 16-nov).*
- **Lazo rápido:** uno por fase, cada ~1 s.
  - Mide P_h,φ en la cabecera; el error es e_φ = P_h,φ − P̄_h.
  - PI con salida en kW y anti-windup, saturado a [−R↓_φ, R↑_φ].
  - Normaliza u_φ = ΔP_φ/R_φ y reparte ΔP_k = u_φ·r_k.
  - No habla con secundarios ni con DER.
- **Q:** no se usa (R > X en BT, y por el Resultado 2 no reduce el desbalance activo). Queda como extensión.
- **Rango de SoC:** se cuida en toda la trayectoria, no solo al final del intervalo.
- **Validación:** primero PLECS offline con modelo promedio; después simulación en tiempo real (CHIL; plataforma por definir).
- **Simulación de la Micro-red DC:** validada por el profesor (primario + secundario, 16-nov). **Siguiente:** el IC deja de ser solo una fuente de potencia en el bus DC y se conecta a una fuente de tensión de 50 Hz (acta 16-nov).

## Obsoleto (no usar)
- Ley de coordinación por SOC con τ (filtro pasa bajos; no corrige el desbalance sostenido).
- Secundario por fase con consenso λ_φ como mecanismo de balance entre fases.
- IC modelado solo desde el lado DC, sin red AC (válido hasta el 16-nov; reemplazado por el acta).
- Desbalance previsible cubierto solo con reserva de potencia de 15 min (láminas v1 del 16-nov).
- IC grid-supporting en AC; "Q primero"; desbalance |B|²+|C|² en el objetivo del terciario; consignas agregadas por fase; cierre diario fijo de SOC con H = 24 h.
