# ================================================================
# FutbolTrack - app/routes/entrenamientos.py
# GET    /api/entrenamientos
# GET    /api/entrenamientos/<id>     [NUEVO - fix #5]
# POST   /api/entrenamientos
# PUT    /api/entrenamientos/<id>
# DELETE /api/entrenamientos/<id>
# ================================================================
from flask import Blueprint, request, jsonify
from app.db.mysql_conn import get_mysql
from app.routes.auth import login_required

entrenamientos_bp = Blueprint("entrenamientos", __name__)


def _format_row(row):
    """
    Fix #4: timedelta de Python se convierte a 'H:MM:SS' en lugar de
    '0:08:00'. Usamos isoformat() en el timedelta directamente.
    """
    import datetime
    if isinstance(row.get("fecha"), datetime.date):
        row["fecha"] = row["fecha"].isoformat()          # '2026-06-10'
    if isinstance(row.get("hora_inicio"), datetime.timedelta):
        total = int(row["hora_inicio"].total_seconds())
        row["hora_inicio"] = f"{total//3600:02d}:{(total%3600)//60:02d}"
    elif row.get("hora_inicio"):
        row["hora_inicio"] = str(row["hora_inicio"])
    if isinstance(row.get("hora_fin"), datetime.timedelta):
        total = int(row["hora_fin"].total_seconds())
        row["hora_fin"] = f"{total//3600:02d}:{(total%3600)//60:02d}"
    elif row.get("hora_fin"):
        row["hora_fin"] = str(row["hora_fin"])
    return row


BASE_QUERY = """
    SELECT
        e.id_entrenamiento,
        e.fecha,
        e.hora_inicio,
        e.hora_fin,
        e.tipo,
        e.estado,
        e.observacion,
        e.id_plan_mongodb,
        e.id_lugar,
        l.nombre      AS lugar_nombre,
        e.id_categoria,
        c.nombre      AS categoria_nombre,
        e.cedula_entrenador,
        CONCAT(p.nombre, ' ', p.apellido) AS entrenador_nombre,
        fn_contar_sesiones_categoria(e.id_categoria) AS total_sesiones_categoria
    FROM entrenamiento e
    JOIN lugar      l  ON e.id_lugar          = l.id_lugar
    JOIN categoria  c  ON e.id_categoria      = c.id_categoria
    JOIN entrenador en ON e.cedula_entrenador = en.cedula_entrenador
    JOIN persona    p  ON en.cedula_entrenador = p.identificacion
"""


@entrenamientos_bp.route("/", methods=["GET"])
@login_required
def listar_entrenamientos():
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)

        from flask import session
        tipo_usuario = session.get("tipo_usuario", "entrenador")
        cedula       = session.get("cedula_usuario")

        # Admin ve todos, entrenador solo los suyos
        if tipo_usuario == "admin":
            cur.execute(BASE_QUERY + " ORDER BY e.id_entrenamiento DESC")
        else:
            cur.execute(
                BASE_QUERY + " WHERE e.cedula_entrenador = %s ORDER BY e.id_entrenamiento DESC",
                (cedula,)
            )

        return jsonify([_format_row(r) for r in cur.fetchall()]), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()

@entrenamientos_bp.route("/<int:id_entrenamiento>", methods=["GET"])
@login_required
def obtener_entrenamiento(id_entrenamiento):
    """Detalle de un entrenamiento individual (fix #5)."""
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute(BASE_QUERY + " WHERE e.id_entrenamiento = %s", (id_entrenamiento,))
        row = cur.fetchone()
        if not row:
            return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404
        return jsonify(_format_row(row)), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@entrenamientos_bp.route("/", methods=["POST"])
@login_required
def crear_entrenamiento():
    d = request.get_json() or {}

    campos_requeridos = ["fecha", "hora_inicio", "hora_fin", "tipo",
                         "id_lugar", "id_categoria", "cedula_entrenador"]
    for campo in campos_requeridos:
        if not str(d.get(campo, "")).strip():
            return jsonify({"ok": False, "mensaje": f"Campo obligatorio faltante: {campo}"}), 400

    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)          # ← dictionary=True para el SELECT final
        if conn.in_transaction:
            conn.rollback()
        conn.start_transaction()

        cur.callproc("sp_crear_entrenamiento", [
            d["fecha"], d["hora_inicio"], d["hora_fin"], d["tipo"],
            int(d["id_lugar"]), int(d["id_categoria"]), d["cedula_entrenador"],
            ""  # OUT param_mensaje
        ])

        # SIGNAL en el SP lanza excepción → si llegamos aquí, el INSERT fue exitoso
        cur.execute("SELECT @_sp_crear_entrenamiento_7 AS msg")
        row = cur.fetchone()                         # dict: {"msg": "OK:5"}
        resultado = row["msg"] if row else None

        conn.commit()

        id_nuevo = None
        if resultado and resultado.startswith("OK:"):
            id_nuevo = int(resultado.split(":")[1])

        return jsonify({"ok": True, "mensaje": "Entrenamiento creado correctamente.",
                        "id": id_nuevo}), 201

    except Exception as e:
        if conn: conn.rollback()
        # Extraer solo el mensaje de usuario del SIGNAL (viene dentro del string)
        msg = str(e)
        # mysql.connector envuelve el mensaje así:
        # "1644 (45000): ERROR: La fecha no puede ser..."
        if "ERROR:" in msg:
            msg = "ERROR:" + msg.split("ERROR:")[1]
        return jsonify({"ok": False, "mensaje": msg}), 400
    finally:
        if conn: conn.close()

@entrenamientos_bp.route("/<int:id_entrenamiento>", methods=["PUT"])
@login_required
def actualizar_estado(id_entrenamiento):
    d            = request.get_json() or {}
    nuevo_estado = d.get("estado", "").strip()

    if not nuevo_estado:
        return jsonify({"ok": False, "mensaje": "El campo 'estado' es obligatorio."}), 400

    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor()
        if conn.in_transaction:
            conn.rollback()
        conn.start_transaction()

        cur.callproc("sp_actualizar_estado_entrenamiento",
                     [id_entrenamiento, nuevo_estado, ""])

        cur.execute("SELECT @_sp_actualizar_estado_entrenamiento_2 AS msg")
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


@entrenamientos_bp.route("/<int:id_entrenamiento>", methods=["DELETE"])
@login_required
def eliminar_entrenamiento(id_entrenamiento):
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)

        cur.execute("SELECT estado FROM entrenamiento WHERE id_entrenamiento = %s",
                    (id_entrenamiento,))
        row = cur.fetchone()
        if not row:
            return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404
        if row["estado"] == "realizado":
            return jsonify({"ok": False,
                            "mensaje": "No se puede eliminar un entrenamiento ya realizado."}), 400

        if conn.in_transaction:
            conn.rollback()
        conn.start_transaction()

        cur.execute("DELETE FROM entrenamiento WHERE id_entrenamiento = %s",
                    (id_entrenamiento,))
        conn.commit()
        return jsonify({"ok": True, "mensaje": "Entrenamiento eliminado correctamente."}), 200

    except Exception as e:
        if conn: conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()
