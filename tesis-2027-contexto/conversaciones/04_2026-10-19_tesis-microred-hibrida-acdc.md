# Tesis micro-red híbrida AC/DC

- **Enlace:** https://claude.ai/chat/564744e5-50cf-415c-803b-849ada992f7d
- **Última actualización:** 19-oct-2026 · 6 turnos

## Pedido de Felipe (textual)
> "Quiero que me indiques los principales problemas, de forma detallada, para explicar al profesor Enrique. Hoy tendré la conversación con el profesor. Me interesa que se pueda ver expertiz de mi parte. Diagnosticar cuellos de botella en la tesis y una propuesta matemática que me permita llevar a cabo la simulación de esta micro-red híbrida AC/DC. Además quiero que sumes preguntas posibles y cuestionamientos que me pueda hacer el profesor Enrique, en función de la tesis de doctorado que realizó."

## Lo que se trabajó
- Se reprodujo la simulación de Felipe (`sim_soc.py` y el escenario periódico de 4 días de `final.py`) para respaldar cada afirmación con números verificados.
- Se armó un documento (Claude Docs) **"Reunión con prof. Espina — Diagnóstico y formulación de tesis"**, con ocho secciones: mensaje central de 60 s, diagnóstico de cuellos de botella, formulación matemática, resultados preliminares, hoja de ruta de simulación en 3 niveles, preguntas probables de Espina, decisiones por cerrar y referencias. Después se agregó una pestaña **"Ficha de reunión"** para repasar justo antes de entrar.
- **Idea central de esa etapa:** sin barra DC común, cada IC solo puede mover energía en el tiempo, a través de la batería de su fase. Eso deja un "piso" de corriente de neutro (6,6 A) que ningún control puede eliminar.
- **11 cuellos de botella (CB1–CB11).** Los tres más críticos:
  - no hay transferencia de potencia entre fases;
  - el modelo de red (rígida o débil, con Thevenin);
  - el compromiso entre secuencia cero (neutro) y negativa (VUF) al usar Q.
- **Ley de coordinación por SOC:** P*_IC,i = P̄_net + (E_i/τ)(SOC̄_w − SOC_i). Se demostró que equivale a un filtro pasa bajos de primer orden. Se derivaron cinco propiedades:
  - P1, conservación;
  - P2, equivalencia con el filtro;
  - P3, piso energético;
  - P4, desplazamiento del SOC y regla de diseño de τ;
  - P5, falla sin el término de SOC.
- **Resultado reportado:** con τ = 4 h el pico de corriente de neutro baja 42 % (21,6 → 12,6 A) sin saturar baterías. *(Después se vio que ese −42 % era solo filtrado de un transitorio; ver conversación 6.)*
- **Contexto investigado:** la tesis doctoral de Espina (U. Chile/Waterloo, 2021), la normativa chilena (NTCS, límite de VUF de 2 %) y sus prototipos experimentales de 24/33 kW.
- **Explicación de las ecuaciones paso a paso:**
  - balance del bus DC, dinámica del SOC y corriente de neutro (con verificación a mano a las 20:00);
  - la ley como dos términos: igualar potencias y volver al SOC medio;
  - las propiedades P1–P5, con P2 explicada con la analogía de un circuito RC;
  - promedio por consenso;
  - por qué Q solo traslada el desbalance entre secuencias;
  - ecuaciones del nivel 2 (modelo promedio conmutado).

## Archivos relacionados
- `documentos/presentaciones/historico/presentacion_tesis_espina.tex` (presentación de esta etapa).
- `documentos/simulacion/historico_ley_soc/` (`sim_soc.py`, `final.py`, `analisis_reunion.py`).
