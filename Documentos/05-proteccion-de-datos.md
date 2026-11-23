# SIIS-PcD · Protección de datos y gobernanza

**Propuesta v0.1 · Noviembre de 2026**

> **Aviso.** Este documento ordena las decisiones que hay que tomar antes de tratar datos reales. No es un dictamen jurídico. Lo marcado como **[CONFIRMAR]** necesita revisión de un delegado de protección de datos o de asesoría jurídica, y lo marcado como **[FIJAR]** depende de decisiones de la entidad. Hoy el repositorio solo contiene datos sintéticos.

## 1. Conclusión previa

Con los datos que el sistema pretende tratar, la entidad que lo use tendrá que hacer una evaluación de impacto (EIPD) **antes** del pilotaje, resolver la base jurídica de cada finalidad y documentar el encaje con el Reglamento europeo de IA. Ninguno de esos tres pasos puede sustituirse por una buena arquitectura técnica, aunque la arquitectura reduzca el riesgo.

## 2. Qué datos se tratarían y por qué importa

La pertenencia de una persona a un servicio de inserción para personas con discapacidad ya revela información sobre su salud. Por eso se propone tratar **todo el expediente** como si contuviera categorías especiales de datos (art. 9 RGPD), aunque el esquema evite los diagnósticos.

El esquema (`src/db/schema.sql`) ya reduce la exposición: separa la identificación del resto, no tiene columnas de diagnóstico y describe los apoyos por tarea y contexto. El riesgo restante está en los **campos de texto libre**, donde puede colarse información de salud sin que nadie lo decida:

| Campo | Riesgo | Control propuesto |
|---|---|---|
| `perfil_competencia.evidencia` | Narrativas con datos clínicos | Guía de redacción: describir lo observado en la tarea, nunca el diagnóstico |
| `apoyo_funcional.tarea_contexto` y `apoyo` | Descripción de limitaciones en términos médicos | Redacción funcional; revisión periódica por muestreo |
| `seguimiento_laboral.observaciones` | Notas de seguimiento con datos de salud o familiares | Aviso visible en el formulario; longitud limitada |
| `accion.resultado` y `derivacion.motivo` | Motivos que revelan condición personal | Lista cerrada de motivos cuando sea posible |

## 3. Finalidades, bases jurídicas y necesidad

La base jurídica se decide por finalidad. La tabla propone un punto de partida **[CONFIRMAR]**.

| Finalidad | Datos principales | Base candidata (art. 6) | Condición art. 9.2 candidata |
|---|---|---|---|
| Construir y revisar el perfil sociolaboral | Competencias, preferencias, apoyos | Consentimiento | Consentimiento explícito |
| Proponer correspondencias con ofertas | Perfil y requisitos de la oferta | Consentimiento | Consentimiento explícito |
| Derivar a otra entidad o a una empresa | Datos mínimos necesarios para la derivación | Consentimiento específico por derivación | Consentimiento explícito |
| Seguimiento posterior a la contratación | Hitos, apoyos activos | Consentimiento | Consentimiento explícito |
| Evaluación del proyecto | Datos agregados | Anonimización antes de analizar | No aplica si la anonimización es efectiva |

Tres cuestiones condicionan la tabla:

- **Quién es el responsable.** Si la entidad piloto trata los datos para sus fines, será la responsable. Quien desarrolle o administre el sistema y acceda a datos reales será encargado y necesitará contrato conforme al art. 28 RGPD. Si el acceso a datos reales no es necesario para desarrollar, no debe existir.
- **Cómo se presta el consentimiento.** Debe ser libre, informado y retirable en cualquier momento, y no puede condicionar el acceso al servicio. Con personas con discapacidad intelectual implica información en lectura fácil y, cuando proceda, los apoyos para el ejercicio de su capacidad jurídica previstos por la legislación vigente **[CONFIRMAR]**.
- **Si hay una base distinta del consentimiento.** Algunas entidades tienen funciones reconocidas por ley en materia de empleo o servicios sociales que podrían servir de base para ciertas finalidades. Solo puede afirmarlo la asesoría jurídica de la entidad.

## 4. Evaluación de impacto (EIPD)

La lista de tratamientos que requieren EIPD publicada por la AEPD establece que es necesaria cuando se cumplen dos o más de sus criterios. Este sistema cumpliría al menos dos: uso de categorías especiales de datos y tratamiento de datos de sujetos vulnerables, que incluye expresamente a las personas con discapacidad. Además, el perfilado para proponer correspondencias podría ser un tercer criterio **[CONFIRMAR]**.

Consecuencia práctica: la EIPD se hace antes de empezar y su esqueleto mínimo es:

1. Descripción sistemática del tratamiento: este documento y el esquema de datos como punto de partida.
2. Necesidad y proporcionalidad: justificar cada campo del esquema (apartado 6).
3. Riesgos para las personas: partir de la tabla de riesgos del documento fundacional (apartado 14) y añadir reidentificación, acceso indebido, perfilado erróneo y efecto de las sugerencias sobre la autonomía.
4. Medidas previstas: apartados 6 a 9 de este documento.
5. Si el riesgo residual sigue siendo alto, consulta previa a la autoridad de control.

## 5. Reglamento europeo de IA

Estado normativo a noviembre de 2026, **[CONFIRMAR]** antes de usarlo:

- El Reglamento (UE) 2026/1744 (Ómnibus Digital de IA) entró en vigor el 27 de julio de 2026 y aplaza las obligaciones de los sistemas de alto riesgo independientes del anexo III al 2 de diciembre de 2027.
- El aplazamiento no deroga la clasificación. El anexo III incluye los sistemas de IA destinados a analizar y filtrar solicitudes de empleo o a evaluar candidatos.

Hipótesis de trabajo: los módulos M3 (análisis de ofertas) y M4 (correspondencia) pueden quedar dentro de ese ámbito según su finalidad prevista. Argumentos a favor de una clasificación menos exigente: el sistema asiste al profesional, no decide y no filtra candidaturas. Argumentos en contra: elabora propuestas sobre personas concretas, lo que puede considerarse perfilado. Hay que documentar el análisis, no darlo por hecho.

Compromisos de diseño que se mantienen en cualquier escenario:

- No se toman decisiones automatizadas con efectos significativos sin intervención humana real (art. 22 RGPD). Eso implica que el profesional pueda contradecir la sugerencia y que lo registre, no que pulse «aceptar».
- No se infieren emociones ni capacidades a partir de diagnósticos o categorías de discapacidad.
- Cada sugerencia conserva su explicación y la versión de reglas que la generó.

## 6. Minimización y diseño técnico

**Principio:** un campo entra en el esquema solo si hay una finalidad que lo exija y una persona concreta que lo use. En la EIPD cada campo lleva una línea de justificación; los que no la tengan se eliminan.

| Medida | Estado en el prototipo | Para el pilotaje |
|---|---|---|
| Separación de identificación | Hecha (`persona_identificacion`) | Almacenamiento y permisos independientes |
| Identificador interno sin significado | Hecho (UUID) | Mantener |
| Cifrado en reposo y en tránsito | No existe | Obligatorio |
| Autenticación y control por roles | No existe (SQLite no lo ofrece) | Obligatorio, ver matriz |
| Registro de actividad | Esquema previsto (`registro_actividad`) | Activo y revisado periódicamente |
| Copias de seguridad cifradas | No existe | Obligatorio, con plazo de borrado |
| Entorno de desarrollo | Solo datos sintéticos | Mantener; nunca copiar datos reales a desarrollo |

**Servicios de terceros e IA generativa.** Regla por defecto: ningún dato personal sale hacia un servicio externo. Si se usa un modelo de lenguaje, solo recibe texto de ofertas, que no contiene datos personales. Un modelo local o con contrato de encargo y garantías de transferencia solo se considera tras la EIPD **[CONFIRMAR]**.

### Matriz de acceso propuesta

C = crear · L = leer · M = modificar · E = exportar. Es una propuesta para validar con la entidad.

| Bloque de datos | Orientador | Preparador laboral | Técnico de intermediación | Coordinador | Tutor natural | Administrador técnico |
|---|---|---|---|---|---|---|
| Identificación | C L M | L | L (solo si hay derivación autorizada) | L | — | — |
| Perfil y preferencias | C L M | L M | L | L | — | — |
| Apoyos funcionales | C L M | C L M | L (los pertinentes) | L | L (solo los de su puesto) | — |
| Itinerario y acciones | C L M | C L M | C L M (derivaciones) | L | — | — |
| Correspondencias | L | L | C L | L | — | — |
| Seguimiento laboral | C L M | C L M | L | L | L (su puesto) | — |
| Evaluación agregada | — | — | — | L E | — | — |
| Registro de actividad | — | — | — | L | — | L |

El tutor natural pertenece a la empresa, que es un tercero. Su acceso a los apoyos exige autorización específica de la persona. La eliminación de registros queda reservada al coordinador y siempre se anota en el registro de actividad.

## 7. Derechos y transparencia

- **Información en capas y en lectura fácil**: qué datos se tratan, para qué, quién los ve y cuánto tiempo se conservan.
- **Ejercicio de derechos** (acceso, rectificación, supresión, limitación, oposición, portabilidad): el sistema debe poder exportar el expediente de una persona, corregirlo y borrarlo. El plazo de respuesta general es un mes.
- **Explicación de las sugerencias**: la persona puede pedir qué datos se usaron y por qué se propuso o no priorizó una oportunidad, y cuestionarlo.
- **Retirada del consentimiento**: debe ser tan sencilla como darlo y tener efectos definidos sobre los datos ya tratados.

## 8. Conservación, evaluación y brechas

**Conservación** **[FIJAR]**:

| Categoría | Plazo | Criterio de borrado |
|---|---|---|
| Expediente activo | | Fin del itinerario |
| Expediente cerrado | | |
| Registro de actividad | | |
| Copias de seguridad | | |

**Datos de evaluación.** Se analizan agregados o seudonimizados. La seudonimización no equivale a anonimización. En una entidad pequeña el riesgo de reidentificación es alto: no se publican resultados por grupos con menos de `[FIJAR]` personas.

**Brechas de seguridad.** Se prepara un protocolo antes del pilotaje: quién detecta, quién decide, quién notifica. Si la brecha entraña riesgo para las personas, la notificación a la autoridad de control debe hacerse en un máximo de 72 horas desde que se tiene conocimiento, y a las personas afectadas cuando el riesgo sea alto.

## 9. Repositorio público

El repositorio no debe contener nunca datos reales. Reglas mínimas:

- `.gitignore` con `*.db`, `*.sqlite`, `*.sqlite3`, `data/real/` y exportaciones (`*.csv` fuera de `data/synthetic/`).
- Activar el análisis de secretos de GitHub y revisar el historial antes de hacer público cualquier commit nuevo con datos.
- Capturas de pantalla y ejemplos: solo con datos sintéticos, revisados antes de subirlos.
- Si algún dato real llega a subirse, se trata como brecha: se retira, se reescribe el historial y se documenta.

## 10. Lista previa al pilotaje

- [ ] Entidad responsable identificada y marco de colaboración firmado.
- [ ] Contrato de encargo si el desarrollador accede a datos reales.
- [ ] Decisión sobre delegado de protección de datos **[CONFIRMAR]**.
- [ ] Registro de actividades de tratamiento actualizado.
- [ ] EIPD completada y aprobada.
- [ ] Base jurídica fijada por finalidad.
- [ ] Información y consentimiento en lectura fácil, probados con personas usuarias.
- [ ] Análisis de encaje con el Reglamento de IA documentado.
- [ ] Controles técnicos del apartado 6 implementados y probados.
- [ ] Plazos de conservación fijados.
- [ ] Protocolo de brechas definido.
- [ ] Revisión por un comité de ética, si la entidad o el proyecto lo requieren.

## 11. Referencias

Consultadas en noviembre de 2026. Comprobar el texto consolidado y la versión vigente antes de citarlas en una EIPD.

- Reglamento (UE) 2016/679 (RGPD), en particular los artículos 6, 9, 22, 28, 33-35.
- Ley Orgánica 3/2018 (LOPDGDD).
- Reglamento (UE) 2024/1689 (Reglamento de IA) y Reglamento (UE) 2026/1744 que lo modifica.
- AEPD, *Listas de tipos de tratamientos de datos que requieren evaluación de impacto (art. 35.4)*: https://www.aepd.es/documento/listas-dpia-es-35-4.pdf
- AEPD, *Gestión del riesgo y evaluación de impacto en tratamientos de datos personales* y recursos de EIPD: https://www.aepd.es/derechos-y-deberes/cumple-tus-deberes/medidas-de-cumplimiento/realizacion-de-evaluaciones-de
- Cuatrecasas, *The Digital Omnibus on AI: How Does It Impact Employment Relations?* (13 de julio de 2026), sobre el aplazamiento de las obligaciones de alto riesgo: https://www.cuatrecasas.com/en/spain/labor-and-employment/art/digital-omnibus-on-ai-how-does-it-impact-employment-relations

## 12. Control de versiones

| Versión | Fecha | Cambios |
|---|---|---|
| 0.1 | Noviembre de 2026 | Propuesta inicial |
