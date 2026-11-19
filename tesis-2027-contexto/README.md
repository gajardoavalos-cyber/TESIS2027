# Contexto completo — Tesis Magíster 2027 (Proyecto "Tesis 2027 Mg")

Exportación del Proyecto de claude.ai **"Tesis 2027 Mg"** para usarla como contexto en Claude Code. Primera versión: 12-nov-2026. **Actualizada el 17-nov-2026** (ver "Cambios del 17-nov" al final).

**Cómo usarla:** abre Claude Code dentro de esta carpeta. `CLAUDE.md` se carga solo y explica el tema, el estado actual, las convenciones y los pendientes.

## Contenido

### Raíz
| Archivo | Qué es |
|---|---|
| `CLAUDE.md` | Instrucciones y contexto para Claude Code (empezar aquí). |
| `CRONOLOGIA.md` | Evolución del tema de julio a noviembre, decisiones vigentes y decisiones obsoletas. |
| `ENLACES.md` | Enlaces a las 8 conversaciones de claude.ai y a los 55 recursos bibliográficos citados, con el archivo donde aparece cada uno. |

### `memoria/`
| Archivo | Qué es |
|---|---|
| `thesis-overview.md` | Copia literal de la memoria del Proyecto (última actualización 10-nov). Es el estado más completo: arquitectura, reunión del 9-nov y correo del 10-nov. |
| `perfil_academico.md` | Perfil de Felipe, contactos de la reunión semanal y preferencias de trabajo. |
| `base-conocimiento/` | Extractos de la base de conocimiento personal de Felipe que tratan la tesis: contexto técnico y preferencias, ficha de la tesis de magíster y laboratorio PLECS. |

### `conversaciones/`
Un archivo por conversación del Proyecto (8 en total), más un índice. Cada uno trae el enlace, el pedido de Felipe, los resultados, las decisiones y los archivos que produjo. En `08_…validacion-planteamiento.md` está **textual** el correo del Prof. Espina del 2-nov con las respuestas de Felipe.

### `documentos/` (25 de los 35 documentos del Proyecto; los otros 10 son versiones superadas, ver abajo; más 2 guías exportadas desde artifacts y el acta del 16-nov)
| Carpeta | Archivos |
|---|---|
| `presentaciones/` | `laminas_reunion_16nov_v2.tex` (**vigente**, la que se presentó el 16-nov), `laminas_reunion_16nov.tex` (v1 del 12-nov), `laminas_reunion_9nov_v6.tex`, `control_bloques_9nov.tex`, `niveles_control_conjuntos.tex`, `propuesta_tesis_usach.tex`, `reunion_tesis_26oct_usach.tex`; `historico/presentacion_tesis_espina.tex` (propuesta original con la ley de SOC, descartada) |
| `pautas/` | `guia_reunion_16nov_problema_terciario.md` (**la más reciente**), `lecturas-terciario-10nov.md` (v3), `pauta_reunion_9nov_v4.tex`, `pauta-matematica-caso-simple.md`, `pauta-diagramas-bloques.md`, `pauta-niveles-conjuntos.md`, `pauta-2da-parte-y-tiempo-real.md`, `pauta-propuesta-tesis-26oct.md`, `pauta-reunion-tesis-26oct.md` |
| `correos/` | `acta-reunion-16nov.md` (**acuerdos vigentes**) + `acta-reunion-16nov_captura.png`, `respuesta-correo-espina-5nov.md` |
| `simulacion/` | `MicroRed_DC_Validacion.plecs` (343 kB, **vigente**; lado DC validado el 16-nov), `guia_simulacion_plecs.md` (guía paso a paso), `referencia_microred_dc.py`, `escenario.py`, `secundario.py`; `historico_ley_soc/` con `sim_soc.py`, `final.py`, `observaciones.py`, `analisis_reunion.py` |

### `referencias/`
- `documento_tesis_microredes_felipe.pdf`: documento de orientación de la propuesta (julio 2026), el único archivo subido al Proyecto.
- `documento_tesis_microredes_felipe.txt`: su texto, extraído para poder buscar en él.

## Verificación hecha
- Las 7 láminas y pautas que no dependen de figuras externas (16-nov v2, 16-nov v1, 9-nov v6, bloques, conjuntos, propuesta y pauta 9-nov v4) **compilan sin errores con XeLaTeX**, usando fondos de prueba en blanco.
- Los 7 scripts Python pasan la revisión de sintaxis. No se ejecutaron: necesitan `cvxpy`, `scipy`, `PPV.csv` o `escenario_out.npz`.
- `reunion_tesis_26oct_usach.tex` y `presentacion_tesis_espina.tex` no se compilaron porque usan figuras PDF que no están en el Proyecto (por ejemplo `esc_perfiles.pdf` y `In_dia4.pdf`). Esas figuras se generan con los scripts.

## Lo que NO se incluyó y por qué
1. **Versiones intermedias superadas** que siguen disponibles en el Proyecto de claude.ai, con su contenido incorporado en la versión final:
   - `laminas_reunion_9nov_v2.tex` a `v5.tex` → reemplazadas por la v6;
   - `pauta_reunion_9nov_v3.tex` y `pauta-reunion-9nov-v2.md` → reemplazadas por `pauta_reunion_9nov_v4.tex`;
   - `laminas_9nov.tex`, `lamina_unica_9nov.tex` y `lamina_niveles_control_9nov.tex` → borradores de la lámina única y del caso simple, que quedaron en la v6;
   - `presentacion_reunion_26oct.tex` → borrador con tema genérico de `reunion_tesis_26oct_usach.tex`, con el mismo contenido.
   Si las necesitas, pídelas y las agrego.
2. **Transcripciones completas de los chats.** Esta sesión solo puede leer las conversaciones de a pocos turnos, y suman más de 130 turnos con código y archivos. Para tenerlas íntegras: **claude.ai → Ajustes → Privacidad → Exportar datos**. Llega un `.zip` por correo; se puede dejar en `conversaciones/export_completo/`.
3. **Archivos que Felipe adjuntó en los chats pero no subió al Proyecto:**
   - `Modelos_ERNC.plecs`;
   - el modelo del convertidor DC;
   - `PPV.csv` (lo necesita `referencia_microred_dc.py`);
   - los fondos `fondo_usach_*.png` de la plantilla (el de contenido se puede extraer con `pdfimages -png` del PDF de las láminas del 9-nov);
   - `verificar_plecs.py` y `gen_plecs.py`, creados en el chat de simulación pero nunca guardados en el Proyecto;
   - el PDF de la tesis doctoral de Espina.
   Hay que copiarlos a mano: `PPV.csv` en `documentos/simulacion/` y los fondos en `documentos/presentaciones/fig/`.
4. **Memoria personal no relacionada con la tesis** (becas, pagos de docencia, plan de doctorado y otros proyectos), por privacidad y para no meter ruido en el contexto.

## Cambios del 17-nov-2026
**Agregado:**
- `documentos/correos/acta-reunion-16nov.md`: acta de la reunión del 16-nov que Felipe envió al profesor el 17-nov, transcrita literal, con la interpretación técnica de cada acuerdo y lo que falta. La acompaña su captura `acta-reunion-16nov_captura.png`.
- `documentos/presentaciones/laminas_reunion_16nov_v2.tex`: las 6 láminas presentadas el 16-nov, con la corrección del terciario.
- `documentos/pautas/guia_reunion_16nov_problema_terciario.md`: guía de la reunión, exportada del artifact de claude.ai.
- `documentos/simulacion/guia_simulacion_plecs.md`: guía paso a paso de la simulación, exportada del artifact. Las 3 imágenes y los 2 widgets del original quedaron como marcadores de texto.

**Actualizado:**
- `CLAUDE.md`: estado al 17-nov, terciario corregido, pendientes ordenados según el acta y próxima reunión probable el 23-nov.
- `CRONOLOGIA.md`: entradas del 13 al 17-nov, decisiones vigentes y obsoletas.
- `conversaciones/07_…`: turnos 25–43, del 13 al 16-nov.
- `conversaciones/00_indice_conversaciones.md` y `ENLACES.md`: enlaces a los artifacts y lecturas nuevas.

**Sin cambios:**
- `MicroRed_DC_Validacion.plecs`: idéntico byte a byte a la versión del Proyecto (SHA-256 `35a25690…`).

## Cambios del 19-nov-2026
**Agregado (material para la reunión del 23-nov, acuerdo A4 del acta):**
- `documentos/presentaciones/laminas_reunion_23nov.tex`: 7 láminas en la plantilla USACH (mismo formato que la v2 del 16-nov). Niveles actualizados, lazo rápido como política afín, modelo del error, factores de participación, energía en la trayectoria, LP completo y lazo rápido coherente. **No se compilaron en el equipo donde se escribieron (sin LaTeX); revisarlas visualmente al compilar.**
- `documentos/presentaciones/fig/fondo_usach_contenido.png`: fondo de contenido recuperado de `laminas_reunion_16nov_final.pdf`.
- `documentos/pautas/estudio_margen_error_terciario_lazo_rapido.md` (+ `.html`): matemática paso a paso del terciario y del lazo rápido, con derivaciones, ejemplo numérico, ejercicios con solución y referencias IEEE.
- `documentos/pautas/guia_reunion_23nov.md` (+ `.html`): guía de la reunión, orden de exposición, banco de preguntas, decisiones a pedir y lista de preparación.
- Los `.html` muestran el mismo contenido con las ecuaciones renderizadas al abrirlos en un navegador (requieren internet para cargar KaTeX y marked desde cdnjs).

**Actualizado:** `CLAUDE.md` (§1, nueva §2bis, fondos y pendiente A4) y `CRONOLOGIA.md` (entrada del 19-nov).
- `referencia_microred_dc.py`, `lecturas-terciario-10nov.md` y la memoria del Proyecto (`memoria/thesis-overview.md`, última actualización 10-nov). **La memoria todavía no refleja la reunión del 16-nov; el acta manda.**
