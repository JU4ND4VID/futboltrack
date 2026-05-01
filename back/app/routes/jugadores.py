# ================================================================
# FutbolTrack - app/routes/jugadores.py
# GET    /api/jugadores
# POST   /api/jugadores       -> sp_registrar_jugador_completo
# PUT    /api/jugadores/:id
# DELETE /api/jugadores/:id   -> sp_eliminar_jugador
#
# NOTA: Los SPs no manejan transacciones internamente.
#       Python abre START TRANSACTION / COMMIT / ROLLBACK.
# ================================================================
from flask import Blueprint, request, jsonify
from app.db.mysql_conn import get_mysql

jugadores_bp = Blueprint("jugadores", __name__)


@jugadores_bp.route("/", methods=["GET"])
def listar_jugadores():
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT
                j.identificacion_jugador AS cedula,
                p.nombre,
                p.apellido,
                j.fecha_nacimiento,
                j.posicion,
                j.id_categoria,
                c.nombre                  AS categoria,
                fn_calcular_porcentaje_asistencia(j.identificacion_jugador) AS pct_asistencia,
                a.cedula_acudiente,
                pa.nombre                 AS nombre_acudiente,
                pa.apellido               AS apellido_acudiente,
                a.telefono                AS telefono_acudiente,
                a.parentesco
            FROM jugador   j
            JOIN persona   p  ON j.identificacion_jugador = p.identificacion
            JOIN categoria c  ON j.id_categoria = c.id_categoria
            LEFT JOIN acudiente a  ON j.identificacion_jugador = a.identificacion_jugador
            LEFT JOIN persona  pa  ON a.cedula_acudiente = pa.identificacion
            ORDER BY c.nombre, p.apellido
        """)
        return jsonify(cur.fetchall()), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@jugadores_bp.route("/", methods=["POST"])
def crear_jugador():
    d = request.get_json() or {}

    campos_requeridos = [
        "identificacion_jugador", "nombre_jugador", "apellido_jugador",
        "fecha_nacimiento", "posicion", "id_categoria",
        "cedula_acudiente", "nombre_acudiente", "apellido_acudiente",
        "telefono_acudiente", "parentesco"
    ]
    for campo in campos_requeridos:
        if not str(d.get(campo, "")).strip():
            return jsonify({"ok": False, "mensaje": f"Campo obligatorio faltante: {campo}"}), 400

    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor()

        # Python maneja la transaccion porque el SP no tiene COMMIT interno
        conn.start_transaction()

        cur.callproc("sp_registrar_jugador_completo", [
            d["identificacion_jugador"], d["nombre_jugador"],  d["apellido_jugador"],
            d["fecha_nacimiento"],       d["posicion"],        int(d["id_categoria"]),
            d["cedula_acudiente"],       d["nombre_acudiente"],d["apellido_acudiente"],
            d["telefono_acudiente"],     d["parentesco"],
            ""  # OUT param_mensaje
        ])

        # Leer el parametro OUT
        cur.execute("SELECT @_sp_registrar_jugador_completo_11 AS msg")
        resultado = (cur.fetchone() or [None])[0]

        if resultado and resultado.startswith("ERROR"):
            conn.rollback()
            return jsonify({"ok": False, "mensaje": resultado}), 400

        conn.commit()
        return jsonify({"ok": True, "mensaje": resultado}), 201

    except Exception as e:
        if conn: conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@jugadores_bp.route("/<string:cedula>", methods=["PUT"])
def actualizar_jugador(cedula):
    d = request.get_json() or {}
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor()
        conn.start_transaction()

        cur.execute("""
            UPDATE persona SET nombre = %s, apellido = %s
            WHERE identificacion = %s
        """, (d.get("nombre"), d.get("apellido"), cedula))

        cur.execute("""
            UPDATE jugador
               SET fecha_nacimiento = %s, posicion = %s, id_categoria = %s
             WHERE identificacion_jugador = %s
        """, (d.get("fecha_nacimiento"), d.get("posicion"),
              d.get("id_categoria"), cedula))

        if cur.rowcount == 0:
            conn.rollback()
            return jsonify({"ok": False, "mensaje": "Jugador no encontrado."}), 404

        conn.commit()
        return jsonify({"ok": True, "mensaje": "Jugador actualizado correctamente."}), 200

    except Exception as e:
        if conn: conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@jugadores_bp.route("/<string:cedula>", methods=["DELETE"])
def eliminar_jugador(cedula):
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor()
        conn.start_transaction()

        cur.callproc("sp_eliminar_jugador", [cedula, ""])
        cur.execute("SELECT @_sp_eliminar_jugador_1 AS msg")
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
