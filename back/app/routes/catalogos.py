# ================================================================
# FutbolTrack - app/routes/catalogos.py
# GET /api/lugares
# GET /api/categorias
# ================================================================
from flask import Blueprint, jsonify
from app.db.mysql_conn import get_mysql

catalogos_bp = Blueprint("catalogos", __name__)


@catalogos_bp.route("/lugares", methods=["GET"])
def listar_lugares():
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute("SELECT id_lugar, nombre, descripcion, direccion FROM lugar ORDER BY nombre")
        return jsonify(cur.fetchall()), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()


@catalogos_bp.route("/categorias", methods=["GET"])
def listar_categorias():
    conn = None
    try:
        conn = get_mysql()
        cur  = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT id_categoria, nombre, edad_minima, edad_maxima,
                   fn_contar_sesiones_categoria(id_categoria) AS total_sesiones
              FROM categoria ORDER BY edad_minima
        """)
        return jsonify(cur.fetchall()), 200
    except Exception as e:
        return jsonify({"ok": False, "mensaje": str(e)}), 500
    finally:
        if conn: conn.close()
