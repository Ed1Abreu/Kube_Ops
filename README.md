## Kube Ops - API Flask com CRUD + CI/CD

API REST em Python/Flask com CRUD de tarefas (Todo), banco SQLite por padrão, validação com Marshmallow, testes com Pytest, container Docker e pipeline de CI/CD usando GitHub Actions que testa, constrói e publica a imagem no GitHub Container Registry (GHCR).

---

## 1) O que este projeto faz
- Exponde endpoints para gerenciar tarefas (criar, listar, buscar, atualizar e remover)
- Persiste dados em SQLite (arquivo `app.db`); pode apontar para PostgreSQL/MySQL mudando a variável `SQLALCHEMY_DATABASE_URI`
- Possui testes automatizados cobrindo os endpoints principais
- Pode ser executado localmente (Flask dev server) ou em produção via Docker (Gunicorn)
- Integra pipeline CI/CD: em PRs roda testes; em pushes na `main` testa, constrói e publica imagem em `ghcr.io/<owner>/<repo>:latest`

---

## 2) Tecnologias
- Flask 3
- Flask‑SQLAlchemy
- Marshmallow
- Pytest
- Gunicorn
- Docker
- GitHub Actions + GHCR

---

## 3) Estrutura do repositório
- `app/__init__.py` – cria e configura a aplicação, inicializa DB, registra blueprints, cria tabelas
- `app/extensions.py` – instância global do SQLAlchemy (`db`)
- `app/models.py` – modelo `Todo`
- `app/schemas.py` – schemas de validação (criação/atualização)
- `app/blueprints.py` – rotas REST da API (`/api/todos`)
- `tests/test_app.py` – testes de integração dos endpoints
- `Dockerfile` – imagem de produção com Gunicorn
- `.dockerignore` – arquivos ignorados no build
- `requirements.txt` – dependências de runtime e testes
- `.github/workflows/main.yml` – pipeline CI/CD

---

## 4) Pré‑requisitos
- Python 3.12+
- PowerShell (Windows) ou shell equivalente
- Docker (opcional, para rodar container)

---

## 5) Executar localmente (Windows PowerShell)
1. Criar e ativar o ambiente virtual e instalar dependências:
   - `python -m venv .venv`
   - `.venv\Scripts\Activate.ps1`
   - `pip install -r requirements.txt`
2. Executar a aplicação (servidor de desenvolvimento do Flask):
   - `python -m flask --app app run --port 8000`
3. Acessar endpoints:
   - `http://localhost:8000/` (mensagem)
   - `http://localhost:8000/healthz` (saúde)
   - CRUD: `http://localhost:8000/api/todos`

Banco de dados: por padrão, `SQLALCHEMY_DATABASE_URI=sqlite:///app.db`. O arquivo `app.db` é criado automaticamente ao iniciar.

Variáveis de ambiente úteis:
- `SQLALCHEMY_DATABASE_URI` – ex.: `postgresql+psycopg2://user:pass@host:5432/dbname`
- `PORT` – a porta de execução (usada pelo Docker/Gunicorn)

---

## 6) Testes
Execute:
```bash
pytest -q
```

---

## 7) Docker
Build e execução local:
```bash
docker build -t kube-ops:local .
docker run -p 8000:8000 kube-ops:local
```

Persistência do SQLite em volume (mantendo o DB fora do container):
```bash
docker run -p 8000:8000 \
  -v ${PWD}/data:/app \
  -e SQLALCHEMY_DATABASE_URI=sqlite:///app.db \
  kube-ops:local
```

Usando outro banco (ex.: PostgreSQL), basta setar `SQLALCHEMY_DATABASE_URI` para a URL do banco.

---

## 8) Endpoints principais (exemplos com curl)
Listar todos:
```bash
curl http://localhost:8000/api/todos
```

Criar:
```bash
curl -X POST http://localhost:8000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Estudar CI/CD"}'
```

Buscar por id:
```bash
curl http://localhost:8000/api/todos/1
```

Atualizar (parcial):
```bash
curl -X PATCH http://localhost:8000/api/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"done":true}'
```

Remover:
```bash
curl -X DELETE http://localhost:8000/api/todos/1 -i
```

---

## 9) CI/CD com GitHub Actions e GHCR
O workflow em `.github/workflows/main.yml` executa em PRs e pushes para `main`.

Fluxo:
1. Instala dependências e roda testes (`pytest`)
2. Em pushes na `main`: autentica no GHCR, constrói a imagem e publica

Tag publicada: `ghcr.io/<owner>/<repo>:latest`

Primeiro uso do GHCR no repositório:
- Não precisa criar token manual; o `GITHUB_TOKEN` já possui `packages: write`
- A imagem aparecerá em Packages do repositório/usuário no GitHub

Executar a imagem publicada (após o pipeline):
```bash
docker pull ghcr.io/<owner>/<repo>:latest
docker run -p 8000:8000 ghcr.io/<owner>/<repo>:latest
```

Publicar no Docker Hub (opcional):
- Alterar o passo de login para `docker.io`
- Definir secrets `DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`
- Ajustar `tags` para `docker.io/<usuario>/<repo>:latest`

---

## 10) Dúvidas comuns
- "Porta já em uso": troque a porta (`--port 8001`) ou pare o processo que usa 8000
- "Banco não persiste no Docker": monte um volume conforme o exemplo de persistência
- "Quero usar outro SGBD": defina `SQLALCHEMY_DATABASE_URI` com a URL do banco desejado

---

Pronto! Com isso você consegue: rodar localmente, testar, criar imagem Docker e publicar no GHCR via pipeline automático.
