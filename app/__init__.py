from __future__ import annotations

import json
import logging
import time
from flask import Flask, jsonify, request
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

    # Logging: JSON to stdout (picked by Filebeat/Docker)
    root_logger = logging.getLogger()
    if not root_logger.handlers:
        # stdout handler (Docker)
        stream_handler = logging.StreamHandler()
        stream_handler.setFormatter(logging.Formatter("%(message)s"))
        root_logger.addHandler(stream_handler)

        # file handler (Filebeat local harvest)
        try:
            file_handler = logging.FileHandler("/var/log/app/app.log")
            file_handler.setFormatter(logging.Formatter("%(message)s"))
            root_logger.addHandler(file_handler)
        except Exception:
            # If path not writable, continue with stdout only
            pass
    root_logger.setLevel(logging.INFO)

    @app.before_request
    def _start_timer():
        request._start_time = time.perf_counter()

    @app.after_request
    def _log_request(response):
        try:
            duration = None
            if hasattr(request, "_start_time"):
                duration = (time.perf_counter() - request._start_time) * 1000.0  # ms

            # Deriva classe de status (2xx, 4xx, 5xx) para facilitar dashboards
            sc = response.status_code
            if sc >= 500:
                status_class = "5xx"
            elif sc >= 400:
                status_class = "4xx"
            elif sc >= 300:
                status_class = "3xx"
            elif sc >= 200:
                status_class = "2xx"
            else:
                status_class = "1xx"

            # ECS-aligned log record
            # Log simplificado para Filebeat: será decodificado do campo message em raiz
            # Formato ECS básico
            log_record = {
                "@timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "event": {"action": "http_request"},
                "http": {"request": {"method": request.method}, "response": {"status_code": response.status_code}},
                "url": {"path": request.path, "query": request.query_string.decode() if request.query_string else ""},
                "client": {"ip": request.remote_addr},
                "user_agent": {"original": request.headers.get("User-Agent")},
                "service": {"name": "kube-ops"},
                "metrics": {"response_time_ms": round(duration, 3) if duration is not None else None},
                "status_class": status_class
            }
            logging.getLogger(__name__).info(json.dumps(log_record))
        except Exception:  # pragma: no cover
            # Don't break responses due to logging issues
            pass
        return response

    @app.get("/")
    def index():
        return jsonify({"message": "Hello, Kube Ops!"})

    @app.get("/healthz")
    def healthz():
        return jsonify({"status": "ok"}), 200

    # Endpoint para simular erro 500 (para dashboards)
    @app.get("/boom")
    def boom():  # pragma: no cover - apenas para testes manuais/observabilidade
        raise RuntimeError("boom")

    # Registra blueprint API
    app.register_blueprint(api_bp)

    # Tratamento de erros de validação do Marshmallow: retorna 400 com detalhes
    @app.errorhandler(ValidationError)
    def handle_validation_error(err: ValidationError):
        return jsonify({"errors": err.messages}), 400

    # Tratamento de erro 500 para garantir log estruturado mesmo em exceções
    @app.errorhandler(500)
    def handle_internal_error(err):  # pragma: no cover - caminho de erro
        try:
            duration = None
            if hasattr(request, "_start_time"):
                duration = (time.perf_counter() - request._start_time) * 1000.0  # ms

            log_record = {
                "@timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "event": {"action": "http_request"},
                "http": {"request": {"method": request.method}, "response": {"status_code": 500}},
                "url": {"path": request.path, "query": request.query_string.decode() if request.query_string else ""},
                "client": {"ip": request.remote_addr},
                "user_agent": {"original": request.headers.get("User-Agent")},
                "service": {"name": "kube-ops"},
                "metrics": {"response_time_ms": round(duration, 3) if duration is not None else None},
                "error": {"message": str(err)},
                "status_class": "5xx"
            }
            logging.getLogger(__name__).info(json.dumps(log_record))
        except Exception:
            pass
        return jsonify({"error": "internal server error"}), 500

    # Cria tabelas em runtime (para simplicidade do exemplo)
    with app.app_context():
        db.create_all()

    return app


# App default para servidores WSGI (ex.: gunicorn)
app = create_app()


