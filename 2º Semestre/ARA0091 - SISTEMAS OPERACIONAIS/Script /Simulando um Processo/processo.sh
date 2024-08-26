#!/bin/bash

# Script para simulação avançada dos estados de um processo com detalhes didáticos e log completo.
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script simula um processo passando por todos os estados típicos
# (Novo, Pronto, Execução, Espera, Finalizado), com informações detalhadas sobre
# a localização do processo na memória e sua interação com a CPU, e salva tudo em log.

LOG_FILE="process_simulation_completo.log"

# Função para logar mensagens
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a $LOG_FILE
}

# Função para mostrar o status do processo e salvar no log
mostrar_status() {
    local state="$1"
    local memory_address="$2"
    local cpu_slot="$3"
    
    local status_message="Estado Atual do Processo: $state\nPCB (Posição em Memória): $memory_address\nPosição no Processador (CPU): $cpu_slot"
    
    echo "=========================================="
    echo -e "$status_message"
    echo "=========================================="
    
    log_message "$status_message"
}

# Função que simula o estado "Novo"
novo() {
    local process_name="$1"
    log_message "Processo '$process_name' criado. Estado: Novo"
    sleep 1
    pronto "$process_name"
}

# Função que simula o estado "Pronto"
pronto() {
    local process_name="$1"
    local memory_address=$(($RANDOM % 1000 + 1000))
    log_message "Processo '$process_name' está pronto para execução. Estado: Pronto"
    mostrar_status "Pronto" "$memory_address" "Aguardando CPU"
    
    echo "O que deseja fazer com o processo '$process_name'?"
    echo "1. Mover para Execução"
    echo "2. Suspender (colocar em Espera)"
    echo "3. Finalizar o processo"
    echo

    read -p "Escolha uma opção: " opcao
    log_message "Opção escolhida: $opcao"

    case $opcao in
        1)
            execucao "$process_name" "$memory_address"
            ;;
        2)
            espera "$process_name" "$memory_address"
            ;;
        3)
            finalizado "$process_name" "$memory_address"
            ;;
        *)
            log_message "Opção inválida escolhida. Retornando ao estado Pronto."
            echo "Opção inválida, retornando ao estado Pronto."
            pronto "$process_name"
            ;;
    esac
}

# Função que simula o estado "Execução"
execucao() {
    local process_name="$1"
    local memory_address="$2"
    local cpu_slot=$(($RANDOM % 4 + 1)) # Simulação de 4 núcleos de CPU

    log_message "Processo '$process_name' em execução. Estado: Execução"
    mostrar_status "Execução" "$memory_address" "CPU Núcleo $cpu_slot"
    
    echo "O processo '$process_name' está em execução. O que deseja fazer?"
    echo "1. Colocar o processo em espera"
    echo "2. Finalizar o processo"
    echo

    read -p "Escolha uma opção: " opcao
    log_message "Opção escolhida: $opcao"

    case $opcao in
        1)
            espera "$process_name" "$memory_address"
            ;;
        2)
            finalizado "$process_name" "$memory_address"
            ;;
        *)
            log_message "Opção inválida escolhida. Continuando em Execução."
            echo "Opção inválida, continuando em Execução."
            execucao "$process_name" "$memory_address"
            ;;
    esac
}

# Função que simula o estado "Espera"
espera() {
    local process_name="$1"
    local memory_address="$2"

    log_message "Processo '$process_name' está aguardando um evento. Estado: Espera"
    mostrar_status "Espera" "$memory_address" "Removido da CPU - Aguardando I/O"
    
    echo "O processo '$process_name' está em espera. O que deseja fazer?"
    echo "1. Retornar ao estado Pronto"
    echo "2. Finalizar o processo"
    echo

    read -p "Escolha uma opção: " opcao
    log_message "Opção escolhida: $opcao"

    case $opcao in
        1)
            pronto "$process_name"
            ;;
        2)
            finalizado "$process_name" "$memory_address"
            ;;
        *)
            log_message "Opção inválida escolhida. Permanecendo em Espera."
            echo "Opção inválida, permanecendo em Espera."
            espera "$process_name" "$memory_address"
            ;;
    esac
}

# Função que simula o estado "Finalizado"
finalizado() {
    local process_name="$1"
    local memory_address="$2"

    log_message "Processo '$process_name' finalizado. Estado: Finalizado"
    mostrar_status "Finalizado" "$memory_address" "Liberado da CPU"
    echo "Processo '$process_name' terminou sua execução."
    log_message "Processo '$process_name' encerrou sua execução e liberou recursos."
    exit 0
}

# Função principal que inicia a simulação do processo
iniciar_simulacao() {
    clear
    echo "========================================================"
    echo "Simulação dos Estados de Processo com Detalhes Didáticos"
    echo "========================================================"
    
    read -p "Informe o nome do processo a ser simulado: " process_name
    log_message "Iniciando simulação do processo '$process_name'"
    
    novo "$process_name"
}

# Função para exibir o log de execução
exibir_log() {
    clear
    echo "========================================================"
    echo "Log de Execução"
    echo "========================================================"
    cat $LOG_FILE
    echo
    read -p "Pressione Enter para voltar ao menu principal."
    menu_principal
}

# Menu principal da simulação
menu_principal() {
    clear
    echo "========================================================"
    echo "Simulação Interativa dos Estados de um Processo"
    echo "========================================================"
    echo "1. Iniciar nova simulação"
    echo "2. Exibir log de execução"
    echo "3. Sair"
    echo "========================================================"
    echo

    read -p "Escolha uma opção: " opcao
    log_message "Opção escolhida no menu principal: $opcao"

    case $opcao in
        1)
            iniciar_simulacao
            ;;
        2)
            exibir_log
            ;;
        3)
            log_message "Saindo do script de simulação."
            echo "Saindo..."
            exit 0
            ;;
        *)
            log_message "Opção inválida escolhida no menu principal."
            echo "Opção inválida, tente novamente."
            menu_principal
            ;;
    esac
}

# Início da execução do script
log_message "Script de simulação de processos iniciado."
menu_principal