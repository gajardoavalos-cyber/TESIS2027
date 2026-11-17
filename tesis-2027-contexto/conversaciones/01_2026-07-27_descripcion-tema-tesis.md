# Descripción del tema de tesis

- **Enlace:** https://claude.ai/chat/d6302b91-e616-478b-aa30-cbbb8c2f90e8
- **Última actualización:** 27-jul-2026

## Pedido de Felipe
1. Describir el tema de tesis a partir del documento de contexto `documento_tesis_microredes_felipe.pdf` (en `referencias/`).
2. Recomendar literatura científica con enlaces directos.
3. Proponer cómo empezar a simular en PLECS para observar el comportamiento real del sistema.

## Lo que se trabajó
- **Tema (versión inicial):** control por fase de una Micro-red híbrida AC/DC conectada a una red trifásica de cuatro hilos existente. Tres IC monofásicos independientes (IC_a, IC_b, IC_c), cada uno acoplado a su propia Micro-red DC (DC-MR_a, DC-MR_b, DC-MR_c), **sin barra DC común**.
- **Problema central:** regular bien el bus DC de cada fase puede producir potencias distintas por fase, lo que en el lado AC aparece como corriente de neutro, VUF y secuencia cero. Cada Micro-red DC tiene FV, BESS, EV/V2G y cargas DC, así que el SOC por fase es una restricción energética.
- **Bibliografía:** hoja de lectura en cinco líneas convergentes. Referencias R1–R10 del documento de Felipe más R11–R19 nuevas, con enlaces (se distinguió acceso libre de acceso institucional IEEE Xplore).
- **Estrategia PLECS en 4 pasos:** de un modelo energético promedio de una rama a un sistema de tres ramas asimétrico con métricas de desbalance. Se conectó con la experiencia previa de Felipe en droop, notch adaptativo a 2ω y sintonía de PI discretos.
