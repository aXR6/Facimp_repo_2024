#!/bin/bash

# Variáveis
ZABBIX_SERVER="zabbix-server-ip"  # Substitua pelo IP do servidor Zabbix
HOSTNAME="885bea602d32" # Substitua pelo nome do container do servidor zabbix
HOSTS=("host1" "host2" "host3")  # Substitua pelos hosts remotos que vão recerber as configurações
SSH_USER="your_ssh_user"
SSH_PASS="your_ssh_password"
LOG_FILE_SIZE="10"  # Exemplo: 10 MB
TLS_CONNECT="psk"
TLS_ACCEPT="psk"
TLS_PSK_FILE="/etc/zabbix/zabbix_agentd.psk"  # Caminho para o arquivo PSK
LISTEN_PORT="10050"

# Função para gerar PSK
generate_psk() {
    echo "Gerando chave PSK..."
    openssl rand -hex 32 > zabbix_agentd.psk
}

# Instalar o sshpass se não estiver instalado
if ! command -v sshpass &> /dev/null
then
    echo "sshpass não encontrado. Instalando..."
    apt-get update
    apt-get install -y sshpass
fi

# Gerar PSK
generate_psk

# Contador para PSK Identity
PSK_IDENTITY_COUNTER=1

# Instalar e configurar o Zabbix Agent em cada host remoto
for HOST in "${HOSTS[@]}"; do
  # Definir o TLS PSK Identity
  TLS_PSK_IDENTITY="PSK$PSK_IDENTITY_COUNTER"
  
  # Incrementar o contador
  PSK_IDENTITY_COUNTER=$((PSK_IDENTITY_COUNTER + 1))

  # Copiar o arquivo PSK para o host remoto
  sshpass -p $SSH_PASS scp -o StrictHostKeyChecking=no zabbix_agentd.psk $SSH_USER@$HOST:/tmp/zabbix_agentd.psk
  
  sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no $SSH_USER@$HOST << EOF
  apt-get update
  apt-get install -y zabbix-agent2

  # Mover o arquivo PSK para o diretório correto e definir permissões
  mv /tmp/zabbix_agentd.psk ${TLS_PSK_FILE}
  chown zabbix:zabbix ${TLS_PSK_FILE}
  chmod 600 ${TLS_PSK_FILE}

  # Adicionar ou substituir parâmetros no arquivo de configuração
  sed -i "s/^LogFileSize=.*$/LogFileSize=${LOG_FILE_SIZE}/" /etc/zabbix/zabbix_agent2.conf
  sed -i "s/^Server=.*$/Server=${ZABBIX_SERVER}/" /etc/zabbix/zabbix_agent2.conf
  sed -i "s/^ServerActive=.*$/ServerActive=${ZABBIX_SERVER}/" /etc/zabbix/zabbix_agent2.conf
  sed -i "s/^Hostname=.*$/Hostname=${HOST}/" /etc/zabbix/zabbix_agent2.conf
  sed -i "s/^TLSConnect=.*$/TLSConnect=${TLS_CONNECT}/" /etc/zabbix/zabbix_agent2.conf
  sed -i "s/^TLSAccept=.*$/TLSAccept=${TLS_ACCEPT}/" /etc/zabbix/zabbix_agent2.conf
  sed -i "s/^TLSPSKIdentity=.*$/TLSPSKIdentity=${TLS_PSK_IDENTITY}/" /etc/zabbix/zabbix_agent2.conf
  sed -i "s|^TLSPSKFile=.*$|TLSPSKFile=${TLS_PSK_FILE}|" /etc/zabbix/zabbix_agent2.conf
  sed -i "s/^ListenPort=.*$/ListenPort=${LISTEN_PORT}/" /etc/zabbix/zabbix_agent2.conf

  # Se o parâmetro não existir, adicioná-lo ao final do arquivo
  grep -q "^LogFileSize=" /etc/zabbix/zabbix_agent2.conf || echo "LogFileSize=${LOG_FILE_SIZE}" >> /etc/zabbix/zabbix_agent2.conf
  grep -q "^Server=" /etc/zabbix/zabbix_agent2.conf || echo "Server=${ZABBIX_SERVER}" >> /etc/zabbix/zabbix_agent2.conf
  grep -q "^ServerActive=" /etc/zabbix/zabbix_agent2.conf || echo "ServerActive=${ZABBIX_SERVER}" >> /etc/zabbix/zabbix_agent2.conf
  grep -q "^Hostname=" /etc/zabbix/zabbix_agent2.conf || echo "Hostname=${HOST}" >> /etc/zabbix/zabbix_agent2.conf
  grep -q "^TLSConnect=" /etc/zabbix/zabbix_agent2.conf || echo "TLSConnect=${TLS_CONNECT}" >> /etc/zabbix/zabbix_agent2.conf
  grep -q "^TLSAccept=" /etc/zabbix/zabbix_agent2.conf || echo "TLSAccept=${TLS_ACCEPT}" >> /etc/zabbix/zabbix_agent2.conf
  grep -q "^TLSPSKIdentity=" /etc/zabbix/zabbix_agent2.conf || echo "TLSPSKIdentity=${TLS_PSK_IDENTITY}" >> /etc/zabbix/zabbix_agent2.conf
  grep -q "^TLSPSKFile=" /etc/zabbix/zabbix_agent2.conf || echo "TLSPSKFile=${TLS_PSK_FILE}" >> /etc/zabbix/zabbix_agent2.conf
  grep -q "^ListenPort=" /etc/zabbix/zabbix_agent2.conf || echo "ListenPort=${LISTEN_PORT}" >> /etc/zabbix/zabbix_agent2.conf

  systemctl restart zabbix-agent2
  systemctl enable zabbix-agent2
EOF
done

echo "Instalação e configuração do Zabbix Agent concluída nos hosts remotos."
