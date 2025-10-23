## Kube_Ops — Comandos rápidos (Windows PowerShell)

Abaixo estão apenas os comandos necessários para rodar o projeto. Escolha entre “stack completo” (API + Elasticsearch + Kibana + Filebeat) ou “somente a API com Docker”.

### Pré‑requisitos
- Docker Desktop (com Docker Compose)
- Windows PowerShell 5.1+

---

### Opção A) Stack completo (API + Elasticsearch + Kibana + Filebeat)
```powershell
git clone https://github.com/Ed1Abreu/Kube_Ops.git
cd Kube_Ops

docker compose up -d --build

# Testar rapidamente (200, 404, 500)
curl.exe http://localhost:8000/
curl.exe -s -o NUL -w "%{http_code}`n" http://localhost:8000/naoexiste
curl.exe http://localhost:8000/boom

# URLs
# API:          http://localhost:8000/
# Elasticsearch: http://localhost:9200/
# Kibana:        http://localhost:5601/

# Parar tudo (e remover volumes)
docker compose down -v
```

---

### Opção B) Somente a API (Docker)
```powershell
git clone https://github.com/Ed1Abreu/Kube_Ops.git
cd Kube_Ops

docker build -t kube-ops:local .
docker run -d --name kube_ops_app -p 8000:8000 kube-ops:local

# Testar
curl.exe http://localhost:8000/
curl.exe http://localhost:8000/healthz

# Parar
docker rm -f kube_ops_app
```

Opcional (persistir SQLite fora do container):
```powershell
mkdir data 2>$null
docker rm -f kube_ops_app 2>$null
docker run -d --name kube_ops_app -p 8000:8000 -v ${PWD}\data:/app -e SQLALCHEMY_DATABASE_URI=sqlite:///app.db kube-ops:local
```
