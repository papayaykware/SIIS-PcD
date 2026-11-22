# SIIS-PcD

**Sistema Inteligente de Itinerarios de Inserción Sociolaboral para Personas con Discapacidad**

Infraestructura digital de orientación, intermediación, derivación y seguimiento sociolaboral.

> **Estado: prototipo sin validar.** Solo datos sintéticos. No usar con datos reales de personas ni como sistema de decisión. Antes de cualquier pilotaje hacen falta base jurídica, evaluación de impacto en protección de datos y acuerdo institucional.

## Qué es

Una herramienta de apoyo para profesionales. La unidad del sistema es la trayectoria sociolaboral de la persona, no la oferta de empleo. Propone correspondencias explicables entre capacidades, preferencias, puestos y apoyos, y nunca emite un «apto/no apto».

El planteamiento completo está en el [documento fundacional](SIIS-PcD_documento_fundacional_v0.1.0.md).

## Contenido

| Ruta | Qué hay |
|---|---|
| `SIIS-PcD_documento_fundacional_v0.1.0.md` | Propósito, arquitectura, límites de la IA, riesgos |
| `docs/04-metodologia-de-evaluacion.md` | Plantilla de preregistro de las hipótesis H1-H6, con umbrales por fijar |
| `src/db/schema.sql` | Esquema SQLite inicial (separa datos identificativos, sin diagnósticos) |
| `examples/ejemplo_m4.py` | Ejemplo trabajado del motor de correspondencia con datos sintéticos |
| `examples/ejemplo_m4_salida.txt` | Salida del ejemplo |

## Probar el ejemplo

Desde la raíz del repositorio, con Python 3 (solo biblioteca estándar):

```bash
python examples/ejemplo_m4.py
```

Carga el esquema en una base en memoria, inserta una persona y dos ofertas sintéticas, y muestra las sugerencias con sus factores, requisitos pendientes de verificar, barreras y apoyos a explorar.

## Limitaciones conocidas

- Las reglas de correspondencia son una primera propuesta y no están validadas.
- La coincidencia de preferencias es literal. Falta una taxonomía de tareas y competencias.
- SQLite no ofrece control de acceso por roles; esa capa está por resolver.
- Las hipótesis de evaluación no tienen umbrales hasta medir la línea base.

## Licencias

- **Código** (`src/`, `examples/`, `tests/`): [Apache-2.0](LICENSE).
- **Documentación, diagramas y datos sintéticos** (`docs/`, `assets/`, `data/synthetic/`): [CC BY 4.0](LICENSE-DOCS).

Abrir el código no abre los datos personales. Este repositorio no debe contener nunca expedientes reales ni información que permita reidentificar a participantes.

## Autoría y uso de IA

Concepto, dirección y decisiones: Javi Ciborro. Redacción y desarrollo asistidos por Claude (Anthropic), declarado como coautor conceptual. A efectos de licencia, el titular de los derechos es Javi Ciborro.

## Cómo citar

Ver [`CITATION.cff`](CITATION.cff). No hay DOI hasta que se registre una versión estable.
