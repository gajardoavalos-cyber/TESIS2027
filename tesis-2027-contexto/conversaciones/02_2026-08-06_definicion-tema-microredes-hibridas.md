# Definición de tema de tesis en micro-redes híbridas

- **Enlace:** https://claude.ai/chat/1167720d-85d2-4293-a7dc-a5741d77a603
- **Última actualización:** 06-ago-2026

## Pedido de Felipe
1. Bibliografía dirigida, anclada en las tesis de magíster y doctorado del Prof. Enrique Espina.
2. Explicación técnica profunda de todos los conceptos de base, para poder defenderlos con seguridad.

## Lo que se trabajó
- **Trayectoria del Prof. Espina:**
  - Magíster (U. de Chile, 2017, guía Roberto Cárdenas-Dobson): droop por fase en Micro-redes de cuatro hilos, en PLECS y con validación experimental.
  - Doctorado (doble grado U. de Chile / U. of Waterloo, 2021): control secundario distribuido por consenso en Micro-redes híbridas AC/DC, donde el IC participa como agente de consenso.
- **Brecha identificada:** la literatura trata el desbalance como un problema del lado AC; en la arquitectura de Felipe el desbalance se origina en el lado DC, por recursos independientes por fase. Ese caso no se había tratado en el grupo de Espina. *(Nota: el 20-oct el profesor mostró que esta afirmación sobre la literatura no tenía respaldo; ver conversación 6.)*
- **Bibliografía:** referencias M1, D1–D4, U1–U3, IC1, más R1–R10.
- **Explicaciones entregadas:**
  - Arquitectura jerárquica primario/secundario/terciario y sus escalas de tiempo.
  - Droop por fase en AC y DC, y por qué el droop trifásico simétrico no aplica a esta topología.
  - Fundamentos de consenso en grafos: ecuación de actualización, convergencia, variantes lineal, heterogénea y de tiempo finito.
  - Aporte doctoral de Espina y cómo se extiende de un IC a tres.
  - Métricas de desbalance: corriente de neutro, componentes simétricas, VUF/CUF y Conservative Power Theory.
  - Estrategia de simular primero con modelo promedio en PLECS y luego conmutado.
  - Errores conceptuales a evitar: neutro AC frente a referencias DC; PCC frente a conductor de neutro; un droop localmente óptimo por fase no garantiza un desbalance global aceptable.
