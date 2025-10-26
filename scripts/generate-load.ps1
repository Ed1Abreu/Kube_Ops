# Script para gerar carga de testes na API (Windows PowerShell)
# Util para visualizar logs e metricas no Kibana em tempo real

param(
    [string]$ApiUrl = "http://localhost:8000",
    [int]$Requests = 100,
    [double]$Delay = 0.1
)

Write-Host "[INICIANDO] Gerando carga de testes na API..." -ForegroundColor Blue
Write-Host "[CONFIG] URL: $ApiUrl" -ForegroundColor Blue
Write-Host "[CONFIG] Requisicoes: $Requests" -ForegroundColor Blue
Write-Host "[CONFIG] Delay: ${Delay}s entre requisicoes" -ForegroundColor Blue
Write-Host ""

for ($i = 1; $i -le $Requests; $i++) {
    # Requisicoes de sucesso (200)
    try {
        $null = Invoke-WebRequest -Uri "$ApiUrl/" -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
        $null = Invoke-WebRequest -Uri "$ApiUrl/api/todos" -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
        $null = Invoke-WebRequest -Uri "$ApiUrl/healthz" -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
    } catch {
        # Ignora erros de conexao
    }
    
    # A cada 10 requisicoes, gera um 404
    if ($i % 10 -eq 0) {
        try {
            $null = Invoke-WebRequest -Uri "$ApiUrl/naoexiste" -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
        } catch {
            # Esperado 404
        }
    }
    
    # A cada 20 requisicoes, gera um 500
    if ($i % 20 -eq 0) {
        try {
            $null = Invoke-WebRequest -Uri "$ApiUrl/boom" -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
        } catch {
            # Esperado 500
        }
    }
    
    # A cada 5 requisicoes, cria um TODO
    if ($i % 5 -eq 0) {
        try {
            $body = @{
                title = "TODO #$i"
                done = $false
            } | ConvertTo-Json
            
            $null = Invoke-RestMethod -Uri "$ApiUrl/api/todos" -Method POST -Body $body -ContentType "application/json" -ErrorAction SilentlyContinue
        } catch {
            # Ignora erros
        }
    }
    
    # Progress
    if ($i % 10 -eq 0) {
        Write-Host "[PROGRESS] $i/$Requests requisicoes enviadas..." -ForegroundColor Yellow
    }
    
    Start-Sleep -Seconds $Delay
}

Write-Host ""
Write-Host "[SUCESSO] Carga de teste concluida!" -ForegroundColor Green
Write-Host "[INFO] Verifique o dashboard no Kibana: http://localhost:5601" -ForegroundColor Blue
Write-Host "[DICA] Execute novamente: .\scripts\generate-load.ps1 -Requests 500" -ForegroundColor Cyan

