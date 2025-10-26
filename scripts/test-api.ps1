# Script de testes end-to-end da API Kube-Ops (Windows PowerShell)
# Gera logs variados para visualização no Kibana

param(
    [string]$ApiUrl = "http://localhost:8000"
)

$ErrorActionPreference = "Stop"

function Write-Status {
    param(
        [string]$Color,
        [string]$Message
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-Status "Blue" "🚀 Iniciando testes da API Kube-Ops..."
Write-Status "Blue" "📍 URL: $ApiUrl"
Write-Host ""

# Teste 1: Health Check
Write-Status "Yellow" "📋 Teste 1: Health Check"
try {
    $response = Invoke-WebRequest -Uri "$ApiUrl/" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Status "Green" "✅ GET / - Status 200 OK"
    }
} catch {
    Write-Status "Red" "❌ GET / - Erro: $($_.Exception.Message)"
    exit 1
}
Write-Host ""

# Teste 2: Healthz endpoint
Write-Status "Yellow" "📋 Teste 2: Kubernetes Health Check"
try {
    $response = Invoke-WebRequest -Uri "$ApiUrl/healthz" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Status "Green" "✅ GET /healthz - Status 200 OK"
    }
} catch {
    Write-Status "Red" "❌ GET /healthz - Erro: $($_.Exception.Message)"
    exit 1
}
Write-Host ""

# Teste 3: Listar TODOs
Write-Status "Yellow" "📋 Teste 3: Listar TODOs"
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/todos" -Method GET
    if ($response.Count -eq 0) {
        Write-Status "Green" "✅ GET /api/todos - Lista vazia OK"
    } else {
        Write-Status "Green" "ℹ️  GET /api/todos - Lista contém $($response.Count) itens"
    }
} catch {
    Write-Status "Red" "❌ GET /api/todos - Erro: $($_.Exception.Message)"
    exit 1
}
Write-Host ""

# Teste 4: Criar TODO #1
Write-Status "Yellow" "📋 Teste 4: Criar TODO #1"
try {
    $body = @{
        title = "Configurar CI/CD com GitHub Actions"
        done = $false
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$ApiUrl/api/todos" -Method POST -Body $body -ContentType "application/json"
    $todo1_id = $response.id
    Write-Status "Green" "✅ POST /api/todos - TODO criado (ID: $todo1_id)"
} catch {
    Write-Status "Red" "❌ POST /api/todos - Erro: $($_.Exception.Message)"
    exit 1
}
Write-Host ""

# Teste 5: Criar TODO #2
Write-Status "Yellow" "📋 Teste 5: Criar TODO #2"
try {
    $body = @{
        title = "Criar Dashboard no Kibana"
        done = $true
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$ApiUrl/api/todos" -Method POST -Body $body -ContentType "application/json"
    $todo2_id = $response.id
    Write-Status "Green" "✅ POST /api/todos - TODO criado (ID: $todo2_id)"
} catch {
    Write-Status "Red" "❌ POST /api/todos - Erro: $($_.Exception.Message)"
    exit 1
}
Write-Host ""

# Teste 6: Criar TODO #3
Write-Status "Yellow" "📋 Teste 6: Criar TODO #3"
try {
    $body = @{
        title = "Deploy no Kubernetes"
        done = $false
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$ApiUrl/api/todos" -Method POST -Body $body -ContentType "application/json"
    $todo3_id = $response.id
    Write-Status "Green" "✅ POST /api/todos - TODO criado (ID: $todo3_id)"
} catch {
    Write-Status "Red" "❌ POST /api/todos - Erro: $($_.Exception.Message)"
}
Write-Host ""

# Teste 7: Buscar TODO específico
Write-Status "Yellow" "📋 Teste 7: Buscar TODO específico"
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/todos/$todo1_id" -Method GET
    Write-Status "Green" "✅ GET /api/todos/$todo1_id - Status 200 OK"
} catch {
    Write-Status "Red" "❌ GET /api/todos/$todo1_id - Erro: $($_.Exception.Message)"
    exit 1
}
Write-Host ""

# Teste 8: Atualizar TODO
Write-Status "Yellow" "📋 Teste 8: Marcar TODO como concluído"
try {
    $body = @{
        done = $true
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$ApiUrl/api/todos/$todo1_id" -Method PATCH -Body $body -ContentType "application/json"
    if ($response.done -eq $true) {
        Write-Status "Green" "✅ PATCH /api/todos/$todo1_id - TODO atualizado"
    }
} catch {
    Write-Status "Red" "❌ PATCH /api/todos/$todo1_id - Erro: $($_.Exception.Message)"
    exit 1
}
Write-Host ""

# Teste 9: Listar todos os TODOs
Write-Status "Yellow" "📋 Teste 9: Listar todos os TODOs"
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/todos" -Method GET
    Write-Status "Green" "✅ GET /api/todos - $($response.Count) TODOs encontrados"
} catch {
    Write-Status "Red" "❌ GET /api/todos - Erro: $($_.Exception.Message)"
}
Write-Host ""

# Teste 10: Deletar TODO
Write-Status "Yellow" "📋 Teste 10: Deletar TODO"
try {
    $response = Invoke-WebRequest -Uri "$ApiUrl/api/todos/$todo2_id" -Method DELETE -UseBasicParsing
    if ($response.StatusCode -eq 204) {
        Write-Status "Green" "✅ DELETE /api/todos/$todo2_id - Status 204 No Content"
    }
} catch {
    Write-Status "Red" "❌ DELETE /api/todos/$todo2_id - Erro: $($_.Exception.Message)"
    exit 1
}
Write-Host ""

# Teste 11: Erro 404
Write-Status "Yellow" "📋 Teste 11: Testar erro 404"
try {
    $response = Invoke-WebRequest -Uri "$ApiUrl/endpoint-que-nao-existe" -Method GET -UseBasicParsing
    Write-Status "Yellow" "⚠️  GET /endpoint-que-nao-existe - Status $($response.StatusCode)"
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 404) {
        Write-Status "Green" "✅ GET /endpoint-que-nao-existe - Status 404 (esperado)"
    } else {
        Write-Status "Yellow" "⚠️  Status: $($_.Exception.Response.StatusCode.value__)"
    }
}
Write-Host ""

# Teste 12: Erro 500
Write-Status "Yellow" "📋 Teste 12: Testar erro 500 (para observabilidade)"
try {
    $response = Invoke-WebRequest -Uri "$ApiUrl/boom" -Method GET -UseBasicParsing
    Write-Status "Yellow" "⚠️  GET /boom - Status $($response.StatusCode)"
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 500) {
        Write-Status "Green" "✅ GET /boom - Status 500 (esperado para testes)"
    } else {
        Write-Status "Yellow" "⚠️  Status: $($_.Exception.Response.StatusCode.value__)"
    }
}
Write-Host ""

# Teste 13: Validação de dados
Write-Status "Yellow" "📋 Teste 13: Validação de dados inválidos"
try {
    $body = @{
        title = ""
        done = $false
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$ApiUrl/api/todos" -Method POST -Body $body -ContentType "application/json"
    Write-Status "Yellow" "⚠️  POST /api/todos (título vazio) - Deveria retornar 400"
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 400) {
        Write-Status "Green" "✅ POST /api/todos (título vazio) - Status 400 (validação OK)"
    } else {
        Write-Status "Yellow" "⚠️  Status: $($_.Exception.Response.StatusCode.value__)"
    }
}
Write-Host ""

# Resumo final
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Status "Green" "✅ Todos os testes principais passaram!"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host ""
Write-Status "Blue" "📊 Verifique os logs no Kibana:"
Write-Status "Blue" "   http://localhost:5601"
Write-Host ""
Write-Status "Green" "🎉 Testes concluídos com sucesso!"

