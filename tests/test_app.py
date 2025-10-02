import json

from app import create_app


def test_index_route_returns_message():
    app = create_app()
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200
    assert response.get_json()["message"].startswith("Hello")


def test_healthz_route_ok():
    app = create_app()
    client = app.test_client()
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_todos_crud_flow():
    app = create_app()
    client = app.test_client()

    # list should be empty
    resp = client.get("/api/todos")
    assert resp.status_code == 200
    assert resp.get_json() == []

    # create
    resp = client.post(
        "/api/todos",
        data=json.dumps({"title": "Estudar CI/CD"}),
        content_type="application/json",
    )
    assert resp.status_code == 201
    todo = resp.get_json()
    assert todo["title"] == "Estudar CI/CD"
    todo_id = todo["id"]

    # get
    resp = client.get(f"/api/todos/{todo_id}")
    assert resp.status_code == 200

    # update
    resp = client.patch(
        f"/api/todos/{todo_id}",
        data=json.dumps({"done": True}),
        content_type="application/json",
    )
    assert resp.status_code == 200
    assert resp.get_json()["done"] is True

    # delete
    resp = client.delete(f"/api/todos/{todo_id}")
    assert resp.status_code == 204

    # list should be empty again
    resp = client.get("/api/todos")
    assert resp.status_code == 200
    assert resp.get_json() == []


