#!/bin/bash

# Definições de nomes de arquivos e diretórios
LOG_DIR="process_logs"
LOG_FILE="$LOG_DIR/process_layers_monitoring.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
MONITOR_DURATION=50  # Duração total do monitoramento em segundos
MONITOR_INTERVAL=5  # Intervalo de tempo entre os ciclos de monitoramento (em segundos)

# Criar diretório de log se não existir
mkdir -p "$LOG_DIR"

# Limpa o arquivo de log anterior
> $LOG_FILE

# Cabeçalho do log
echo "===================================================" >> $LOG_FILE
echo "Monitoramento e Simulação de Processos - Início em $DATE" >> $LOG_FILE
echo "===================================================" >> $LOG_FILE

# Função para determinar a camada do processo
determine_layer() {
    local process_name="$1"

    # Heurísticas simples para determinar a camada (adaptado conforme necessário)
    if [[ "$process_name" == "systemd" || "$process_name" == "init" ]]; then
        echo "Camada de Gerenciamento de Sistema"
    elif [[ "$process_name" == *"bash"* || "$process_name" == *"sh"* || "$process_name" == *"zsh"* ]]; then
        echo "Camada de Interface de Usuário (Shell)"
    elif [[ "$process_name" == *"Xorg"* || "$process_name" == *"gnome-shell"* || "$process_name" == *"plasma"* ]]; then
        echo "Camada de Interface Gráfica (GUI)"
    elif [[ "$process_name" == *"sshd"* || "$process_name" == *"httpd"* || "$process_name" == *"nginx"* ]]; then
        echo "Camada de Aplicação/Serviço"
    elif [[ "$process_name" == *"kworker"* || "$process_name" == *"ksoftirqd"* || "$process_name" == *"rcu"* ]]; then
        echo "Camada de Kernel"
    else
        echo "Camada de Aplicação Geral"
    fi
}

# Função para monitorar processos em tempo real
monitor_processes() {
    declare -A process_layers  # Array associativo para armazenar camadas de processos
    local start_time=$(date +%s)

    while true; do
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        if [ "$elapsed_time" -ge "$MONITOR_DURATION" ]; then
            echo "Tempo limite de monitoramento ($MONITOR_DURATION segundos) atingido." | tee -a "$LOG_FILE"
            break
        fi

        echo "----------------------------------------------------" >> $LOG_FILE
        echo "Ciclo de Monitoramento - $(date '+%Y-%m-%d %H:%M:%S')" >> $LOG_FILE
        echo "----------------------------------------------------" >> $LOG_FILE

        # Itera sobre os processos em execução
        ps -eo pid,comm --no-headers | while read -r pid comm; do
            layer=$(determine_layer "$comm")

            # Verifica se o processo já foi registrado antes e se houve mudança de camada
            if [[ "${process_layers[$pid]}" && "${process_layers[$pid]}" != "$layer" ]]; then
                echo "MUDANÇA DE CAMADA DETECTADA: PID: $pid - Processo: $comm - De: ${process_layers[$pid]} Para: $layer" >> $LOG_FILE
            fi

            # Atualiza ou registra a camada atual do processo
            process_layers[$pid]=$layer

            echo "PID: $pid - Processo: $comm - Camada Atual: $layer" >> $LOG_FILE
        done

        echo "===================================================" >> $LOG_FILE

        # Aguarda até o próximo ciclo de monitoramento
        sleep $MONITOR_INTERVAL
    done

    echo "Monitoramento concluído e registrado em $LOG_FILE"
}

# Função para simular um processo e monitorá-lo
simulate_process() {
    echo "Iniciando simulação de um processo interagindo em diversas camadas..."
    sleep 1000 &  # Inicia um processo de longa duração
    local pid=$!
    local start_time=$(date +%s)
    
    while true; do
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        if [ "$elapsed_time" -ge "$MONITOR_DURATION" ]; then
            echo "Simulação encerrada após $MONITOR_DURATION segundos." | tee -a "$LOG_FILE"
            kill -TERM $pid
            break
        fi

        echo "Simulando diferentes camadas para o processo PID: $pid - Tempo: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"

        if [ $((elapsed_time % 10)) -le 5 ]; then
            echo "Simulação: Processo interagindo na Camada de Interface Gráfica (GUI)" | tee -a "$LOG_FILE"
        else
            echo "Simulação: Processo interagindo na Camada de Kernel" | tee -a "$LOG_FILE"
        fi

        sleep 2
    done

    echo "Simulação concluída."
}

# Função para exibir o menu
show_menu() {
    clear
    echo "========================================================"
    echo "Monitoramento e Simulação de Processos - Menu Principal"
    echo "========================================================"
    echo "1. Monitorar os processos no computador"
    echo "2. Simular um processo interagindo em diversas camadas"
    echo "3. Sair"
    echo "========================================================"
    echo

    read -p "Escolha uma opção: " option

    case $option in
        1)
            # Monitoramento dos processos no computador
            monitor_processes
            ;;
        2)
            # Simulação de um processo interagindo em diversas camadas
            simulate_process
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