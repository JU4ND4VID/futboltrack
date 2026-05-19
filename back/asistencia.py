# ================================================================
# FutbolTrack - app/routes/asistencia.py
# GET  /api/asistencia/<id_entrenamiento>
# POST /api/asistencia/<id_entrenamiento>  -> sp_registrar_asistencia_sesion
# ================================================================
import json
from flask import Blueprint, request, jsonify
from app.db.mysql_conn import get_mysql
from app.routes.auth import login_required

asistencia_bp = Blueprint("asistencia", __name__)


@asistencia_bp.route("/<int:id_entrenamiento>", methods=["GET"])
@login_required
def listar_asistencia(id_entrenamiento):
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute(
            """
            SELECT
                a.id_entrenamiento,
                a.identificacion_jugador,
                p.nombre,
                p.apellido,
                a.estado_asistencia
            FROM asistencia a
            JOIN persona p ON a.identificacion_jugador = p.identificacion
            WHERE a.id_entrenamiento = %s
            ORDER BY p.apellido
        """,
            (id_entrenamiento,),
        )
        return jsonify(cur.fetchall()), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


@asistencia_bp.route("/<int:id_entrenamiento>", methods=["POST"])
@login_required
def registrar_asistencia(id_entrenamiento):
    """
    Body ejemplo:
    [
      {"identificacion_jugador": "1006748391", "estado_asistencia": "presente"},
      {"identificacion_jugador": "1007123456", "estado_asistencia": "ausente"}
    ]
    """
    datos = request.get_json() or []
    if not isinstance(datos, list) or len(datos) == 0:
        return (
            jsonify({"ok": False, "mensaje": "Se requiere un array de asistencias."}),
            400,
        )

    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor()
        if conn.in_transaction:
            conn.rollback()
        conn.start_transaction()
        
        datos_transformados = [
            {"id": d["identificacion_jugador"], "estado": d["estado_asistencia"]}
            for d in datos
        ]
        payload = json.dumps(datos_transformados)

        cur.callproc("sp_registrar_asistencia_sesion", [id_entrenamiento, payload, ""])

        cur.execute("SELECT @_sp_registrar_asistencia_sesion_2 AS msg")
        resultado = (cur.fetchone() or [None])[0]

        if resultado and resultado.startswith("ERROR"):
            conn.rollback()
            return jsonify({"ok": False, "mensaje": resultado}), 400

        conn.commit()
        return jsonify({"ok": True, "mensaje": resultado}), 201

    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()
