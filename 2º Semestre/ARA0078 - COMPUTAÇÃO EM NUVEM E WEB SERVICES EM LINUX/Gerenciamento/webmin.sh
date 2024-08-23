#!/bin/bash

# Atualizar pacotes e instalar dependências
apt update -y
apt upgrade -y
apt install -y software-properties-common apt-transport-https wget

# Adicionar o repositório do Webmin
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'

# Instalar o Webmin
apt update -y
apt install -y webmin ufw
ufw enable

# Configurar UFW para permitir o acesso ao Webmin
ufw allow 10000/tcp  # Porta padrão do Webmin
ufw enable

# Exibir a URL de acesso ao Webmin
echo "Instalação do Webmin concluída. Acesse via https://$(hostname -I | awk '{print $1}'):10000/"

