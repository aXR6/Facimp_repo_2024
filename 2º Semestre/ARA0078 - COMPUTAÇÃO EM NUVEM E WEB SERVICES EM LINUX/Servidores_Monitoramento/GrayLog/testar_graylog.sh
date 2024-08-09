#!/bin/bash

# Configurações do Graylog
GRAYLOG_HOST="192.7.0.26"
GRAYLOG_PORT="12201" # Porta onde o Graylog está ouvindo para syslog

# Mensagem de teste
LOG_MESSAGE="Teste de log enviado para o Graylog $(date)"

# Enviar log usando o comando logger
logger -n ${GRAYLOG_HOST} -P ${GRAYLOG_PORT} -t "GraylogTest" "${LOG_MESSAGE}"

# Feedback ao usuário
echo "Mensagem de teste enviada para o Graylog: ${LOG_MESSAGE}"

# Aguardar alguns segundos para garantir que o log seja processado
sleep 5

# Exibir logs capturados localmente para verificação
echo "Logs recentes capturados localmente:"
sudo tail /var/log/syslog | grep "GraylogTest"

# Instruções adicionais para verificar no Graylog
echo "Verifique o Graylog para confirmar que a mensagem foi capturada."
