#!/bin/bash

# Script interativo avançado para simulação de chamadas de sistema (system calls)
# com foco em educação e interação com alunos.
# Autor: [Seu Nome]
# Data: [Data de Criação]
# Descrição: Este script simula múltiplas chamadas de sistema, permitindo aos
# alunos interagir diretamente, fornecendo entradas como arquivos, diretórios, e comandos.
# O sistema de log foi aprimorado para registrar informações técnicas sobre o sistema.

# Log file para registrar as atividades
LOG_FILE="system_call_simulation_interativo.log"

# Função para logar mensagens com informações detalhadas sobre o sistema
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a $LOG_FILE
}

# Função para logar informações técnicas do sistema
log_system_info() {
    log_message "=== Informações Técnicas do Sistema ==="
    log_message "Usuário: $(whoami)"
    log_message "ID do Usuário: $(id -u)"
    log_message "Hostname: $(hostname)"
    log_message "Kernel: $(uname -r)"
    log_message "Arquitetura: $(uname -m)"
    log_message "Sistema Operacional: $(uname -o)"
    log_message "======================================="
}

# Função que simula a camada de Cliente (Usuário)
cliente_simulation() {
    local operation="$1"
    log_message "Cliente (Usuário) solicitou operação: $operation"
    echo "Cliente (Usuário) solicitando operação: $operation"
    
    # Verificando se o usuário tem permissão para fazer a chamada
    if [ "$(id -u)" -ne 0 ]; then
        log_message "Cliente não tem permissões elevadas. Encaminhando ao Sistema Operacional."
        so_simulation "$operation"
    else
        log_message "Cliente é root. Pode interagir diretamente com o Kernel."
        kernel_simulation "$operation"
    fi
}

# Função que simula a camada do Sistema Operacional
so_simulation() {
    local operation="$1"
    log_message "Sistema Operacional recebendo solicitação: $operation"
    echo "Sistema Operacional processando solicitação: $operation"

    case $operation in
        "ler_arquivo")
            read -p "Informe o caminho do arquivo que deseja ler: " file_path
            log_message "Arquivo solicitado para leitura: $file_path"
            read_file_system_call "$file_path"
            ;;
        "escrever_arquivo")
            read -p "Informe o caminho do arquivo em que deseja escrever: " file_path
            read -p "Digite o conteúdo a ser escrito: " content
            log_message "Arquivo solicitado para escrita: $file_path"
            log_message "Conteúdo a ser escrito: $content"
            write_file_system_call "$file_path" "$content"
            ;;
        "executar_comando_privilegiado")
            log_message "Sistema Operacional encaminha para o Kernel devido à natureza privilegiada."
            kernel_simulation "$operation"
            ;;
        *)
            log_message "Operação desconhecida no Sistema Operacional."
            echo "Erro: Operação desconhecida."
            ;;
    esac
}

# Função que simula a camada do Kernel
kernel_simulation() {
    local operation="$1"
    log_message "Kernel recebendo solicitação: $operation"
    echo "Kernel processando solicitação: $operation"

    case $operation in
        "ler_arquivo")
            read -p "Informe o caminho do arquivo sensível que deseja ler: " file_path
            log_message "Arquivo sensível solicitado para leitura: $file_path"
            read_file_system_call "$file_path"
            ;;
        "escrever_arquivo")
            read -p "Informe o caminho do arquivo sensível em que deseja escrever: " file_path
            read -p "Digite o conteúdo a ser escrito: " content
            log_message "Arquivo sensível solicitado para escrita: $file_path"
            log_message "Conteúdo a ser escrito: $content"
            write_file_system_call "$file_path" "$content"
            ;;
        "executar_comando_privilegiado")
            read -p "Informe o comando privilegiado que deseja executar: " command
            log_message "Comando privilegiado solicitado: $command"
            privileged_command_system_call "$command"
            ;;
        *)
            log_message "Operação desconhecida no Kernel."
            echo "Erro: Operação desconhecida."
            ;;
    esac
}

# Função que simula a chamada de sistema de leitura de arquivos
read_file_system_call() {
    local file_path="$1"
    log_message "Iniciando leitura do arquivo: $file_path"
    if [ -r "$file_path" ]; then
        log_message "Permissão concedida para leitura."
        cat "$file_path" | tee -a $LOG_FILE
    else
        log_message "Erro: Permissão negada para leitura do arquivo $file_path."
        echo "Erro: Permissão negada."
    fi
}

# Função que simula a chamada de sistema de escrita em arquivos
write_file_system_call() {
    local file_path="$1"
    local content="$2"
    log_message "Iniciando escrita no arquivo: $file_path"
    if [ -w "$file_path" ]; then
        log_message "Permissão concedida para escrita."
        echo "$content" | tee -a "$file_path" | tee -a $LOG_FILE
    else
        log_message "Erro: Permissão negada para escrita no arquivo $file_path."
        echo "Erro: Permissão negada."
    fi
}

# Função que simula a chamada de sistema de execução de comandos privilegiados
privileged_command_system_call() {
    local command="$1"
    log_message "Tentando executar comando privilegiado: $command"
    if [ "$(id -u)" -eq 0 ]; then
        log_message "Permissão concedida para execução do comando."
        eval "$command" | tee -a $LOG_FILE
    else
        log_message "Erro: Permissão negada. Comando requer privilégios de superusuário."
        echo "Erro: Permissão negada. Comando requer privilégios de superusuário."
    fi
}

# Menu principal para selecionar a simulação
menu_principal() {
    clear
    echo "========================================================"
    echo "Simulação Interativa Avançada de Chamadas de Sistema"
    echo "========================================================"
    echo "1. Simular leitura de arquivo"
    echo "2. Simular escrita em arquivo"
    echo "3. Simular execução de comando privilegiado"
    echo "4. Exibir informações técnicas do sistema"
    echo "5. Sair"
    echo "========================================================"
    echo

    read -p "Escolha uma operação para simular: " operacao

    case $operacao in
        1)
            cliente_simulation "ler_arquivo"
            ;;
        2)
            cliente_simulation "escrever_arquivo"
            ;;
        3)
            cliente_simulation "executar_comando_privilegiado"
            ;;
        4)
            log_system_info
            ;;
        5)
            log_message "Execução do script encerrada."
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida, tente novamente."
            menu_principal
            ;;
    esac
}

# Início da execução do script
log_message "Execução do script iniciada."
menu_principal
