## Kube Ops — Guia rápido (somente Docker)

Este README contém apenas os pré‑requisitos e os comandos na ordem correta para executar tudo com Docker no Windows PowerShell: a API isolada e, opcionalmente, o stack de logging (Elasticsearch + Kibana + Filebeat + API).

---

## Pré‑requisitos
- Git
- Windows PowerShell 5.1 (padrão do Windows)
- Docker Desktop (com Docker Compose)

---

## Opção A) Rodar com Docker (API)
```powershell
git clone https://github.com/Ed1Abreu/Kube_Ops.git
cd Kube_Ops

docker build -t kube-ops:local .
docker run -d --name kube_ops -p 8000:8000 kube-ops:local

# Verificar rapidamente
curl.exe http://localhost:8000/
curl.exe http://localhost:8000/healthz
```
Persistir SQLite fora do container (opcional):
```powershell
mkdir data 2>$null
docker run -d --name kube_ops -p 8000:8000 -v ${PWD}\data:/app -e SQLALCHEMY_DATABASE_URI=sqlite:///app.db kube-ops:local
```

---

## Opção B) Rodar stack de Logging (Elasticsearch + Kibana + Filebeat + API)
```powershell
git clone https://github.com/Ed1Abreu/Kube_Ops.git
cd Kube_Ops\logging

docker compose up -d --build
```
URLs:
- API: http://localhost:8000/
- Elasticsearch: http://localhost:9200/
- Kibana: http://localhost:5601/

Primeiro acesso ao Kibana (uma vez):
1) Abra http://localhost:5601/ → Discover.
2) Crie um Data View com padrão `filebeat-*` e campo de tempo `@timestamp`.
3) Gere tráfego na API e clique em Refresh no Discover:
```powershell
curl.exe http://localhost:8000/
curl.exe http://localhost:8000/healthz
curl.exe -X POST -H "Content-Type: application/json" -d "{\"title\":\"Teste\"}" http://localhost:8000/api/todos
```
Parar o stack:
```powershell
cd Kube_Ops\logging
docker compose down -v
```

---
Pronto. Se o Discover do Kibana mostrar “No results”, aumente o intervalo de tempo (ex.: “Last 1 hour”) e gere requisições na API antes de atualizar.
