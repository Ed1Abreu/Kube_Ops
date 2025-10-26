# Kube_Ops — API Flask com CI/CD e Observabilidade Completa

Projeto completo de DevOps demonstrando práticas modernas de desenvolvimento, deployment e observabilidade.

## 🎯 O que é este projeto?

**Kube_Ops** é uma aplicação Flask (API REST para gerenciar TODOs) que demonstra:
- ✅ **CI/CD completo** - Pipeline automatizado com GitHub Actions
- ✅ **Observabilidade total** - Stack ELK (Elasticsearch, Kibana, Filebeat)
- ✅ **Orquestração** - Deploy em Kubernetes via Helm
- ✅ **Boas práticas** - Testes, logs estruturados, monitoramento

---

## 📋 Índice

1. [Pré-requisitos](#-pré-requisitos)
2. [Como Rodar o Projeto](#-como-rodar-o-projeto)
   - [Stack Completa (Docker Compose)](#1-stack-completa-docker-compose)
   - [Somente API (Docker)](#2-somente-api-docker)
   - [Deploy no Kubernetes (Minikube)](#3-deploy-no-kubernetes-minikube)
3. [Arquitetura e Componentes](#-arquitetura-e-componentes)
4. [Pipeline CI/CD](#-pipeline-cicd)
5. [Observabilidade (ELK Stack)](#-observabilidade-elk-stack)
6. [API Endpoints](#-api-endpoints)
7. [Testes](#-testes)
8. [Troubleshooting](#-troubleshooting)

---

## 🔧 Pré-requisitos

### **Obrigatórios:**
- **Docker Desktop** - [Download](https://www.docker.com/products/docker-desktop)
- **Git** - [Download](https://git-scm.com/downloads)
- **Windows PowerShell 5.1+** (ou Bash no Linux/Mac)

### **Opcionais (para Kubernetes):**
- **Minikube** - [Instalação](https://minikube.sigs.k8s.io/docs/start/)
- **kubectl** - [Instalação](https://kubernetes.io/docs/tasks/tools/)
- **Helm** - [Instalação](https://helm.sh/docs/intro/install/)

---

## 🚀 Como Rodar o Projeto

### **1. Stack Completa (Docker Compose)**

Esta é a forma **recomendada** para ver todo o projeto funcionando, incluindo observabilidade.

#### **Passo 1: Clone o repositório**
```powershell
git clone https://github.com/Ed1Abreu/Kube_Ops.git
cd Kube_Ops
```

#### **Passo 2: Inicie todos os serviços**
```powershell
docker compose up -d --build
```

**O que esse comando faz:**
- Faz build da aplicação Flask
- Sobe 4 containers:
  - `kube_ops_app` - API Flask (porta 8000)
  - `elasticsearch` - Armazena logs (porta 9200)
  - `kibana` - Interface de visualização (porta 5601)
  - `filebeat` - Coleta logs da aplicação

#### **Passo 3: Verifique se tudo subiu**
```powershell
docker ps
```

Você deve ver 4 containers rodando:
```
CONTAINER ID   IMAGE                              STATUS
xxxxx          kube-ops:local                     Up
xxxxx          docker.elastic.co/kibana...        Up
xxxxx          docker.elastic.co/elasticsearch... Up (healthy)
xxxxx          local/filebeat:8.13.4              Up
```

#### **Passo 4: Aguarde 30 segundos**

O Elasticsearch e Kibana levam alguns segundos para inicializar completamente.

```powershell
# Aguarde no PowerShell
Start-Sleep -Seconds 30

# Ou no Bash
sleep 30
```

#### **Passo 5: Teste a API**

**Windows PowerShell:**
```powershell
# Teste básico
curl.exe http://localhost:8000/

# Health check
curl.exe http://localhost:8000/healthz

# Listar TODOs
curl.exe http://localhost:8000/api/todos

# Criar um TODO
curl.exe -X POST http://localhost:8000/api/todos `
  -H "Content-Type: application/json" `
  -d '{\"title\":\"Meu primeiro TODO\",\"done\":false}'
```

**Linux/Mac Bash:**
```bash
# Teste básico
curl http://localhost:8000/

# Health check
curl http://localhost:8000/healthz

# Listar TODOs
curl http://localhost:8000/api/todos

# Criar um TODO
curl -X POST http://localhost:8000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Meu primeiro TODO","done":false}'
```

#### **Passo 6: Execute os testes automatizados**

```powershell
# Windows
.\scripts\test-api.ps1

# Linux/Mac
chmod +x scripts/test-api.sh
./scripts/test-api.sh
```

#### **Passo 7: Gere carga de teste (para ver logs no Kibana)**

```powershell
# Windows
.\scripts\generate-load.ps1 -Requests 100

# Linux/Mac
chmod +x scripts/generate-load.sh
REQUESTS=100 ./scripts/generate-load.sh
```

Este script vai gerar:
- Requisições **200** (sucesso)
- Requisições **404** (não encontrado)
- Requisições **500** (erro)
- Criar TODOs variados

#### **Passo 8: Acesse os serviços**

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **API Flask** | http://localhost:8000 | API REST principal |
| **Elasticsearch** | http://localhost:9200 | Banco de dados de logs |
| **Kibana** | http://localhost:5601 | Dashboard de visualização |

#### **Passo 9: Visualize logs no Kibana**

1. Acesse: http://localhost:5601
2. No menu lateral: **☰ Menu → Analytics → Discover**
3. Clique em **"Create data view"**
4. Configure:
   - **Name**: `Logs Kube-Ops`
   - **Index pattern**: `app-logs-*`
   - **Timestamp field**: `@timestamp`
5. Clique em **"Save data view to Kibana"**
6. Agora você verá todos os logs em tempo real!

**Criar visualizações:**
1. Vá em **☰ Menu → Analytics → Dashboard**
2. Clique em **"Create dashboard"**
3. Adicione visualizações (gráficos de status code, tempo de resposta, etc.)

#### **Passo 10: Parar todos os serviços**

```powershell
# Parar e remover containers (mantém dados)
docker compose down

# Parar e remover TUDO (incluindo volumes/dados)
docker compose down -v
```

---

### **2. Somente API (Docker)**

Se você quer apenas a API rodando sem observabilidade:

#### **Opção A: Build e Run manual**

```powershell
# 1. Build da imagem
docker build -t kube-ops:local .

# 2. Run do container
docker run -d --name kube_ops_app -p 8000:8000 kube-ops:local

# 3. Testar
curl.exe http://localhost:8000/
curl.exe http://localhost:8000/healthz

# 4. Ver logs
docker logs kube_ops_app

# 5. Parar e remover
docker stop kube_ops_app
docker rm kube_ops_app
```

#### **Opção B: Com persistência de dados**

```powershell
# 1. Criar diretório para dados
mkdir data

# 2. Run com volume montado
docker run -d --name kube_ops_app `
  -p 8000:8000 `
  -v ${PWD}/data:/app `
  -e SQLALCHEMY_DATABASE_URI=sqlite:///app.db `
  kube-ops:local

# Agora o banco SQLite fica em ./data/app.db
```

---

### **3. Deploy no Kubernetes (Minikube)**

Para rodar no Kubernetes local:

#### **Passo 1: Instale Minikube**

```powershell
# Windows (via Chocolatey)
choco install minikube

# Ou baixe: https://minikube.sigs.k8s.io/docs/start/
```

#### **Passo 2: Inicie o Minikube**

```powershell
minikube start
```

**O que acontece:**
- Cria uma VM/container com Kubernetes
- Configura kubectl para usar este cluster
- Demora ~1-3 minutos na primeira vez

#### **Passo 3: Build da imagem no Minikube**

```powershell
# Opção A: Build direto no Minikube
minikube image build -t kube-ops:local .

# OU Opção B: Usar Docker local
eval $(minikube docker-env)
docker build -t kube-ops:local .
```

**Por quê isso?** O Minikube usa seu próprio Docker daemon. Precisamos que a imagem esteja lá dentro.

#### **Passo 4: Deploy com Helm**

```powershell
# Instalar a aplicação
helm install kube-ops ./helm `
  --set image.repository=kube-ops `
  --set image.tag=local `
  --set image.pullPolicy=Never

# Ver o que foi criado
helm list
```

**O que o Helm faz:**
- Cria um **Deployment** (gerencia pods)
- Cria um **Service** (expõe a aplicação na porta 30080)
- Configura um **ConfigMap** (configuração do Filebeat)

#### **Passo 5: Verificar pods**

```powershell
# Ver pods
kubectl get pods

# Ver detalhes
kubectl describe pod <NOME_DO_POD>

# Ver logs
kubectl logs <NOME_DO_POD>
```

Aguarde até o pod ficar **Running** e **Ready 1/1**:
```
NAME                        READY   STATUS    RESTARTS   AGE
kube-ops-xxxxxxxxx-xxxxx    1/1     Running   0          30s
```

#### **Passo 6: Acessar a aplicação**

```powershell
# Obter a URL
minikube service kube-ops --url

# Vai retornar algo como: http://192.168.49.2:30080

# Testar
$url = minikube service kube-ops --url
curl.exe $url
curl.exe $url/healthz
curl.exe $url/api/todos
```

#### **Passo 7: Verificar serviços**

```powershell
# Ver todos os recursos
kubectl get all

# Ver detalhes do service
kubectl get svc kube-ops

# Abrir navegador automaticamente
minikube service kube-ops
```

#### **Passo 8: Atualizar a aplicação**

```powershell
# 1. Fazer alterações no código

# 2. Rebuild da imagem
minikube image build -t kube-ops:local .

# 3. Atualizar deployment
helm upgrade kube-ops ./helm `
  --set image.repository=kube-ops `
  --set image.tag=local `
  --set image.pullPolicy=Never

# 4. Reiniciar pods (força pull da nova imagem)
kubectl rollout restart deployment kube-ops
```

#### **Passo 9: Remover tudo**

```powershell
# Desinstalar via Helm
helm uninstall kube-ops

# Parar Minikube
minikube stop

# Deletar completamente (cuidado!)
minikube delete
```

---

## 🏗️ Arquitetura e Componentes

### **Visão Geral**

```
┌─────────────────────────────────────────────────────────────┐
│                         USUÁRIO                              │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP Request
                         ▼
            ┌────────────────────────────┐
            │    API Flask (Gunicorn)    │
            │    Porta: 8000             │
            └────┬──────────────┬────────┘
                 │              │
        ┌────────▼─────┐   ┌───▼─────────────────┐
        │  SQLite DB   │   │  Logs JSON (stdout) │
        │  (TODOs)     │   │  + /var/log/app/    │
        └──────────────┘   └──────────┬──────────┘
                                      │
                                      ▼
                           ┌──────────────────┐
                           │    Filebeat      │
                           │   (Coletor)      │
                           └─────────┬────────┘
                                     │
                                     ▼
                          ┌──────────────────────┐
                          │   Elasticsearch      │
                          │  (Armazena logs)     │
                          │  Índice: app-logs-*  │
                          └──────────┬───────────┘
                                     │
                                     ▼
                          ┌──────────────────────┐
                          │      Kibana          │
                          │   (Visualização)     │
                          │  Dashboard + Gráficos│
                          └──────────────────────┘
```

### **Componentes Principais**

#### **1. API Flask (`app/`)**

**Arquivo principal:** `app/__init__.py`

**Funcionalidades:**
- API RESTful para gerenciar TODOs
- Endpoints: /, /healthz, /api/todos
- Logs estruturados em JSON (formato ECS)
- Validação de dados com Marshmallow
- Persistência com SQLAlchemy

**Como funciona:**
1. Recebe requisição HTTP
2. Processa (CRUD no banco)
3. Retorna resposta JSON
4. Gera log estruturado com métricas (tempo de resposta, status code, etc.)

#### **2. Dockerfile**

**Arquivo:** `Dockerfile`

**O que faz:**
- Base: Python 3.12 slim (leve)
- Instala dependências (requirements.txt)
- Copia código da aplicação
- Expõe porta 8000
- Roda Gunicorn (servidor WSGI de produção)

**Build:**
```powershell
docker build -t kube-ops:local .
```

#### **3. Docker Compose (`docker-compose.yml`)**

**O que faz:**
- Orquestra 4 serviços:
  - `app` - API Flask
  - `elasticsearch` - Banco de dados de logs
  - `kibana` - Interface web
  - `filebeat` - Coleta logs

**Vantagens:**
- Sobe tudo com 1 comando
- Networking automático (containers se comunicam por nome)
- Volumes compartilhados (logs entre app e filebeat)
- Healthchecks (garante ordem de inicialização)

#### **4. Helm Chart (`helm/`)**

**Estrutura:**
```
helm/
├── Chart.yaml           # Metadados do chart
├── values.yaml          # Configurações padrão
├── values-minikube.yaml # Config para Minikube
└── templates/
    ├── deployment.yaml  # Deploy da aplicação
    ├── service.yaml     # Expõe a aplicação
    └── filebeat-configmap.yaml  # Config Filebeat
```

**Como usar:**
```powershell
helm install kube-ops ./helm
helm upgrade kube-ops ./helm
helm uninstall kube-ops
```

---

## 🔄 Pipeline CI/CD

### **Arquivo:** `.github/workflows/main.yml`

### **Como Funciona**

O pipeline é **automático** e roda a cada push na branch `main`:

```
Push no GitHub
    ↓
┌─────────────────────┐
│  Job 1: test-build- │
│        push         │
└──────────┬──────────┘
           │
    ┌──────▼──────────────┐
    │ 1. Checkout código  │
    │ 2. Setup Python 3.12│
    │ 3. Install deps     │
    │ 4. Run pytest       │  ← TESTES
    │ 5. Login GHCR       │
    │ 6. Build Docker img │
    │ 7. Push to GHCR     │  ← BUILD
    └──────────┬──────────┘
               │
    ┌──────────▼────────────┐
    │   Job 2: deploy       │
    └──────────┬────────────┘
               │
    ┌──────────▼────────────┐
    │ 1. Checkout código    │
    │ 2. Setup kubectl      │
    │ 3. Setup Helm         │
    │ 4. Decode KUBECONFIG  │
    │ 5. helm upgrade       │  ← DEPLOY
    │ 6. kubectl validate   │
    └───────────────────────┘
```

### **Jobs Detalhados**

#### **Job 1: test-build-push**

**O que faz:**
1. **Testa** - Executa `pytest` para validar código
2. **Build** - Cria imagem Docker
3. **Push** - Envia para GitHub Container Registry (GHCR)

**Resultado:**
- Imagem disponível em: `ghcr.io/ed1abreu/kube_ops:latest`
- Testes validados
- Pronto para deploy

#### **Job 2: deploy**

**O que faz:**
1. Decodifica secret `KUBE_CONFIG`
2. Conecta no cluster Kubernetes
3. Executa: `helm upgrade --install kube-ops ./helm`
4. Valida se pods subiram

**Quando roda:**
- Só se o secret `KUBE_CONFIG` estiver configurado
- Após job 1 ter sucesso

### **Como Configurar o Pipeline**

#### **Para usar GHCR (GitHub Container Registry):**

✅ **Já funciona automaticamente!** Não precisa configurar nada.

#### **Para deploy automático no Kubernetes:**

1. **Gere o kubeconfig em base64:**

```powershell
# Windows
$kubeconfig = Get-Content $env:USERPROFILE\.kube\config -Raw
$bytes = [System.Text.Encoding]::UTF8.GetBytes($kubeconfig)
$base64 = [System.Convert]::ToBase64String($bytes)
$base64 | Set-Clipboard

# Linux/Mac
cat ~/.kube/config | base64 -w 0 | pbcopy
```

2. **Configure o secret no GitHub:**
   - Vá em: `Settings → Secrets and variables → Actions`
   - Clique em **"New repository secret"**
   - Name: `KUBE_CONFIG`
   - Value: Cole o base64
   - Salve

3. **Pronto!** No próximo push, o deploy será automático.

### **Ver Execução do Pipeline**

```
https://github.com/Ed1Abreu/Kube_Ops/actions
```

---

## 📊 Observabilidade (ELK Stack)

### **O que é ELK?**

**ELK** = **E**lasticsearch + **L**ogstash (substituído por Filebeat) + **K**ibana

### **Componentes**

#### **1. Elasticsearch (Porta 9200)**

**O que faz:**
- Banco de dados de logs
- Indexa e armazena logs em formato JSON
- Permite buscas rápidas e agregações

**Acesso:**
```powershell
# Ver saúde do cluster
curl.exe http://localhost:9200/_cluster/health

# Ver índices
curl.exe http://localhost:9200/_cat/indices

# Buscar logs
curl.exe http://localhost:9200/app-logs-*/_search
```

**Configuração:**
- Single-node (1 servidor - adequado para dev)
- Sem segurança (sem senha - apenas dev!)
- Memória: 512MB (limitado para máquinas locais)

#### **2. Filebeat**

**O que faz:**
- **Coleta** logs do arquivo `/var/log/app/app.log`
- **Processa** JSON (decodifica campo `message`)
- **Envia** para Elasticsearch

**Arquivo de config:** `logging/filebeat/filebeat.yml`

**Fluxo:**
```
App gera log → /var/log/app/app.log
                       ↓
         Filebeat monitora arquivo
                       ↓
         Decodifica JSON do log
                       ↓
   Adiciona metadados (service.name, etc)
                       ↓
     Envia para Elasticsearch
     (índice: app-logs-YYYY.MM.DD)
```

#### **3. Kibana (Porta 5601)**

**O que faz:**
- Interface web para visualizar logs
- Cria dashboards e gráficos
- Busca e filtra logs em tempo real

**Como usar:**

1. **Acessar:** http://localhost:5601

2. **Criar Data View:**
   - Menu → Management → Stack Management → Data Views
   - Create data view
   - Name: `Logs Kube-Ops`
   - Index pattern: `app-logs-*`
   - Timestamp: `@timestamp`
   - Save

3. **Ver logs em tempo real:**
   - Menu → Analytics → Discover
   - Selecione data view `Logs Kube-Ops`
   - Ajuste período: Last 15 minutes
   - Adicione campos: `http.response.status_code`, `url.path`, `metrics.response_time_ms`

4. **Criar Dashboard:**
   - Menu → Analytics → Dashboard
   - Create dashboard
   - Add visualization
   - Crie gráficos de:
     - Status codes (bar chart)
     - Response time (metric)
     - Requests over time (line chart)
     - Top endpoints (pie chart)

### **Logs Estruturados**

A aplicação gera logs em formato JSON com esta estrutura:

```json
{
  "@timestamp": "2025-10-26T15:30:45Z",
  "event": {
    "action": "http_request"
  },
  "http": {
    "request": {
      "method": "GET"
    },
    "response": {
      "status_code": 200
    }
  },
  "url": {
    "path": "/api/todos",
    "query": ""
  },
  "client": {
    "ip": "172.18.0.1"
  },
  "user_agent": {
    "original": "curl/7.68.0"
  },
  "service": {
    "name": "kube-ops"
  },
  "metrics": {
    "response_time_ms": 12.345
  },
  "status_class": "2xx"
}
```

**Campos importantes:**
- `@timestamp` - Quando aconteceu
- `http.response.status_code` - 200, 404, 500, etc.
- `url.path` - Endpoint acessado
- `metrics.response_time_ms` - Tempo de resposta
- `status_class` - 2xx, 4xx, 5xx (para gráficos)

---

## 📚 API Endpoints

### **Documentação da API**

#### **1. Health Checks**

**GET /**
```powershell
curl.exe http://localhost:8000/
```
**Resposta:**
```json
{"message": "Hello, Kube Ops!"}
```

**GET /healthz**
```powershell
curl.exe http://localhost:8000/healthz
```
**Resposta:**
```json
{"status": "ok"}
```

#### **2. Listar TODOs**

**GET /api/todos**
```powershell
curl.exe http://localhost:8000/api/todos
```
**Resposta:**
```json
[
  {
    "id": 1,
    "title": "Estudar DevOps",
    "done": false,
    "created_at": "2025-10-26T15:30:00Z"
  }
]
```

#### **3. Criar TODO**

**POST /api/todos**
```powershell
curl.exe -X POST http://localhost:8000/api/todos `
  -H "Content-Type: application/json" `
  -d '{\"title\":\"Estudar Kubernetes\",\"done\":false}'
```
**Resposta (201):**
```json
{
  "id": 2,
  "title": "Estudar Kubernetes",
  "done": false,
  "created_at": "2025-10-26T15:35:00Z"
}
```

#### **4. Buscar TODO específico**

**GET /api/todos/{id}**
```powershell
curl.exe http://localhost:8000/api/todos/1
```
**Resposta:**
```json
{
  "id": 1,
  "title": "Estudar DevOps",
  "done": false,
  "created_at": "2025-10-26T15:30:00Z"
}
```

#### **5. Atualizar TODO**

**PATCH /api/todos/{id}**
```powershell
curl.exe -X PATCH http://localhost:8000/api/todos/1 `
  -H "Content-Type: application/json" `
  -d '{\"done\":true}'
```
**Resposta:**
```json
{
  "id": 1,
  "title": "Estudar DevOps",
  "done": true,
  "created_at": "2025-10-26T15:30:00Z"
}
```

#### **6. Deletar TODO**

**DELETE /api/todos/{id}**
```powershell
curl.exe -X DELETE http://localhost:8000/api/todos/1
```
**Resposta (204):** (sem conteúdo)

#### **7. Simular erro 500**

**GET /boom**
```powershell
curl.exe http://localhost:8000/boom
```
**Resposta (500):**
```json
{"error": "internal server error"}
```
*Útil para testar observabilidade e logs de erro*

---

## 🧪 Testes

### **Testes Automatizados (pytest)**

#### **Executar testes:**

```powershell
# Instalar dependências
pip install -r requirements.txt

# Executar todos os testes
pytest -v

# Com cobertura
pip install pytest-cov
pytest --cov=app --cov-report=term-missing
```

#### **Testes implementados:**

**Arquivo:** `tests/test_app.py`

1. **test_index_route_returns_message** - Testa endpoint /
2. **test_healthz_route_ok** - Testa /healthz
3. **test_todos_crud_flow** - Testa CRUD completo:
   - Lista vazia inicialmente
   - Cria TODO
   - Busca TODO
   - Atualiza TODO
   - Deleta TODO
   - Lista vazia novamente

### **Scripts de Teste End-to-End**

#### **Windows:**
```powershell
.\scripts\test-api.ps1
```

#### **Linux/Mac:**
```bash
chmod +x scripts/test-api.sh
./scripts/test-api.sh
```

**O que testa:**
- ✅ Health checks (/, /healthz)
- ✅ CRUD completo de TODOs
- ✅ Validação de dados (retorna 400 em erro)
- ✅ Erro 404 (endpoint inexistente)
- ✅ Erro 500 (/boom)

### **Geração de Carga**

Para visualizar logs no Kibana:

#### **Windows:**
```powershell
.\scripts\generate-load.ps1 -Requests 100 -Delay 0.1
```

#### **Linux/Mac:**
```bash
chmod +x scripts/generate-load.sh
REQUESTS=100 DELAY=0.1 ./scripts/generate-load.sh
```

**O que faz:**
- Gera requisições variadas (200, 404, 500)
- Cria TODOs dinamicamente
- Simula carga real de uso

---

## 🔧 Troubleshooting

### **Problema: Containers não sobem**

```powershell
# Ver logs de todos os containers
docker compose logs

# Ver log específico
docker compose logs app
docker compose logs elasticsearch
docker compose logs kibana
docker compose logs filebeat

# Verificar portas em uso
netstat -an | findstr "8000 9200 5601"

# Limpar tudo e recomeçar
docker compose down -v
docker compose up -d --build
```

### **Problema: Kibana não mostra logs**

**Causas comuns:**
1. Elasticsearch ainda está inicializando
2. Filebeat não está rodando
3. Logs não estão sendo gerados

**Soluções:**
```powershell
# 1. Aguarde 1-2 minutos após docker compose up

# 2. Verifique Elasticsearch
curl.exe http://localhost:9200/_cat/health

# 3. Verifique se há índices
curl.exe http://localhost:9200/_cat/indices | Select-String app-logs

# 4. Gere logs
.\scripts\generate-load.ps1 -Requests 50

# 5. Verifique logs do Filebeat
docker logs filebeat
```

### **Problema: API não responde**

```powershell
# Ver logs da aplicação
docker logs kube_ops_app

# Verificar se container está rodando
docker ps | Select-String kube

# Testar porta
Test-NetConnection localhost -Port 8000

# Reiniciar container
docker restart kube_ops_app
```

### **Problema: Minikube não inicia**

```powershell
# Ver status
minikube status

# Deletar e recriar
minikube delete
minikube start

# Ver logs
minikube logs

# Usar driver diferente
minikube start --driver=virtualbox
# ou
minikube start --driver=hyperv
```

### **Problema: Pipeline CI/CD falha**

**Verificar:**
1. Secrets configurados corretamente
2. Testes passando localmente
3. Logs do GitHub Actions

```
https://github.com/Ed1Abreu/Kube_Ops/actions
```

### **Problema: Erros de encoding no PowerShell**

Se scripts com emojis derem erro:

```powershell
# Usar versão sem emojis dos scripts
# Ou executar:
chcp 65001  # Muda para UTF-8
```

---

## 📁 Estrutura do Projeto

```
Kube_Ops/
├── .github/
│   └── workflows/
│       └── main.yml              # Pipeline CI/CD
├── app/
│   ├── __init__.py              # Factory app + logging
│   ├── models.py                # Modelo TODO
│   ├── schemas.py               # Validação Marshmallow
│   ├── blueprints.py            # Rotas API
│   └── extensions.py            # SQLAlchemy
├── tests/
│   └── test_app.py              # Testes pytest
├── helm/
│   ├── Chart.yaml               # Metadados Helm
│   ├── values.yaml              # Config padrão
│   ├── values-minikube.yaml     # Config Minikube
│   └── templates/
│       ├── deployment.yaml      # Deploy K8s
│       ├── service.yaml         # Service K8s
│       └── filebeat-configmap.yaml
├── logging/
│   └── filebeat/
│       ├── Dockerfile           # Build Filebeat
│       └── filebeat.yml         # Config Filebeat
├── scripts/
│   ├── test-api.ps1            # Testes Windows
│   ├── test-api.sh             # Testes Linux/Mac
│   ├── generate-load.ps1       # Carga Windows
│   └── generate-load.sh        # Carga Linux/Mac
├── Dockerfile                   # Build da aplicação
├── docker-compose.yml           # Stack completa
├── requirements.txt             # Deps Python
├── pytest.ini                   # Config pytest
└── README.md                    # Este arquivo
```

---

## 🎓 Conceitos Demonstrados

### **DevOps/SRE:**
- ✅ CI/CD com GitHub Actions
- ✅ Containerização (Docker)
- ✅ Orquestração (Kubernetes + Helm)
- ✅ Observabilidade (ELK Stack)
- ✅ Infrastructure as Code (IaC)
- ✅ Testes automatizados

### **Cloud Native:**
- ✅ 12-Factor App
- ✅ Stateless architecture
- ✅ Health checks (liveness/readiness)
- ✅ Logs estruturados
- ✅ Configuration via environment
- ✅ Sidecar pattern (Filebeat)

### **Desenvolvimento:**
- ✅ API RESTful (Flask)
- ✅ ORM (SQLAlchemy)
- ✅ Validação (Marshmallow)
- ✅ Testes (pytest)
- ✅ Type hints
- ✅ Factory pattern

---

## 🤝 Contribuindo

```bash
# Fork o projeto
git clone https://github.com/seu-usuario/Kube_Ops.git

# Crie uma branch
git checkout -b feature/minha-feature

# Faça suas alterações
git add .
git commit -m "feat: adiciona nova funcionalidade"

# Push e abra um PR
git push origin feature/minha-feature
```

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja [LICENSE](LICENSE) para detalhes.

---

## 👨‍💻 Autor

**Ed1Abreu**
- GitHub: [@Ed1Abreu](https://github.com/Ed1Abreu)
- Projeto: [Kube_Ops](https://github.com/Ed1Abreu/Kube_Ops)

---

## 🎯 Resumo Rápido

### **Para rodar localmente (completo):**
```powershell
git clone https://github.com/Ed1Abreu/Kube_Ops.git
cd Kube_Ops
docker compose up -d --build
Start-Sleep -Seconds 30
.\scripts\test-api.ps1
# API: http://localhost:8000
# Kibana: http://localhost:5601
```

### **Para deploy no Kubernetes:**
```powershell
minikube start
minikube image build -t kube-ops:local .
helm install kube-ops ./helm --set image.repository=kube-ops --set image.tag=local --set image.pullPolicy=Never
minikube service kube-ops --url
```

### **Para rodar testes:**
```powershell
pip install -r requirements.txt
pytest -v
```

---

**⭐ Se este projeto te ajudou, deixe uma estrela no GitHub!**

---

**Desenvolvido com ❤️ para demonstrar práticas modernas de DevOps e Cloud Native**
