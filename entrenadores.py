# ================================================================
# FutbolTrack - app/routes/entrenadores.py
# CRUD de entrenadores — solo accesible para administradores.
# Regla de negocio: maximo un entrenador por categoria.
# ================================================================
import re
import bcrypt
from flask import Blueprint, request, jsonify
from app.db.mysql_conn import get_mysql
from app.routes.auth import admin_required

entrenadores_bp = Blueprint("entrenadores", __name__)

BASE_QUERY = """
    SELECT
        e.cedula_entrenador,
        p.nombre,
        p.apellido,
        e.email,
        e.telefono,
        e.id_categoria,
        c.nombre AS categoria_nombre
    FROM entrenador e
    JOIN persona   p ON e.cedula_entrenador = p.identificacion
    JOIN categoria c ON e.id_categoria      = c.id_categoria
"""

SOLO_NUMEROS = re.compile(r"^\d+$")
SOLO_LETRAS = re.compile(r"^[A-Za-zÁÉÍÓÚáéíóúÑñÜü\s]+$")
EMAIL_RE = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")


def _validar_datos_basicos(d, creando=True):
    requeridos = ["nombre", "apellido", "email", "telefono", "id_categoria"]
    if creando:
        requeridos = ["cedula_entrenador", "contrasena", *requeridos]

    for campo in requeridos:
        if not str(d.get(campo, "")).strip():
            return f"Campo obligatorio faltante: {campo}"

    if creando:
        cedula = str(d.get("cedula_entrenador", "")).strip()
        if not SOLO_NUMEROS.match(cedula) or not 6 <= len(cedula) <= 15:
            return "Cedula invalida: debe tener entre 6 y 15 digitos numericos."

    nombre = str(d.get("nombre", "")).strip()
    apellido = str(d.get("apellido", "")).strip()
    if nombre and (not SOLO_LETRAS.match(nombre) or len(nombre) < 2):
        return "Nombre invalido: usa solo letras y minimo 2 caracteres."
    if apellido and (not SOLO_LETRAS.match(apellido) or len(apellido) < 2):
        return "Apellido invalido: usa solo letras y minimo 2 caracteres."

    email = str(d.get("email", "")).strip()
    if email and not EMAIL_RE.match(email):
        return "Email invalido."

    telefono = str(d.get("telefono", "")).strip()
    if telefono and (not SOLO_NUMEROS.match(telefono) or len(telefono) != 10):
        return "Telefono invalido: debe tener 10 digitos numericos."

    if d.get("contrasena") and len(str(d["contrasena"])) < 6:
        return "La contrasena debe tener al menos 6 caracteres."

    try:
        int(d.get("id_categoria"))
    except (TypeError, ValueError):
        return "Categoria invalida."

    return None


def _validar_categoria_disponible(cur, id_categoria, cedula_actual=None):
    cur.execute("SELECT id_categoria, nombre FROM categoria WHERE id_categoria = %s", (id_categoria,))
    categoria = cur.fetchone()
    if not categoria:
        return "La categoria seleccionada no existe."

    params = [id_categoria]
    where_extra = ""
    if cedula_actual:
        where_extra = " AND e.cedula_entrenador <> %s"
        params.append(cedula_actual)

    cur.execute(
        f"""
        SELECT e.cedula_entrenador, p.nombre, p.apellido
          FROM entrenador e
          JOIN persona p ON e.cedula_entrenador = p.identificacion
         WHERE e.id_categoria = %s{where_extra}
         LIMIT 1
        """,
        tuple(params),
    )
    ocupado = cur.fetchone()
    if ocupado:
        nombre = f"{ocupado['nombre']} {ocupado['apellido']}"
        return f"La categoria {categoria['nombre']} ya tiene asignado al entrenador {nombre}."

    return None


# ── Listar ────────────────────────────────────────────────────────

@entrenadores_bp.route("/", methods=["GET"])
@admin_required
def listar_entrenadores():
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute(BASE_QUERY + " ORDER BY p.apellido, p.nombre")
        return jsonify(cur.fetchall()), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


# ── Obtener uno ───────────────────────────────────────────────────

@entrenadores_bp.route("/<string:cedula>", methods=["GET"])
@admin_required
def obtener_entrenador(cedula):
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)
        cur.execute(BASE_QUERY + " WHERE e.cedula_entrenador = %s", (cedula,))
        row = cur.fetchone()
        if not row:
            return jsonify({"ok": False, "mensaje": "Entrenador no encontrado."}), 404
        return jsonify(row), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


# ── Crear ─────────────────────────────────────────────────────────

@entrenadores_bp.route("/", methods=["POST"])
@admin_required
def crear_entrenador():
    d = request.get_json() or {}

    error = _validar_datos_basicos(d, creando=True)
    if error:
        return jsonify({"ok": False, "mensaje": error}), 400

    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)

        cedula = str(d["cedula_entrenador"]).strip()
        email = str(d["email"]).strip()
        id_categoria = int(d["id_categoria"])

        cur.execute("SELECT identificacion FROM persona WHERE identificacion = %s", (cedula,))
        if cur.fetchone():
            return jsonify({"ok": False, "mensaje": "Ya existe una persona con esa cedula."}), 400

        cur.execute("SELECT cedula_entrenador FROM entrenador WHERE email = %s", (email,))
        if cur.fetchone():
            return jsonify({"ok": False, "mensaje": "El email ya esta registrado para otro entrenador."}), 400

        error_categoria = _validar_categoria_disponible(cur, id_categoria)
        if error_categoria:
            return jsonify({"ok": False, "mensaje": error_categoria}), 400

        hash_pw = bcrypt.hashpw(
            str(d["contrasena"]).encode("utf-8"), bcrypt.gensalt(12)
        ).decode("utf-8")

        if conn.in_transaction:
            conn.rollback()
        conn.start_transaction()

        cur.execute(
            "INSERT INTO persona (identificacion, nombre, apellido) VALUES (%s, %s, %s)",
            (cedula, str(d["nombre"]).strip(), str(d["apellido"]).strip()),
        )
        cur.execute(
            """INSERT INTO entrenador
               (cedula_entrenador, email, contrasena, telefono, id_categoria)
               VALUES (%s, %s, %s, %s, %s)""",
            (cedula, email, hash_pw, str(d["telefono"]).strip(), id_categoria),
        )
        conn.commit()
        return jsonify({"ok": True, "mensaje": "Entrenador creado correctamente."}), 201

    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


# ── Actualizar ────────────────────────────────────────────────────

@entrenadores_bp.route("/<string:cedula>", methods=["PUT"])
@admin_required
def actualizar_entrenador(cedula):
    d = request.get_json() or {}

    error = _validar_datos_basicos(d, creando=False)
    if error:
        return jsonify({"ok": False, "mensaje": error}), 400

    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)

        cur.execute(
            "SELECT cedula_entrenador FROM entrenador WHERE cedula_entrenador = %s",
            (cedula,),
        )
        if not cur.fetchone():
            return jsonify({"ok": False, "mensaje": "Entrenador no encontrado."}), 404

        email = str(d.get("email", "")).strip()
        if email:
            cur.execute(
                """
                SELECT cedula_entrenador
                  FROM entrenador
                 WHERE email = %s
                   AND cedula_entrenador <> %s
                """,
                (email, cedula),
            )
            if cur.fetchone():
                return jsonify({"ok": False, "mensaje": "El email ya esta registrado para otro entrenador."}), 400

        id_categoria = int(d["id_categoria"])
        error_categoria = _validar_categoria_disponible(cur, id_categoria, cedula_actual=cedula)
        if error_categoria:
            return jsonify({"ok": False, "mensaje": error_categoria}), 400

        if conn.in_transaction:
            conn.rollback()
        conn.start_transaction()

        cur.execute(
            """UPDATE persona
                  SET nombre = %s,
                      apellido = %s
                WHERE identificacion = %s""",
            (str(d["nombre"]).strip(), str(d["apellido"]).strip(), cedula),
        )

        if d.get("contrasena"):
            hash_pw = bcrypt.hashpw(
                str(d["contrasena"]).encode("utf-8"), bcrypt.gensalt(12)
            ).decode("utf-8")
            cur.execute(
                """UPDATE entrenador
                      SET email = %s,
                          telefono = %s,
                          id_categoria = %s,
                          contrasena = %s
                    WHERE cedula_entrenador = %s""",
                (email, str(d["telefono"]).strip(), id_categoria, hash_pw, cedula),
            )
        else:
            cur.execute(
                """UPDATE entrenador
                      SET email = %s,
                          telefono = %s,
                          id_categoria = %s
                    WHERE cedula_entrenador = %s""",
                (email, str(d["telefono"]).strip(), id_categoria, cedula),
            )

        conn.commit()
        return jsonify({"ok": True, "mensaje": "Entrenador actualizado correctamente."}), 200

    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()


# ── Eliminar ──────────────────────────────────────────────────────

@entrenadores_bp.route("/<string:cedula>", methods=["DELETE"])
@admin_required
def eliminar_entrenador(cedula):
    conn = None
    try:
        conn = get_mysql()
        cur = conn.cursor(dictionary=True)

        cur.execute(
            "SELECT cedula_entrenador FROM entrenador WHERE cedula_entrenador = %s",
            (cedula,),
        )
        if not cur.fetchone():
            return jsonify({"ok": False, "mensaje": "Entrenador no encontrado."}), 404

        cur.execute(
            "SELECT COUNT(*) AS total FROM entrenamiento WHERE cedula_entrenador = %s",
            (cedula,),
        )
        if cur.fetchone()["total"] > 0:
            return jsonify({
                "ok": False,
                "mensaje": "No se puede eliminar: el entrenador tiene entrenamientos registrados.",
            }), 400

        if conn.in_transaction:
            conn.rollback()
        conn.start_transaction()

        cur.execute("DELETE FROM entrenador WHERE cedula_entrenador = %s", (cedula,))
        cur.execute("DELETE FROM persona WHERE identificacion = %s", (cedula,))
        conn.commit()
        return jsonify({"ok": True, "mensaje": "Entrenador eliminado correctamente."}), 200

    except Exception as e:
        if conn:
            conn.rollback()
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn:
            conn.close()
