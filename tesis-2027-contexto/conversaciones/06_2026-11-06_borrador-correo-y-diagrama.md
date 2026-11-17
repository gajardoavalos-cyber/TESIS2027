# Borrador de correo y diagrama de tesis

- **Enlace:** https://claude.ai/chat/942f4d69-ce96-4d67-a4a0-7a6d6c5a1fbc
- **Última actualización:** 06-nov-2026 · 71 turnos (la conversación más larga del proyecto)

## Pedido inicial de Felipe (textual)
> "Quiero que me ayudes a elaborar un borrador de correo electrónico que diga relación con explicar la idea del tema de tesis. Para enviar al profesor Enrique Espina. Por otro lado, quiero que me des un esquema que logre representar el problema de forma clara para hacer un dibujo a mano y sumarlo al correo que quiero enviar al profesor Enrique."

## Evolución dentro de esta conversación
1. **Correo del 19-oct al profesor.** Explicaba la idea inicial (coordinación por SOC de IC monofásicos por fase), con esquemas para dibujar a mano, diagramas de bloques y ecuaciones verificadas con `sim_soc.py` y `analisis_reunion.py`.
2. **Respuesta del profesor (20-oct) con 6 observaciones.** Se verificaron numéricamente con el código de Felipe:
   - **Obs. 1:** al sumar la ley sobre las tres fases, la corrección por SOC se anula: Σ E_i(SOC̄_w − SOC_i) = 0, luego ΣP_B ≡ 0 (3·10⁻¹⁵ kW en la simulación) y el SOC promedio queda fijo en 0,5.
   - **Obs. 2:** con potencias netas sostenidas, P_IC → P_net, igual que sin coordinar (I_n = 15,06 A en ambos casos). La ley es un filtro pasa bajos, ΔP_IC = ΔP_net/(1+sτ). El −42 % salía de suavizar la punta transitoria del EV.
   - **Obs. 3:** para que una batería "ayude" a otra fase, la energía tiene que pasar por la red AC, y eso es desbalance.
   - **Obs. 4:** las métricas se monitoreaban, pero no entraban como restricción.
   - **Obs. 5:** los diagramas mezclaban un coordinador central con un consenso.
   - **Obs. 6:** la afirmación de que la literatura solo trataba el desbalance desde el lado AC no tenía respaldo. Sí existen trabajos: Pinthurat y Hredzak, Mexis et al., Hashmi et al., Raza y Jiang, Islam et al.
3. **Escenario ampliado (propuesto por Espina).**
   - Alimentador BT 3φ-4W, ya desbalanceado por clientes monofásicos.
   - Varias Micro-redes DC por fase (N_a, N_b, N_c), que actúan como actuadores compensadores.
   - Terciario centralizado en cabecera (MPC/SOCP) y secundario distribuido por consenso, con un λ por fase.
   - Prototipo en cvxpy (`escenario.py`, `secundario.py`):
     - **Resultado 1:** I₀ = I₂ = 0 si y solo si las tres fases tienen la misma potencia compleja en cabecera.
     - **Resultado 2:** |I₀|² + |I₂|² = 2|B|² + 2|C|², es decir, Q no reduce el desbalance de potencia activa; solo lo traslada entre secuencias.
     - I_n RMS baja de 30,2 a 11,1 A (−63 %) con costo comparable.
4. **Presentaciones Beamer (formato clases USACH).**
   - Primero una técnica con el prototipo (`reunion_tesis_26oct_usach.tex`).
   - Luego una "propuesta nueva" limpia con láminas de respaldo R1–R8 (`propuesta_tesis_usach.tex`).
   - Después, láminas de teoría de conjuntos y diagramas de bloques (`niveles_control_conjuntos.tex`, `control_bloques_9nov.tex`).
5. **Correo del profesor (2-nov).** Pedía confirmar 9 puntos de entendimiento y comentar 2 ideas nuevas: rango de SoC por Micro-red y lazo rápido. Se redactó la respuesta punto por punto (`documentos/correos/respuesta-correo-espina-5nov.md`).
6. **Lámina única para el 9-nov**, como pidió el profesor: qué mide, qué decide y a quién envía cada nivel, más el caso simple de demanda alta prolongada (`pauta-matematica-caso-simple.md`).
7. **Explicaciones pedagógicas:**
   - descomposición B/C y ley del paralelogramo;
   - restricción de cierre del SOC;
   - Lagrangiano/KKT del consenso de costo incremental;
   - IC grid-supporting frente a grid-feeding;
   - mecánica del lazo rápido;
   - simulación en tiempo real (CHIL/HIL, PLECS RT Box, OPAL-RT, Typhoon HIL).

## Preferencias que Felipe dejó explícitas en esta conversación
- Láminas "más livianas de letras", con más diagramas.
- Separar el material exploratorio o de respaldo de las láminas principales.
- Rigor matemático defendible: "no quiero que el profesor me atrape".
- Preparar un banco de preguntas y contraargumentos antes de cada reunión.
- Presentar el tema como **propuesta nueva**, no como "respuesta a correcciones".
- No incluir el prototipo ni la validación cuando no se piden.
- Para la lámina del profesor, usar solo diagramas de bloques; el ejemplo numérico va aparte, con su propia pauta matemática.
