# ================================================================
# FutbolTrack - app/routes/sesiones.py
# Planes de sesion y estadisticas almacenados en MongoDB.
# El puente entre MySQL y MongoDB es el campo id_plan_mongodb
# de la tabla entrenamiento.
#
# GET  /api/sesion/:id_entrenamiento
# POST /api/sesion/:id_entrenamiento
# PUT  /api/sesion/:id_entrenamiento
# GET  /api/sesion/estadisticas/:id_entrenamiento
# POST /api/sesion/estadisticas/:id_entrenamiento
# GET  /api/sesion/estadisticas/jugador/:cedula
# ================================================================
from flask import Blueprint, request, jsonify
from bson  import ObjectId
from bson.errors import InvalidId
from app.db.mysql_conn import get_mysql
from app.db.mongo_conn import get_mongo_db

sesiones_bp = Blueprint("sesiones", __name__)


def object_id_to_str(doc):
    """Convierte _id de ObjectId a string para poder serializar a JSON."""
    if doc and "_id" in doc:
        doc["_id"] = str(doc["_id"])
    return doc


# ----------------------------------------------------------------
# PLANES DE SESION
# ----------------------------------------------------------------

@sesiones_bp.route("/<int:id_entrenamiento>", methods=["GET"])
def obtener_plan(id_entrenamiento):
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT id_plan_mongodb FROM entrenamiento
            WHERE id_entrenamiento = %s
        """, (id_entrenamiento,))
        row = cur.fetchone()

        if not row:
            return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404
        if not row["id_plan_mongodb"]:
            return jsonify({"ok": False, "mensaje": "Este entrenamiento no tiene plan registrado aun."}), 404

        db  = get_mongo_db()
        doc = db["planes_sesion"].find_one({"_id": ObjectId(row["id_plan_mongodb"])})
        if not doc:
            return jsonify({"ok": False, "mensaje": "Plan no encontrado en MongoDB."}), 404

        return jsonify(object_id_to_str(doc)), 200

    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@sesiones_bp.route("/<int:id_entrenamiento>", methods=["POST"])
def crear_plan(id_entrenamiento):
    """
    Body ejemplo:
    {
      "calentamiento": "Trote suave 10 min",
      "bloques": [
        {"nombre": "Tecnica", "duracion_min": 30, "ejercicios": ["Conduccion", "Pase"]},
        {"nombre": "Partido reducido", "duracion_min": 20, "ejercicios": ["4v4"]}
      ],
      "materiales": ["conos", "balones x10"],
      "vuelta_calma": "Estiramientos 5 min"
    }
    """
    d = request.get_json() or {}
    if not d:
        return jsonify({"ok": False, "mensaje": "El body del plan no puede estar vacio."}), 400

    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)

        # Verificar que el entrenamiento exista y no tenga plan
        cur.execute("""
            SELECT id_plan_mongodb FROM entrenamiento
            WHERE id_entrenamiento = %s
        """, (id_entrenamiento,))
        row = cur.fetchone()

        if not row:
            return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404
        if row["id_plan_mongodb"]:
            return jsonify({"ok": False,
                            "mensaje": "Este entrenamiento ya tiene plan. Use PUT para actualizar."}), 400

        # Insertar en MongoDB
        d["id_entrenamiento_mysql"] = id_entrenamiento
        db     = get_mongo_db()
        result = db["planes_sesion"].insert_one(d)
        nuevo_id = str(result.inserted_id)

        # Actualizar el puente en MySQL
        conn.start_transaction()
        cur.execute("""
            UPDATE entrenamiento SET id_plan_mongodb = %s
            WHERE id_entrenamiento = %s
        """, (nuevo_id, id_entrenamiento))
        conn.commit()

        return jsonify({"ok": True, "id_plan_mongodb": nuevo_id}), 201

    except Exception as e:
        if conn: conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@sesiones_bp.route("/<int:id_entrenamiento>", methods=["PUT"])
def actualizar_plan(id_entrenamiento):
    d = request.get_json() or {}
    if not d:
        return jsonify({"ok": False, "mensaje": "El body del plan no puede estar vacio."}), 400

    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT id_plan_mongodb FROM entrenamiento
            WHERE id_entrenamiento = %s
        """, (id_entrenamiento,))
        row = cur.fetchone()

        if not row or not row["id_plan_mongodb"]:
            return jsonify({"ok": False, "mensaje": "No existe un plan para actualizar. Use POST primero."}), 404

        db = get_mongo_db()
        db["planes_sesion"].update_one(
            {"_id": ObjectId(row["id_plan_mongodb"])},
            {"$set": d}
        )
        return jsonify({"ok": True, "mensaje": "Plan actualizado correctamente."}), 200

    except InvalidId:
        return jsonify({"ok": False, "mensaje": "El id_plan_mongodb guardado no es valido."}), 500
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


# ----------------------------------------------------------------
# ESTADISTICAS POR SESION
# ----------------------------------------------------------------

@sesiones_bp.route("/estadisticas/<int:id_entrenamiento>", methods=["GET"])
def obtener_estadisticas_sesion(id_entrenamiento):
    try:
        db   = get_mongo_db()
        docs = list(db["estadisticas_jugador"].find(
            {"id_entrenamiento": id_entrenamiento}
        ))
        return jsonify([object_id_to_str(d) for d in docs]), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500


@sesiones_bp.route("/estadisticas/<int:id_entrenamiento>", methods=["POST"])
def guardar_estadisticas_sesion(id_entrenamiento):
    """
    Body ejemplo:
    [
      {"cedula_jugador": "1006748391", "distancia_km": 7.2, "sprints": 15, "nota": 8},
      {"cedula_jugador": "1007123456", "distancia_km": 6.8, "sprints": 12, "nota": 7}
    ]
    """
    datos = request.get_json() or []
    if not isinstance(datos, list) or len(datos) == 0:
        return jsonify({"ok": False, "mensaje": "Se requiere un array de estadisticas."}), 400

    try:
        db = get_mongo_db()
        for item in datos:
            item["id_entrenamiento"] = id_entrenamiento
            db["estadisticas_jugador"].update_one(
                {"id_entrenamiento": id_entrenamiento,
                 "cedula_jugador":   item.get("cedula_jugador")},
                {"$set": item},
                upsert=True
            )
        return jsonify({"ok": True, "mensaje": f"{len(datos)} estadistica(s) guardadas."}), 201

    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500


@sesiones_bp.route("/estadisticas/jugador/<string:cedula>", methods=["GET"])
def obtener_estadisticas_jugador(cedula):
    try:
        db   = get_mongo_db()
        docs = list(db["estadisticas_jugador"].find({"cedula_jugador": cedula}))
        return jsonify([object_id_to_str(d) for d in docs]), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
