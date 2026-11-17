# Acta de la reunión del 16-nov-2026 (enviada al Prof. Espina el 17-nov)

- **Asunto del correo:** "Acta Reunión 16/11/2026"
- **De:** Felipe Gajardo Ávalos (felipe.gajardo.a@usach.cl) · **Para:** Enrique (Prof. Enrique Espina)
- **Enviado:** martes 17-nov-2026, 14:50 (hora de Chile)
- **Adjunto:** una imagen de la lámina "Niveles de control: qué mide, decide e informa" (la lámina 1 de `presentaciones/laminas_reunion_16nov_v2.tex`).
- **Captura original:** `acta-reunion-16nov_captura.png` (en esta misma carpeta).
- **Estado:** a la fecha de esta exportación (17-nov, 18:36) **no hay respuesta registrada del profesor**. El acta la redactó Felipe; los acuerdos se consideran vigentes salvo que Espina corrija algo.

## Texto del correo (transcripción literal)

> Estimado profesor, junto con saludar le dejo los principales acuerdos adoptados el día de ayer para efectos de la próxima reunión que tengamos para cotejar el avance de tesis:
>
> **Sobre la simulación:**
> - Se valida lo mostrado respecto a la Micro-red, junto a su control primario y secundario. Se debe modificar el subsistema que dice relación con el IC, ya que este debe estar conectado a una fuente de tensión a 50 hz y validar la simulación sin que denote fallas.
> - Mostrar los flujos de potencia en el lado DC y AC para comprobar el funcionamiento del IC.
>
> **Sobre el control terciario y el lazo rápido:**
> - Se debe trabajar el álgebra del margen de error que se mostró en el cambio del control terciario, junto con profundizar el estudio del mismo y dejar las ecuaciones acabadas respecto a la implementación de este margen. Tener una formulación más detallada del control terciario.
>
> Quedo atento a sus comentarios,
>
> Saludos cordiales,
>
> Felipe Salvador Gajardo Ávalos — Ingeniero Civil Eléctrico — Estudiante de Magíster en Ciencias de la Ingeniería, mención eléctrica — Universidad de Santiago de Chile

## Qué significa cada acuerdo en términos técnicos (interpretación de Claude, no del profesor)

### A1. La Micro-red DC con primario y secundario queda validada
- Lo que se mostró: `simulacion/MicroRed_DC_Validacion.plecs` (FV, BESS, EV y carga como subsistemas dentro de "MR a1: PV - BESS - EV - carga"; primario droop V_dc–P; secundario con restauración de V_dc y reglas de SOC).
- **Consecuencia:** no se rediseña el lado DC. Los parámetros y las leyes de control de la Micro-red quedan congelados salvo que la conexión AC obligue a cambiarlos.

### A2. El IC debe conectarse a una fuente de tensión de 50 Hz
- Hasta el 16-nov el IC estaba modelado **solo desde su lado DC**: una fuente de potencia que tomaba o entregaba P_IC en el bus. Felipe había pedido explícitamente no modelar la red AC ni la S/E. **Ese criterio queda reemplazado por este acuerdo.**
- Lo mínimo que se pide: el lado AC del IC conectado a una **fuente de tensión sinusoidal de 50 Hz** (la fase φ vista desde el IC; monofásica, fase–neutro, 220–230 V RMS), con la simulación corriendo **sin errores**.
- Modelo coherente con la arquitectura vigente (IC **grid-following**, `P_ref = P*_k + u_φ·r_k`, `Q_ref = 0`). Propuesta a validar con el profesor si hay duda:
  - **Etapa de potencia:** inversor monofásico de puente completo en **modelo promedio** (fuente de tensión controlada `v_inv = m·V_dc`) + filtro L (o LCL) hacia la fuente de 50 Hz. En el lado DC, una fuente de corriente controlada `i_dc = p_ac / V_dc` para conservar la potencia (balance de potencia del modelo promedio).
  - **Sincronización:** PLL monofásico (SOGI-PLL) o, para empezar, el ángulo tomado directamente de la fuente ideal (aceptable mientras la red sea una fuente ideal; hay que decirlo).
  - **Lazo de corriente:** PR (proporcional-resonante) a 50 Hz en marco estacionario, o dq con señal en cuadratura (SOGI). Referencia de corriente: `i* = (2·P_ref / V̂)·sin(θ)` con `Q_ref = 0`.
  - **Quién fija V_dc:** hoy lo fija la BESS con droop y el secundario lo restaura. El IC sigue P_ref y **no** regula V_dc. Esto es consistente con grid-following y con la lámina de niveles; conviene confirmarlo explícitamente en la próxima reunión.
- **Riesgo conocido:** un IC monofásico tiene potencia instantánea pulsante a **100 Hz** (2·f). En modelo promedio con fuente de corriente en el bus DC aparece un rizado de 100 Hz en V_dc que el condensador del bus (4,7 mF) debe absorber. Hay que mostrarlo, no ocultarlo: es una diferencia real respecto del modelo anterior.

### A3. Mostrar los flujos de potencia en el lado DC y en el lado AC
- Scopes nuevos: `P_dc` del IC (V_dc·i_dc), `P_ac` (promedio de v·i en un ciclo de 50 Hz) y `Q_ac`, más tensión y corriente AC instantáneas.
- Prueba esperada: `P_ac ≈ P_dc − pérdidas` (en modelo promedio sin pérdidas, iguales en promedio) y `Q_ac ≈ 0`. Un escalón de P_ref debe verse en ambos lados y en el balance del bus DC (FV + BESS + EV − carga = P_IC).
- Conviene una tabla de balance de potencia en régimen permanente por escenario (DC vs AC) en la guía de simulación.

### A4. Terciario: álgebra del margen de error, ecuaciones acabadas
- Se refiere a lo presentado en las láminas v2 (`presentaciones/laminas_reunion_16nov_v2.tex`, lámina "Terciario: objetivo, envolvente que recibe y reserva que asigna"): restricciones (a)–(d), con `ŷ_k` (uso previsto del margen, energía), `r↑_k, r↓_k` (margen para el error, potencia), `ε̄_k` (error de la MR), `σ_φ`, `z`, `m`, `τ`, `ρ_φ`.
- Lo que falta para que las ecuaciones queden "acabadas":
  1. **Definir cada símbolo con unidades** y de dónde sale (medido, pronosticado, parámetro de diseño). En particular `τ` (duración de la reserva, hoy 15 min), `m`, `z` y `ρ̄`.
  2. **Modelo del error:** de dónde salen `σ_φ` y `ε̄_k` (error histórico del pronóstico simple, ventana, estacionalidad) y qué nivel de confianza fija `z`.
  3. **Cómo se reparte el margen de la fase entre sus MR:** (d) solo acota la suma `Σ r_k`; falta el criterio de reparto (proporcional a la envolvente libre, al costo, o como variable del LP con algún peso).
  4. **Dinámica de energía del margen:** que (c) quede escrita como una trayectoria de SoC con el uso previsto `ŷ_k` y el peor caso del error, verificando que no se viola en ningún instante dentro del intervalo, no solo al final.
  5. **El LP completo, en una sola página:** variables de decisión, parámetros, objetivo, todas las restricciones, horizonte H = 12 h con paso Δt = 15 min, y cómo se re-resuelve cada 15 min (horizonte rodante) con el SoC medido.
  6. **Coherencia con el lazo rápido:** que `R_φ = Σ r_k` sea exactamente el límite del PI y que `u_φ = ΔP_φ / R_φ` no supere 1 en el caso nominal.
- Lecturas que respaldan esta parte: `pautas/guia_reunion_16nov_problema_terciario.md` (Warrington et al. 2013, "policy-based reserves"; Sun et al. 2016, "phase balancing using energy storage"; Nasrolahpour et al. 2017, energía + reserva con almacenamiento).

## Lo que el acta NO dice (no inventar)
- No dice si el profesor aceptó tal cual la restricción (a) (balance previsto como energía comprometida en el terciario) ni la separación "lo previsible es energía, el error es reserva". Dice que hay que **trabajar el álgebra** y **detallar** la formulación: se interpreta como aceptación de la dirección, con exigencia de rigor. Confirmar en la próxima reunión.
- No fija la fecha de la próxima reunión. Por la regla semanal (lunes 17:00) sería el **lunes 23-nov-2026**, **sin confirmar**.
- No menciona la potencia reactiva ni el tiempo real.
