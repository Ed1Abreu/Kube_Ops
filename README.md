# Kube_Ops — Guia Rápido

Objetivo: subir a API Flask e observar logs/métricas HTTP via Filebeat + Elasticsearch + Kibana.

## 1. Pré‑requisitos
- Windows PowerShell 5.1+ (ou outro shell que prefira)
- Docker Desktop (inclui Docker Compose)
- (Para Kubernetes) Minikube + Helm
- Git

---
## 2. Clonar
```powershell
git clone https://github.com/Ed1Abreu/Kube_Ops.git
cd Kube_Ops
```

---
## 3. Modo A: Somente API (Docker)
Build e run:
```powershell
docker build -t kube-ops:local .
docker run -d --name kube_ops -p 8000:8000 kube-ops:local
```
Testar:
```powershell
curl.exe http://localhost:8000/
curl.exe http://localhost:8000/healthz
```
Parar/remover:
```powershell
docker rm -f kube_ops
```

Persistir SQLite (opcional):
```powershell
mkdir data 2>$null
docker run -d --name kube_ops -p 8000:8000 -v ${PWD}\data:/app kube-ops:local
```

---
## 4. Modo B: Stack de Logging (Docker Compose)
Sobe API + Elasticsearch + Kibana + Filebeat.
```powershell
cd logging
docker compose up -d --build
```
URLs:
- API: http://localhost:8000/
- Kibana: http://localhost:5601/
- Elasticsearch: http://localhost:9200/

Primeiro uso no Kibana:
1. Abrir Kibana → Discover.
2. Criar Data View: pattern `logs-app-default*` (ou `logs-*`), campo de tempo `@timestamp`.
3. Gerar tráfego:
    ```powershell
    curl.exe http://localhost:8000/
    curl.exe http://localhost:8000/healthz
    curl.exe -X POST -H "Content-Type: application/json" -d "{\"title\":\"Teste\"}" http://localhost:8000/api/todos
    ```
4. Atualizar Discover.

Parar stack:
```powershell
docker compose down -v
```

---
## 5. Modo C: Kubernetes (Minikube + Helm) com Observabilidade
### 5.1 Iniciar Minikube
```powershell
minikube delete  # se já existir e quiser recriar
minikube start --memory=6144 --cpus=2 --kubernetes-version=stable
```
(Opcional Ingress)
```powershell
minikube addons enable ingress
```

### 5.2 Instalar Elasticsearch e Kibana (charts oficiais)
```powershell
helm repo add elastic https://helm.elastic.co
helm repo update
kubectl create namespace observability

# Elasticsearch (usa values-es-minikube.yaml já no repositório)
helm install elasticsearch elastic/elasticsearch -n observability -f values-es-minikube.yaml
kubectl get pods -n observability -w

# Kibana (usa values-kibana-minikube.yaml)
helm install kibana elastic/kibana -n observability -f values-kibana-minikube.yaml
kubectl get pods -n observability -w
```

### 5.3 Instalar a aplicação com Filebeat sidecar
```powershell
helm install kube-ops ./helm -n observability -f helm/values-minikube.yaml
kubectl get pods -n observability
```

### 5.4 Port-forward para testar
Em dois terminais:
```powershell
kubectl port-forward -n observability deploy/kube-ops 8000:8000
kubectl port-forward -n observability deploy/kibana-kibana 5601:5601
```

### 5.5 Gerar tráfego
```powershell
curl.exe http://localhost:8000/
curl.exe http://localhost:8000/healthz
curl.exe -X POST -H "Content-Type: application/json" -d "{\"title\":\"Task K8s\"}" http://localhost:8000/api/todos
```

### 5.6 Criar Data View no Kibana
1. Abrir http://localhost:5601/
2. Discover → Create data view.
3. Pattern: `logs-app-default*` (ou `logs-*`). Time field: `@timestamp`.
4. Verificar campos: `http.request.method`, `http.response.status_code`, `url.path`, `metrics.response_time_ms`.

### 5.7 Conferir sidecar Filebeat
```powershell
kubectl logs -n observability deploy/kube-ops -c filebeat --tail=50
```

### 5.8 Limpeza
```powershell
helm uninstall kube-ops -n observability
helm uninstall kibana -n observability
helm uninstall elasticsearch -n observability
kubectl delete namespace observability
minikube delete
```

---
## 6. Dashboard simples (manual)
No Kibana Dashboard:
1. Lens: Bar chart → Horizontal axis = `http.response.status_code` (Top values), Métrica = Count. Salvar como *HTTP Status Codes*.
2. Lens: Métrica média → Métrica = Average(`metrics.response_time_ms`). Salvar como *Avg Response Time (ms)*.
3. Lens: Timeseries (opcional) → `metrics.response_time_ms` Average over time.
4. Adicionar as visualizações + um Saved Search (Discover salvo) em um novo Dashboard *API Observability*.

---
## 7. Estrutura de Logs (ECS Básico)
Cada request gera JSON com campos principais:
- `@timestamp`
- `event.action = http_request`
- `http.request.method`, `http.response.status_code`
- `url.path`, `url.query`
- `client.ip`
- `user_agent.original`
- `metrics.response_time_ms`

Isso facilita filtros no Kibana e futuras métricas.

---
## 8. Problemas Comuns
| Sintoma | Causa | Ação |
|--------|-------|------|
| Data View vazia | Falta de tráfego ou pattern errado | Gerar requests e revisar pattern `logs-*` |
| Filebeat CrashLoop | Host ES inacessível | Ver `kubectl logs` do sidecar e DNS do serviço |
| Kibana sem iniciar | Recursos insuficientes | Aumentar memória Minikube ou reduzir limites |
| Campos não aparecem | Data View criada antes de existirem documentos | Recriar Data View ou usar Refresh field list |

---
## 9. Próximos Passos (Sugestões)
- Adicionar métricas (Prometheus + Grafana) e correlação com logs.
- Exportar Dashboard (NDJSON) e versionar.
- Ingress + TLS para acesso externo.

---
Pronto. Siga a seção do modo que deseja usar (A, B ou C) e em minutos terá logs estruturados no Kibana.
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
