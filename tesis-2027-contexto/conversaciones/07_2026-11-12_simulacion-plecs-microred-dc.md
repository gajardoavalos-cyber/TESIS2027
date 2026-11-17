# Simulación PLECS micro-red DC

- **Enlace:** https://claude.ai/chat/7e6e1711-b7d6-47c5-9847-9ccd945719e1
- **Última actualización:** 16-nov-2026 · 43 turnos (actualizado en la exportación del 17-nov)

## Pedido de Felipe (textual)
> "Se adjunta la información que dice relación con una simulación en PLECS de recursos renovables. Te las adjunto porque me interesa que se pueda sacar en limpio el modelo del PPV y el de la batería; recuerda que ahora estoy en la etapa de realizar la simulación de mi micro-red DC con control primario y secundario, sumado a que tenga incorporado los modelos de PPV, batería y cargador de vehículos EV. Quiero que tomes todo esto en consideración para que me des un archivo PLECS que tenga todo esto dispuesto para simular y validar la primera parte de la simulación de la tesis. Me interesa mucho eso, ya que es algo que le debo saber mostrar al profesor para la próxima reunión el día lunes 16. Por otro lado, también se adjunta el modelo de un convertidor DC para que lo uses como base para la simulación. Me interesa que además de realizar el archivo para que lo pueda modelar, también puedas darme un paso a paso de manera muy pedagógica para que esté al tanto y pueda explicar lo que se va a disponer en la simulación. Guíate en la memoria del chat de este proyecto denominado 'Validación del planteamiento de micro-redes' para entender más contextualmente lo que requiero."

## Archivos que adjuntó Felipe (no están en el Proyecto; pedirlos si se necesitan)
- `Modelos_ERNC.plecs`: modelos FV y batería de un laboratorio de ERNC.
- Modelo de un convertidor DC, usado como base.
- `PPV.csv`: perfiles horarios de irradiancia y temperatura (enero/julio). **Lo necesita `referencia_microred_dc.py`** y no está en esta carpeta.

## Resultado
- **`documentos/simulacion/MicroRed_DC_Validacion.plecs`:** modelo promedio de una Micro-red DC (bus de 400 V).
  - **Ramas:** FV (RS6F-200M, 2 strings × 8 módulos), BESS (6,5 Ah × 9 en paralelo, 360 V, ±5 kW), cargador EV (3,7 kW), carga DC e IC (fuente de potencia), sobre un bus con C = 4,7 mF.
  - **Control primario:** lazos de corriente PI discretos (Ts = 1/15000 s) y droop V–I en la BESS (y opcionalmente en el EV).
  - **Control secundario:** PI que restaura V_dc, más reglas de SOC: recorte FV, reducción del EV y límites de la BESS.
  - **Escenario 1 (validación dinámica, 3,4 s):** V_dc entre 394 y 405 V; el secundario restaura en unos 0,2 s.
  - **Escenario 2 (día comprimido, 1 s = 1 h):** el SOC sube de 0,50 a 0,85 y termina el día en 0,42.
  - **Organización de la planta** (última versión): un subsistema por equipo (PV, BESS, EV, carga DC), con el control afuera, igual que en la lámina de niveles. Etiquetas Goto/From con prefijos `pv_`, `bt_`, `ev_`, `ld_`.
  - **Revisión:** Claude no tiene PLECS, así que **el archivo no se ha probado en PLECS**. Pasó un verificador propio: conexiones completas, bornes bien numerados, Goto/From únicos y con su par, tramos solo horizontales o verticales, y quiebres a ≥ 45 px de cada bloque para evitar el error "connection segment".
- **`documentos/simulacion/referencia_microred_dc.py`:** las mismas ecuaciones en Python, para obtener las formas de onda esperadas y compararlas con PLECS. Si PLECS da algo distinto, hay que revisar el modelo PLECS.
- **Guía pedagógica paso a paso:** es un documento (artifact) de claude.ai, "Guía de simulación PLECS: Micro-red DC con control primario y secundario" (https://claude.ai/artifact/46KxbqnwPPqHd4Ssv24XLD). Su exportación a Markdown está en `documentos/simulacion/guia_simulacion_plecs.md` (las 3 imágenes y 2 widgets del original quedaron como texto). Incluye el mapa del archivo, cómo correrlo, los resultados esperados, el guion para el 16-nov y la tabla de problemas de PLECS.
- **Orden sugerido para mostrarlo el lunes 16:** primero la lámina de niveles, luego el nivel superior del archivo y después el bloque de la Micro-red con los cuatro equipos en el bus.


## Continuación del 13 al 16-nov (turnos 25–43)

### Simulación PLECS
- **Error "cannot determine start point of connection segment" (turno 25).** Hipótesis de Claude: un primer o último quiebre de cable quedaba encima de un borne, a 20–40 px del centro de fuentes, condensador del bus, voltímetro, sumadores y bornes DC+/DC−, y el tramo resultaba de largo cero. Corrección:
  - filas de la planta separadas cada 160 px;
  - quiebres a ≥ 45 px de cualquier bloque;
  - sin señales bifurcadas y con tramos solo ortogonales.
  Se agregó al verificador una revisión de holgura. **Sin PLECS no se pudo confirmar**; se recomendó a Felipe instalar la actualización de PLECS si el error volvía.
- **Pedido de Felipe (turno 26, textual):** "Me gustaría que para efectos de la simulación puedas ejemplificar el sistema de micro-red DC con sus ppv, bess y ev modelados como subsistemas para que se parezca a la representación de la imagen del esquema que ya has analizado." Resultado: FV, BESS, EV y carga quedaron como subsistemas dentro de "MR a1: PV - BESS - EV - carga", con prefijos de etiquetas `pv_`, `bt_`, `ev_` y `ld_`. La guía se actualizó en estos puntos:
  - "Mapa del archivo";
  - "Cómo leerlo en PLECS";
  - Paso 2;
  - lista de prefijos.
- **Archivos del chat que NO están en el Proyecto:** `verificar_plecs.py` (verificador estructural) y `gen_plecs.py` (generador del `.plecs`). El `.plecs` del Proyecto es la última versión guardada y coincide byte a byte con el de esta carpeta (SHA-256 `35a25690…`).

### Láminas del 16-nov: "el problema del terciario"
- **Pedido de Felipe (textual):** "dame las láminas actualizadas sobre todo atendiendo el problema del terciario y cómo puedo solucionarlo para efectos de la presentación. Además de las láminas, dame una guía y material (papers) para leerlos antes de la reunión de hoy a las 17:00".
- **Supuesto declarado por Claude:** no había un registro escrito de cuál era "el problema". Se diagnosticaron dos fallas:
  1. El desbalance previsible se trató como reserva (potencia de 15 min), aunque dura horas, así que el lazo rápido gastaba SoC no planificado.
  2. El propio plan del terciario cambia el desbalance, porque cada IC es monofásico.
- **Corrección:** lo previsible es energía comprometida (ŷ_k, restricción (a)) y el error es reserva (r_k, restricción (d)). Fórmulas completas en `CLAUDE.md` §2.
- **Iteraciones de las láminas (todas guardadas en el Proyecto con el nombre `laminas_reunion_16nov_v2.tex`):**
  - v2: cada lámina indicaba a qué punto del correo del 10-nov respondía.
  - v4: sin índice, sin alusiones al correo, columna "Mide o recibe" ordenada y flechas rectas en la lámina de la línea BT.
  - v5: se quitaron la lámina de decisiones y los respaldos R1–R2, y quedaron 6 láminas.
  - Final: con el fondo USACH extraído del PDF del 9-nov que adjuntó Felipe.
- **Guía de la reunión** (artifact https://claude.ai/artifact/YYZ7uaPKr3bfUQ8XKDSKzd), exportada a `documentos/pautas/guia_reunion_16nov_problema_terciario.md`:
  - orden de exposición;
  - la idea en ecuaciones;
  - preguntas probables con respuesta;
  - lecturas (Warrington et al. 2013; Sun et al. 2016; Müller et al. 2019; Nasrolahpour et al. 2017; Bustos et al. 2023);
  - lo no verificado.
  Ojo: la tabla de orden de exposición de la guía corresponde a la versión de 7 láminas más respaldos, no a la final de 6.

### Resultado de la reunión
Ver `documentos/correos/acta-reunion-16nov.md`. El acta la escribió Felipe y la envió el 17-nov.
