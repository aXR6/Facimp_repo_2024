#!/bin/bash

# Função para configurar o repositório do Docker
setup_docker_repo() {
    echo "Configurando o repositório do Docker..."

    apt-get update
    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
}

# Função para instalar o Docker CE
install_docker() {
    echo "Instalando o Docker CE..."

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "Verificando a instalação do Docker..."
    docker --version
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