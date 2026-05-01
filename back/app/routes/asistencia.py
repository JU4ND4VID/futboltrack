# ================================================================
# FutbolTrack - app/routes/asistencia.py
# GET  /api/asistencia/:id_entrenamiento
# POST /api/asistencia/:id_entrenamiento -> sp_registrar_asistencia_sesion
# ================================================================
import json
from flask import Blueprint, request, jsonify
from app.db.mysql_conn import get_mysql

asistencia_bp = Blueprint("asistencia", __name__)


@asistencia_bp.route("/<int:id_entrenamiento>", methods=["GET"])
def obtener_asistencia(id_entrenamiento):
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT
                a.identificacion_jugador AS cedula_jugador,
                CONCAT(p.nombre, ' ', p.apellido) AS jugador,
                j.posicion,
                a.estado_asistencia,
                a.observacion,
                fn_calcular_porcentaje_asistencia(a.identificacion_jugador) AS pct_asistencia
            FROM asistencia  a
            JOIN jugador     j ON a.identificacion_jugador = j.identificacion_jugador
            JOIN persona     p ON j.identificacion_jugador = p.identificacion
            WHERE a.id_entrenamiento = %s
            ORDER BY p.apellido
        """, (id_entrenamiento,))
        return jsonify(cur.fetchall()), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@asistencia_bp.route("/<int:id_entrenamiento>", methods=["POST"])
def registrar_asistencia(id_entrenamiento):
    """
    Body esperado:
    {
      "asistencia": [
        {"id": "1006748391", "estado": "presente",    "obs": ""},
        {"id": "1007123456", "estado": "ausente",     "obs": "Sin aviso"},
        {"id": "1006987654", "estado": "justificado", "obs": "Certificado medico"}
      ]
    }
    """
    d           = request.get_json() or {}
    lista       = d.get("asistencia", [])

    if not isinstance(lista, list) or len(lista) == 0:
        return jsonify({"ok": False,
                        "mensaje": "Se requiere un array 'asistencia' con al menos un jugador."}), 400

    # Convertir la lista Python a JSON string para el SP
    json_asistencia = json.dumps(lista)

    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor()
        conn.start_transaction()

        cur.callproc("sp_registrar_asistencia_sesion",
                     [id_entrenamiento, json_asistencia, ""])

        cur.execute("SELECT @_sp_registrar_asistencia_sesion_2 AS msg")
        resultado = (cur.fetchone() or [None])[0]

        if resultado and resultado.startswith("ERROR"):
            conn.rollback()
            return jsonify({"ok": False, "mensaje": resultado}), 400

        conn.commit()
        return jsonify({"ok": True, "mensaje": resultado}), 200

    except Exception as e:
        if conn: conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()
