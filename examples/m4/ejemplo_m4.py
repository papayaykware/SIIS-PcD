#!/usr/bin/env python3
"""SIIS-PcD · ejemplo trabajado del módulo M4 (correspondencia explicable).

Solo datos sintéticos. Reglas explícitas y legibles, sin modelos predictivos.
La salida nunca es «apto/no apto»: es una sugerencia argumentada para que la
persona y el profesional decidan.

Uso:  python ejemplo_m4.py
"""
import json
import sqlite3
from datetime import date
from pathlib import Path

HOY = date(2026, 11, 20)          # fija, para que el ejemplo sea reproducible
VERSION_REGLAS = "reglas-0.1"


# ---------------------------------------------------------------
# Datos sintéticos
# ---------------------------------------------------------------
def cargar_datos(con):
    c = con.cursor()
    c.execute("INSERT INTO entidad VALUES ('E-001','CEE de ejemplo (sintético)','CEE','Tenerife','dato sintético','2026-11-01','coordinación')")
    c.execute("INSERT INTO profesional VALUES ('PR-001','E-001','orientador')")
    c.execute("INSERT INTO persona VALUES ('P-001','2026-10-01','activa','2026-10-01','consentimiento')")

    c.executemany("INSERT INTO competencia(id_competencia,nombre,categoria) VALUES (?,?,?)", [
        (1, "destreza manual fina", "manipulativa"),
        (2, "clasificar y ordenar material", "funcional"),
        (3, "uso básico de ordenador", "digital"),
        (4, "comunicación telefónica", "comunicativa"),
    ])
    c.executemany("INSERT INTO perfil_competencia VALUES (?,?,?,?,?,?)", [
        ("P-001", 1, "Realizó con precisión las tareas de montaje en el taller", "demostrada", 1, "2026-10-05"),
        ("P-001", 2, "Propuesta del sistema a partir de una descripción de tareas", "inferida_ia", 0, "2026-10-05"),
        ("P-001", 3, "La persona indica que usa el móvil y el ordenador a diario", "declarada", 0, "2026-10-05"),
    ])
    c.executemany("INSERT INTO preferencia(id_persona,tipo,descripcion,intensidad,fecha) VALUES (?,?,?,?,?)", [
        ("P-001", "actividad", "producción artesanal", "interes", "2026-10-05"),
        ("P-001", "tarea", "atención telefónica", "evita", "2026-10-05"),
    ])
    c.execute("INSERT INTO apoyo_funcional(id_persona,tarea_contexto,apoyo,intensidad_contextual,duracion_estimada,fecha_revision) "
              "VALUES ('P-001','aprender tareas nuevas en el puesto','demostración práctica y pictogramas','frecuente','primeras semanas','2026-10-05')")

    c.executemany("INSERT INTO oportunidad(id_oportunidad,id_entidad,titulo,tipo,fuente,fecha_publicacion,vigente) VALUES (?,?,?,?,?,?,1)", [
        ("O-001", "E-001", "Ayudante de producción artesanal", "empleo", "dato sintético", "2026-11-10"),
        ("O-002", "E-001", "Auxiliar administrativo con atención telefónica", "empleo", "dato sintético", "2026-11-12"),
    ])
    # (id_requisito, oportunidad, descripcion, naturaleza, tarea_esencial)
    c.executemany("INSERT INTO requisito(id_requisito,id_oportunidad,descripcion,naturaleza,tarea_esencial) VALUES (?,?,?,?,?)", [
        (1, "O-001", "Manipular piezas pequeñas con precisión", "empresa", 1),
        (2, "O-001", "Clasificar y ordenar piezas por tipo", "empresa", 1),
        (3, "O-001", "Experiencia previa de 6 meses en producción", "empresa", 0),
        (4, "O-001", "Desplazamiento diario al polígono industrial", "descriptivo", 0),
        (5, "O-002", "Atender llamadas telefónicas de clientes", "empresa", 1),
        (6, "O-002", "Uso básico de ofimática", "deseable", 0),
    ])
    c.executemany("INSERT INTO requisito_competencia VALUES (?,?)", [(1, 1), (2, 2), (5, 4), (6, 3)])
    con.commit()


# ---------------------------------------------------------------
# Reglas de correspondencia
# ---------------------------------------------------------------
def correspondencia(con, id_persona, id_oportunidad):
    op = con.execute("SELECT * FROM oportunidad WHERE id_oportunidad=?", (id_oportunidad,)).fetchone()

    # Última entrada de perfil por competencia
    perfil = {}
    for r in con.execute("SELECT * FROM perfil_competencia WHERE id_persona=? ORDER BY fecha", (id_persona,)):
        perfil[r["id_competencia"]] = r

    reqs = con.execute(
        """SELECT r.*, rc.id_competencia, comp.nombre AS comp_nombre
           FROM requisito r
           LEFT JOIN requisito_competencia rc ON rc.id_requisito = r.id_requisito
           LEFT JOIN competencia comp ON comp.id_competencia = rc.id_competencia
           WHERE r.id_oportunidad=?""", (id_oportunidad,)).fetchall()

    coincidencias, pendientes, barreras = [], [], []
    esenciales_total = esenciales_cubiertas = 0

    for r in reqs:
        if r["tarea_esencial"]:
            esenciales_total += 1
        if r["id_competencia"] is None:
            pendientes.append(f"«{r['descripcion']}»: el perfil no tiene datos para verificarlo")
            if r["naturaleza"] in ("empresa", "legal"):
                barreras.append(f"«{r['descripcion']}» es un requisito de {r['naturaleza']} que podría dificultar el acceso; "
                                "consultar con la entidad si admite alternativas o acreditación no formal")
            continue
        p = perfil.get(r["id_competencia"])
        if p is None:
            pendientes.append(f"«{r['descripcion']}»: la competencia «{r['comp_nombre']}» no consta en el perfil")
        elif p["origen"] == "inferida_ia" or not p["validada_con_persona"]:
            pendientes.append(f"«{r['descripcion']}»: «{r['comp_nombre']}» consta ({p['origen']}) pero sin validar con la persona")
        else:
            coincidencias.append(f"«{r['descripcion']}»: «{r['comp_nombre']}» ({p['origen']}, validada). Evidencia: {p['evidencia']}")
            if r["tarea_esencial"]:
                esenciales_cubiertas += 1

    # Preferencias: coincidencia literal con el título o los requisitos (limitación conocida)
    texto = (op["titulo"] + " " + " ".join(r["descripcion"] for r in reqs)).lower()
    hay_evita = False
    for pref in con.execute("SELECT * FROM preferencia WHERE id_persona=?", (id_persona,)):
        if pref["descripcion"].lower() in texto:
            if pref["intensidad"] == "evita":
                hay_evita = True
                barreras.append(f"La persona indica que evita «{pref['descripcion']}», presente en esta oportunidad")
            else:
                coincidencias.append(f"Preferencia de la persona: «{pref['descripcion']}» ({pref['intensidad']})")
    hay_pref = any(c.startswith("Preferencia") for c in coincidencias)

    apoyos = [f"{a['apoyo']} (para: {a['tarea_contexto']})"
              for a in con.execute("SELECT * FROM apoyo_funcional WHERE id_persona=?", (id_persona,))]

    # Sugerencia: reglas en orden, la primera que se cumple decide
    if hay_evita:
        sugerencia = "no_priorizar_ahora"
        motivo = "Choca con una preferencia expresada por la persona. Puede revisarse si ella lo decide."
    elif esenciales_total and esenciales_cubiertas == esenciales_total and not any(
            r["naturaleza"] in ("empresa", "legal") and r["id_competencia"] is None for r in reqs):
        sugerencia = "revisar"
        motivo = "Todas las tareas esenciales tienen competencia validada y no quedan requisitos formales sin dato."
    elif esenciales_cubiertas > 0 or hay_pref:
        sugerencia = "explorar_con_apoyos"
        motivo = (f"{esenciales_cubiertas} de {esenciales_total} tareas esenciales cubiertas con competencia validada"
                  + ("; hay coincidencia con sus preferencias" if hay_pref else "")
                  + ". Quedan puntos por verificar antes de decidir.")
    else:
        sugerencia = "no_priorizar_ahora"
        motivo = "Ninguna tarea esencial está cubierta por competencias validadas ni hay coincidencia de preferencias."

    # Calidad y antigüedad de los datos
    fechas = [date.fromisoformat(p["fecha"]) for p in perfil.values()]
    validadas = sum(1 for p in perfil.values() if p["validada_con_persona"])
    edad_oferta = (HOY - date.fromisoformat(op["fecha_publicacion"])).days
    calidad = (f"Perfil: {validadas} de {len(perfil)} entradas validadas; entrada más antigua de "
               f"{(HOY - min(fechas)).days} días. Oferta publicada hace {edad_oferta} días, fuente: {op['fuente']}.")

    con.execute(
        """INSERT INTO correspondencia(id_persona,id_oportunidad,version_reglas,generada_en,factores_coincidencia,
           requisitos_pendientes,barreras_identificadas,apoyos_a_explorar,calidad_datos,sugerencia,motivo)
           VALUES (?,?,?,?,?,?,?,?,?,?,?)""",
        (id_persona, id_oportunidad, VERSION_REGLAS, HOY.isoformat(),
         json.dumps(coincidencias, ensure_ascii=False), json.dumps(pendientes, ensure_ascii=False),
         json.dumps(barreras, ensure_ascii=False), json.dumps(apoyos, ensure_ascii=False),
         calidad, sugerencia, motivo))
    con.commit()

    return op["titulo"], sugerencia, motivo, coincidencias, pendientes, barreras, apoyos, calidad


def imprimir(res):
    titulo, sugerencia, motivo, coincidencias, pendientes, barreras, apoyos, calidad = res
    print(f"=== {titulo} ===")
    print(f"Sugerencia: {sugerencia}")
    print(f"Motivo: {motivo}")
    for nombre, items in (("Coincidencias", coincidencias), ("Pendiente de verificar", pendientes),
                          ("Barreras identificadas", barreras), ("Apoyos a explorar", apoyos)):
        print(f"\n{nombre}:")
        print("\n".join(f"  - {i}" for i in items) if items else "  (ninguno)")
    print(f"\nCalidad de los datos: {calidad}\n")


if __name__ == "__main__":
    con = sqlite3.connect(":memory:")
    con.row_factory = sqlite3.Row
    con.executescript((Path(__file__).parent / "schema.sql").read_text(encoding="utf-8"))
    cargar_datos(con)
    for id_op in ("O-001", "O-002"):
        imprimir(correspondencia(con, "P-001", id_op))
    print("Limitaciones: la coincidencia de preferencias es literal; una taxonomía de tareas la mejoraría. "
          "Las sugerencias son orientativas y requieren valoración profesional y de la persona.")
