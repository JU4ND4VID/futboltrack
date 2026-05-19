# ================================================================
# FutbolTrack - app/routes/sesiones.py
# ================================================================
from flask import Blueprint, request, jsonify
from bson import ObjectId
from bson.errors import InvalidId
from app.db.mysql_conn import get_mysql
from app.db.mongo_conn import get_mongo_db
from app.routes.auth import login_required

sesiones_bp = Blueprint("sesiones", __name__)


def oid(doc):
    # El front no necesita ver el identificador interno de MongoDB.
    if doc and "_id" in doc:
        doc.pop("_id", None)
    return doc


def _limpiar_plan_mysql(cur, conn, id_entrenamiento):
    cur.execute(
        "UPDATE entrenamiento SET id_plan_mongodb = NULL WHERE id_entrenamiento = %s",
        (id_entrenamiento,),
    )
    conn.commit()


# ----------------------------------------------------------------
# HELPERS: inferencia de campos dinamicos desde MongoDB
# ----------------------------------------------------------------

CAMPOS_ID_SESION = {"_id", "id_entrenamiento", "id_entrenamiento_mysql"}
MIN_FRECUENCIA_CAMPOS = 3


def _label_campo(key):
    return key.replace("_", " ").title()


def _tipo_desde_valor(value):
    if isinstance(value, bool):
        return "text"
    if isinstance(value, (int, float)):
        return "number"
    if isinstance(value, list):
        if all(not isinstance(item, (dict, list)) for item in value):
            return "list"
        return "json"
    if isinstance(value, dict):
        return "json"
    texto = "" if value is None else str(value)
    if "\n" in texto or len(texto) > 90:
        return "textarea"
    return "text"


def _combinar_tipo(actual, nuevo):
    if not actual:
        return nuevo
    if actual == nuevo:
        return actual
    tipos = {actual, nuevo}
    if "json" in tipos:
        return "json"
    if "list" in tipos and len(tipos) > 1:
        return "json"
    if "textarea" in tipos and tipos <= {"textarea", "text"}:
        return "textarea"
    if "number" in tipos and len(tipos) > 1:
        return "text"
    return nuevo


def _obtener_contexto_entrenamiento(id_entrenamiento):
    """Devuelve entrenador, tipo y sesiones comparables para sugerir campos dinamicos."""
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute(
            """
            SELECT id_entrenamiento, cedula_entrenador, tipo
              FROM entrenamiento
             WHERE id_entrenamiento = %s
            """,
            (id_entrenamiento,),
        )
        actual = cur.fetchone()
        if not actual:
            return None

        cur.execute(
            """
            SELECT id_entrenamiento
              FROM entrenamiento
             WHERE cedula_entrenador = %s
               AND tipo = %s
            """,
            (actual["cedula_entrenador"], actual["tipo"]),
        )
        ids = [int(row["id_entrenamiento"]) for row in cur.fetchall()]
        actual["ids_entrenamientos"] = ids or [int(id_entrenamiento)]
        return actual
    finally:
        if conn:
            conn.close()


def _filtro_mongo_por_contexto(id_entrenamiento):
    contexto = _obtener_contexto_entrenamiento(id_entrenamiento)
    if not contexto:
        return None, None
    ids = contexto.get("ids_entrenamientos") or [int(id_entrenamiento)]
    return {
        "$or": [
            {"id_entrenamiento_mysql": {"$in": ids}},
            {"id_entrenamiento": {"$in": ids}},
        ]
    }, contexto


def _inferir_campos_coleccion(nombre_coleccion, campos_excluir=None, limite=300, min_frecuencia=MIN_FRECUENCIA_CAMPOS, filtro=None):
    campos_excluir = set(campos_excluir or set()) | CAMPOS_ID_SESION
    db = get_mongo_db()
    query = filtro or {}
    docs = list(db[nombre_coleccion].find(query).sort("_id", -1).limit(limite))

    frecuencia = {}
    tipos = {}

    for doc in docs:
        claves_doc = set()
        for key, value in doc.items():
            if key in campos_excluir:
                continue
            claves_doc.add(key)
            tipos[key] = _combinar_tipo(tipos.get(key), _tipo_desde_valor(value))

        # La frecuencia cuenta documentos, no cantidad de valores repetidos.
        for key in claves_doc:
            frecuencia[key] = frecuencia.get(key, 0) + 1

    campos = []
    for key, freq in sorted(frecuencia.items(), key=lambda item: (-item[1], item[0])):
        if freq < min_frecuencia:
            continue
        campos.append({
            "key": key,
            "label": _label_campo(key),
            "type": tipos.get(key, "text"),
            "frecuencia": freq,
            "total_documentos": len(docs),
            "esSugerido": True,
        })
    return campos


def _limpiar_payload_documento(data):
    limpio = dict(data or {})
    # _id no se puede actualizar con $set y los ids de sesion los controla el backend.
    for campo in CAMPOS_ID_SESION:
        limpio.pop(campo, None)
    return limpio


# ----------------------------------------------------------------
# PLANES DE SESION
# ----------------------------------------------------------------

@sesiones_bp.route("/planes/campos-comunes", methods=["GET"])
@login_required
def campos_comunes_planes():
    try:
        filtro = None
        id_entrenamiento = request.args.get("id_entrenamiento", type=int)
        if id_entrenamiento:
            filtro, contexto = _filtro_mongo_por_contexto(id_entrenamiento)
            if not contexto:
                return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404

        campos = _inferir_campos_coleccion(
            "planes_sesion",
            campos_excluir={"duracion_total_min"},
            min_frecuencia=MIN_FRECUENCIA_CAMPOS,
            filtro=filtro,
        )
        return jsonify({"campos": campos}), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500

@sesiones_bp.route("/<int:id_entrenamiento>", methods=["GET"])
@login_required
def obtener_plan(id_entrenamiento):
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT id_plan_mongodb FROM entrenamiento WHERE id_entrenamiento = %s",
            (id_entrenamiento,),
        )
        row = cur.fetchone()
        if not row:
            return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404
        if not row["id_plan_mongodb"]:
            return jsonify({"ok": False, "mensaje": "Este entrenamiento no tiene plan registrado aun."}), 404
        try:
            object_id = ObjectId(row["id_plan_mongodb"])
        except InvalidId:
            _limpiar_plan_mysql(cur, conn, id_entrenamiento)
            return jsonify({"ok": False, "mensaje": "Este entrenamiento no tiene plan registrado aun."}), 404

        db = get_mongo_db()
        doc = db["planes_sesion"].find_one({"_id": object_id})
        if not doc:
            _limpiar_plan_mysql(cur, conn, id_entrenamiento)
            return jsonify({"ok": False, "mensaje": "Este entrenamiento no tiene plan registrado aun."}), 404
        return jsonify(oid(doc)), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


@sesiones_bp.route("/<int:id_entrenamiento>", methods=["POST"])
@login_required
def crear_plan(id_entrenamiento):
    d = request.get_json() or {}
    if not d:
        return jsonify({"ok": False, "mensaje": "El body del plan no puede estar vacio."}), 400
    d = _limpiar_payload_documento(d)
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT id_plan_mongodb FROM entrenamiento WHERE id_entrenamiento = %s",
            (id_entrenamiento,),
        )
        row = cur.fetchone()
        if not row:
            return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404

        if row["id_plan_mongodb"]:
            db = get_mongo_db()
            try:
                existing = db["planes_sesion"].find_one({"_id": ObjectId(row["id_plan_mongodb"])})
            except InvalidId:
                existing = None
            if existing:
                return jsonify({"ok": False, "mensaje": "Este entrenamiento ya tiene plan. Use PUT para actualizar."}), 400
            else:
                _limpiar_plan_mysql(cur, conn, id_entrenamiento)

        d["id_entrenamiento_mysql"] = id_entrenamiento
        db = get_mongo_db()
        result = db["planes_sesion"].insert_one(d)
        nuevo_id = str(result.inserted_id)

        if not db["estadisticas_jugador"].find_one({"id_entrenamiento_mysql": id_entrenamiento}):
            db["estadisticas_jugador"].insert_one({
                "id_entrenamiento_mysql": id_entrenamiento,
                "jugadores": [],
                "count": 0,
            })

        if not db["observaciones_sesion"].find_one({
            "$or": [
                {"id_entrenamiento_mysql": id_entrenamiento},
                {"id_entrenamiento": id_entrenamiento},
            ]
        }):
            db["observaciones_sesion"].insert_one({
                "id_entrenamiento_mysql": id_entrenamiento,
                "id_entrenamiento": id_entrenamiento,
                "observacion_general": "",
                "aspectos_positivos": [],
                "aspectos_a_mejorar": [],
                "estado_animo_grupo": "",
                "condiciones_clima": "",
            })

        cur.execute(
            "UPDATE entrenamiento SET id_plan_mongodb = %s WHERE id_entrenamiento = %s",
            (nuevo_id, id_entrenamiento),
        )
        conn.commit()
        return jsonify({
            "ok": True,
            "id_plan_mongodb": nuevo_id,
            "mensaje": "Plan creado. Estadísticas y observaciones inicializadas.",
        }), 201
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


@sesiones_bp.route("/<int:id_entrenamiento>", methods=["PUT"])
@login_required
def actualizar_plan(id_entrenamiento):
    d = request.get_json() or {}
    if not d:
        return jsonify({"ok": False, "mensaje": "El body del plan no puede estar vacio."}), 400
    d = _limpiar_payload_documento(d)
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT id_plan_mongodb FROM entrenamiento WHERE id_entrenamiento = %s",
            (id_entrenamiento,),
        )
        row = cur.fetchone()
        if not row or not row["id_plan_mongodb"]:
            return jsonify({"ok": False, "mensaje": "No existe un plan para actualizar. Use POST primero."}), 404

        db = get_mongo_db()
        db["planes_sesion"].update_one({"_id": ObjectId(row["id_plan_mongodb"])}, {"$set": d})
        return jsonify({"ok": True, "mensaje": "Plan actualizado correctamente."}), 200
    except InvalidId:
        return jsonify({"ok": False, "mensaje": "El id_plan_mongodb guardado no es valido."}), 500
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


# ----------------------------------------------------------------
# ESTADISTICAS POR SESION
# ----------------------------------------------------------------

def _inferir_campos_estadisticas(limite=300, min_frecuencia=MIN_FRECUENCIA_CAMPOS, filtro=None):
    campos_excluir = {
        "_id", "id_entrenamiento", "id_entrenamiento_mysql",
        "identificacion_jugador", "cedula_jugador", "nombre",
    }
    db = get_mongo_db()
    query = filtro or {}
    docs = list(db["estadisticas_jugador"].find(query).sort("_id", -1).limit(limite))

    frecuencia = {}
    tipos = {}

    for doc in docs:
        jugadores = doc.get("jugadores", [])
        if not isinstance(jugadores, list):
            continue

        claves_doc = set()
        for jugador in jugadores:
            if not isinstance(jugador, dict):
                continue
            for key, value in jugador.items():
                if key in campos_excluir:
                    continue
                claves_doc.add(key)
                tipos[key] = _combinar_tipo(tipos.get(key), _tipo_desde_valor(value))

        # La frecuencia cuenta documentos de estadistica, no jugadores.
        for key in claves_doc:
            frecuencia[key] = frecuencia.get(key, 0) + 1

    campos = []
    for key, freq in sorted(frecuencia.items(), key=lambda item: (-item[1], item[0])):
        if freq < min_frecuencia:
            continue
        campos.append({
            "key": key,
            "label": _label_campo(key),
            "type": tipos.get(key, "text"),
            "frecuencia": freq,
            "total_documentos": len(docs),
            "esSugerido": True,
        })
    return campos


@sesiones_bp.route("/estadisticas/campos-comunes", methods=["GET"])
@login_required
def campos_comunes_estadisticas():
    try:
        filtro = None
        id_entrenamiento = request.args.get("id_entrenamiento", type=int)
        if id_entrenamiento:
            filtro, contexto = _filtro_mongo_por_contexto(id_entrenamiento)
            if not contexto:
                return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404

        campos = _inferir_campos_estadisticas(
            min_frecuencia=MIN_FRECUENCIA_CAMPOS,
            filtro=filtro,
        )
        return jsonify({"campos": campos}), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500


@sesiones_bp.route("/estadisticas/<int:id_entrenamiento>", methods=["GET"])
@login_required
def obtener_estadisticas_sesion(id_entrenamiento):
    try:
        db = get_mongo_db()
        doc = db["estadisticas_jugador"].find_one({
            "$or": [
                {"id_entrenamiento": id_entrenamiento},
                {"id_entrenamiento_mysql": id_entrenamiento},
            ]
        })
        if not doc:
            return jsonify([]), 200

        jugadores = doc.get("jugadores", [])
        CAMPOS_EXCLUIR = {"_id", "identificacion_jugador", "nombre"}
        resultado = []
        for j in jugadores:
            entrada = {
                "cedula_jugador": j.get("identificacion_jugador", ""),
                "nombre":         j.get("nombre", ""),
            }
            for key, value in j.items():
                if key not in CAMPOS_EXCLUIR:
                    entrada[key] = value
            resultado.append(entrada)

        resumen = doc.get("resumen_computado", None)
        return jsonify({"jugadores": resultado, "resumen": resumen}), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500


@sesiones_bp.route("/estadisticas/<int:id_entrenamiento>", methods=["POST"])
@login_required
def guardar_estadisticas_sesion(id_entrenamiento):
    datos = request.get_json() or []
    if not isinstance(datos, list) or len(datos) == 0:
        return jsonify({"ok": False, "mensaje": "Se requiere un array de estadisticas."}), 400

    conn = None
    try:
        # ── 0. Tipo de entrenamiento desde MySQL ──────────────────────────
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT tipo FROM entrenamiento WHERE id_entrenamiento = %s",
            (id_entrenamiento,),
        )
        row = cur.fetchone()
        tipo_raw = (row.get("tipo") or "") if row else ""
        tipo = (
            tipo_raw.lower()
            .replace("á","a").replace("é","e").replace("í","i")
            .replace("ó","o").replace("ú","u")
        )  # "fisico" | "tecnico" | "tactico" | "mixto"

        db = get_mongo_db()

        CAMPOS_IDENTIDAD = {"cedula_jugador", "nombre"}
        CAMPOS_FLOAT = {"distancia_km", "nota", "cumplimiento_sistema"}
        CAMPOS_INT   = {"sprints", "series", "repeticiones", "pases_completados",
                        "balones_usados", "conos_usados"}

        jugadores = []
        for item in datos:
            entrada = {
                "identificacion_jugador": item.get("cedula_jugador", ""),
                "nombre": item.get("nombre", ""),
            }
            for key, value in item.items():
                if key in CAMPOS_IDENTIDAD:
                    continue
                if key in CAMPOS_FLOAT:
                    try:
                        entrada[key] = float(value) if value != "" else 0.0
                    except (TypeError, ValueError):
                        entrada[key] = 0.0
                elif key in CAMPOS_INT:
                    try:
                        entrada[key] = int(value) if value != "" else 0
                    except (TypeError, ValueError):
                        entrada[key] = 0
                else:
                    entrada[key] = value if value is not None else ""
            jugadores.append(entrada)

        # ── Computed Pattern: resumen por tipo ────────────────────────────
        notas = [j["nota"] for j in jugadores if j.get("nota", 0) > 0]

        jugador_destacado = ""
        nombre_destacado  = ""
        if notas:
            mejor = max(jugadores, key=lambda j: j.get("nota", 0))
            jugador_destacado = mejor.get("identificacion_jugador", "")
            nombre_destacado  = mejor.get("nombre", "")

        resumen_computado = {
            "total_jugadores":   len(jugadores),
            "jugador_destacado": jugador_destacado,
            "nombre_destacado":  nombre_destacado,
            "tipo_sesion":       tipo_raw,
        }
        if notas:
            resumen_computado["promedio_nota"] = round(sum(notas) / len(notas), 2)

        if tipo in ("fisico", "mixto"):
            distancias = [j["distancia_km"] for j in jugadores if j.get("distancia_km", 0) > 0]
            sprints_l  = [j["sprints"]      for j in jugadores if j.get("sprints", 0)      > 0]
            if distancias:
                resumen_computado["distancia_total_km"] = round(sum(distancias), 1)
            if sprints_l:
                resumen_computado["sprints_total"] = sum(sprints_l)

        if tipo in ("tecnico", "mixto"):
            pases_l = [j["pases_completados"] for j in jugadores if j.get("pases_completados", 0) > 0]
            if pases_l:
                resumen_computado["promedio_pases"] = round(sum(pases_l) / len(pases_l), 1)

        if tipo == "tactico":
            cump_l = [j["cumplimiento_sistema"] for j in jugadores if j.get("cumplimiento_sistema", 0) > 0]
            if cump_l:
                resumen_computado["promedio_cumplimiento"] = round(sum(cump_l) / len(cump_l), 2)

        db["estadisticas_jugador"].update_one(
            {
                "$or": [
                    {"id_entrenamiento_mysql": id_entrenamiento},
                    {"id_entrenamiento": id_entrenamiento},
                ]
            },
            {
                "$set": {
                    "id_entrenamiento_mysql": id_entrenamiento,
                    "jugadores":              jugadores,
                    "count":                  len(jugadores),
                    "resumen_computado":      resumen_computado,
                }
            },
            upsert=True,
        )
        return jsonify({
            "ok":      True,
            "mensaje": f"{len(datos)} estadistica(s) guardadas.",
            "resumen": resumen_computado,
        }), 201

    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


@sesiones_bp.route("/estadisticas/jugador/<string:cedula>", methods=["GET"])
@login_required
def obtener_estadisticas_jugador(cedula):
    try:
        db = get_mongo_db()
        docs = list(db["estadisticas_jugador"].find(
            {"jugadores.identificacion_jugador": cedula}
        ))
        resultado = []
        for doc in docs:
            for j in doc.get("jugadores", []):
                if j.get("identificacion_jugador") == cedula:
                    resultado.append({
                        "id_entrenamiento_mysql": doc.get("id_entrenamiento_mysql"),
                        "fecha":        doc.get("fecha", ""),
                        "categoria":    doc.get("categoria", ""),
                        "distancia_km": j.get("distancia_km", 0),
                        "sprints":      j.get("sprints", 0),
                        "nota":         j.get("nota", 0),
                    })
        return jsonify(resultado), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500


# ----------------------------------------------------------------
# OBSERVACIONES POST-SESION
# ----------------------------------------------------------------

@sesiones_bp.route("/observaciones/campos-comunes", methods=["GET"])
@login_required
def campos_comunes_observaciones():
    try:
        filtro = None
        id_entrenamiento = request.args.get("id_entrenamiento", type=int)
        if id_entrenamiento:
            filtro, contexto = _filtro_mongo_por_contexto(id_entrenamiento)
            if not contexto:
                return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404

        campos = _inferir_campos_coleccion(
            "observaciones_sesion",
            min_frecuencia=MIN_FRECUENCIA_CAMPOS,
            filtro=filtro,
        )
        return jsonify({"campos": campos}), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500

@sesiones_bp.route("/observaciones/<int:id_entrenamiento>", methods=["POST"])
@login_required
def guardar_observaciones(id_entrenamiento):
    d = _limpiar_payload_documento(request.get_json() or {})
    if not d.get("observacion_general"):
        return jsonify({"ok": False, "mensaje": "El campo 'observacion_general' es obligatorio."}), 400
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT estado FROM entrenamiento WHERE id_entrenamiento = %s",
            (id_entrenamiento,),
        )
        row = cur.fetchone()
        if not row:
            return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404

        db = get_mongo_db()
        d["id_entrenamiento"] = id_entrenamiento
        d["id_entrenamiento_mysql"] = id_entrenamiento
        result = db["observaciones_sesion"].update_one(
            {
                "$or": [
                    {"id_entrenamiento": id_entrenamiento},
                    {"id_entrenamiento_mysql": id_entrenamiento},
                ]
            },
            {"$set": d},
            upsert=True,
        )
        return jsonify({
            "ok": True,
            "mensaje": "Observaciones guardadas correctamente.",
            "upserted": result.upserted_id is not None,
        }), 201
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


@sesiones_bp.route("/observaciones/<int:id_entrenamiento>", methods=["GET"])
@login_required
def obtener_observaciones(id_entrenamiento):
    try:
        db = get_mongo_db()
        doc = db["observaciones_sesion"].find_one({
            "$or": [
                {"id_entrenamiento": id_entrenamiento},
                {"id_entrenamiento_mysql": id_entrenamiento},
            ]
        })
        if not doc:
            return jsonify({"ok": False, "mensaje": "No hay observaciones registradas para esta sesion."}), 404
        return jsonify(oid(doc)), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500


# ----------------------------------------------------------------
# DELETE
# ----------------------------------------------------------------

@sesiones_bp.route("/<int:id_entrenamiento>", methods=["DELETE"])
@login_required
def eliminar_plan(id_entrenamiento):
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT id_plan_mongodb FROM entrenamiento WHERE id_entrenamiento = %s",
            (id_entrenamiento,),
        )
        row = cur.fetchone()
        if not row or not row["id_plan_mongodb"]:
            return jsonify({"ok": False, "mensaje": "Este entrenamiento no tiene plan registrado."}), 404

        db = get_mongo_db()
        db["planes_sesion"].delete_one({"_id": ObjectId(row["id_plan_mongodb"])})
        cur.execute(
            "UPDATE entrenamiento SET id_plan_mongodb = NULL WHERE id_entrenamiento = %s",
            (id_entrenamiento,),
        )
        conn.commit()
        return jsonify({"ok": True, "mensaje": "Plan eliminado correctamente."}), 200
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


@sesiones_bp.route("/estadisticas/<int:id_entrenamiento>", methods=["DELETE"])
@login_required
def eliminar_estadisticas(id_entrenamiento):
    try:
        db = get_mongo_db()
        result = db["estadisticas_jugador"].delete_one({
            "$or": [
                {"id_entrenamiento": id_entrenamiento},
                {"id_entrenamiento_mysql": id_entrenamiento},
            ]
        })
        if result.deleted_count == 0:
            return jsonify({"ok": False, "mensaje": "No hay estadisticas para eliminar."}), 404
        return jsonify({"ok": True, "mensaje": "Estadisticas eliminadas correctamente."}), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500


@sesiones_bp.route("/observaciones/<int:id_entrenamiento>", methods=["DELETE"])
@login_required
def eliminar_observaciones(id_entrenamiento):
    try:
        db = get_mongo_db()
        result = db["observaciones_sesion"].delete_one({
            "$or": [
                {"id_entrenamiento": id_entrenamiento},
                {"id_entrenamiento_mysql": id_entrenamiento},
            ]
        })
        if result.deleted_count == 0:
            return jsonify({"ok": False, "mensaje": "No hay observaciones para eliminar."}), 404
        return jsonify({"ok": True, "mensaje": "Observaciones eliminadas correctamente."}), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500