# ================================================================
# FutbolTrack - app/routes/catalogos.py
# GET /api/lugares
# GET /api/categorias
# POST/PUT/DELETE /api/categorias - gestion por administrador
# ================================================================
from flask import Blueprint, jsonify, request
from app.db.mysql_conn import get_mysql
from app.routes.auth import login_required, admin_required

catalogos_bp = Blueprint("catalogos", __name__)


@catalogos_bp.route("/lugares", methods=["GET"])
@login_required
def listar_lugares():
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT id_lugar, nombre, direccion FROM lugar ORDER BY nombre")
        return jsonify(cur.fetchall()), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


@catalogos_bp.route("/categorias", methods=["GET"])
@login_required
def listar_categorias():
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT
                c.id_categoria,
                c.nombre,
                c.edad_minima AS rango_edad_min,
                c.edad_maxima AS rango_edad_max,
                fn_contar_sesiones_categoria(c.id_categoria) AS total_sesiones
            FROM categoria c
            ORDER BY c.edad_minima, c.nombre
        """)
        return jsonify(cur.fetchall()), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


def _validar_categoria_payload(data):
    nombre = str(data.get("nombre", "")).strip()
    edad_min = data.get("edad_minima", data.get("rango_edad_min"))
    edad_max = data.get("edad_maxima", data.get("rango_edad_max"))

    if len(nombre) < 2 or len(nombre) > 60:
        return None, "El nombre de la categoria debe tener entre 2 y 60 caracteres."

    try:
        edad_min = int(edad_min)
        edad_max = int(edad_max)
    except (TypeError, ValueError):
        return None, "Las edades de la categoria deben ser numeros enteros."

    if edad_min < 4 or edad_max > 30:
        return None, "Las edades deben estar entre 4 y 30 anos."
    if edad_min > edad_max:
        return None, "La edad minima no puede ser mayor que la edad maxima."

    return {
        "nombre": nombre,
        "edad_minima": edad_min,
        "edad_maxima": edad_max,
    }, None


@catalogos_bp.route("/categorias", methods=["POST"])
@admin_required
def crear_categoria():
    data, error = _validar_categoria_payload(request.get_json() or {})
    if error:
        return jsonify({"ok": False, "mensaje": error}), 400

    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)

        cur.execute("SELECT id_categoria FROM categoria WHERE LOWER(nombre) = LOWER(%s)", (data["nombre"],))
        if cur.fetchone():
            return jsonify({"ok": False, "mensaje": "Ya existe una categoria con ese nombre."}), 400

        cur.execute(
            "INSERT INTO categoria (nombre, edad_minima, edad_maxima) VALUES (%s, %s, %s)",
            (data["nombre"], data["edad_minima"], data["edad_maxima"]),
        )
        conn.commit()
        return jsonify({
            "ok": True,
            "mensaje": "Categoria creada correctamente.",
            "id_categoria": cur.lastrowid,
        }), 201
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


@catalogos_bp.route("/categorias/<int:id_categoria>", methods=["PUT"])
@admin_required
def actualizar_categoria(id_categoria):
    data, error = _validar_categoria_payload(request.get_json() or {})
    if error:
        return jsonify({"ok": False, "mensaje": error}), 400

    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)

        cur.execute("SELECT id_categoria FROM categoria WHERE id_categoria = %s", (id_categoria,))
        if not cur.fetchone():
            return jsonify({"ok": False, "mensaje": "Categoria no encontrada."}), 404

        cur.execute(
            """
            SELECT id_categoria
              FROM categoria
             WHERE LOWER(nombre) = LOWER(%s)
               AND id_categoria <> %s
            """,
            (data["nombre"], id_categoria),
        )
        if cur.fetchone():
            return jsonify({"ok": False, "mensaje": "Ya existe otra categoria con ese nombre."}), 400

        cur.execute(
            """
            UPDATE categoria
               SET nombre = %s,
                   edad_minima = %s,
                   edad_maxima = %s
             WHERE id_categoria = %s
            """,
            (data["nombre"], data["edad_minima"], data["edad_maxima"], id_categoria),
        )
        conn.commit()
        return jsonify({"ok": True, "mensaje": "Categoria actualizada correctamente."}), 200
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


@catalogos_bp.route("/categorias/<int:id_categoria>", methods=["DELETE"])
@admin_required
def eliminar_categoria(id_categoria):
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)

        cur.execute("SELECT id_categoria FROM categoria WHERE id_categoria = %s", (id_categoria,))
        if not cur.fetchone():
            return jsonify({"ok": False, "mensaje": "Categoria no encontrada."}), 404

        usos = []
        for tabla, etiqueta in (
            ("entrenador", "entrenadores"),
            ("jugador", "jugadores"),
            ("entrenamiento", "entrenamientos"),
        ):
            cur.execute(f"SELECT COUNT(*) AS total FROM {tabla} WHERE id_categoria = %s", (id_categoria,))
            total = cur.fetchone()["total"]
            if total:
                usos.append(f"{total} {etiqueta}")

        if usos:
            return jsonify({
                "ok": False,
                "mensaje": "No se puede eliminar la categoria porque esta asociada a " + ", ".join(usos) + ".",
            }), 400

        cur.execute("DELETE FROM categoria WHERE id_categoria = %s", (id_categoria,))
        conn.commit()
        return jsonify({"ok": True, "mensaje": "Categoria eliminada correctamente."}), 200
    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()
