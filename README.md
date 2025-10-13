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
- Helm
- Minikube/Kind

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
- `helm/` - chart Helm para deploy
- `pytest.ini` - para rodar testes sem erro de import

---

## 4) Pré‑requisitos
- Python 3.12+
- PowerShell (Windows) ou shell equivalente
- Docker (opcional, para rodar container)
- Minikube (ou Kind)
- Helm

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
```powershell
# Build a imagem localmente
docker build -t kube-ops:local .

# Rodar em background mapeando a porta 8000
docker run -d --name kube_ops_local -p 8000:8000 kube-ops:local

# Verificar endpoints (no PowerShell):
curl http://localhost:8000/
curl http://localhost:8000/healthz

# Rodar testes dentro de um container temporário (a imagem já possui pytest):
docker run --rm -e PORT=8000 kube-ops:local python -m pytest -q
```

Persistência do SQLite em volume (mantendo o DB fora do container):
```powershell
# Persistir o arquivo SQLite em um diretório `data` na raiz do projeto:
docker run -d -p 8000:8000 \
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

## 10) Como rodar o projeto do zero

### O que o projeto faz
- API REST Python/Flask para tarefas (CRUD)
- Banco SQLite por padrão (pode usar PostgreSQL/MySQL)
- Testes automatizados (pytest)
- Dockerfile para build/execução
- CI/CD com GitHub Actions: testa, constrói e publica imagem no GHCR/Docker Hub
- Deploy automático em Kubernetes via Helm (Minikube ou Kind)

### Tecnologias
- Flask 3, Flask-SQLAlchemy, Marshmallow, Pytest, Gunicorn
- Docker, Helm, Minikube/Kind, GitHub Actions

### Estrutura
- `app/` - código da API
- `tests/` - testes
- `Dockerfile`, `.dockerignore`, `requirements.txt`
- `.github/workflows/main.yml` - pipeline CI/CD
- `helm/` - chart Helm para deploy
- `pytest.ini` - para rodar testes sem erro de import

### Pré-requisitos
- Python 3.12+
- Docker
- Minikube (ou Kind)
- Helm

### Como rodar localmente (Windows PowerShell)
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m flask --app app run --port 8000
pytest -q
```

### Como rodar com Docker
```powershell
docker build -t kube-ops:local .
docker run -d --name kube_ops_local -p 8000:8000 kube-ops:local
curl http://localhost:8000/
curl http://localhost:8000/healthz
docker run --rm -e PORT=8000 kube-ops:local python -m pytest -q
```
Persistir banco:
```powershell
docker run -d -p 8000:8000 -v ${PWD}/data:/app -e SQLALCHEMY_DATABASE_URI=sqlite:///app.db kube-ops:local
```

### CI/CD com GitHub Actions
- Testa com pytest
- Build/push para GHCR e Docker Hub (se secrets configurados)
- Deploy automático no Kubernetes via Helm (se secret `KUBE_CONFIG` configurado)
- Veja logs na aba Actions do GitHub

### Como rodar no Minikube/Kind com Helm
1. Inicie o cluster:
   ```powershell
   minikube start
   ```
2. Carregue a imagem local:
   ```powershell
   minikube image load kube-ops:local
   ```
3. Deploy com Helm:
   ```powershell
   helm upgrade --install kube-ops ./helm --set image.repository=kube-ops --set image.tag=local --set service.type=NodePort
   ```
4. Verifique pods e serviços:
   ```powershell
   kubectl get pods
   kubectl get svc
   minikube service kube-ops-kube-ops --url
   # ou
   kubectl port-forward svc/kube-ops-kube-ops 8000:8000
   ```
5. Acesse no navegador:
   - http://localhost:8000/
   - http://localhost:8000/healthz

### Como entregar as etapas
- Etapa 2: arquivo `.github/workflows/main.yml` + print do pipeline executado com sucesso
- Etapa 3: diretório `/helm` + print do serviço rodando no Kubernetes (`kubectl get pods`, `kubectl get svc`, acesso via browser)

### Dúvidas comuns
- Porta em uso: troque a porta ou mate o processo
- Banco não persiste: monte volume conforme exemplo
- Outro SGBD: defina `SQLALCHEMY_DATABASE_URI`
- Serviço não acessível: use nome exato do serviço ou port-forward

### Resumo
- Projeto roda local, Docker ou Kubernetes
- CI/CD automatiza testes, build, push e deploy
- Deploy no Kubernetes via Helm, serviço exposto por NodePort
- Prints dos comandos e do workflow servem como prova para entrega

---

Pronto! Com isso você consegue: rodar localmente, testar, criar imagem Docker e publicar no GHCR via pipeline automático.
