#!/bin/bash

# Função para detectar repositório do .git
detect_repo() {
    # Verifica se está em um repositório git
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "❌ Erro: Você não está em um repositório git."
        echo "Execute este script dentro de um repositório git."
        exit 1
    fi
    
    # Pega a URL do remote
    local url=$(git config --get remote.origin.url 2>/dev/null)
    
    # Se não tiver origin, tenta o primeiro remote
    if [ -z "$url" ]; then
        local first_remote=$(git remote 2>/dev/null | head -n1)
        if [ -n "$first_remote" ]; then
            url=$(git config --get "remote.$first_remote.url")
        else
            echo "❌ Erro: Nenhum remote configurado neste repositório."
            echo "Configure um remote com: git remote add origin <url>"
            exit 1
        fi
    fi
    
    # Extrai usuario/repositorio
    local repo=$(echo "$url" | sed -E '
        s/^[a-zA-Z]+:\/\///g
        s/^[^@]+@//g
        s/^[^:]+[:/]//g
        s/\.git$//g
    ')
    
    echo "$repo"
}

# Função principal
delete_all_logs() {
    local REPO=$(detect_repo)
    echo "📁 Repositório: $REPO"
    
    echo "🔍 Buscando todos os runs..."
    
    # Busca todos os runs
    RUNS=$(gh api "/repos/$REPO/actions/runs" --paginate --jq '.workflow_runs[].id')
    TOTAL=$(echo "$RUNS" | grep -c . 2>/dev/null || echo 0)
    
    if [ "$TOTAL" -eq 0 ]; then
        echo "✅ Nenhum run encontrado para deletar."
        return 0
    fi
    
    echo "📊 Encontrados $TOTAL runs"
    read -p "⚠️  Deletar todos? (sim/não): " CONFIRMACAO
    
    if [ "$CONFIRMACAO" != "sim" ]; then
        echo "❌ Cancelado."
        return 0
    fi
    
    CONTADOR=0
    for RUN in $RUNS; do
        echo "🗑️  Deletando $((++CONTADOR))/$TOTAL - Run ID: $RUN"
        gh api --silent --method DELETE "/repos/$REPO/actions/runs/$RUN"
        sleep 0.1
    done
    
    echo "✅ Todos os $TOTAL runs foram deletados!"
}

# Executa
delete_all_logs
