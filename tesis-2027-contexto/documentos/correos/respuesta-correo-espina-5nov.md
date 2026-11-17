# Correo del Prof. Espina (2 nov, 22:59) y respuesta propuesta

## Solicitud del profesor
Confirmar sí/no en 9 puntos de entendimiento del problema (si es no, explicar cómo se entiende) y opinar sobre 2 ideas nuevas. Pidió **no cambiar la presentación por ahora**. Próxima reunión: lunes 9 de noviembre de 2026.

## Diagnóstico frente a la presentación del 2 de noviembre
| Punto | Respuesta | Diferencia con la presentación |
|---|---|---|
| 1. BT 3φ-4W | Sí | — |
| 2. Desbalance previo y variable | Sí | — |
| 3. DER (PV, BESS, EV) + cargas = micro-red DC, recursos distintos | Sí, con matiz | EV estaba como extensión; ahora pasa al núcleo |
| 4. Un IC monofásico por micro-red; Na, Nb, Nc distintos | Sí | — |
| 5. Sin barra DC común; intercambio solo por el alimentador | Sí | — |
| 6. DER grid-supporting | **No exactamente** | Se había supuesto FV en MPPT (grid-feeding), BESS formando V_dc y el IC como grid-following |
| 7. Secundario dentro de cada micro-red (reparte entre sus DER y cuida límites de BESS/EV) | **No** | El secundario era por fase (consenso λ entre micro-redes de una fase) |
| 8. Terciario: intercambio con la red, consignas a los IC, minimizar compra y equilibrar fases | Sí, con matiz | Consignas agregadas por fase → ahora por IC; "compra de energía" vs. costo con tarifa |
| 9. Cada 15 min con pronósticos; ventana < 24 h | Sí, con matiz | Horizonte de 24 h y cierre diario de SoC → condición terminal (rango de SoC) |

## Arquitectura implícita en el correo
1. **Terciario (central, 15 min, ventana < 24 h):** plan de potencia por IC + rango de SoC por micro-red.
2. **Lazo rápido (segundos, por definir):** usa el margen del rango de SoC para corregir el desbalance medido en cabecera.
3. **Secundario (dentro de cada micro-red):** reparte la consigna del IC entre PV, BESS y EV; cuida límites.
4. **Primario:** DER grid-supporting (droop).

El consenso por fase con un λ por fase deja de ser el secundario. Puede reaparecer como candidato para implementar el lazo rápido de forma distribuida.

## Opciones para el "cómo" del lazo rápido (para traer el 9 de noviembre, sin cambiar la presentación)
- **A. Centralizado en cabecera:** se mide B y C (desbalance de P y Q) y un control PI calcula correcciones por fase. Se reparten entre micro-redes según su margen de SoC restante (factores de participación).
- **B. Distribuido:** los líderes por fase reciben la medición de cabecera y las micro-redes de cada fase hacen consenso en la "utilización del margen", de modo que la que tiene más margen aporta más. Es la reutilización del λ por fase.
- **C. MPC rápido de horizonte corto** (segundos a minutos) con el rango de SoC como restricción dura.
- En las tres opciones, Q se usa primero porque no tiene costo energético (Resultado 2). P se usa dentro del margen de energía: |ΔP|·τ ≤ E_k·(SoC_max − SoC) para cargar y E_k·(SoC − SoC_min) para descargar.

## Borrador de respuesta (enviado al estudiante)
Ver el texto del correo en la conversación del 5 de noviembre de 2026.
