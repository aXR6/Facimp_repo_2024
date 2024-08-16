#!/bin/bash

# Função para configurar o repositório do Docker
setup_docker_repo() {
    echo "Configurando o repositório do Docker..."

    # Atualizar os pacotes do sistema
    apt-get update
    
    # Instalar pacotes necessários para adicionar o repositório Docker
    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Criar um diretório para armazenar a chave GPG do Docker
    install -m 0755 -d /etc/apt/keyrings

    # Baixar e adicionar a chave GPG oficial do Docker
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Adicionar o repositório oficial do Docker aos sources do APT
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "Repositório do Docker configurado com sucesso."
}

# Função para instalar o Docker CE
install_docker() {
    echo "Instalando o Docker CE..."

    # Atualizar a lista de pacotes para incluir o repositório Docker
    apt-get update

    # Instalar os pacotes Docker CE e suas dependências
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Verificar se o Docker foi instalado corretamente
    echo "Verificando a instalação do Docker..."
    docker --version

    # Habilitar o serviço Docker para iniciar automaticamente na inicialização do sistema
    systemctl enable docker

    # Iniciar o serviço Docker
    systemctl start docker

    echo "Docker CE instalado e configurado com sucesso."
}

# Função para instalar o Docker Compose
install_docker_compose() {
    echo "Baixando e instalando o Docker Compose..."

    DOCKER_COMPOSE_VERSION="2.10.2"  # Substitua pela versão desejada
    curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    chmod +x /usr/local/bin/docker-compose

    echo "Verificando a instalação do Docker Compose..."
    docker-compose --version
}

# Função para instalar dependências Python
install_python_dependencies() {
    echo "Instalando dependências Python..."

    apt-get install -y python3 python3-pip
    pip3 install requests

    echo "Verificando a instalação das dependências Python..."
    python3 --version
    pip3 --version
    pip3 show requests
}

# Função principal
main() {
    setup_docker_repo
    install_docker
    install_docker_compose
    install_python_dependencies
    echo "Instalação do Docker, Docker Compose e dependências Python concluída."
}

# Executar a função principal
main
