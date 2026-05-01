# ================================================================
# FutbolTrack - app.py
# Punto de entrada principal del backend Flask
# ================================================================
from flask import Flask
from flask_cors import CORS
from config import Config

# Importar blueprints
from app.routes.auth           import auth_bp
from app.routes.jugadores      import jugadores_bp
from app.routes.entrenamientos import entrenamientos_bp
from app.routes.asistencia     import asistencia_bp
from app.routes.catalogos      import catalogos_bp
from app.routes.sesiones       import sesiones_bp

def create_app():
    app = Flask(__name__)
    CORS(app, origins=["http://localhost:5173"])

    # Registrar blueprints con prefijo /api
    app.register_blueprint(auth_bp,           url_prefix="/api/auth")
    app.register_blueprint(jugadores_bp,      url_prefix="/api/jugadores")
    app.register_blueprint(entrenamientos_bp, url_prefix="/api/entrenamientos")
    app.register_blueprint(asistencia_bp,     url_prefix="/api/asistencia")
    app.register_blueprint(catalogos_bp,      url_prefix="/api")
    app.register_blueprint(sesiones_bp,       url_prefix="/api/sesion")

    return app

if __name__ == "__main__":
    app = create_app()
    app.run(
        host="0.0.0.0",
        port=Config.FLASK_PORT,
        debug=Config.FLASK_DEBUG
    )
