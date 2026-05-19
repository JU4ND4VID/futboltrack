# ================================================================
# FutbolTrack - app/routes/auth.py
#
# Login revisa primero la tabla entrenador y luego administrador.
# La sesión guarda tipo_usuario: 'entrenador' | 'admin'.
# El decorador admin_required protege los endpoints de escritura.
# ================================================================
from functools import wraps
from flask import Blueprint, request, jsonify, session
import bcrypt
from app.db.mysql_conn import get_mysql

auth_bp = Blueprint("auth", __name__)


# ── Decoradores de acceso ─────────────────────────────────────────

def login_required(f):
    """Cualquier usuario autenticado (entrenador o admin)."""
    @wraps(f)
    def decorated(*args, **kwargs):
        if "cedula_usuario" not in session:
            return jsonify({"ok": False,
                            "mensaje": "No autenticado. Inicia sesion primero."}), 401
        return f(*args, **kwargs)
    return decorated


def admin_required(f):
    """Solo administradores. Retorna 403 si el usuario es entrenador."""
    @wraps(f)
    def decorated(*args, **kwargs):
        if "cedula_usuario" not in session:
            return jsonify({"ok": False,
                            "mensaje": "No autenticado. Inicia sesion primero."}), 401
        if session.get("tipo_usuario") != "admin":
            return jsonify({"ok": False,
                            "mensaje": "Accion restringida a administradores."}), 403
        return f(*args, **kwargs)
    return decorated


# ── Rutas ─────────────────────────────────────────────────────────

@auth_bp.route("/login", methods=["POST"])
def login():
    data       = request.get_json() or {}
    cedula     = data.get("cedula", "").strip()
    contrasena = data.get("contrasena", "")

    if not cedula or not contrasena:
        return jsonify({"ok": False,
                        "mensaje": "Cedula y contrasena son obligatorios."}), 400

    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)

        # ── Paso 1: intentar como entrenador ────────────────────────
        cur.execute("""
            SELECT e.cedula_entrenador AS cedula, e.contrasena,
                   p.nombre, p.apellido, e.email, e.telefono,
                   e.id_categoria, c.nombre AS categoria_nombre,
                   'entrenador' AS tipo_usuario
              FROM entrenador e
              JOIN persona   p ON e.cedula_entrenador = p.identificacion
              JOIN categoria c ON e.id_categoria      = c.id_categoria
             WHERE e.cedula_entrenador = %s
        """, (cedula,))
        usuario = cur.fetchone()

        # ── Paso 2: si no existe como entrenador, intentar como admin ─
        if not usuario:
            cur.execute("""
                SELECT a.cedula_admin AS cedula, a.contrasena,
                       p.nombre, p.apellido, a.email, a.telefono,
                       NULL AS id_categoria, NULL AS categoria_nombre,
                       'admin' AS tipo_usuario
                  FROM administrador a
                  JOIN persona p ON a.cedula_admin = p.identificacion
                 WHERE a.cedula_admin = %s
            """, (cedula,))
            usuario = cur.fetchone()

        # ── Paso 3: validar existencia y contraseña ──────────────────
        if not usuario:
            return jsonify({"ok": False,
                            "mensaje": "Credenciales incorrectas."}), 401

        if not bcrypt.checkpw(contrasena.encode("utf-8"),
                               usuario["contrasena"].encode("utf-8")):
            return jsonify({"ok": False,
                            "mensaje": "Credenciales incorrectas."}), 401

        # ── Paso 4: guardar en sesión ────────────────────────────────
        session["cedula_usuario"]  = usuario["cedula"]
        session["nombre"]          = usuario["nombre"]
        session["apellido"]        = usuario["apellido"]
        session["id_categoria"]    = usuario["id_categoria"]
        session["tipo_usuario"]    = usuario["tipo_usuario"]

        return jsonify({
            "ok": True,
            "entrenador": {
                "cedula"          : usuario["cedula"],
                "nombre"          : usuario["nombre"],
                "apellido"        : usuario["apellido"],
                "email"           : usuario["email"],
                "telefono"        : usuario["telefono"],
                "id_categoria"    : usuario["id_categoria"],
                "categoria_nombre": usuario["categoria_nombre"],
                "tipo_usuario"    : usuario["tipo_usuario"],
            }
        }), 200

    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@auth_bp.route("/logout", methods=["POST"])
def logout():
    session.clear()
    return jsonify({"ok": True, "mensaje": "Sesion cerrada."}), 200


@auth_bp.route("/me", methods=["GET"])
@login_required
def me():
    conn = None
    try:
        tipo = session.get("tipo_usuario", "entrenador")
        categoria_nombre = None

        if tipo == "entrenador":
            conn = get_mysql()
            cur  = conn.cursor(dictionary=True)
            cur.execute("""
                SELECT c.nombre AS categoria_nombre
                  FROM entrenador e
                  JOIN categoria c ON e.id_categoria = c.id_categoria
                 WHERE e.cedula_entrenador = %s
            """, (session.get("cedula_usuario"),))
            row = cur.fetchone()
            if row:
                categoria_nombre = row["categoria_nombre"]

        return jsonify({
            "ok"              : True,
            "cedula"          : session.get("cedula_usuario"),
            "nombre"          : session.get("nombre"),
            "apellido"        : session.get("apellido"),
            "id_categoria"    : session.get("id_categoria"),
            "categoria_nombre": categoria_nombre,
            "tipo_usuario"    : tipo,
        }), 200

    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()