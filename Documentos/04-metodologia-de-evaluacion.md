# SIIS-PcD · Metodología de evaluación

**Plantilla de preregistro · v0.1 · Noviembre de 2026**

Estado: **borrador con huecos deliberados**. Los campos marcados `[FIJAR]` solo pueden rellenarse después de medir el procedimiento actual de la entidad (línea base). Ningún umbral de este documento es válido hasta que esté completado y fechado **antes** del pilotaje.

## 1. Reglas de preregistro

1. Todas las definiciones, denominadores, ventanas temporales y reglas de decisión se fijan antes de introducir el prototipo y quedan archivadas con fecha (commit de Git etiquetado, por ejemplo `prereg-v1`).
2. Después de esa fecha no se cambian umbrales. Si hay que cambiarlos, se crea una versión nueva y se documenta el motivo.
3. Los resultados nulos o negativos se publican con el mismo detalle que los positivos.
4. Con muestras pequeñas no se hace contraste de hipótesis. Se informa de valores individuales y medianas, y los resultados se presentan como evidencia de viabilidad, no como prueba de eficacia (apartado 5).

## 2. Procedimiento de referencia

Descripción de cómo localiza hoy la entidad recursos y oportunidades, registra derivaciones y hace el seguimiento de los itinerarios.

| Elemento | Descripción |
|---|---|
| Herramientas y fuentes actuales | `[FIJAR]` |
| Quién lo hace y con qué tiempo asignado | `[FIJAR]` |
| Registro actual (papel, hoja de cálculo, otro) | `[FIJAR]` |
| Periodo de medición de línea base | `[FIJAR]` (fecha de inicio y fin) |
| Número de casos o tareas de la línea base | `[FIJAR]` |

## 3. Hipótesis

Cada hipótesis sigue la misma ficha. La regla de decisión y la de refutación se escriben antes de ver datos.

### H1 · Tiempo de localización

| Campo | Contenido |
|---|---|
| Enunciado | El sistema reduce el tiempo necesario para localizar recursos adecuados. |
| Medida | Minutos por tarea-tipo, cronometrados por el profesional. Las tareas-tipo son las mismas en línea base y pilotaje (por ejemplo, «localizar una oportunidad compatible con el perfil X»). |
| Unidad de análisis | Tarea-tipo, con el profesional que la realiza identificado. |
| Valor de línea base | `[FIJAR]` (mediana y rango) |
| Mínimo relevante | `[FIJAR]` (reducción que la entidad considera que merece la pena) |
| Regla de decisión | Se sostiene si la mediana del pilotaje baja al menos el mínimo relevante respecto a la línea base, sin que empeore la pertinencia (H2). |
| Refutación | La mediana no baja el mínimo relevante, o sube. |
| Confusores a registrar | Experiencia del profesional, complejidad del perfil, aprendizaje de la herramienta. |

### H2 · Pertinencia de las correspondencias

| Campo | Contenido |
|---|---|
| Enunciado | Las propuestas del sistema son al menos tan pertinentes como las del procedimiento habitual. |
| Medida | Valoración estructurada de 1 a 5 (tabla `valoracion_correspondencia`), con rúbrica escrita y fijada antes. |
| Diseño | Propuestas del sistema y del procedimiento habitual para los mismos perfiles, mezcladas y valoradas, si es posible, por un profesional que no sabe cuál es cuál. |
| Rúbrica | `[FIJAR]` (qué significa cada nivel) |
| Regla de decisión | Se sostiene si la mediana de pertinencia del sistema no es inferior a la de referencia y la proporción de propuestas valoradas con 4 o más alcanza `[FIJAR]`. |
| Refutación | La mediana del sistema es inferior, o la proporción de propuestas de 4 o más queda por debajo del umbral. |
| Control adicional | Proporción de requisitos marcados «pendiente de verificar» que resultan relevantes al comprobarlos (calidad de la incertidumbre declarada). |

### H3 · Derivaciones efectivas

| Campo | Contenido |
|---|---|
| Enunciado | Aumenta la proporción de derivaciones que culminan en procesos de selección. |
| Medida | Derivaciones atendidas o con entrevista / derivaciones realizadas. Se informa siempre con numerador y denominador, no solo con porcentaje. |
| Ventana | Cada derivación se sigue durante `[FIJAR]` días desde su fecha. |
| Valor de línea base | `[FIJAR]` |
| Regla de decisión | Se sostiene si la proporción sube al menos `[FIJAR]` puntos porcentuales y el número absoluto de derivaciones es comparable entre periodos. |
| Refutación | La proporción no sube o baja. |
| Datos ausentes | Derivaciones «sin respuesta» se cuentan como no efectivas y se informa aparte de cuántas son. |

### H4 · Trazabilidad del seguimiento

| Campo | Contenido |
|---|---|
| Enunciado | Mejora la trazabilidad y el seguimiento de los itinerarios. |
| Medida 1 | Proporción de acciones con responsable, fecha y resultado registrados. |
| Medida 2 | Número de itinerarios sin contacto registrado durante más de `[FIJAR]` días, y cuántos de ellos se habían detectado antes de que lo señalara una persona. |
| Valor de línea base | `[FIJAR]` (completitud actual del registro) |
| Regla de decisión | Se sostiene si la completitud alcanza `[FIJAR]` % y el tiempo de registro por caso no aumenta más de `[FIJAR]` minutos respecto a la línea base. |
| Refutación | La completitud no mejora o el tiempo de registro supera el límite. |

## 4. Hipótesis propuestas para añadir (decisión pendiente)

Estas dos no figuran en el documento fundacional, que solo las recoge como criterios de revisión. Convertirlas en hipótesis las haría refutables.

### H5 · Equidad de las sugerencias

| Campo | Contenido |
|---|---|
| Enunciado | La distribución de sugerencias (`revisar`, `explorar_con_apoyos`, `no_priorizar_ahora`) no depende de variables que no deberían influir. |
| Medida | Distribución de sugerencias por perfil, comparada con la valoración profesional, solo con variables cuyo análisis sea lícito y necesario (apartado de protección de datos). |
| Regla de decisión | Revisión manual de todos los casos `no_priorizar_ahora`, con registro del motivo. Se sostiene si el profesional confirma el motivo en al menos `[FIJAR]` % de los casos y los desacuerdos no se concentran en un tipo de perfil. |
| Refutación | Los desacuerdos se agrupan en un tipo de perfil o de oportunidad. |

### H6 · Usabilidad y carga profesional

| Campo | Contenido |
|---|---|
| Enunciado | La herramienta es utilizable por los profesionales sin aumentar su carga administrativa. |
| Medida | Cuestionario de usabilidad estandarizado (por ejemplo, SUS) más tiempo de gestión por caso. |
| Umbral | `[FIJAR]` |
| Refutación | Puntuación por debajo del umbral o aumento sostenido del tiempo de gestión sin beneficio en H1-H4. |

## 5. Tamaño de muestra y alcance de las conclusiones

| Aspecto | Decisión |
|---|---|
| Número de participantes del pilotaje | `[FIJAR]` |
| Número de profesionales implicados | `[FIJAR]` |
| Umbral mínimo para hacer contraste estadístico | `[FIJAR]` (por debajo se informa de valores individuales y medianas) |
| Tipo de conclusión permitida | Viabilidad y asociaciones. No se afirma eficacia causal sin diseño que lo permita. |

## 6. Criterios de inclusión y datos ausentes

| Aspecto | Decisión |
|---|---|
| Quién participa | Participación voluntaria; criterios `[FIJAR]` |
| Quién queda fuera y por qué | `[FIJAR]` |
| Abandonos | Se registran y se informan; no se excluyen del análisis sin justificación escrita. |
| Datos perdidos | Se informa de cuántos hay por variable y cómo se tratan `[FIJAR]` |

## 7. Lista de congelación antes del pilotaje

- [ ] Línea base medida y archivada.
- [ ] Todos los `[FIJAR]` rellenados.
- [ ] Rúbrica de pertinencia (H2) escrita y probada con dos profesionales.
- [ ] Base jurídica y evaluación de impacto en protección de datos resueltas.
- [ ] Documento etiquetado en Git con fecha (`prereg-v1`).
- [ ] Decisión sobre si H5 y H6 se incorporan.

## 8. Control de versiones

| Versión | Fecha | Cambios |
|---|---|---|
| 0.1 | Noviembre de 2026 | Plantilla inicial con hipótesis H1-H4 y propuestas H5-H6 |
