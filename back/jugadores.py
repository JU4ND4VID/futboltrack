# ================================================================
# FutbolTrack - app/routes/jugadores.py
# ================================================================
from flask import Blueprint, request, jsonify
from app.db.mysql_conn import get_mysql
from app.routes.auth import login_required, admin_required

jugadores_bp = Blueprint("jugadores", __name__)


def _format_jugador(row):
    if row.get("fecha_nacimiento"):
        row["fecha_nacimiento"] = str(row["fecha_nacimiento"])
    return row


# ── NUEVA función auxiliar ────────────────────────────────────────────────────
def _calcular_id_categoria(fecha_nacimiento_str: str) -> int | None:
    """
    Calcula la edad del jugador y consulta la tabla `categoria`
    para devolver el id_categoria que corresponda según
    edad_minima y edad_maxima.
    Retorna None si no existe ninguna categoría para esa edad.
    """
    from datetime import date
    try:
        fn = date.fromisoformat(str(fecha_nacimiento_str))
    except ValueError:
        return None

    hoy  = date.today()
    edad = hoy.year - fn.year - ((hoy.month, hoy.day) < (fn.month, fn.day))

    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute(
            "SELECT id_categoria FROM categoria "
            "WHERE %s BETWEEN edad_minima AND edad_maxima "
            "LIMIT 1",
            (edad,)
        )
        row = cur.fetchone()
        return row["id_categoria"] if row else None
    finally:
        if conn: conn.close()
# ─────────────────────────────────────────────────────────────────────────────


@jugadores_bp.route("/", methods=["GET"])
@login_required
def listar_jugadores():
    """
    Si se pasa ?id_categoria=N filtra por esa categoría.
    El frontend envía la categoría del entrenador en sesión.
    """
    conn = None
    try:
        id_categoria = request.args.get("id_categoria", type=int)

        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)

        query = """
            SELECT
                j.identificacion_jugador,
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
        """

        if id_categoria:
            query += " WHERE j.id_categoria = %s ORDER BY c.nombre, p.apellido"
            cur.execute(query, (id_categoria,))
        else:
            query += " ORDER BY c.nombre, p.apellido"
            cur.execute(query)

        return jsonify([_format_jugador(r) for r in cur.fetchall()]), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()

@jugadores_bp.route("/<string:cedula>", methods=["GET"])
@login_required
def obtener_jugador(cedula):
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT
                j.identificacion_jugador,
                p.nombre,
                p.apellido,
                j.fecha_nacimiento,
                j.posicion,
                j.id_categoria,
                c.nombre                  AS categoria,
                fn_calcular_porcentaje_asistencia(j.identificacion_jugador) AS pct_asistencia,
                fn_calcular_edad_jugador(j.fecha_nacimiento) AS edad,
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
            WHERE j.identificacion_jugador = %s
        """, (cedula,))
        row = cur.fetchone()
        if not row:
            return jsonify({"ok": False, "mensaje": "Jugador no encontrado."}), 404
        return jsonify(_format_jugador(row)), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@jugadores_bp.route("/", methods=["POST"])
@admin_required
def crear_jugador():
    d = request.get_json() or {}

    # id_categoria ya NO es obligatorio desde el frontend — se calcula aquí
    campos_requeridos = [
        "identificacion_jugador", "nombre_jugador", "apellido_jugador",
        "fecha_nacimiento", "posicion",
        "cedula_acudiente", "nombre_acudiente", "apellido_acudiente",
        "telefono_acudiente", "parentesco"
    ]
    for campo in campos_requeridos:
        if not str(d.get(campo, "")).strip():
            return jsonify({"ok": False, "mensaje": f"Campo obligatorio faltante: {campo}"}), 400

    # ── Calcular categoría por fecha de nacimiento ───────────────────────────
    id_categoria = _calcular_id_categoria(d["fecha_nacimiento"])
    if id_categoria is None:
        return jsonify({
            "ok": False,
            "mensaje": "No existe una categoría registrada para la edad del jugador. "
                       "Verifica la fecha de nacimiento o las categorías en el sistema."
        }), 400
    # ────────────────────────────────────────────────────────────────────────

    conn = None
    try:
        from datetime import datetime
        fecha_raw = d["fecha_nacimiento"]
        try:
            fecha = datetime.strptime(fecha_raw, "%Y-%m-%d").date()
        except ValueError:
            try:
                fecha = datetime.strptime(fecha_raw, "%m/%d/%Y").date()
            except ValueError:
                return jsonify({"ok": False, "mensaje": "Formato de fecha inválido."}), 400

        conn = get_mysql()
        conn.autocommit = True
        cur = conn.cursor()

        cur.execute("SET @msg = ''")
        cur.execute("""
            CALL sp_registrar_jugador_completo(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, @msg)
        """, (
            d["identificacion_jugador"], d["nombre_jugador"],  d["apellido_jugador"],
            fecha,                       d["posicion"],        id_categoria,   # ← calculado
            d["cedula_acudiente"],       d["nombre_acudiente"],d["apellido_acudiente"],
            d["telefono_acudiente"],     d["parentesco"]
        ))

        while cur.nextset():
            pass

        cur.execute("SELECT @msg AS msg")
        row = cur.fetchone()
        resultado = row[0] if row else None

        if not resultado:
            return jsonify({"ok": False,
                            "mensaje": "Error al crear el jugador. Verifica los datos."}), 400
        if resultado.startswith("ERROR"):
            return jsonify({"ok": False,
                            "mensaje": resultado.replace("ERROR: ", "")}), 400

        return jsonify({"ok": True, "mensaje": "Jugador creado correctamente.",
                        "id_categoria_asignada": id_categoria}), 201

    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@jugadores_bp.route("/<string:cedula>", methods=["PUT"])
@admin_required
def actualizar_jugador(cedula):
    d = request.get_json() or {}
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)

        cur.execute(
            "SELECT identificacion_jugador FROM jugador WHERE identificacion_jugador = %s",
            (cedula,)
        )
        if not cur.fetchone():
            return jsonify({"ok": False, "mensaje": "Jugador no encontrado."}), 404

        if conn.in_transaction:
            conn.rollback()
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

        if any(k in d for k in ("nombre_acudiente", "apellido_acudiente",
                                 "telefono_acudiente", "parentesco")):
            cur.execute("""
                SELECT cedula_acudiente FROM acudiente
                WHERE identificacion_jugador = %s
            """, (cedula,))
            acudiente_row = cur.fetchone()

            if acudiente_row:
                cedula_acudiente = acudiente_row["cedula_acudiente"]

                if d.get("nombre_acudiente") or d.get("apellido_acudiente"):
                    cur.execute("""
                        UPDATE persona
                           SET nombre   = COALESCE(%s, nombre),
                               apellido = COALESCE(%s, apellido)
                         WHERE identificacion = %s
                    """, (d.get("nombre_acudiente"), d.get("apellido_acudiente"),
                          cedula_acudiente))

                cur.execute("""
                    UPDATE acudiente
                       SET telefono   = COALESCE(%s, telefono),
                           parentesco = COALESCE(%s, parentesco)
                     WHERE cedula_acudiente = %s
                       AND identificacion_jugador = %s
                """, (d.get("telefono_acudiente"), d.get("parentesco"),
                      cedula_acudiente, cedula))

        conn.commit()
        return jsonify({"ok": True, "mensaje": "Jugador actualizado correctamente."}), 200

    except Exception as e:
        if conn: conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@jugadores_bp.route("/<string:cedula>", methods=["DELETE"])
@admin_required
def eliminar_jugador(cedula):
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor()
        if conn.in_transaction:
            conn.rollback()
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