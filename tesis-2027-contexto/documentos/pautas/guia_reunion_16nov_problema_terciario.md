# Guía para la reunión del 16-nov: el problema del terciario y lecturas

Nov 16, 2026 · @Felipe Salvador Gajardo Ávalos

## En 30 segundos

El terciario de la versión anterior trataba el desbalance que ya se conoce (los clientes monofásicos de la fase más cargada, que duran horas) como si fuera reserva para 15 minutos. El lazo rápido lo corrige durante horas y gasta energía de las BESS que el terciario nunca planificó. Es exactamente el conflicto que el profesor describió el 10-nov: "el terciario planifica con SoC que después se gasta".

La corrección separa dos cosas. La parte previsible del desbalance es **energía comprometida**: el terciario la anticipa y la deja disponible en la trayectoria de cada Micro-red. La parte imprevisible (el error del pronóstico, con media cero) es **reserva**. El objetivo del terciario sigue siendo solo energía y el lazo rápido sigue siendo el único que balancea.

## Orden de exposición (láminas v2)

| Lámina | Punto del correo | Qué decir, en simple | Tiempo |
| --- | --- | --- | --- |
| 1. Qué pidió el correo | todos | "Ordené la presentación según los 4 puntos de su correo y los 3 entregables." Es el índice. | 1 min |
| 2. Niveles | 1 y 2 (entregable 1) | Qué mide, qué decide y a quién informa cada nivel. El lazo rápido solo le habla a los IC. | 2 min |
| 3. El problema | 2 | Lo que dice el correo: los dos niveles perseguían el balance (dos choferes con un volante). Y lo que hay que cuidar: el margen debe estar también en energía, porque el desbalance dura horas (gráfico). | 3 min |
| 4. Roles separados | 2 y 3 | Terciario = energía + asigna margen; lazo rápido = balance usando solo ese margen. Si una MR se equivoca, consume margen. | 3 min |
| 5. Terciario | 2 y 3 (entregable 2) | Leer en orden: envolvente que recibe, objetivo (solo energía), reserva que asigna (a)–(d). | 4 min |
| 6. Lazo rápido | 1 y 4 (entregable 3) | Qué mide, cómo calcula la corrección por fase, cómo la reparte entre los IC. Q no va primero. | 2 min |
| 7. Decisiones | — | Pedirle que decida las 3 preguntas; mostrar el avance de PLECS. | resto |
| R1 y R2 | 2 y 3 | Solo si pregunta por los números. | — |

## La idea en ecuaciones (para defenderla de memoria)

Error que verá el lazo rápido en la fase φ, si el plan es P\*:

```latex
\hat e_\phi=\hat D_\phi-\left(S_\phi-\bar S\right),\qquad S_\phi=\sum_{k\in\mathcal N_\phi}P^*_k,\qquad \bar S=\tfrac13\sum_\psi S_\psi
```

El terciario reparte esa corrección entre las Micro-redes de la fase, con un residual acotado:

```latex
\sum_{k\in\mathcal N_\phi}\hat y_k=\hat e_\phi-\rho_\phi,\qquad |\rho_\phi|\le\bar\rho
```

Las envolventes de potencia y energía se aplican a lo que el IC hará en promedio, no solo al plan:

```latex
\tilde P_k=P^*_k+\hat y_k,\qquad W^{\min}_k+r^{\downarrow}_k\tau+\bar\varepsilon_k\le\sum_{s\le t}\tilde P_k\,\Delta t\le W^{\max}_k-r^{\uparrow}_k\tau-\bar\varepsilon_k
```

La reserva se dimensiona solo con el error del pronóstico:

```latex
\sum_{k\in\mathcal N_\phi}r^{\uparrow}_k\ge z\,\sigma_\phi+m
```

Tres propiedades que conviene saber decir:

- **No cambia la compra total.** Como la suma de los errores de las tres fases es cero, la suma de las correcciones también lo es. El balance no se paga en energía comprada; se paga en SoC de las Micro-redes de la fase cargada.
- **Todo es lineal.** La compra positiva se escribe con una variable auxiliar g ≥ 0 y g ≥ demanda − ΣP\*. El problema sigue siendo un LP.
- **Límite físico.** Una BESS solo compensa la parte del desbalance con media diaria cero. Si la fase a es la más cargada todos los días, la compensación necesita excedente FV en esa fase. Si no lo hay, queda un residual acotado. Esto es "verdad cruda" y conviene decirlo antes de que él lo note.

## Preguntas probables y respuestas

**"¿No estás metiendo el balance de vuelta en el terciario?"** No en el objetivo. Es una restricción de consistencia: el terciario no puede prometer una trayectoria de SoC que el lazo rápido va a cambiar. El lazo rápido sigue siendo el único que actúa sobre el balance; el terciario solo le deja la energía.

**"¿Por qué no basta con una reserva más grande?"** Porque la reserva está en kW y no dice cuántos kWh. El desbalance de la tarde dura 4 h; con 15 min de margen la BESS se agota a mitad de camino (respaldo R1: a las 20:40).

**"¿Y si no alcanza la energía?"** El LP lo dice con hasta 12 h de anticipación: la parte que no cabe sale como residual ρ acotado. Hoy aparecería sin aviso.

**"¿Cómo obtienes el desbalance previsto sin medir clientes?"** La demanda no gestionada de cada fase es la potencia medida en la cabecera más lo que inyectan sus IC. Con eso se arma un perfil conocido y su error histórico σ (el "pronóstico simple" que él pidió). Es el indicador que sugirió el 9-nov.

**"¿El lazo rápido sigue sumando cero si se satura?"** No. Si una fase satura, la compra total cambia. Por eso la reserva se asigna por fase y, con la corrección, la saturación debería ser rara. Es un caso que hay que mostrar en simulación.

**"¿Y la potencia reactiva?"** Fuera por ahora: en BT R > X y, por el Resultado 2, Q no reduce el desbalance de potencia activa.

## Lecturas antes de las 17:00 (en este orden)

Con poco tiempo, lee solo el resumen y la formulación de las dos primeras. Las demás son para la semana.

| # | Paper | Por qué sirve para esta reunión | Qué leer |
| --- | --- | --- | --- |
| 1 | Warrington, Goulart, Mariéthoz, Morari, "Policy-based reserves for power systems", IEEE TPWRS 28(4), 2013. [arXiv](https://arxiv.org/abs/1212.2119) | Es la base formal de la corrección: un programa nominal más una respuesta planificada al error, con la energía del almacenamiento contabilizada desde el plan. Respalda la frase "lo previsible es energía; el error, reserva". | Resumen, introducción y la sección donde define las políticas afines (10 min) |
| 2 | Sun, Liang, Dong, Taylor, "Phase balancing using energy storage in power grids under uncertainty", IEEE TPWRS, 2016. [arXiv](https://arxiv.org/pdf/1505.03187) | Es casi tu escenario: una subestación con fases que tienen cargas, generación y almacenamiento monofásicos; minimiza costo y balancea las fases. Muestra que en este tipo de red el balance y la energía quedan acoplados a través del almacenamiento. | Resumen, introducción y formulación del problema (10 min) |
| 3 | Müller, Szabo, Sundström, Lygeros, IEEE TSG 2019 (envolventes de flexibilidad). [arXiv](https://arxiv.org/pdf/1705.02815) | Respalda la envolvente que informa cada Micro-red. | Figura de la envolvente y su definición (5 min) |
| 4 | Nasrolahpour, Kazempour, Zareipour, Rosehart, IEEE TSTE 2017 (energía + reserva con almacenamiento). [PDF](https://core.ac.uk/download/86558459.pdf) | Por qué una reserva de almacenamiento necesita margen de energía, no solo de potencia. | Restricciones de SoC con reserva |
| 5 | Bustos, Marín, Navas-Fonseca, Reyes-Chamorro, Sáez, Applied Energy 342, 2023. [Enlace](https://ideas.repec.org/a/eee/appene/v342y2023ics0306261923005093.html) | Grupo de la U. de Chile (línea de Sáez, cercana al profesor). | Arquitectura jerárquica |

El resto de la lista del 10-nov (Mexis, Liu, Hans, Palma-Behnke, Parisio, Pinthurat, Olivares) sigue vigente para después.

## Lo que no está verificado

- La corrección no está simulada todavía. El ejemplo de la lámina R1 es un cálculo a mano (6 kWh disponibles, 1,5 kW durante 4 h).
- No sé si el profesor aceptará la restricción (a) en el terciario o preferirá otra forma de separar roles. Por eso la lámina 6 se lo pregunta en vez de darlo por cerrado.
