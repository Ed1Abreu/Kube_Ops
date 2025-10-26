#!/bin/bash
# Script para gerar carga de testes na API
# Útil para visualizar logs e métricas no Kibana em tempo real

API_URL="${API_URL:-http://localhost:8000}"
REQUESTS="${REQUESTS:-100}"
DELAY="${DELAY:-0.1}"

echo "🔥 Gerando carga de testes na API..."
echo "📍 URL: $API_URL"
echo "📊 Requisições: $REQUESTS"
echo "⏱️  Delay: ${DELAY}s entre requisições"
echo ""

for i in $(seq 1 $REQUESTS); do
    # Requisições de sucesso (200)
    curl -s -o /dev/null "$API_URL/" &
    curl -s -o /dev/null "$API_URL/api/todos" &
    curl -s -o /dev/null "$API_URL/healthz" &
    
    # A cada 10 requisições, gera um 404
    if [ $((i % 10)) -eq 0 ]; then
        curl -s -o /dev/null "$API_URL/naoexiste" &
    fi
    
    # A cada 20 requisições, gera um 500
    if [ $((i % 20)) -eq 0 ]; then
        curl -s -o /dev/null "$API_URL/boom" &
    fi
    
    # A cada 5 requisições, cria um TODO
    if [ $((i % 5)) -eq 0 ]; then
        curl -s -o /dev/null -X POST "$API_URL/api/todos" \
            -H "Content-Type: application/json" \
            -d "{\"title\":\"TODO #$i\",\"done\":false}" &
    fi
    
    # Progress
    if [ $((i % 10)) -eq 0 ]; then
        echo "⏳ Progresso: $i/$REQUESTS requisições enviadas..."
    fi
    
    sleep $DELAY
done

# Aguardar requisições finalizarem
wait

echo ""
echo "✅ Carga de teste concluída!"
echo "📊 Verifique o dashboard no Kibana: http://localhost:5601"
echo "💡 Execute novamente: REQUESTS=500 ./scripts/generate-load.sh"

