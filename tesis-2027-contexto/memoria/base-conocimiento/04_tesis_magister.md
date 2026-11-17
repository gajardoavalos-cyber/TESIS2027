# Tesis Magíster 2027 — Micro-redes híbridas AC/DC con convertidores monofásicos por fase

Fuente original: `04_TESIS_MAGISTER_2027_MICROREDES_AC_DC.txt`.

## 1. Contexto
Proyecto principal de investigación del magíster. La arquitectura nace de la sugerencia de utilizar tres módulos monofásicos, uno por fase, conectados a una red trifásica de cuatro hilos.

## 2. Arquitectura
Red: fases a, b, c; neutro n; PCC de cuatro hilos.
Convertidores: IC_a entre a-n; IC_b entre b-n; IC_c entre c-n.
Lado DC: DC-MR_a; DC-MR_b; DC-MR_c; referencias independientes 0V_a, 0V_b y 0V_c.

Restricción: las referencias DC no se conectan al neutro común; no existe una barra DC común; la red AC sí conserva neutro; los convertidores deben representarse con aislamiento o referencias flotantes según la topología final.

## 3. Motivación
Permitir integración modular de recursos DC por fase y estudiar cómo diferencias de carga, generación y almacenamiento afectan la red AC.

## 4. Problema
Los buses DC deben regularse localmente, pero esa regulación puede exigir potencias distintas por fase, generando: desequilibrio; corriente de neutro; VUF; secuencia cero; pérdidas; THD; exigencia desigual de convertidores.

## 5. SOC por fase
Variables: SOC_a; SOC_b; SOC_c.
El control debe: evitar sobrecarga y sobredescarga; repartir esfuerzo; equilibrar SOC cuando sea posible; priorizar continuidad de cargas críticas; gestionar EV/V2G.

## 6. Control coordinado
Estructura posible: lazo interno de corriente; regulación de V_dc; control de potencia; supervisor coordinado; generación de P_IC,i; gestión de almacenamiento; corrección de desbalance.

Función objetivo conceptual: minimizar error de V_dc; minimizar I_n; minimizar VUF; minimizar desbalance de SOC; respetar límites.

## 7. Métricas
Error RMS de V_dc; sobreimpulso; tiempo de establecimiento; I_n RMS; VUF; CUF; THD; pérdidas; energía no servida; saturación; variación de SOC; potencia por fase.

## 8. Estado del arte
Líneas de trabajo: hybrid AC/DC microgrids; interlinking converters; four-wire systems; unbalanced operation; per-phase control; zero-sequence control; DC-link ripple; distributed control; model predictive control; energy management; EV/V2G; battery balancing.

## 9. Casos de estudio
Caso equilibrado; carga DC desigual; generación FV desigual; SOC desigual; EV monofásico; V2G; saturación de convertidor; pérdida de recurso; cambios simultáneos.

## 10. Entregables desarrollados
Estado del arte inicial; diagramas; presentación Beamer; presentación para profesor; mapa conceptual; planteamiento de problema; hipótesis preliminar; carta Gantt; figuras eléctricas y de bloques.

## 11. Pendientes
Versión definitiva de hipótesis; validación bibliográfica; topología final; aislamiento; modelo matemático; selección de control; implementación PLECS; comparación de estrategias; resultados; paper.

## 12. Advertencias — no asumir
- Operación en isla.
- Bus DC común.
- Neutro compartido en DC.
- Estrategia final aprobada.
- Hardware definitivo.
