#!/bin/bash
# Script de testes end-to-end da API Kube-Ops
# Gera logs variados para visualização no Kibana

set -e

API_URL="${API_URL:-http://localhost:8000}"
COLORS=true

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para print colorido
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_status "$BLUE" "🚀 Iniciando testes da API Kube-Ops..."
print_status "$BLUE" "📍 URL: $API_URL"
echo ""

# Teste 1: Health Check
print_status "$YELLOW" "📋 Teste 1: Health Check"
response=$(curl -s -w "\n%{http_code}" "$API_URL/")
status_code=$(echo "$response" | tail -n1)
if [ "$status_code" == "200" ]; then
    print_status "$GREEN" "✅ GET / - Status 200 OK"
else
    print_status "$RED" "❌ GET / - Status $status_code (esperado 200)"
    exit 1
fi
echo ""

# Teste 2: Healthz endpoint
print_status "$YELLOW" "📋 Teste 2: Kubernetes Health Check"
response=$(curl -s -w "\n%{http_code}" "$API_URL/healthz")
status_code=$(echo "$response" | tail -n1)
if [ "$status_code" == "200" ]; then
    print_status "$GREEN" "✅ GET /healthz - Status 200 OK"
else
    print_status "$RED" "❌ GET /healthz - Status $status_code (esperado 200)"
    exit 1
fi
echo ""

# Teste 3: Listar TODOs (deve estar vazio inicialmente)
print_status "$YELLOW" "📋 Teste 3: Listar TODOs (vazio)"
response=$(curl -s "$API_URL/api/todos")
if [ "$response" == "[]" ]; then
    print_status "$GREEN" "✅ GET /api/todos - Lista vazia OK"
else
    print_status "$GREEN" "ℹ️  GET /api/todos - Lista contém itens: $response"
fi
echo ""

# Teste 4: Criar TODO #1
print_status "$YELLOW" "📋 Teste 4: Criar TODO #1"
response=$(curl -s -X POST "$API_URL/api/todos" \
    -H "Content-Type: application/json" \
    -d '{"title":"Configurar CI/CD com GitHub Actions","done":false}')
todo1_id=$(echo "$response" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
if [ -n "$todo1_id" ]; then
    print_status "$GREEN" "✅ POST /api/todos - TODO criado (ID: $todo1_id)"
else
    print_status "$RED" "❌ POST /api/todos - Falha ao criar TODO"
    exit 1
fi
echo ""

# Teste 5: Criar TODO #2
print_status "$YELLOW" "📋 Teste 5: Criar TODO #2"
response=$(curl -s -X POST "$API_URL/api/todos" \
    -H "Content-Type: application/json" \
    -d '{"title":"Criar Dashboard no Kibana","done":true}')
todo2_id=$(echo "$response" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
if [ -n "$todo2_id" ]; then
    print_status "$GREEN" "✅ POST /api/todos - TODO criado (ID: $todo2_id)"
else
    print_status "$RED" "❌ POST /api/todos - Falha ao criar TODO"
    exit 1
fi
echo ""

# Teste 6: Criar TODO #3
print_status "$YELLOW" "📋 Teste 6: Criar TODO #3"
response=$(curl -s -X POST "$API_URL/api/todos" \
    -H "Content-Type: application/json" \
    -d '{"title":"Deploy no Kubernetes","done":false}')
todo3_id=$(echo "$response" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
if [ -n "$todo3_id" ]; then
    print_status "$GREEN" "✅ POST /api/todos - TODO criado (ID: $todo3_id)"
fi
echo ""

# Teste 7: Buscar TODO específico
print_status "$YELLOW" "📋 Teste 7: Buscar TODO específico"
response=$(curl -s -w "\n%{http_code}" "$API_URL/api/todos/$todo1_id")
status_code=$(echo "$response" | tail -n1)
if [ "$status_code" == "200" ]; then
    print_status "$GREEN" "✅ GET /api/todos/$todo1_id - Status 200 OK"
else
    print_status "$RED" "❌ GET /api/todos/$todo1_id - Status $status_code"
    exit 1
fi
echo ""

# Teste 8: Atualizar TODO
print_status "$YELLOW" "📋 Teste 8: Marcar TODO como concluído"
response=$(curl -s -X PATCH "$API_URL/api/todos/$todo1_id" \
    -H "Content-Type: application/json" \
    -d '{"done":true}')
if echo "$response" | grep -q '"done":true'; then
    print_status "$GREEN" "✅ PATCH /api/todos/$todo1_id - TODO atualizado"
else
    print_status "$RED" "❌ PATCH /api/todos/$todo1_id - Falha ao atualizar"
    exit 1
fi
echo ""

# Teste 9: Listar todos os TODOs
print_status "$YELLOW" "📋 Teste 9: Listar todos os TODOs"
response=$(curl -s "$API_URL/api/todos")
todo_count=$(echo "$response" | grep -o '"id":' | wc -l)
print_status "$GREEN" "✅ GET /api/todos - $todo_count TODOs encontrados"
echo ""

# Teste 10: Deletar TODO
print_status "$YELLOW" "📋 Teste 10: Deletar TODO"
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$API_URL/api/todos/$todo2_id")
if [ "$status_code" == "204" ]; then
    print_status "$GREEN" "✅ DELETE /api/todos/$todo2_id - Status 204 No Content"
else
    print_status "$RED" "❌ DELETE /api/todos/$todo2_id - Status $status_code"
    exit 1
fi
echo ""

# Teste 11: Erro 404 (endpoint inexistente)
print_status "$YELLOW" "📋 Teste 11: Testar erro 404"
status_code=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/endpoint-que-nao-existe")
if [ "$status_code" == "404" ]; then
    print_status "$GREEN" "✅ GET /endpoint-que-nao-existe - Status 404 (esperado)"
else
    print_status "$YELLOW" "⚠️  GET /endpoint-que-nao-existe - Status $status_code"
fi
echo ""

# Teste 12: Erro 500 (endpoint /boom)
print_status "$YELLOW" "📋 Teste 12: Testar erro 500 (para observabilidade)"
status_code=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/boom")
if [ "$status_code" == "500" ]; then
    print_status "$GREEN" "✅ GET /boom - Status 500 (esperado para testes)"
else
    print_status "$YELLOW" "⚠️  GET /boom - Status $status_code"
fi
echo ""

# Teste 13: Validação de dados (deve retornar 400)
print_status "$YELLOW" "📋 Teste 13: Validação de dados inválidos"
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL/api/todos" \
    -H "Content-Type: application/json" \
    -d '{"title":"","done":false}')
if [ "$status_code" == "400" ]; then
    print_status "$GREEN" "✅ POST /api/todos (título vazio) - Status 400 (validação OK)"
else
    print_status "$YELLOW" "⚠️  POST /api/todos (título vazio) - Status $status_code"
fi
echo ""

# Resumo final
print_status "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_status "$GREEN" "✅ Todos os testes principais passaram!"
print_status "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_status "$BLUE" "📊 Verifique os logs no Kibana:"
print_status "$BLUE" "   http://localhost:5601"
echo ""
print_status "$GREEN" "🎉 Testes concluídos com sucesso!"

