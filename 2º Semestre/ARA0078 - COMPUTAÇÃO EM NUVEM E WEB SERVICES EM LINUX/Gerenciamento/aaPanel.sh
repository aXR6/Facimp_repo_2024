#!/bin/bash

# Atualizar pacotes e instalar dependências
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl wget sudo ufw python3 python3-pip

# Instalar o aaPanel
URL=https://www.aapanel.com/script/install_7.0_en.sh
if [ -f /usr/bin/curl ]; then
    curl -ksSO "$URL"
else
    wget --no-check-certificate -O install_7.0_en.sh "$URL"
fi
bash install_7.0_en.sh

# Instalar Redis
sudo apt install -y redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Instalar Memcached
sudo apt install -y memcached
sudo systemctl enable memcached
sudo systemctl start memcached

# Configurar UFW
sudo ufw allow 8888/tcp  # Porta padrão do aaPanel
sudo ufw enable

echo "Instalação e configuração do aaPanel com Redis e Memcached concluídas."
