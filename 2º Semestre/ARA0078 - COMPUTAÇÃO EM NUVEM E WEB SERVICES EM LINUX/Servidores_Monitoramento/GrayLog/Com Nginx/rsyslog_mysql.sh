#!/bin/bash

# Variável de configuração
GRAYLOG_SERVER_IP="192.7.0.32"  # Substitua pelo IP do servidor Graylog
GRAYLOG_SERVER_PORT="12201"     # Substitua pela porta correta do Graylog, por exemplo, 12201 para GELF

# Atualizar e instalar pacotes necessários
apt-get update
apt-get install -y rsyslog

# Configurar o rsyslog para enviar logs ao Graylog
bash -c "cat <<EOF >> /etc/rsyslog.conf
# Enviar logs via TCP para o servidor Graylog
*.* @@${GRAYLOG_SERVER_IP}:${GRAYLOG_SERVER_PORT};RSYSLOG_SyslogProtocol23Format

# Enviar logs via UDP para o servidor Graylog (opcional)
*.* @${GRAYLOG_SERVER_IP}:${GRAYLOG_SERVER_PORT};RSYSLOG_SyslogProtocol23Format

EOF"

# Reiniciar o rsyslog para aplicar as mudanças
systemctl restart rsyslog && systemctl status rsyslog

# Feedback ao usuário
echo "Configuração do rsyslog para envio de logs ao Graylog configurada com sucesso."