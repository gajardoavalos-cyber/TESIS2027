# Contexto maestro completo

Fuente original: `01_MASTER_CONTEXT_COMPLETO.txt` (versión consolidada julio de 2026).

## 2. Perfil técnico
Áreas de trabajo y estudio: sistemas eléctricos de potencia; electrónica de potencia; micro-redes; micro-redes híbridas AC/DC; convertidores electrónicos; control automático; sistemas de almacenamiento; servicios auxiliares de red; regulación de frecuencia y tensión; calidad de energía; modelado y simulación; proyectos eléctricos; normativa eléctrica chilena; tramitación SEC; alumbrado público; puesta a tierra; resistividad de terreno; memorias y especificaciones técnicas.

Software utilizado: PLECS; MATLAB; Simulink; LaTeX; AutoCAD; Excel; Power BI; PSIM; herramientas ofimáticas y de presentación.

## 5. Preferencias de respuesta
Felipe prefiere: explicaciones paso a paso; rigor matemático; claridad física; precisión técnica; referencias bibliográficas; referencias normativas; no omitir supuestos; distinguir claramente lo comprobado de lo inferido; documentos utilizables directamente; menos listas y más texto continuo en informes; nivel de magíster en materias académicas; lenguaje profesional para clientes y organismos públicos.

En documentos LaTeX: estructura completa; código listo para copiar; figuras integradas o con espacios claramente definidos; estilo académico; referencias IEEE; consistencia de símbolos; evitar adornos innecesarios; portadas limpias; buena calidad gráfica.

## 6. Convenciones importantes
- Usar "Micro-red" con guion.
- En la tesis de magíster, distinguir siempre red AC, convertidores y Micro-redes DC.
- No conectar directamente 0V_a, 0V_b y 0V_c al neutro común.
- No confundir PCC con neutro.
- Mantener variables por fase.
- Cuando una norma o requisito pueda haber cambiado, verificar antes de afirmar.
- En temas SEC, Enel, e-Declarador o normativos, priorizar documentos oficiales y versiones vigentes.
- En proyectos profesionales, diferenciar diseño, ejecución, inspección y declaración.

## 7. Datos técnicos recurrentes
Frecuencia nominal utilizada en PLECS: 50 Hz. Control por fase: fases a, b y c. Filtro notch: discreto, centrado en 2ω. Ganancia notch reportada: k = 20,9. Modelo de laboratorio: cuatro DG con control primario y secundario. Eventos típicos: conexión de carga en t = 1 s o impacto monofásico. Caso reportado: P_A,3 cambia de 4 kW a 8 kW.

Puesta a tierra: instrumento Sonel MRU-11; método de tres polos; mediciones mencionadas: 2,26 Ω, 16,76 Ω y 204 Ω según caso.

Infraestructura E2Tech: BPC 200 x 50 mm; BPC 100 x 50 mm; EMT 32, 40, 63 y 95 mm; conductor de unión o aterrizamiento de 21,2 mm² (nota: el archivo específico de E2Tech lo describe como valor *aproximado*; verificar contra memoria de cálculo si se usa como valor de diseño).

