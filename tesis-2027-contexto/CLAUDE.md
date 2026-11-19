# CLAUDE.md — Tesis de Magíster 2027 (Felipe Gajardo Ávalos, USACH)

Este archivo es el punto de entrada para Claude Code. Léelo completo antes de trabajar en esta carpeta.

## 1. Quién y qué
- **Estudiante:** Felipe Salvador Gajardo Ávalos. Ingeniero Civil Eléctrico (PUCV). Magíster en Ciencias de la Ingeniería, mención Eléctrica, USACH (ingresó en 1-2026). Docente de Circuitos Eléctricos I en USACH.
- **Profesor guía:** Dr. Enrique Espina González (USACH). Su tesis doctoral (U. Chile / U. Waterloo, 2021, control secundario distribuido por consenso en Micro-redes híbridas AC/DC) y su tesis de magíster (U. Chile, 2017, droop por fase en Micro-redes de 4 hilos, PLECS) son la base metodológica.
- **Reunión semanal:** lunes 17:00, Laboratorio E2Tech, con Espina, Bernhardt Gotschlich e Ignacio Staforelli (hasta el 21-dic-2026).
- **Última reunión:** lunes **16-nov-2026**. Se presentaron `documentos/presentaciones/laminas_reunion_16nov_v2.tex` (6 láminas, con la corrección del terciario) y la simulación PLECS de una Micro-red DC.
- **Acuerdos vigentes:** `documentos/correos/acta-reunion-16nov.md` (acta enviada por Felipe al profesor el 17-nov, 14:50; sin respuesta registrada). **Leerla antes de cualquier tarea.**
- **Próxima reunión:** probablemente lunes **23-nov-2026**, 17:00 (por la regla semanal; no confirmado en el acta).
- **Material preparado para el 23-nov (19-nov):** `documentos/presentaciones/laminas_reunion_23nov.tex` (7 láminas, acuerdo A4), `documentos/pautas/estudio_margen_error_terciario_lazo_rapido.md` (matemática paso a paso) y `documentos/pautas/guia_reunion_23nov.md` (guía y banco de preguntas). Ver §2bis. **Es una propuesta: el profesor aún no la valida.**

## 2. El tema hoy (al 17-nov-2026)
**Gestión jerárquica de un alimentador BT trifásico de 4 hilos con Micro-redes DC por fase.**

El alimentador ya está desbalanceado por clientes monofásicos sin gestión. En cada fase φ ∈ {a, b, c} hay N_φ Micro-redes DC residenciales (FV, BESS, EV, cargas), cada una conectada a su fase por un IC monofásico. No hay barra DC común: las Micro-redes solo intercambian energía a través del alimentador. Los IC se usan como actuadores para gestionar, desde la cabecera, la compra de energía y el balance entre fases.

Arquitectura vigente (detalle en `CRONOLOGIA.md` → "Decisiones vigentes"):

| Nivel | Cuántos / cada cuánto | Mide o recibe | Decide | Envía a |
|---|---|---|---|---|
| Terciario | 1 central, 15 min, H = 12 h | envolvente 𝓔_k y energía E_k de cada MR, tarifa, desbalance previsto por fase D̂_φ y su error típico σ_φ | **solo energía** en el objetivo (mín. compra, LP): plan P*_k, uso previsto del margen ŷ_k (energía) y margen para el error r↑_k, r↓_k (potencia) | IC_k; R_φ = Σr_k al lazo rápido |
| Lazo rápido | 1 por fase, ~1 s | P_h,φ en cabecera; reserva de la fase | **solo balance**: e_φ = P_h,φ − P̄_h, PI saturado → ΔP_φ; u_φ = ΔP_φ/R_φ | IC de la fase (ΔP_k = u_φ r_k) |
| Secundario | 1 por MR, s | V_dc,k, SoC de BESS/EV, FV disponible | restaura V_dc, reparte entre sus DER, cuida límites, calcula su envolvente | primario de cada DER; envolvente al terciario (vía IC) |
| Primario | 1 por convertidor, ms | locales | DER: droop V_dc–P · IC: grid-following, P_ref = P*_k + u_φ r_k, Q_ref = 0 | — |

**Resultados analíticos propios** (se usan para defender decisiones):
- **R1:** con tensión de cabecera balanceada, I₀ = I₂ = 0 ⇔ S_h,a = S_h,b = S_h,c. Por eso "igualar las potencias por fase" equivale a anular las secuencias.
- **R2 (paralelogramo):** |I₀|² + |I₂|² = 2|B|² + 2|C|², con B el desbalance de P y C el de Q. Q no puede reducir el desbalance activo.
- **Piso energético:** con ΔSOC = 0 en el día, la media diaria del desbalance activo no la corrige ningún control. Es un tema de diseño, no de control.
- **Caso simple:** la energía disponible fija cuánto se corrige; la forma de gastarla fija el pico. Repartir parejo es óptimo (por convexidad), y por eso H ≥ duración del evento.

**Terciario corregido (láminas v2 del 16-nov; el profesor pidió detallar su álgebra):**
- **El problema:** antes el desbalance previsible (clientes monofásicos, dura horas) se cubría con reserva de potencia de 15 min. El lazo rápido gastaba energía de las BESS que el terciario no había planificado (ejemplo a mano: la BESS de la fase cargada se agota a las 20:40).
- **La corrección:** lo **previsible** del desbalance se trata como **energía comprometida** (ŷ_k, dentro de la banda de SoC). El **error** del pronóstico (media cero) se trata como **reserva de potencia** r_k = margen para el error.
- **Objetivo:** min Σ_t c(t)·g(t)·Δt, con g ≥ P̂_L,tot − Σ_k P*_k y g ≥ 0 (sigue siendo LP).
- **Restricciones:**
  - (a) Σ_{k∈N_φ} ŷ_k = D̂_φ − (S_φ − S̄) − ρ_φ, con |ρ_φ| ≤ ρ̄, S_φ = Σ_{k∈N_φ} P*_k y S̄ = (1/3)Σ_ψ S_ψ.
  - (b) P^min_k + r↓_k ≤ P̃_k = P*_k + ŷ_k ≤ P^max_k − r↑_k.
  - (c) W^min_k + r↓_k·τ + ε̄_k ≤ Σ_{s≤t} P̃_k·Δt ≤ W^max_k − r↑_k·τ − ε̄_k.
  - (d) Σ_{k∈N_φ} r↑_k ≥ z·σ_φ + m, y Σ_{k∈N_φ} r↓_k ≥ z·σ_φ + m.
- **Propiedad clave:** Σ_φ ê_φ = 0, así que el balance no cambia la compra total; se paga con SoC de las Micro-redes de la fase cargada.
- **Límite físico (verdad cruda):** una BESS solo compensa la parte del desbalance con media diaria cero. Lo demás queda como residual acotado ρ_φ.
- **Aún sin simular.** La lista de lo que falta para dejar las ecuaciones "acabadas" está en `documentos/correos/acta-reunion-16nov.md` (A4).

## 2bis. Formulación del margen de error propuesta para el 23-nov (por validar)
Detalle y derivaciones en `documentos/pautas/estudio_margen_error_terciario_lazo_rapido.md`.
- **Idea central:** el lazo rápido es una **política afín de reserva diagonal** (Warrington et al., 2013): `P_IC,k = P*_k + α_k·ΔP_φ`, con factores de participación `α_k ≥ 0`, `Σα_k = 1`.
- **Reparto:** `ŷ_k = α_k·b_φ`, `b_φ = ê_φ − ρ_φ`; `r_k = α_k·R^ε_φ`. `α_k` se fija antes de resolver (propuesta `α_k = E_k/ΣE_j`, mismo ΔSoC); si fuera variable, el problema sería bilineal. (d) se cumple por construcción.
- **Margen de potencia:** `R^ε↑_φ = q_{1−ε}(ξ_φ) + m` (cuantil empírico propuesto, precedente SOGL art. 157 al 99 %; gaussiano `zσ_φ + m`). `m` = variación dentro de 15 min + medida + seguimiento del PI.
- **Energía (c):** margen creciente `Z_φ(t) = (zσ_φ·√f(t+1) + m)·Δt`, con `f(n)` del error AR(1); en el primer tramo `Z = R^ε·Δt`, así que `τ = Δt`. Variantes a simular: (c-i) solo el primer tramo, (c-ii) creciente.
- **LP:** compra con `P̃_k = P*_k + ŷ_k`; `|ρ_φ| ≤ ρ̄` y `Σ_φ ρ_φ = 0`; condición final `Σ P̃_k Δt ≤ W^fin_k`.
- **Lazo rápido:** error `e_φ − ρ_φ`; PI limitado a `[b_φ − R^ε↓_φ, b_φ + R^ε↑_φ]` (no `±Σr_k`); indicador `u_φ = (ΔP_φ − b_φ)/R^ε_φ ∈ [−1, 1]`; forma equivalente `P_ref,k = P*_k + ŷ_k + u_φ·r_k` (ŷ_k como prealimentación es una decisión pendiente).
- **Preguntas abiertas al profesor:** prealimentación de ŷ_k, criterio de α_k, nivel ε, variante de (c), origen de ρ̄, quién regula V_dc con el lado AC.

## 3. Mapa de la carpeta
```
CLAUDE.md                 ← este archivo
README.md                 ← índice completo, qué se incluyó y qué no
CRONOLOGIA.md             ← evolución del tema, decisiones vigentes y obsoletas
ENLACES.md                ← chats de claude.ai + toda la bibliografía con enlace
memoria/                  ← memoria de Claude sobre la tesis (thesis-overview.md = estado más completo) y perfil
conversaciones/           ← resumen de cada chat del Proyecto (pedidos, resultados, correos del profesor)
documentos/presentaciones ← Beamer (XeLaTeX); laminas_reunion_16nov_v2.tex es la vigente (la v1 queda como histórico)
documentos/pautas         ← guiones de reunión, matemática y bibliografía comentada; guia_reunion_16nov_problema_terciario.md = la más reciente
documentos/correos        ← respuesta al correo del 2-nov y ACTA DEL 16-NOV (acuerdos vigentes) + captura
documentos/simulacion     ← PLECS + guía de simulación (guia_simulacion_plecs.md) + referencia Python + prototipos cvxpy; historico_ley_soc/ = etapa descartada
referencias/              ← documento de orientación de julio 2026 (PDF + texto extraído)
```

## 4. Cómo trabajar con Felipe
- **Idioma:** español de Chile, registro técnico. Escribir "Micro-red" con guion.
- **Estilo:** directo, con datos, sin suavizar ("verdad cruda"). Todo detallado y documentado. Explicaciones paso a paso, con rigor matemático y claridad física. Distinguir lo comprobado de lo supuesto o inferido, y no omitir supuestos.
- **Antes de cada reunión:** preparar un banco de preguntas y contraargumentos. Felipe tiene que poder defender cada ecuación ante el profesor.
- **Láminas:** livianas en texto y basadas en diagramas. El material de respaldo va aparte. Presentar el tema como propuesta, no como "corrección". No incluir prototipos ni validación si no se piden.
- **LaTeX:**
  - Plantilla de clases USACH: `beamer`, `aspectratio=169`, XeLaTeX con `fontspec` + `polyglossia` (español).
  - Colores: teal `#009688`, naranjo `#E77500`; código de colores por nivel: terciario naranjo, lazo rápido verde `#2E7D32`, secundario teal, primario azul `#1F5FAF`.
  - Fondos `fig/fondo_usach_portada.png` y `fig/fondo_usach_contenido.png`. Desde el 19-nov, `documentos/presentaciones/fig/fondo_usach_contenido.png` **está en el repositorio** (recuperado de la imagen embebida en `laminas_reunion_16nov_final.pdf`, 1387×778 px). El de portada sigue faltando; pedírselo a Felipe si se necesita.
  - Sin referencias al correo en las láminas ("punto 2", "10-nov"): Felipe las menciona de palabra.
  - Referencias en formato IEEE.
- **Convenciones de signo:** P_IC > 0 = DC→AC (inyecta a la red); P_B > 0 = la batería descarga; P_h > 0 = el alimentador importa desde la S/E. En la lámina 16-nov, P > 0 = el IC entrega a la red.
- **Errores a no cometer:**
  - conectar 0V_a, 0V_b y 0V_c al neutro;
  - confundir el PCC con el neutro;
  - suponer barra DC común, operación en isla o hardware definitivo;
  - mezclar el secundario (por MR) con el lazo rápido (por fase);
  - volver a la ley de SOC con τ (ojo: el τ de la restricción (c) del terciario es otra cosa, la duración de la reserva, 15 min);
  - volver a poner el desbalance en el objetivo del terciario, o cubrir el desbalance previsible solo con reserva de potencia (kW) de 15 min.
- **No inventar:** si algo depende de un archivo que no está aquí, pedirlo.

## 5. Pendientes abiertos (ordenados según el acta del 16-nov)
**Para la próxima reunión (acta del 16-nov):**
1. **Conectar el IC a una fuente de tensión de 50 Hz en PLECS** y que la simulación corra sin fallas. Hasta ahora el IC era solo una fuente de potencia en el bus DC; **el criterio anterior de "no modelar el lado AC" queda reemplazado**. Propuesta: inversor monofásico en modelo promedio + filtro L/LCL + PLL (SOGI) + control de corriente PR a 50 Hz, grid-following con P_ref y Q_ref = 0. Detalle y riesgos (rizado de 100 Hz en V_dc) en `documentos/correos/acta-reunion-16nov.md` (A2).
2. **Mostrar los flujos de potencia DC y AC del IC** (P_dc, P_ac, Q_ac, v y i AC) y comprobar P_ac ≈ P_dc y Q_ac ≈ 0 (A3).
3. **Terciario: álgebra del margen de error y formulación acabada** (A4). **Propuesta preparada el 19-nov** (§2bis, láminas del 23-nov); falta que el profesor la valide y simularla. Lo pedido era: definir cada símbolo con unidades; modelo del error (σ_φ, ε̄_k, z); criterio de reparto de r_k entre las MR de una fase; restricción de energía en toda la trayectoria; LP completo en una página con horizonte rodante; coherencia con el límite del PI del lazo rápido.

**Siguen abiertos:**
4. **PLECS nunca ejecutado por Claude.** El `.plecs` lo abrió Felipe y fue validado por el profesor en lo DC. Errores ya vistos al abrir: "cannot determine start point of connection segment" (corregido con holgura de ≥ 45 px entre quiebres y bloques). `verificar_plecs.py` y `gen_plecs.py` (generador del `.plecs`) existieron en el chat de simulación, pero **no están en el Proyecto ni en esta carpeta**: si se necesitan, pedírselos a Felipe o reescribirlos.
5. La referencia Python (`referencia_microred_dc.py`) necesita `PPV.csv`, que **no está en la carpeta**.
6. **Simular la corrección del terciario** (hoy solo hay un ejemplo a mano: 6 kWh, 1,5 kW durante 4 h).
7. **Qué pasa cuando una MR se equivoca en su pronóstico:** el error consume margen; formalizarlo (es parte de A4).
8. **Tiempo real:** plataforma por definir (PLECS RT Box es la opción natural); compresión de tiempo κ para el terciario.
9. **Revisión sistemática de literatura** para confirmar la brecha candidata.

## 6. Fuera de alcance
No mezclar con otros proyectos de Felipe (Electra Consultora, proyectos SEC, paper EVSE, laboratorio de Sistemas Lineales, plan de doctorado) salvo que él lo pida.
