## Kube Ops — Guia rápido para rodar o projeto

Este README contém apenas o essencial: programas necessários e os comandos na ordem correta para executar a API localmente, via Docker, com logging (ELK) e no Kubernetes (Minikube + Helm), usando Windows PowerShell.

---

## Pré‑requisitos (instale conforme o que pretende usar)
- Git
- Windows PowerShell 5.1 (padrão do Windows)
- Python 3.12+ (para rodar localmente)
- Docker Desktop (para Docker e stack de logging)
- Minikube, kubectl e Helm (para Kubernetes)

---

## Opção A) Rodar local (Python)
```powershell
git clone https://github.com/Ed1Abreu/Kube_Ops.git
cd Kube_Ops

python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Executar API na porta 8000
python -m flask --app app run --port 8000
```
Acessar:
- http://localhost:8000/
- http://localhost:8000/healthz
- CRUD: http://localhost:8000/api/todos

Observações:
- Banco padrão: SQLite em `app.db` (criado automaticamente).
- Para outro banco, defina `SQLALCHEMY_DATABASE_URI` (ex.: PostgreSQL).

---

## Opção B) Rodar com Docker (API)
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

## Opção C) Rodar stack de Logging (Elasticsearch + Kibana + Filebeat + API)
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

## Opção D) Rodar no Kubernetes (Minikube + Helm)
```powershell
# 1) Iniciar cluster
minikube start

# 2) (Opcional) Carregar imagem local, se não estiver em registry
minikube image load kube-ops:local

# 3) Fazer deploy com Helm
cd Kube_Ops
helm upgrade --install kube-ops .\helm --set service.type=NodePort --set image.repository=kube-ops --set image.tag=local

# 4) Descobrir o serviço e obter a URL
kubectl get svc
minikube service <nome-do-servico> --url
# (Alternativa) Port-forward
kubectl port-forward svc/<nome-do-servico> 8000:8000
```
Acessar:
- http://localhost:8000/
- http://localhost:8000/healthz

Remover do cluster:
```powershell
helm uninstall kube-ops
```

---

Pronto. Use a opção que preferir (A, B, C ou D). Se o Discover do Kibana mostrar “No results”, aumente o intervalo de tempo (ex.: “Last 1 hour”) e gere requisições na API antes de atualizar.
