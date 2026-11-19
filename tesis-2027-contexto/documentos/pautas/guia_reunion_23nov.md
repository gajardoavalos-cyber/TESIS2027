# Guía para la reunión del 23-nov: margen de error del terciario y lazo rápido

Lunes 23-nov-2026, 17:00, Laboratorio E2Tech (fecha probable por la regla semanal; el acta del 16-nov no la fija). Con: Prof. Enrique Espina, Bernhardt Gotschlich e Ignacio Staforelli.

Material:
- Láminas: `presentaciones/laminas_reunion_23nov.tex`, 8 láminas (versión 2 del 19-nov, rehecha tras revisar el PDF compilado).
- **Documento principal de estudio:** `pautas/documento_formulacion_terciario_lazo_rapido.md`, con la matemática, la explicación en simple, el glosario completo, el PI y el anti-windup, y las decisiones a validar.
- Versión en simple: `pautas/explicacion_pedagogica_margen_error.md`.
- Estudio paso a paso, versión anterior: `pautas/estudio_margen_error_terciario_lazo_rapido.md`.
- Acuerdos que se responden: `correos/acta-reunion-16nov.md`, acuerdo A4.

---

## En 30 segundos

El lazo rápido de cada fase es una **política afín de reserva con matriz diagonal**: el plan del terciario más una fracción fija $\alpha_k$ de la corrección de la fase. Es el mismo objeto que la reserva secundaria clásica, con factores de participación (Warrington et al., 2013).

Escribirlo así deja acabada el álgebra del margen:
- **Margen de potencia por fase:** $R^{\varepsilon}_\phi=q_{1-\varepsilon}(\xi_\phi)+m$, con el cuantil del error del pronóstico simple.
- **Reparto entre MR:** $\hat y_k=\alpha_k b_\phi$ y $r_k=\alpha_k R^{\varepsilon}_\phi$, con $\alpha_k\propto E_k$ (mismo $\Delta$SoC).
- **Energía:** el margen crece con el horizonte, $Z_\phi(t)=(z\sigma_\phi\sqrt{f(t+1)}+m)\Delta t$. En el primer tramo vale $R^{\varepsilon}\Delta t$, así que el antiguo $\tau$ es $\Delta t$.
- **Banda del PI:** $b_\phi\pm R^{\varepsilon}_\phi$, no $\pm\sum r_k$.

El terciario sigue siendo un LP con solo energía en el objetivo.

---

## Estado de los acuerdos del 16-nov

| Acuerdo | Estado al 19-nov | Qué decir |
|---|---|---|
| A1. MR DC con primario y secundario validada | Cerrado | – |
| A2. IC conectado a una fuente de 50 Hz, sin fallas | **Pendiente.** `MicroRed_DC_Validacion2.plecs` reorganiza la planta, pero aún no tiene lado AC (sin PLL, fuente sinusoidal ni filtro). | Decir el avance real. No mostrar nada que no corra. |
| A3. Flujos de potencia DC y AC del IC | **Pendiente** (depende de A2) | Ídem |
| A4. Álgebra del margen de error y formulación acabada | **Láminas 2 a 8** | Es el centro de la reunión |

Si A2 avanza antes del lunes, agregar una lámina con la simulación (escalón de $P_{\mathrm{ref}}$, $P_{dc}$ frente a $P_{ac}$, $Q_{ac}\approx0$, rizado de 100 Hz en $V_{dc}$). Si no avanza, decirlo de entrada y comprometer una fecha.

---

## Orden de exposición

| Lámina | Qué decir, en simple | Tiempo |
|---|---|---|
| 1. Niveles | Lo mismo de siempre, con dos cambios: el terciario envía $P^{\ast}_k$ y $\alpha_k$ a cada IC, y $b_\phi$, $\rho_\phi$ y $R^{\varepsilon}_\phi$ al lazo. El IC sigue $P^{\ast}_k+\alpha_k\Delta P_\phi$. | 2 min |
| 2. Dos tipos de desbalance | Lo previsible (6 kWh de 18 a 22 h) se aparta como energía; el error, como margen. Antes todo era margen de 15 min y la BESS se agotaba a las 20:40. Los roles no cambian. | 3 min |
| 3. Plan + reacción proporcional | El IC hace $P^{\ast}_k+\alpha_k\Delta P_\phi$: política afín, como la reserva secundaria clásica. Tabla: con reparto libre se rompe el plan; con $\alpha_k\propto E_k$ todas bajan 24 % de SoC. | 4 min |
| 4. Modelo del error | Pronóstico simple → error histórico → margen al 99 %. Cuantil empírico (precedente FRR europea). Qué cubre $m$. Ejemplo: 1,37 kW. | 3 min |
| 5. Margen de energía | El error se acumula; fórmula $f(n)$; gráfico (0,34 frente a 3,04 kWh a las 4 h); $\tau=\Delta t$. | 4 min |
| 6. LP completo | Variables, parámetros, objetivo y (0) a (e). Todo lineal porque $\alpha_k$, $R$ y $Z$ son datos. | 3 min |
| 7. Lazo rápido | Diagrama: error de la fase → $-\rho_\phi$ → PI saturado en $b\pm R$ con anti-windup → $\times\alpha_k$ → IC. Tres recuadros: banda, compra, forma equivalente. | 3 min |
| 8. Decisiones | Recorrer la tabla y anotar qué acepta y qué cambia. | resto |

---

## Ecuaciones para saber de memoria

```math
e_\phi=P_{h,\phi}-\bar P_h=D_\phi-(S_\phi-\bar S)=\hat e_\phi+\xi_\phi,\qquad \textstyle\sum_\phi e_\phi=0
```

```math
P_{\mathrm{IC},k}=P^{\ast}_k+\alpha_k\Delta P_\phi,\qquad \hat y_k=\alpha_k b_\phi,\qquad r_k=\alpha_kR^{\varepsilon}_\phi,\qquad \alpha_k=\frac{E_k}{\sum_j E_j}
```

```math
R^{\varepsilon\uparrow}_\phi=q_{1-\varepsilon}(\xi_\phi)+m\quad(\text{gaussiano: }z\sigma_\phi+m)
```

```math
Z_\phi(t)=\big(z\sigma_\phi\sqrt{f(t+1)}+m\big)\Delta t,\qquad f(n)=\frac{n(1+a)}{1-a}-\frac{2a(1-a^n)}{(1-a)^2}
```

```math
\Delta P_\phi\in[\,b_\phi-R^{\varepsilon\downarrow}_\phi,\ b_\phi+R^{\varepsilon\uparrow}_\phi\,],\qquad u_\phi=\frac{\Delta P_\phi-b_\phi}{R^{\varepsilon}_\phi}\in[-1,1]
```

Tres números del ejemplo, con $\sigma=0{,}5$ kW, $z=2{,}33$ y $m=0{,}2$ kW:
- $R^{\varepsilon}=1{,}37$ kW;
- $Z$ a las 4 h: $1{,}22$ kWh con $a=0$ y $3{,}04$ kWh con $a=0{,}8$;
- MR$_1$ ($\alpha=0{,}4$): $3{,}6$ kWh apartados, frente a los $0{,}14$ kWh de $r\tau$.

---

## Banco de preguntas y respuestas

**1. "¿Por qué una política afín y no otra cosa?"**
Porque es lo que el lazo ya hace: un PI con reparto fijo es una respuesta lineal al error. Escribirlo así permite al terciario saber de antemano cuánta energía y potencia va a gastar el lazo. Warrington lo muestra para reservas en sistemas de potencia; la diagonal es la reserva secundaria clásica.

**2. "¿No estás metiendo el balance en el terciario otra vez?"**
No en el objetivo, que sigue siendo solo compra. El terciario aparta la energía que el lazo va a usar; el único que balancea es el lazo. (a) y (b) son restricciones de consistencia, no un costo de desbalance.

**3. "¿Por qué fijas $\alpha_k$ y no lo optimizas?"**
Si $\hat y_k$ y $r_k$ son libres por separado, el lazo, que reparte en proporción fija, no ejecuta lo planificado; para forzarlo hace falta $\hat y_kR_\phi=r_kb_\phi$, que es bilineal. Con $\alpha_k$ fijo el problema sigue siendo LP. Optimizarlo con LP secuencial es una extensión.

**4. "¿Por qué proporcional a $E_k$?"**
Porque iguala el $\Delta$SoC de todas las MR de la fase: $\Delta\mathrm{SoC}_k=\Delta E_\phi/\sum_j E_j$. Ninguna se agota antes.

**5. "¿De dónde sale $\sigma_\phi$ si no tienes datos?"**
Del historial del error del pronóstico naive estacional, por hora del día. Hoy no hay datos del alimentador; propongo perfiles sintéticos (por ejemplo, el alimentador europeo de BT de IEEE) para estimar $\sigma$ y $a$. Decirlo como supuesto.

**6. "¿Por qué no asumir gaussiano y listo?"**
Se puede, y da $z=2{,}33$ al 1 %. Pero el error de demanda suele ser asimétrico y de colas pesadas. El cuantil empírico no supone forma y tiene precedente: la FRR europea cubre el 99 % de los desbalances históricos. Cantelli (sin supuesto) da $9{,}95\sigma$, demasiado conservador.

**7. "¿Qué es $m$ exactamente?"**
Lo que no ve el promedio de 15 min: la variación dentro del tramo, más la medida y el seguimiento del PI. Se estima con datos de 1 min.

**8. "¿Por qué el margen de energía crece con el tiempo? ¿No se re-planifica cada 15 min?"**
Sí, y por eso en el primer tramo basta con $R\cdot\Delta t$. Pero el plan de los tramos siguientes tiene que seguir siendo alcanzable: si el error persiste, la energía ya gastada no vuelve. Por eso propongo simular las dos variantes (solo el primer tramo frente a creciente) y elegir con datos.

**9. "¿Qué pasó con $\tau$?"**
Era la duración supuesta de la reserva. Con la política afín y re-planificación cada 15 min, $\tau=\Delta t$: no es un parámetro libre.

**10. "¿Por qué la banda del PI no es $\pm\sum r_k$?"**
Porque el lazo también entrega lo previsible $b_\phi$, que puede superar el margen del error (1,5 frente a 1,37 kW en el ejemplo). Con $\pm\sum r_k$ quedaría saturado todo el evento. Con $b_\phi\pm R^{\varepsilon}_\phi$, $u_\phi=0$ en lo nominal y $|u_\phi|\le1$ con probabilidad $1-\varepsilon$.

**11. "¿El balance cambia la compra?"**
Con $\sum_\phi\rho_\phi=0$ y sin saturación, no: $\sum_\phi\Delta P_\phi=0$. Si una fase se satura, sí. Por eso la compra del LP se escribe con $\tilde P$, y es el caso que hay que mostrar en simulación.

**12. "¿Qué pasa si no alcanza la energía?"**
El LP lo detecta con hasta 12 h de anticipación: aparece un residual $\rho$ o, si supera $\bar\rho$, una holgura penalizada que funciona como alarma. Una BESS solo compensa la parte del desbalance con media diaria cero (piso energético); lo demás es diseño, no control.

**13. "¿Por qué agregas una condición al final del horizonte?"**
Sin ella, el LP no valora la energía después de 12 h y tiende a vaciar las baterías al final. Es la miopía típica del horizonte finito.

**14. "¿Cómo sintonizas el PI?"**
Primer paso: la planta, en el subespacio de suma cero, tiene ganancia unitaria. Con cancelación polo-cero del IC, el lazo cerrado es de primer orden con constante $1/K_i$ de 5 a 10 s. Queda por validar en PLECS cuando el IC tenga lado AC.

**15. "¿Por qué un PI y no solo un proporcional?"**
Porque necesito error permanente cero. Con solo P queda $d/(1+K_p)$ sin corregir; el integrador sigue actuando hasta que la fase iguala al promedio (o al residual aceptado $\rho_\phi$).

**16. "¿Qué es el anti-windup y por qué lo necesitas?"**
Cuando la salida del PI llega al límite de la banda, el error no baja, pero el integrador lo sigue acumulando y se "infla". Al volver el margen, el lazo se queda pegado al límite mientras desacumula, empujando en la dirección equivocada (unos 60 s en el ejemplo del documento). El anti-windup por retrocálculo descuenta del integrador lo que no se pudo aplicar ($K_{aw}=1$). Además, cuando $b_\phi$ cambia cada 15 min, desplazo el integrador en la misma cantidad para que no haya saltos. Detalle en la sección 13 del documento principal.

---

## Decisiones que conviene pedirle

1. ¿$\hat y_k$ se envía al IC como **prealimentación**, o el PI lo alcanza por integración?
2. ¿Acepta $\alpha_k\propto E_k$, o prefiere otro criterio?
3. ¿Qué **nivel de riesgo** $\varepsilon$? ¿Acepta el cuantil empírico al estilo de la FRR europea?
4. ¿Margen de energía **solo en el primer tramo** o **creciente** (o simular ambos)?
5. ¿De dónde debe salir $\bar\rho$: una norma de desbalance o un criterio de diseño?
6. ¿Confirma que el IC no regula $V_{dc}$ (lo hacen la BESS y el secundario) al conectar el lado AC?

---

## Lista antes del lunes

- [ ] Compilar las láminas con XeLaTeX (dos pasadas) y revisar que nada se salga de los recuadros.
- [ ] Leer el estudio (secciones 3, 4, 6 y 9 primero) y hacer los ejercicios E1, E3 y E5 a mano.
- [ ] Repasar de memoria las cinco ecuaciones de arriba y los tres números del ejemplo.
- [ ] Leer [Warrington et al.](https://arxiv.org/abs/1212.2119): resumen, secc. 3.1 y 4.2–4.3 (20 min).
- [ ] Leer [Bienstock et al.](https://arxiv.org/abs/1209.5779): solo la parte de factores de participación y la reformulación con $z\sigma$ (15 min).
- [ ] Decidir qué decir sobre A2/A3 (avance real del IC con lado AC).
- [ ] Llevar impresa la lámina 6 (LP completo) para anotar lo que diga el profesor.

---

## Lo que no está verificado

- Nada de la nueva formulación está simulado; los números son un ejemplo a mano con supuestos ($\sigma$, $a$, $E_k$).
- Las láminas no se compilaron en este equipo, que no tiene LaTeX instalado. Están escritas sobre la plantilla de la v2 del 16-nov, que sí compilaba, pero hay que revisarlas visualmente.
- No se sabe si el profesor aceptará fijar $\alpha_k$ o el cuantil empírico. Por eso van como preguntas, no como decisiones cerradas.
- La cita "Nasrolahpour et al., IEEE TSTE 2017" de la guía del 16-nov parece estar mal: lo que se encontró de esos autores es un paper en IEEE TSG sobre otro tema. No usarla hasta verificarla.
