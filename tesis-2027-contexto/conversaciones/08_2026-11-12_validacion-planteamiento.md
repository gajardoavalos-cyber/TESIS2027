# Validación del planteamiento de micro-redes

- **Enlace:** https://claude.ai/chat/33b1576a-e642-4a13-a92e-22ec9c510899
- **Última actualización:** 12-nov-2026 · 28 turnos

## Turno 0: correo del Prof. Espina (2-nov-2026) con las respuestas de Felipe (textual)

> Hola Felipe,
>
> Antes de seguir con la propuesta, quiero comprobar que vemos el problema de la misma forma. Indíqueme sí o no en cada punto. Si es no, explique brevemente cómo lo entiende. Por ahora, no cambie la presentación.
>
> 1. Trabajamos con un alimentador de distribución de baja tensión, trifásico de cuatro hilos. **(Sí)**
> 2. El alimentador ya opera desbalanceado por clientes monofásicos sin gestión, y ese desbalance varía durante el día. **(Sí)**
> 3. Las unidades DER, como PV, BESS y EV, forman junto con las cargas una micro-red DC residencial. Cada micro-red tiene una cantidad distinta de cada recurso. **(Sí. A priori, en la presentación no había incluido las unidades EV en las ecuaciones; pensaba verlo como una extensión si el planteamiento estaba correcto.)**
> 4. Cada micro-red se conecta a una sola fase mediante un IC monofásico, y el número de micro-redes puede ser distinto en cada fase (Na, Nb y Nc). **(Sí)**
> 5. Las micro-redes no comparten una barra DC, así que solo intercambian energía a través del alimentador. **(Sí)**
> 6. Los DER operan como grid-supporting. **(Sí, aunque tengo algunas dudas de cómo interactuaría el sistema completo conectado a la red.)**
> 7. Cada micro-red tiene su propio control secundario, que regula la interacción entre sus DER. Ese nivel también cuida los límites de cada BESS y EV. **(Sí. En un principio pensaba el sistema sin EV, no por no querer incorporarlo, sino para validar en primer lugar el sistema sin EV. De todas formas creo que es importante incorporarlo.)**
> 8. El control terciario regula el intercambio con la red principal y asigna las consignas a los IC. Busca minimizar la compra de energía y que ese intercambio sea equilibrado entre fases. **(Sí)**
> 9. El terciario se actualiza cada 15 minutos con pronósticos y una ventana de predicción que puede ser menor a 24 h. **(No. Se podría dejar el terciario con predicciones menores a 24 h, pero hasta el momento lo había pensado como valor fijo.)**
>
> Ideas nuevas, todavía en discusión:
> - **Idea 1.** Cada 15 minutos, además de un plan de potencia, el terciario entrega a cada micro-red un rango de SoC, en lugar de una consigna fija para todo el intervalo. **(Sí. Entiendo que esto ayudaría a regular la energía que entregan las baterías grandes respecto de las pequeñas, en proporción a su tamaño. También puede limitar el balance si en una ventana prolongada de alta demanda las baterías no alcanzan. Lo investigaré.)**
> - **Idea 2.** Dentro de esos 15 minutos, un lazo más rápido usa el margen de ese rango para corregir en segundos el desbalance medido en la cabecera. Cómo hacerlo está por definir. **(No del todo. Lo entiendo como una concatenación entre el terciario y los controles secundarios por fase para corregir la desviación de la predicción dentro de los 15 minutos.)**

**Observaciones de Claude antes del envío:**
- En el punto 9, el "No" deja implícito que Felipe está de acuerdo con la actualización cada 15 min; conviene decirlo.
- En la idea 2, el profesor habla de corregir el **desbalance medido en cabecera**, no la **desviación del plan**.
- "Secundarios por fase" contradice el punto 7, donde el secundario es **por Micro-red**.
- Repartir en proporción al tamaño de la batería es una hipótesis de Felipe, no algo que dijera el profesor.

## Lo que siguió en la conversación
1. **Lámina para el 9-nov,** según lo conversado con el profesor (versiones v2–v6 de `laminas_reunion_9nov`, más la pauta v3/v4). La versión final es `documentos/presentaciones/laminas_reunion_9nov_v6.tex` + `documentos/pautas/pauta_reunion_9nov_v4.tex`.
2. **Reunión del 9-nov.** Espina visó en gran medida la presentación. Se confirmó que los **IC son grid-following** en AC. Próximo paso aprobado: simular la validación de una Micro-red DC con primario y secundario, y luego su conexión a la red. Pendiente: nuevos indicadores para el terciario.
3. **Correo del 10-nov** (reformular la arquitectura):
   - el lazo rápido actúa solo sobre los IC;
   - objetivos separados: el terciario se encarga de la energía y la reserva; el lazo rápido, del balance;
   - cada MR informa una envolvente (P_min, P_max, W_min, W_max);
   - basta un pronóstico simple;
   - el lazo rápido se formula por fase e iguala las potencias por fase;
   - hay que revisar si conviene usar Q primero en BT, donde R > X.
   Ver `documentos/pautas/lecturas-terciario-10nov.md` (v3) y `memoria/thesis-overview.md`.
4. **Láminas para el 16-nov** (`documentos/presentaciones/laminas_reunion_16nov.tex`):
   - niveles actualizados;
   - formulación del terciario (solo energía, envolvente, reserva por fase, LP);
   - regla del lazo rápido (PI con salida en kW y anti-windup, normalización u_φ, reparto ΔP_k = u_φ·r_k);
   - respaldo con un ejemplo numérico de envolvente.
   - **Corrección v3 (12-nov):** el PI debe entregar ΔP_φ en kW y normalizar después; si se aplica sobre u_φ, Σ_φ ΔP_φ = 0 solo se cumple con reservas iguales por fase.
