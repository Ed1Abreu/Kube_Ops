from __future__ import annotations

from flask import Blueprint, jsonify, request

from .extensions import db
from .models import Todo
from .schemas import TodoCreateSchema, TodoUpdateSchema


bp = Blueprint("api", __name__, url_prefix="/api")


@bp.get("/todos")
def list_todos():
    todos = Todo.query.order_by(Todo.id.desc()).all()
    return jsonify([t.to_dict() for t in todos])


@bp.post("/todos")
def create_todo():
    data = request.get_json(silent=True) or {}
    payload = TodoCreateSchema().load(data)
    todo = Todo(**payload)
    db.session.add(todo)
    db.session.commit()
    return jsonify(todo.to_dict()), 201


@bp.get("/todos/<int:todo_id>")
def get_todo(todo_id: int):
    todo = Todo.query.get_or_404(todo_id)
    return jsonify(todo.to_dict())


@bp.patch("/todos/<int:todo_id>")
def update_todo(todo_id: int):
    todo = Todo.query.get_or_404(todo_id)
    data = request.get_json(silent=True) or {}
    updates = TodoUpdateSchema().load(data, partial=True)
    for key, value in updates.items():
        setattr(todo, key, value)
    db.session.commit()
    return jsonify(todo.to_dict())


@bp.delete("/todos/<int:todo_id>")
def delete_todo(todo_id: int):
    todo = Todo.query.get_or_404(todo_id)
    db.session.delete(todo)
    db.session.commit()
    return ("", 204)


