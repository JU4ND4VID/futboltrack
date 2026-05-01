# ================================================================
# FutbolTrack - app/routes/entrenamientos.py
# GET    /api/entrenamientos
# POST   /api/entrenamientos       -> sp_crear_entrenamiento
# PUT    /api/entrenamientos/:id   -> sp_actualizar_estado_entrenamiento
# DELETE /api/entrenamientos/:id
# ================================================================
from flask import Blueprint, request, jsonify
from app.db.mysql_conn import get_mysql

entrenamientos_bp = Blueprint("entrenamientos", __name__)


@entrenamientos_bp.route("/", methods=["GET"])
def listar_entrenamientos():
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute("""
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
            JOIN lugar      l ON e.id_lugar         = l.id_lugar
            JOIN categoria  c ON e.id_categoria     = c.id_categoria
            JOIN entrenador en ON e.cedula_entrenador = en.cedula_entrenador
            JOIN persona    p  ON en.cedula_entrenador = p.identificacion
            ORDER BY e.fecha DESC, e.hora_inicio DESC
        """)
        # Convertir TIME y DATE a string para JSON
        rows = []
        for row in cur.fetchall():
            row["fecha"]       = str(row["fecha"])
            row["hora_inicio"] = str(row["hora_inicio"])
            row["hora_fin"]    = str(row["hora_fin"])
            rows.append(row)
        return jsonify(rows), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@entrenamientos_bp.route("/", methods=["POST"])
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
        cur  = conn.cursor()
        conn.start_transaction()

        cur.callproc("sp_crear_entrenamiento", [
            d["fecha"], d["hora_inicio"], d["hora_fin"], d["tipo"],
            int(d["id_lugar"]), int(d["id_categoria"]), d["cedula_entrenador"],
            ""  # OUT param_mensaje
        ])

        cur.execute("SELECT @_sp_crear_entrenamiento_7 AS msg")
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


@entrenamientos_bp.route("/<int:id_entrenamiento>", methods=["PUT"])
def actualizar_estado(id_entrenamiento):
    d            = request.get_json() or {}
    nuevo_estado = d.get("estado", "").strip()

    if not nuevo_estado:
        return jsonify({"ok": False, "mensaje": "El campo 'estado' es obligatorio."}), 400

    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor()
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
def eliminar_entrenamiento(id_entrenamiento):
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)

        # Verificar que no este realizado
        cur.execute("SELECT estado FROM entrenamiento WHERE id_entrenamiento = %s",
                    (id_entrenamiento,))
        row = cur.fetchone()
        if not row:
            return jsonify({"ok": False, "mensaje": "Entrenamiento no encontrado."}), 404
        if row["estado"] == "realizado":
            return jsonify({"ok": False,
                            "mensaje": "No se puede eliminar un entrenamiento ya realizado."}), 400

        conn.start_transaction()
        # asistencia se elimina en cascada por FK (ON DELETE CASCADE en DDL)
        cur.execute("DELETE FROM entrenamiento WHERE id_entrenamiento = %s",
                    (id_entrenamiento,))
        conn.commit()
        return jsonify({"ok": True, "mensaje": "Entrenamiento eliminado correctamente."}), 200

    except Exception as e:
        if conn: conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()
