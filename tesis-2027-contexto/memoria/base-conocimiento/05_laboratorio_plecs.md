# Laboratorio de Micro-redes, PLECS y deberes

Fuente original: `05_LABORATORIO_MICROREDES_PLECS_Y_DEBERES.txt`.

## 1. Modelo actual
El modelo incluye cuatro DG con: control primario por fase; control secundario por ángulo; cálculo de potencia activa por fase; notch adaptativo a 2ω; filtro de primer orden; activación con Switch/Memory; integradores angulares; referencias fa_ref, fb_ref y fc_ref; tensiones v_a*, v_b* y v_c*.

## 2. Frecuencia y muestreo
Frecuencia nominal: 50 Hz. El notch es discreto y debe centrarse en 100 Hz. Se reportó una ganancia k = 20,9. Los PI también son discretos y dependen del Ts del modelo.

## 3. Control primario
Principio: mayor potencia activa implica reducción de frecuencia según pendiente droop; cada fase tiene su propia señal; el cálculo de potencia debe eliminar el rizado a 2ω; el filtro pasa bajos reduce ruido y rizado residual.

## 4. Control secundario
Objetivo: eliminar error estacionario de frecuencia; modificar referencia angular; utilizar PI discretos; evitar lazos algebraicos mediante Unit Delay o Memory.

## 5. Resultados conocidos
Caso monofásico: escalón de potencia en fase A; P_A,3 cambia de 4 a 8 kW; cae f_a; aumenta potencia; el secundario recupera frecuencia; se observa corriente de neutro.

## 6. Errores resueltos
Se trabajó en: coeficientes de función de transferencia discreta; configuración de notch; variables de bloque; errores de compilación; algebraic loops; inicialización; uso de Goto/From globales; selección de señales.

## 7. Informe
Debe incluir: teoría; ecuaciones; planta; droop; notch; filtro; PI; sintonización; LGR; figuras; análisis de resultados.

## 8. Guía N.º 2
Está pendiente un desarrollo paso a paso equivalente al apoyo entregado en la experiencia 1.

## 9. Otros deberes
Sistemas Lineales Avanzados: controlabilidad; observabilidad; LQR; Riccati; observador; Beamer; LaTeX.
Integrantes: Luis Manzano, Cristian Ruiz y Felipe Gajardo.
Profesora: Ingeborg Mahla.

## 10. Pendientes
Archivo de parámetros; diagrama completo; tabla de señales; análisis de estabilidad; consolidación del informe; Guía N.º 2.
