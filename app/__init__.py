from __future__ import annotations

from flask import Flask, jsonify
from marshmallow import ValidationError

from .blueprints import bp as api_bp
from .extensions import db


def create_app() -> Flask:
    app = Flask(__name__)

    # Config simples: SQLite em arquivo local
    app.config.setdefault("SQLALCHEMY_DATABASE_URI", "sqlite:///app.db")
    app.config.setdefault("SQLALCHEMY_TRACK_MODIFICATIONS", False)

    # Inicializa extensões
    db.init_app(app)

    @app.get("/")
    def index():
        return jsonify({"message": "Hello, Kube Ops!"})

    @app.get("/healthz")
    def healthz():
        return jsonify({"status": "ok"}), 200

    # Registra blueprint API
    app.register_blueprint(api_bp)

    # Tratamento de erros de validação do Marshmallow: retorna 400 com detalhes
    @app.errorhandler(ValidationError)
    def handle_validation_error(err: ValidationError):
        return jsonify({"errors": err.messages}), 400

    # Cria tabelas em runtime (para simplicidade do exemplo)
    with app.app_context():
        db.create_all()

    return app


# App default para servidores WSGI (ex.: gunicorn)
app = create_app()


