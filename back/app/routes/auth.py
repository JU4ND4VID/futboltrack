from flask import Blueprint, request, jsonify
import bcrypt
from app.db.mysql_conn import get_mysql

auth_bp = Blueprint("auth", __name__)

@auth_bp.route("/login", methods=["POST"])
def login():
    data       = request.get_json() or {}
    cedula     = data.get("cedula", "").strip()
    contrasena = data.get("contrasena", "")

    if not cedula or not contrasena:
        return jsonify({"ok": False, "mensaje": "Cedula y contrasena son obligatorios."}), 400

    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT e.cedula_entrenador, e.contrasena,
                   p.nombre, p.apellido, e.email, e.telefono
              FROM entrenador e
              JOIN persona p ON e.cedula_entrenador = p.identificacion
             WHERE e.cedula_entrenador = %s
        """, (cedula,))
        entrenador = cur.fetchone()

        if not entrenador:
            return jsonify({"ok": False, "mensaje": "Credenciales incorrectas."}), 401

        if not bcrypt.checkpw(contrasena.encode("utf-8"),
                               entrenador["contrasena"].encode("utf-8")):
            return jsonify({"ok": False, "mensaje": "Credenciales incorrectas."}), 401

        return jsonify({
            "ok": True,
            "entrenador": {
                "cedula"  : entrenador["cedula_entrenador"],
                "nombre"  : entrenador["nombre"],
                "apellido": entrenador["apellido"],
                "email"   : entrenador["email"],
                "telefono": entrenador["telefono"]
            }
        }), 200

    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()
