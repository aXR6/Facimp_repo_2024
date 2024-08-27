#!/bin/bash

# Definições de nomes de arquivos e diretórios
LOG_DIR="process_logs"
LOG_FILE="$LOG_DIR/process_actions.log"
OUTPUT_FILE="$LOG_DIR/interpreted_process_actions.log"
MONITOR_FILE="$LOG_DIR/monitoring.log"
MONITOR_DURATION=50  # Duração total do monitoramento em segundos

# Função para lidar com a interrupção do script (CTRL+C)
cleanup() {
    echo -e "\nEncerrando o monitoramento..."
    if [ -n "$STRACE_PID" ]; then
        kill $STRACE_PID 2>/dev/null
        wait $STRACE_PID 2>/dev/null
    fi
    if [ -n "$LSOF_PID" ]; then
        kill $LSOF_PID 2>/dev/null
        wait $LSOF_PID 2>/dev/null
    fi
    echo "Monitoramento encerrado. Os logs intermediários foram salvos em '$LOG_DIR'."
    echo "Relatório final disponível em '$OUTPUT_FILE' e detalhes adicionais em '$MONITOR_FILE'."
    exit 0
}

# Captura o sinal de interrupção (CTRL+C) e chama a função cleanup
trap cleanup SIGINT

# Verificação se o comando foi executado com root ou com sudo
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute como root ou usando sudo."
    exit 1
fi

# Verifica se o strace e o lsof estão instalados
if ! command -v strace &> /dev/null; then
    echo "O comando strace não está instalado. Instalando agora..."
    apt-get install -y strace || yum install -y strace || zypper install -y strace
fi

if ! command -v lsof &> /dev/null; then
    echo "O comando lsof não está instalado. Instalando agora..."
    apt-get install -y lsof || yum install -y lsof || zypper install -y lsof
fi

# Função para traduzir o estado do processo
translate_state() {
    local state="$1"
    case "$state" in
        R*) echo "Executando" ;;
        S*) echo "Dormindo (sono interruptível)" ;;
        D*) echo "Esperando por I/O (não interruptível)" ;;
        Z*) echo "Zumbi" ;;
        T*) echo "Parado (traced ou suspendido)" ;;
        t*) echo "Parado (no job control)" ;;
        X*) echo "Morto" ;;
        I*) echo "Inativo (Idle kernel thread)" ;;
        K*) echo "Despertando (Wakekill)" ;;
        W*) echo "Deletado, mas imortal" ;;
        P*) echo "Suspenso em troca de contexto" ;;
        *) echo "Estado desconhecido" ;;
    esac
}

# Função para monitorar o estado atual do processo
monitor_process() {
    local pid="$1"
    local duration="$2"
    local start_time=$(date +%s)

    echo "Iniciando monitoramento detalhado do processo com PID $pid..." | tee -a "$MONITOR_FILE"
    echo "Monitoramento será feito por $duration segundos." | tee -a "$MONITOR_FILE"

    while true; do
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        if [ "$elapsed_time" -ge "$duration" ]; then
            echo "Tempo limite de monitoramento ($duration segundos) atingido." | tee -a "$MONITOR_FILE"
            break
        fi

        if ps -p $pid > /dev/null; then
            echo "----------------------------------------------------" | tee -a "$MONITOR_FILE"
            echo "Momento: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$MONITOR_FILE"

            # Captura o estado do processo
            local raw_state=$(ps -o stat= -p $pid | awk '{print $1}')
            local translated_state=$(translate_state "$raw_state")
            echo "Estado atual do processo: $translated_state (Código: $raw_state)" | tee -a "$MONITOR_FILE"

            # Captura o espaço de memória (simulação do PCB)
            local memory_address=$(pmap $pid | tail -n 1 | awk '/total/ {print $2}')
            echo "Espaço de memória ocupado (PCB): $memory_address" | tee -a "$MONITOR_FILE"

            # Captura a utilização da CPU (simulação da posição no processador)
            local cpu_usage=$(ps -p $pid -o %cpu=)
            echo "Utilização de CPU: $cpu_usage%" | tee -a "$MONITOR_FILE"
        else
            echo "Processo com PID $pid foi finalizado." | tee -a "$MONITOR_FILE"
            break
        fi

        sleep 1
    done

    echo "Monitoramento do processo concluído." | tee -a "$MONITOR_FILE"
}

# Função para iniciar um processo exemplo e monitorá-lo
start_example_process() {
    echo "Iniciando um processo exemplo..."
    sleep 1000 &  # Inicia um processo de longa duração
    local pid=$!
    echo "Processo de exemplo iniciado com PID $pid. Passando pelos estados..."

    # Iniciar o monitoramento do processo exemplo
    monitor_process $pid $MONITOR_DURATION &

    # Simular diferentes estados
    sleep 2
    kill -STOP $pid  # Parar o processo (suspensão)
    sleep 2

    kill -CONT $pid  # Continuar o processo
    sleep 2

    kill -TERM $pid  # Finalizar o processo
    sleep 2
}

# Função para exibir o menu
show_menu() {
    clear
    echo "========================================================"
    echo "Simulação de Processos - Menu Principal"
    echo "========================================================"
    echo "1. Monitorar um processo existente"
    echo "2. Iniciar e monitorar um processo exemplo"
    echo "3. Sair"
    echo "========================================================"
    echo

    read -p "Escolha uma opção: " option

    case $option in
        1)
            # Solicita ao usuário o PID do processo que ele deseja monitorar
            echo "Digite o PID do processo que você deseja monitorar:"
            read PID

            # Verifica se o PID é um número
            if ! [[ "$PID" =~ ^[0-9]+$ ]]; then
                echo "PID inválido. Deve ser um número."
                exit 1
            fi

            # Verifica se o processo está em execução
            if ! ps -p $PID > /dev/null; then
                echo "O processo com PID $PID não está em execução."
                exit ssos e sua1
            fi

            # Inicia o monitoramento do processo
            monitor_process $PID $MONITOR_DURATION
            ;;
        2)
            # Inicia um processo exemplo e monitora
            start_example_process
            ;;
        3)
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida. Tente novamente."
            show_menu
            ;;
    esac
}

# Função principal
main() {
    # Cria o diretório para armazenar os logs intermediários
    mkdir -p "$LOG_DIR"

    # Exibe o menu principal
    show_menu
}

# Início da execução do script
main