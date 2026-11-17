# Pauta: lámina de niveles de control y caso simple, con su matemática

**Material:** `laminas_9nov.pdf`  
- **Lámina 1:** niveles de control en diagrama de bloques. Es la que pidió el profesor.  
- **Lámina 2:** caso simple, demanda alta prolongada en una fase.  

**Reunión:** lunes 9 de noviembre de 2026, con el Prof. Enrique Espina.

---

## Parte I. Cómo presentar la lámina 1 (≈ 3 min)

**Regla de lectura** (está escrita en la lámina):

- La **flecha gris que entra** a un bloque es lo que ese nivel **mide**.
- El **bloque** es lo que **decide**.
- La **flecha de color que sale** dice **a quién envía**.

**Recorrido sugerido, de arriba abajo por franjas:**

1. **Terciario (franja naranja, cada 15 min).**
   - **Mide:** pronósticos de clientes, FV y EV, la tarifa ②, $S_{h,\phi}$ en la cabecera y el SoC de cada micro-red.
   - **Envía:** el **rango de SoC** al secundario de cada micro-red ③ y el **plan** $P^*_k$, $Q^*_k$ al IC.
   - **Por aclarar:** la ventana $H$ es fija y falta elegir su duración ①.
2. **Lazo rápido (franja verde, segundos).**
   - **Mide:** $I_0$ e $I_2$ en la cabecera.
   - **Envía:** $\Delta P_k$, $\Delta Q_k$ al IC.
   - Corrige lo **medido**, no el plan.
   - **Por aclarar:** el camino de esa corrección hasta los IC ④.
3. **Secundario de cada micro-red (franja teal).**
   - **Mide:** $V_{dc}$ y el SoC de sus propios recursos.
   - **Envía:** referencias a sus DER.
   - Remarcar lo que está en rojo: **no ve la cabecera** y no coordina con otras micro-redes.
4. **Primario (franja azul).**
   - Los DER sostienen $V_{dc}$ con droop.
   - El IC sigue $P_{ref}=P^*_k+\Delta P_k$.
   - **Por aclarar:** si el IC también es grid-supporting en AC ⑤.

**Cierre de la lámina 1:** leer los cinco puntos por aclarar y pedirle su opinión en cada uno. Orden sugerido: ④ → ① → ③ → ⑤ → ②.

---

## Parte II. La matemática del caso simple (lámina 2)

### 1. Objetivo del caso

Responder la pregunta del profesor: **¿cuánto desbalance se puede corregir cuando las baterías no alcanzan a cubrir toda la ventana?**

### 2. Datos y supuestos

| Símbolo | Valor | Significado |
|---|---|---|
| $V$ | 230 V | Tensión fase–neutro en la cabecera (balanceada y rígida) |
| $D$ | 6 kW | Potencia **extra** que pide la fase $a$ respecto de $b$ y $c$ |
| $T$ | 4 h (18–22 h) | Duración del evento de demanda alta |
| $N_a$ | 2 | Micro-redes en la fase $a$ |
| $E_{\text{disp}}$ | 2 × 4 = 8 kWh | Energía que el **rango de SoC** deja usar en la fase $a$ |
| $P^{\max}_a$ | 2 × 3 = 6 kW | Potencia máxima de las baterías de la fase $a$ |
| $Q$ | 0 | Sin desbalance de reactivos (se aísla el efecto de $P$) |

### 3. Paso 1: corriente de neutro sin corrección

Las potencias por fase son $P_a=P_0+D$, $P_b=P_0$ y $P_c=P_0$, donde $P_0$ es lo común a las tres. Con la definición de $B$ de la propuesta (idea 2, Resultado 2):

$$B=\frac{1}{3V}\left(P_a+a^2P_b+aP_c\right)=\frac{1}{3V}\Big(P_0\underbrace{(1+a+a^2)}_{=0}+D\Big)=\frac{D}{3V}$$

Como $Q=0$, se tiene $C=0$, $I_0=B$ y

$$I_n=3|I_0|=\frac{D}{V}=\frac{6000}{230}=26{,}1\ \text{A}.$$

**Chequeo intuitivo:** si solo la fase $a$ lleva corriente extra, toda esa corriente extra ($D/V$) vuelve por el neutro. Coincide.

**Observación clave:** la parte común $P_0$ desaparece. **Solo importa la diferencia entre fases.**

### 4. Paso 2: con corrección

Sean:

- $x(t)$: potencia que **descargan** las baterías de la fase $a$, lo que reduce $P_a$;
- $y(t)$: potencia que **cargan** las baterías de $b$ y de $c$, igual en ambas, lo que aumenta $P_b$ y $P_c$.

Entonces $P_a=P_0+D-x$ y $P_b=P_c=P_0+y$. Al quitar la parte común $P_0+y$, la diferencia que queda es $D-x-y$, y por el mismo cálculo del paso 1:

$$\boxed{I_n(t)=\frac{D-x(t)-y(t)}{V}}$$

El balance completo exige $x+y=D$.

### 5. Paso 3: la energía fija el promedio

El rango de SoC limita la energía que la fase $a$ puede entregar en el evento:

$$\int_0^T x(t)\,dt\le E_{\text{disp}}=8\ \text{kWh}.$$

Para corregir todo solo con la fase $a$ ($x=D$) haría falta

$$E_{\text{nec}}=D\,T=6\cdot4=24\ \text{kWh}.$$

La fracción corregible es $E_{\text{disp}}/E_{\text{nec}}=8/24=\mathbf{1/3}$.

**El promedio no depende de la estrategia.** Como $I_n$ es lineal en $x$, si se usan los 8 kWh completos (con $y=0$):

$$\bar I_n=\frac{1}{T}\int_0^T\frac{D-x}{V}\,dt=\frac{D-E_{\text{disp}}/T}{V}=\frac{6000-2000}{230}=17{,}4\ \text{A}.$$

### 6. Paso 4: la forma de gastarla fija el pico y el RMS

**Estrategia A: corregir todo hasta agotarse.**

- Se descarga $x=\min(D,P^{\max}_a)=6$ kW mientras dure la energía: $t_A=E_{\text{disp}}/x=8/6=1{,}33$ h.
- Durante 1,33 h: $I_n=0$. Durante las 2,67 h restantes: $I_n=26{,}1$ A.
- Máximo: **26,1 A**. No mejora el pico.
- RMS:
$$I_{n,\text{RMS}}=\sqrt{\frac{0^2\cdot1{,}33+26{,}1^2\cdot2{,}67}{4}}=26{,}1\sqrt{\tfrac{2}{3}}=\mathbf{21{,}3\ A}.$$

**Estrategia B: repartir parejo.**

- $x=E_{\text{disp}}/T=8/4=2$ kW durante las 4 h. Es posible porque $2\le P^{\max}_a=6$ kW.
- $I_n=(6000-2000)/230=$ **17,4 A** constante, que es a la vez su máximo y su RMS.

**¿Por qué B es la mejor? (prueba corta)**

- Se quiere minimizar $J=\int_0^T (D-x)^2\,dt$, que es proporcional al RMS al cuadrado, sujeto a $\int_0^T x\,dt=E$.
- Por la desigualdad de Cauchy–Schwarz (o de Jensen):
$$\int_0^T (D-x)^2\,dt\;\ge\;\frac{1}{T}\Big(\int_0^T (D-x)\,dt\Big)^2=\frac{(DT-E)^2}{T},$$
y la igualdad se cumple **solo si $D-x(t)$ es constante**, es decir, si $x$ es constante: $x=E/T$.
- Lo mismo vale para el máximo: si $x$ no es constante, en algún momento $D-x$ supera su promedio, y por lo tanto el pico es mayor que con $x$ constante.
- **Conclusión:** repartir parejo minimiza el RMS **y** el pico. El costo del desbalance es **convexo**, y en problemas convexos conviene repartir parejo.

**Estrategia C: B más cargar en las fases livianas.**

- Además de $x=2$ kW en $a$, las baterías de $b$ y $c$ **cargan** $y=2$ kW cada una. Para eso necesitan margen hacia arriba en su rango: $y\,T=8$ kWh cada una.
- $I_n=(6000-2000-2000)/230=$ **8,7 A**.
- **Costo energético:**
$$\underbrace{2\cdot y\,T}_{\text{cargan } b,c}-\underbrace{x\,T}_{\text{descarga } a}=16-8=+8\ \text{kWh importados}.$$

### 7. Fórmula general (para el documento)

Con la estrategia pareja:

$$I_{n,\min}=\frac{1}{V}\max\Big\{0,\;D-\underbrace{\min\big(P^{\max}_a,\,E^{\text{des}}_a/T\big)}_{x}-\underbrace{\min\big(P^{\max}_{b},P^{\max}_{c},\,E^{\text{car}}_{b}/T,\,E^{\text{car}}_{c}/T\big)}_{y}\Big\}$$

Se lee así: **la corrección está limitada por la potencia o por la energía, la que sea menor**. Con eventos largos (T grande) manda la energía.

### 8. Consecuencia para la ventana $H$ (punto ① del correo)

- Si la ventana del terciario es más corta que el evento ($H<T$), el terciario no "ve" que la demanda alta sigue después y tiende a gastar la energía al principio. Eso equivale a la estrategia A.
- **Ejemplo:** con $H=1$ h a las 18:00, el terciario solo ve 1 h del evento. Lo óptimo dentro de esa hora es corregir al máximo (6 kW), y la energía se agota a las 19:20.
- **Criterio propuesto para justificar $H$:**
$$H\;\ge\;T_{\text{evento}}\quad\text{(duración del evento de demanda alta más largo que se quiere gestionar).}$$
- En una red residencial, la punta de la tarde dura entre 3 y 5 h, por lo que $H$ entre 4 y 6 h sería el orden de magnitud. **Hay que verificarlo con perfiles reales.**

### 9. Lo que el caso NO dice (honestidad)

- Supone la cabecera rígida y balanceada, y no considera pérdidas.
- Supone $D$ constante. Con $D(t)$ variable, lo óptimo es "aplanar" $D(t)-x(t)$ (técnica de llenado por nivel de agua, *water-filling*), no hacer $x$ constante.
- $Q=0$. Si los clientes también tienen desbalance de reactivos, ese sí se corrige con $Q$ sin gastar energía (Resultado 2).

---

## Parte III. Guion de la lámina 2 (≈ 3 min)

> "Supongamos que la fase $a$ pide 6 kW más que las otras durante 4 horas. Eso da 26 A por el neutro. Corregirlo entero exigiría 24 kWh, pero el rango de SoC de las micro-redes de esa fase deja 8. Entonces, haga lo que haga, solo puedo corregir un tercio del promedio: el neutro promedio queda en 17,4 A. Lo que sí elijo es **cómo** gastar esos 8 kWh. Si los gasto al principio, el pico sigue en 26 A. Si los reparto parejo, el neutro queda en 17,4 A todo el evento, y eso es óptimo porque el costo es convexo. Si además cargo baterías en $b$ y $c$, bajo a 8,7 A, pero importo 8 kWh más. **Para repartir parejo, el terciario tiene que ver el evento completo: de aquí sale el criterio para elegir la ventana: $H$ mayor o igual que el evento más largo.**"

## Parte IV. Preguntas probables

- **"¿Por qué no usar $Q$?"** Porque este desbalance es de potencia activa. $Q$ no reduce $B$ (Resultado 2); solo sirve si los clientes tienen desbalance de reactivos.
- **"¿Y si $D$ no es constante?"** Lo óptimo es aplanar $D(t)-x(t)$ hasta un nivel común (*water-filling*). La conclusión se mantiene: la energía fija el promedio y la forma de gastarla fija el pico.
- **"¿Quién decide entre B y C?"** El terciario, con el peso que le dé al desbalance frente a la energía importada (punto ②).
- **"¿Qué pasa si $E_{\text{disp}}$ alcanza?"** Si $E_{\text{disp}}\ge DT$ y $P^{\max}_a\ge D$, se corrige todo: $I_n=0$.
