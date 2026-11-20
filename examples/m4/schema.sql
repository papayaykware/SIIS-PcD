-- SIIS-PcD · esquema inicial v0.1 (SQLite)
-- Solo para prototipo con datos sintéticos. No contiene diagnósticos ni puntuaciones de empleabilidad.
-- Los datos identificativos viven en una tabla aparte; el resto se enlaza por identificador interno.

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------
-- 1. Personas y datos identificativos (separados)
-- ---------------------------------------------------------------
CREATE TABLE persona (
    id_persona      TEXT PRIMARY KEY,              -- identificador interno (UUID), sin significado externo
    fecha_alta      TEXT NOT NULL,
    estado          TEXT NOT NULL DEFAULT 'activa' CHECK (estado IN ('activa','pausada','cerrada')),
    consentimiento_fecha TEXT,                      -- fecha de información/consentimiento (o base jurídica)
    base_juridica   TEXT NOT NULL                   -- p. ej. 'consentimiento', 'convenio', a determinar con asesoría RGPD
);

CREATE TABLE persona_identificacion (              -- acceso restringido a roles concretos
    id_persona      TEXT PRIMARY KEY REFERENCES persona(id_persona) ON DELETE CASCADE,
    nombre          TEXT NOT NULL,
    contacto        TEXT
);

-- ---------------------------------------------------------------
-- 2. Actores del itinerario (empleo con apoyo)
-- ---------------------------------------------------------------
CREATE TABLE entidad (
    id_entidad      TEXT PRIMARY KEY,
    nombre          TEXT NOT NULL,
    tipo            TEXT NOT NULL CHECK (tipo IN ('CEE','empresa_ordinaria','intermediacion','servicio_publico','formacion','otra')),
    ambito          TEXT,
    fuente          TEXT NOT NULL,                  -- de dónde procede el dato
    fecha_verificacion TEXT NOT NULL,
    responsable_actualizacion TEXT
);

CREATE TABLE profesional (
    id_profesional  TEXT PRIMARY KEY,
    id_entidad      TEXT NOT NULL REFERENCES entidad(id_entidad),
    rol             TEXT NOT NULL CHECK (rol IN ('orientador','preparador_laboral','tecnico_intermediacion','coordinador','admin'))
);

CREATE TABLE tutor_natural (                        -- compañero/a de la empresa que apoya en el puesto
    id_tutor        TEXT PRIMARY KEY,
    id_entidad      TEXT NOT NULL REFERENCES entidad(id_entidad),
    formacion_recibida TEXT                         -- p. ej. fecha de la sesión de capacitación
);

CREATE TABLE asignacion (                           -- quién acompaña a quién y en qué periodo
    id_asignacion   INTEGER PRIMARY KEY AUTOINCREMENT,
    id_persona      TEXT NOT NULL REFERENCES persona(id_persona),
    id_profesional  TEXT REFERENCES profesional(id_profesional),
    id_tutor        TEXT REFERENCES tutor_natural(id_tutor),
    desde           TEXT NOT NULL,
    hasta           TEXT,
    CHECK (id_profesional IS NOT NULL OR id_tutor IS NOT NULL)
);

-- ---------------------------------------------------------------
-- 3. Perfil sociolaboral (descripción funcional, validada con la persona)
-- ---------------------------------------------------------------
CREATE TABLE competencia (                          -- catálogo; anclar a ESCO / catálogo de cualificaciones cuando se decida
    id_competencia  INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre          TEXT NOT NULL UNIQUE,
    categoria       TEXT,                           -- digital, manipulativa, comunicativa, social, funcional
    referencia_externa TEXT                         -- código ESCO u otro, si existe
);

CREATE TABLE perfil_competencia (
    id_persona      TEXT NOT NULL REFERENCES persona(id_persona),
    id_competencia  INTEGER NOT NULL REFERENCES competencia(id_competencia),
    evidencia       TEXT NOT NULL,                  -- cómo se ha observado o demostrado
    origen          TEXT NOT NULL CHECK (origen IN ('demostrada','declarada','observada_profesional','inferida_ia')),
    validada_con_persona INTEGER NOT NULL DEFAULT 0 CHECK (validada_con_persona IN (0,1)),
    fecha           TEXT NOT NULL,
    PRIMARY KEY (id_persona, id_competencia, fecha)
);

CREATE TABLE preferencia (
    id_preferencia  INTEGER PRIMARY KEY AUTOINCREMENT,
    id_persona      TEXT NOT NULL REFERENCES persona(id_persona),
    tipo            TEXT NOT NULL CHECK (tipo IN ('actividad','sector','tarea','entorno','horario')),
    descripcion     TEXT NOT NULL,
    intensidad      TEXT CHECK (intensidad IN ('interes','prefiere','evita')),
    fecha           TEXT NOT NULL
);

CREATE TABLE apoyo_funcional (                      -- apoyos ligados a tarea y contexto, nunca a un diagnóstico
    id_apoyo        INTEGER PRIMARY KEY AUTOINCREMENT,
    id_persona      TEXT NOT NULL REFERENCES persona(id_persona),
    tarea_contexto  TEXT NOT NULL,                  -- p. ej. 'seguir instrucciones nuevas en producción'
    apoyo           TEXT NOT NULL,                  -- p. ej. 'demostración práctica y pictogramas'
    intensidad_contextual TEXT CHECK (intensidad_contextual IN ('ocasional','frecuente','continuo')),
    duracion_estimada TEXT,
    fecha_revision  TEXT NOT NULL
);

-- ---------------------------------------------------------------
-- 4. Oportunidades y requisitos diferenciados
-- ---------------------------------------------------------------
CREATE TABLE oportunidad (
    id_oportunidad  TEXT PRIMARY KEY,
    id_entidad      TEXT REFERENCES entidad(id_entidad),
    titulo          TEXT NOT NULL,
    tipo            TEXT NOT NULL CHECK (tipo IN ('empleo','practicas','formacion','otra')),
    fuente          TEXT NOT NULL,                  -- origen autorizado de la oferta
    fecha_publicacion TEXT,
    vigente         INTEGER NOT NULL DEFAULT 1 CHECK (vigente IN (0,1)),
    jornada         TEXT,
    ubicacion       TEXT,
    accesibilidad_conocida TEXT
);

CREATE TABLE requisito (
    id_requisito    INTEGER PRIMARY KEY AUTOINCREMENT,
    id_oportunidad  TEXT NOT NULL REFERENCES oportunidad(id_oportunidad) ON DELETE CASCADE,
    descripcion     TEXT NOT NULL,
    naturaleza      TEXT NOT NULL CHECK (naturaleza IN ('legal','empresa','deseable','descriptivo')),
    tarea_esencial  INTEGER NOT NULL DEFAULT 0 CHECK (tarea_esencial IN (0,1)),
    verificado_por  TEXT REFERENCES profesional(id_profesional)  -- clasificación validada por una persona
);

CREATE TABLE requisito_competencia (                -- qué competencia del catálogo permite verificar el requisito
    id_requisito    INTEGER NOT NULL REFERENCES requisito(id_requisito) ON DELETE CASCADE,
    id_competencia  INTEGER NOT NULL REFERENCES competencia(id_competencia),
    PRIMARY KEY (id_requisito, id_competencia)
);

-- ---------------------------------------------------------------
-- 5. Correspondencia explicable (la salida nunca es apto/no apto)
-- ---------------------------------------------------------------
CREATE TABLE correspondencia (
    id_correspondencia INTEGER PRIMARY KEY AUTOINCREMENT,
    id_persona      TEXT NOT NULL REFERENCES persona(id_persona),
    id_oportunidad  TEXT NOT NULL REFERENCES oportunidad(id_oportunidad),
    version_reglas  TEXT NOT NULL,                  -- reproducibilidad: qué reglas generaron esto
    generada_en     TEXT NOT NULL,
    factores_coincidencia   TEXT NOT NULL,          -- JSON: competencias/preferencias que coinciden
    requisitos_pendientes   TEXT NOT NULL,          -- JSON: lo que no se pudo verificar
    barreras_identificadas  TEXT,
    apoyos_a_explorar       TEXT,
    calidad_datos   TEXT NOT NULL,                  -- antigüedad y fiabilidad de lo usado
    sugerencia      TEXT NOT NULL CHECK (sugerencia IN ('revisar','explorar_con_apoyos','no_priorizar_ahora')),
    motivo          TEXT NOT NULL
);

CREATE TABLE valoracion_correspondencia (           -- alimenta H2 (pertinencia) y la auditoría de sesgos
    id_correspondencia INTEGER PRIMARY KEY REFERENCES correspondencia(id_correspondencia),
    id_profesional  TEXT NOT NULL REFERENCES profesional(id_profesional),
    pertinencia     INTEGER NOT NULL CHECK (pertinencia BETWEEN 1 AND 5),
    decision_acordada_con_persona TEXT,
    comentario      TEXT,
    fecha           TEXT NOT NULL
);

-- ---------------------------------------------------------------
-- 6. Itinerario, acciones y derivaciones
-- ---------------------------------------------------------------
CREATE TABLE accion (
    id_accion       INTEGER PRIMARY KEY AUTOINCREMENT,
    id_persona      TEXT NOT NULL REFERENCES persona(id_persona),
    fase            TEXT NOT NULL CHECK (fase IN ('orientacion','formacion','candidatura','derivacion','entrevista','incorporacion','seguimiento','revision')),
    descripcion     TEXT NOT NULL,
    id_responsable  TEXT REFERENCES profesional(id_profesional),
    fecha_prevista  TEXT,
    fecha_realizada TEXT,
    resultado       TEXT
);

CREATE TABLE derivacion (
    id_derivacion   INTEGER PRIMARY KEY AUTOINCREMENT,
    id_persona      TEXT NOT NULL REFERENCES persona(id_persona),
    id_entidad_destino TEXT NOT NULL REFERENCES entidad(id_entidad),
    id_oportunidad  TEXT REFERENCES oportunidad(id_oportunidad),
    motivo          TEXT NOT NULL,
    fecha           TEXT NOT NULL,
    base_juridica   TEXT NOT NULL,                  -- consentimiento u otra, obligatorio
    estado          TEXT NOT NULL CHECK (estado IN ('propuesta','autorizada','enviada','atendida','rechazada','sin_respuesta')),
    resultado_conocido TEXT
);

-- Seguimiento posterior a la contratación (H3, permanencia a 3 y 6 meses)
CREATE TABLE seguimiento_laboral (
    id_seguimiento  INTEGER PRIMARY KEY AUTOINCREMENT,
    id_persona      TEXT NOT NULL REFERENCES persona(id_persona),
    id_oportunidad  TEXT REFERENCES oportunidad(id_oportunidad),
    fecha_contacto  TEXT NOT NULL,
    hito            TEXT CHECK (hito IN ('incorporacion','1_mes','3_meses','6_meses','otro')),
    continua_en_puesto INTEGER CHECK (continua_en_puesto IN (0,1)),
    apoyos_activos  TEXT,
    observaciones   TEXT
);

-- ---------------------------------------------------------------
-- 7. Auditoría (quién hizo qué)
-- ---------------------------------------------------------------
CREATE TABLE registro_actividad (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    momento         TEXT NOT NULL,
    id_profesional  TEXT REFERENCES profesional(id_profesional),
    operacion       TEXT NOT NULL CHECK (operacion IN ('crear','consultar','modificar','exportar','eliminar')),
    tabla_afectada  TEXT NOT NULL,
    id_registro     TEXT
);

-- Vista para evaluación: sin identificación directa
CREATE VIEW v_evaluacion_derivaciones AS
SELECT d.id_derivacion, d.fecha, d.estado, e.tipo AS tipo_entidad_destino
FROM derivacion d
JOIN entidad e ON e.id_entidad = d.id_entidad_destino;
